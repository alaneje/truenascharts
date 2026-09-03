{{- define "droposs.service" -}}
service:
  droposs:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: droposs
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.dropossNetwork.webPort }}
        nodePort: {{ .Values.dropossNetwork.webPort }}
        targetPort: 3000
        targetSelector: droposs
  {{- include "ix.v1.common.app.postgresService" $ | nindent 2 }}
{{- end -}}
