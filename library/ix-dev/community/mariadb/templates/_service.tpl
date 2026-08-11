{{- define "mariadb.service" -}}
service:
  mariadb:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: mariadb
    ports:
      server:
        enabled: true
        primary: true
        port: {{ .Values.mariadbNetwork.serverPort }}
        nodePort: {{ .Values.mariadbNetwork.serverPort }}
        targetPort: 3306
        targetSelector: mariadb
        protocol: tcp
{{- end -}}
