{{- define "teamcity.workload" -}}
workload:
  teamcity:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.teamcityNetwork.hostNetwork }}
      securityContext:
        fsGroup: 1000
      containers:
        teamcity:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 1000
            runAsGroup: 1000
          {{ with .Values.teamcityConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          {{ $scheme := "http" }}
          {{ if .Values.teamcityNetwork.certificateID }}
            {{ $scheme = "https" }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: {{ $scheme }}
              port: 8111
              path: /
            readiness:
              enabled: true
              type: {{ $scheme }}
              port: 8111
              path: /
            startup:
              enabled: true
              type: {{ $scheme }}
              port: 8111
              path: /
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 1000
                                                        "GID" 1000
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
      {{- if .Values.teamcityNetwork.certificateID }}
        02-cert-container:
          {{- include "teamcity.certContainer" $ | nindent 10 }}
      {{- end }}

{{/* Service */}}
service:
  teamcity:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: teamcity
    ports:
      web:
        enabled: true
        primary: true
        port: {{ .Values.teamcityNetwork.webPort }}
        nodePort: {{ .Values.teamcityNetwork.webPort }}
        targetPort: 8111
        targetSelector: teamcity

{{/* Persistence */}}
persistence:
  data:
    enabled: true
    {{- include "teamcity.storage.ci.migration" (dict "storage" .Values.teamcityStorage.data) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.teamcityStorage.data) | nindent 4 }}
    targetSelector:
      teamcity:
        teamcity:
          mountPath: /data/teamcity_server/datadir
        {{- if and (eq .Values.teamcityStorage.data.type "ixVolume") (not (.Values.teamcityStorage.data.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/teamcity_data
        {{- end }}
        02-cert-container:
          mountPath: /data/teamcity_server/datadir
  logs:
    enabled: true
    {{- include "teamcity.storage.ci.migration" (dict "storage" .Values.teamcityStorage.logs) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.teamcityStorage.logs) | nindent 4 }}
    targetSelector:
      teamcity:
        teamcity:
          mountPath: /opt/teamcity/logs
        {{- if and (eq .Values.teamcityStorage.logs.type "ixVolume") (not (.Values.teamcityStorage.logs.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/teamcity_logs
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      teamcity:
        teamcity:
          mountPath: /tmp
        02-cert-container:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.teamcityStorage.additionalStorages }}
  {{ printf "teamcity-%v:" (int $idx) }}
    enabled: true
    {{- include "teamcity.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      teamcity:
        teamcity:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
  {{- if .Values.teamcityNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: teamcity-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: {{ .Values.teamcityConstants.keyName }}
      - key: tls.crt
        path: {{ .Values.teamcityConstants.crtName }}
    targetSelector:
      teamcity:
        02-cert-container:
          mountPath: {{ .Values.teamcityConstants.certsPath }}
          readOnly: true

scaleCertificate:
  teamcity-cert:
    enabled: true
    id: {{ .Values.teamcityNetwork.certificateID }}
    {{- end -}}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "teamcity.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
