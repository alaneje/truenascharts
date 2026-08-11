{{- define "horilla.persistence" -}}
persistence:
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.horillaStorage.data) | nindent 4 }}
    targetSelector:
      horilla:
        horilla:
          mountPath: /data
        {{- if and (eq .Values.horillaStorage.data.type "ixVolume")
                  (not (.Values.horillaStorage.data.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/data
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      horilla:
        horilla:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.horillaStorage.additionalStorages }}
  {{ printf "horilla-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      horilla:
        horilla:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}

  {{- if .Values.horillaNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: horilla-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: tls.key
      - key: tls.crt
        path: tls.crt
    targetSelector:
      horilla:
        horilla:
          mountPath: /certs
          readOnly: true

scaleCertificate:
  horilla-cert:
    enabled: true
    id: {{ .Values.horillaNetwork.certificateID }}
    {{- end -}}
{{- end -}}
