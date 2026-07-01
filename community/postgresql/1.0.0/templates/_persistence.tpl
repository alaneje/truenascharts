{{- define "postgresql.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.postgresqlStorage.data.type }}
    datasetName: {{ .Values.postgresqlStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.postgresqlStorage.data.hostPath | default "" }}
    targetSelector:
      postgresql:
        postgresql:
          mountPath: /var/lib/postgresql/data
  {{- range $idx, $storage := .Values.postgresqlStorage.additionalStorages }}
  {{ printf "postgresql-%v:" (int $idx) }}
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      postgresql:
        postgresql:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
