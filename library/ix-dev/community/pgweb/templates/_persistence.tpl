{{- define "pgweb.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "pgweb.storage.ci.migration" (dict "storage" .Values.pgwebStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.pgwebStorage.config) | nindent 4 }}
    targetSelector:
      pgweb:
        pgweb:
          mountPath: /var/lib/pgweb
        {{- if and (eq .Values.pgwebStorage.config.type "ixVolume")
                  (not (.Values.pgwebStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/pgweb
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      pgweb:
        pgweb:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.pgwebStorage.additionalStorages }}
  {{ printf "pgweb-%v" (int $idx) }}:
    enabled: true
    {{- include "pgweb.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      pgweb:
        pgweb:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}

  {{- if .Values.pgwebNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: pgweb-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: server.key
      - key: tls.crt
        path: server.cert
    targetSelector:
      pgweb:
        pgweb:
          mountPath: /certs
          readOnly: true

scaleCertificate:
  pgweb-cert:
    enabled: true
    id: {{ .Values.pgwebNetwork.certificateID }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "pgweb.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
