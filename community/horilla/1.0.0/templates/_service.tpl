{{- define "horilla.service" -}}
service:
  horilla:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: horilla
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.horillaNetwork.webPort }}
        nodePort: {{ .Values.horillaNetwork.webPort }}
        targetPort: 8000
        targetSelector: horilla
{{- end -}}
