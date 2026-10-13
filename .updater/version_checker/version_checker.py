import base64
import logging
import re
from abc import ABC, abstractmethod
from dataclasses import dataclass
from datetime import datetime
from typing import Dict, List, Optional, Tuple
from urllib.parse import urljoin

import requests

logger = logging.getLogger(__name__)


@dataclass
class ImageVersion:
    """Represents version information for a container image."""

    tags: List[str]
    digest: str
    last_updated: datetime


class VersionChecker(ABC):
    """Abstract base class for container registry version checkers."""

    def __init__(self, timeout: int = 30):
        self.timeout = timeout
        self.session = requests.Session()

    @abstractmethod
    def get_latest_version(self, image: str, label: Optional[str] = None) -> ImageVersion:
        """
        Get the latest version information for a container image.

        Args:
            image: Image name (e.g. 'library/ubuntu' or 'jellyfin/jellyfin')
            label: Optional label/tag to filter by (e.g. 'stable', 'latest')

        Returns:
            ImageVersion object containing tags and digest information
        """


class DockerHubChecker(VersionChecker):
    """Version checker for Docker Hub registry."""

    def __init__(self, timeout: int = 30):
        super().__init__(timeout)
        self.base_url = "https://hub.docker.com/v2/"

    def get_latest_version(self, image: str, label: Optional[str] = None) -> ImageVersion:
        # Handle official images that start with 'library/'
        if "/" not in image:
            image = f"library/{image}"

        url = urljoin(self.base_url, f"repositories/{image}/tags")
        params = {"page_size": 100, "ordering": "last_updated"}

        response = self.session.get(url, params=params, timeout=self.timeout)
        response.raise_for_status()
        data = response.json()

        if not data.get("results"):
            raise ValueError(f"No tags found for image {image}")

        results = data["results"]
        if label:
            matching_results = [r for r in results if r.get("name") == label]
            if not matching_results:
                raise ValueError(f"No tags matching label '{label}' found for image {image}")
            target_tag = matching_results[0]
        else:
            target_tag = results[0]

        digest = target_tag.get("digest")
        if not digest:
            # Older single-arch images may only have digest inside the images array.
            images = target_tag.get("images", [])
            if images:
                digest = images[0].get("digest", "")
        if not digest:
            digest = ""
        matching_tags: List[str] = [target_tag["name"]]

        # Paginate through a couple pages to find all tags pointing to this digest.
        num_page_to_check = 2
        current_page = data
        while True:
            for result in current_page["results"]:
                if result.get("digest") and result["digest"] == digest:
                    matching_tags.append(result["name"])

            next_page = current_page.get("next")
            num_page_to_check -= 1
            if not next_page or num_page_to_check == 0:
                break

            response = self.session.get(next_page, timeout=self.timeout)
            response.raise_for_status()
            current_page = response.json()

        return ImageVersion(
            tags=sorted(set(matching_tags)),
            digest=digest,
            last_updated=datetime.strptime(target_tag["last_updated"], "%Y-%m-%dT%H:%M:%S.%fZ"),
        )


class GHCRChecker(VersionChecker):
    """Version checker for GitHub Container Registry."""

    MEDIA_TYPES = {
        "manifest_v2": "application/vnd.docker.distribution.manifest.v2+json",
        "manifest_list_v2": "application/vnd.docker.distribution.manifest.list.v2+json",
        "oci_index": "application/vnd.oci.image.index.v1+json",
        "oci_manifest": "application/vnd.oci.image.manifest.v1+json",
        "docker_manifest": "application/vnd.docker.distribution.manifest.v1+json",
    }

    def __init__(self, timeout: int = 30):
        super().__init__(timeout)
        self.base_url = "https://ghcr.io/v2/"
        self.session.headers.update({"User-Agent": "Docker-Client/20.10.2 (linux)"})

    def _auth(self, package_owner: str, package_name: str) -> str:
        token = base64.b64encode(f"v1:{package_owner}/{package_name}:0".encode())
        return token.decode("utf-8")

    def _get_manifest(self, package_owner: str, package_name: str, tag: str) -> Tuple[Dict, str]:
        url = urljoin(self.base_url, f"{package_owner}/{package_name}/manifests/{tag}")
        headers = {
            "Authorization": f"Bearer {self._auth(package_owner, package_name)}",
            "Accept": (
                f"{self.MEDIA_TYPES['manifest_list_v2']}, "
                f"{self.MEDIA_TYPES['manifest_v2']}, "
                f"{self.MEDIA_TYPES['docker_manifest']}, "
                f"{self.MEDIA_TYPES['oci_index']}, "
                f"{self.MEDIA_TYPES['oci_manifest']}"
            ),
        }

        response = self.session.get(url, headers=headers, timeout=self.timeout)
        response.raise_for_status()
        digest = response.headers.get("Docker-Content-Digest", "")
        return response.json(), digest

    def get_latest_version(self, image: str, label: Optional[str] = None) -> ImageVersion:
        package_owner, package_name = image.split("/")

        # 1. Get the manifest + digest for the anchor tag.
        target_tag = label or "latest"
        manifest, digest = self._get_manifest(package_owner, package_name, target_tag)
        if not digest:
            raise ValueError(f"Could not find manifest digest for {image}:{target_tag}")

        # 2. Try to extract version from OCI annotations (avoids iterating tags).
        matching_tags = [target_tag]
        annotations = manifest.get("annotations", {})
        oci_version = annotations.get("org.opencontainers.image.version", "")
        if oci_version and oci_version != target_tag:
            # Verify this tag actually exists and points to the same digest.
            try:
                _, version_digest = self._get_manifest(package_owner, package_name, oci_version)
                if version_digest == digest:
                    matching_tags.append(oci_version)
            except Exception:
                # Tag might not exist as a standalone tag; still use the version string.
                matching_tags.append(oci_version)

        # 3. Get the full tag list but only check a small filtered subset.
        url = urljoin(self.base_url, f"{package_owner}/{package_name}/tags/list")
        headers = {"Authorization": f"Bearer {self._auth(package_owner, package_name)}"}
        response = self.session.get(url, headers=headers, timeout=self.timeout)
        response.raise_for_status()
        tags_data = response.json()
        all_tags = tags_data.get("tags", [])

        # Filter to only semver-like tags to avoid checking hundreds of commit/PR tags.
        semver_pattern = re.compile(r"^v?\d+\.\d+\.\d+")
        candidate_tags = [
            t for t in all_tags
            if t not in matching_tags and t != target_tag and semver_pattern.match(t)
        ]

        # Cap the number of manifest lookups to avoid excessive requests.
        max_lookups = 20
        for tag in candidate_tags[:max_lookups]:
            try:
                _, tag_digest = self._get_manifest(package_owner, package_name, tag)
                if tag_digest == digest:
                    matching_tags.append(tag)
            except Exception as e:
                logger.debug(f"Error getting manifest for tag {tag}: {e}")
                continue

        return ImageVersion(tags=sorted(set(matching_tags)), digest=digest, last_updated=datetime.now())


