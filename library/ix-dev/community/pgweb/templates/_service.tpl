{{- define "pgweb.service" -}}
service:
  pgweb:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: pgweb
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.pgwebNetwork.webPort }}
        nodePort: {{ .Values.pgwebNetwork.webPort }}
        targetSelector: pgweb
{{- end -}}
