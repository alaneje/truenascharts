{{- define "mariadb.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.mariadbStorage.data.type }}
    datasetName: {{ .Values.mariadbStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.mariadbStorage.data.hostPath | default "" }}
    targetSelector:
      mariadb:
        mariadb:
          mountPath: /var/lib/mariadb/data
  {{- range $idx, $storage := .Values.mariadbStorage.additionalStorages }}
  {{ printf "mariadb-%v:" (int $idx) }}
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      mariadb:
        mariadb:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
