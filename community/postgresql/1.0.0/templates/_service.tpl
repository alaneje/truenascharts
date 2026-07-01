{{- define "postgresql.service" -}}
service:
  postgresql:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: postgresql
    ports:
      server:
        enabled: true
        primary: true
        port: {{ .Values.postgresqlNetwork.serverPort }}
        nodePort: {{ .Values.postgresqlNetwork.serverPort }}
        targetSelector: postgresql
        protocol: tcp
{{- end -}}
