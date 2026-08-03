{{- define "shoutrrr.persistence" -}}
persistence:
  {{- with (.Values.shoutrrrStorage | default dict).storage }}
  storage:
    enabled: true
    {{- include "shoutrrr.storage.ci.migration" (dict "storage" .) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .) | nindent 4 }}
    targetSelector:
      shoutrrr:
        shoutrrr:
          mountPath: /var/www/html/storage
        {{- if and (eq .type "ixVolume")
                  (not (.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/storage
        {{- end }}
  {{- end }}
  {{- with (.Values.shoutrrrStorage | default dict).database }}
  database:
    enabled: true
    {{- include "shoutrrr.storage.ci.migration" (dict "storage" .) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .) | nindent 4 }}
    targetSelector:
      shoutrrr:
        shoutrrr:
          mountPath: /var/www/html/database/sqlite
        {{- if and (eq .type "ixVolume")
                  (not (.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/database
        {{- end }}
  {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      shoutrrr:
        shoutrrr:
          mountPath: /tmp
  {{- range $idx, $storage := (.Values.shoutrrrStorage | default dict).additionalStorages }}
  {{ printf "shoutrrr-%v" (int $idx) }}:
    enabled: true
    {{- include "shoutrrr.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      shoutrrr:
        shoutrrr:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "shoutrrr.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
