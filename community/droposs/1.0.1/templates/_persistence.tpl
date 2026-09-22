{{- define "droposs.persistence" -}}
persistence:
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.dropossStorage.data) | nindent 4 }}
    targetSelector:
      droposs:
        droposs:
          mountPath: /data
        {{- if and (eq .Values.dropossStorage.data.type "ixVolume")
                  (not (.Values.dropossStorage.data.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/data
        {{- end }}
  library:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.dropossStorage.library) | nindent 4 }}
    targetSelector:
      droposs:
        droposs:
          mountPath: /library
        {{- if and (eq .Values.dropossStorage.library.type "ixVolume")
                  (not (.Values.dropossStorage.library.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/library
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      droposs:
        droposs:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.dropossStorage.additionalStorages }}
  {{ printf "droposs-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      droposs:
        droposs:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.dropossStorage.pgData
            "pgBackup" .Values.dropossStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
