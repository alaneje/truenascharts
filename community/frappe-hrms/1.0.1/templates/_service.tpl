{{- define "frappeHrms.service" -}}
service:
  actual:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: actual
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.frappeHrmsNetwork.webPort }}
        nodePort: {{ .Values.frappeHrmsNetwork.webPort }}
        targetPort: 8000
        targetSelector: actual
{{- end -}}
