{{- define "shoutrrr.service" -}}
service:
  shoutrrr:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: shoutrrr
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ (.Values.shoutrrrNetwork | default dict).webPort | default 31014 }}
        nodePort: {{ (.Values.shoutrrrNetwork | default dict).webPort | default 31014 }}
        targetPort: 8080
        targetSelector: shoutrrr
{{- end -}}
