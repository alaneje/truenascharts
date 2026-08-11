{{- define "frappeHrms.persistence" -}}
persistence:
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.frappeHrmsStorage.data) | nindent 4 }}
    targetSelector:
      actual:
        actual:
          mountPath: /data
        {{- if and (eq .Values.frappeHrmsStorage.data.type "ixVolume")
                  (not (.Values.frappeHrmsStorage.data.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/data
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      actual:
        actual:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.frappeHrmsStorage.additionalStorages }}
  {{ printf "actual-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      actual:
        actual:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}

  {{- if .Values.frappeHrmsNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: actual-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: tls.key
      - key: tls.crt
        path: tls.crt
    targetSelector:
      actual:
        actual:
          mountPath: /certs
          readOnly: true

scaleCertificate:
  actual-cert:
    enabled: true
    id: {{ .Values.frappeHrmsNetwork.certificateID }}
    {{- end -}}
{{- end -}}
