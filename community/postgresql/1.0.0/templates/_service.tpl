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
        targetPort: 5432
        targetSelector: postgresql
        protocol: tcp
{{- end -}}
