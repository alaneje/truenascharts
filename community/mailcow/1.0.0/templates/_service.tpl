{{- define "mailcow.service" -}}
service:
  mailcow:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: mailcow
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.mailcowNetwork.webPort }}
        nodePort: {{ .Values.mailcowNetwork.webPort }}
        targetPort: 80
        targetSelector: mailcow
      webhttps:
        enabled: true
        port: {{ .Values.mailcowNetwork.webHttpsPort }}
        nodePort: {{ .Values.mailcowNetwork.webHttpsPort }}
        targetPort: 443
        targetSelector: mailcow
  mailcow-mail:
    enabled: true
    type: ClusterIP
    targetSelector: mailcow
    ports:
      smtp:
        enabled: true
        port: {{ .Values.mailcowNetwork.smtpPort }}
        targetPort: 25
        targetSelector: mailcow
      smtps:
        enabled: true
        port: {{ .Values.mailcowNetwork.smtpsPort }}
        targetPort: 465
        targetSelector: mailcow
      submission:
        enabled: true
        port: {{ .Values.mailcowNetwork.submissionPort }}
        targetPort: 587
        targetSelector: mailcow
      imap:
        enabled: true
        port: {{ .Values.mailcowNetwork.imapPort }}
        targetPort: 143
        targetSelector: mailcow
      imaps:
        enabled: true
        port: {{ .Values.mailcowNetwork.imapsPort }}
        targetPort: 993
        targetSelector: mailcow
      pop3:
        enabled: true
        port: {{ .Values.mailcowNetwork.pop3Port }}
        targetPort: 110
        targetSelector: mailcow
      pop3s:
        enabled: true
        port: {{ .Values.mailcowNetwork.pop3sPort }}
        targetPort: 995
        targetSelector: mailcow
      sieve:
        enabled: true
        port: {{ .Values.mailcowNetwork.sievePort }}
        targetPort: 4190
        targetSelector: mailcow
  redis:
    enabled: true
    type: ClusterIP
    targetSelector: redis
    ports:
      redis:
        enabled: true
        primary: true
        port: 6379
        targetPort: 6379
        targetSelector: redis
  mariadb:
    enabled: true
    type: ClusterIP
    targetSelector: mariadb
    ports:
      mariadb:
        enabled: true
        primary: true
        port: 3306
        targetPort: 3306
        targetSelector: mariadb
{{- end -}}
