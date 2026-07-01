{{- define "starbound.service" -}}
service:
  starbound:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: starbound
    ports:
      server:
        enabled: true
        primary: true
        port: {{ .Values.starboundNetwork.serverPort }}
        nodePort: {{ .Values.starboundNetwork.serverPort }}
        targetSelector: starbound
        protocol: tcp
{{- end -}}
