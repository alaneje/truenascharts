{{- define "starbound.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.starboundStorage.data.type }}
    datasetName: {{ .Values.starboundStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.starboundStorage.data.hostPath | default "" }}
    targetSelector:
      starbound:
        starbound:
          mountPath: /starbound
  {{- range $idx, $storage := .Values.starboundStorage.additionalStorages }}
  {{ printf "starbound-%v:" (int $idx) }}
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      starbound:
        starbound:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
