{{- define "mailcow.configuration" -}}

  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-mariadb" $fullname) -}}
  {{- $dbUser := "mailcow" -}}
  {{- $dbName := "mailcow" -}}

  {{- $dbPass := (randAlphaNum 32) -}}
  {{- $dbRootPass := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-mariadb-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "MARIADB_PASSWORD") | b64dec) -}}
    {{- $dbRootPass = ((index .data "MARIADB_ROOT_PASSWORD") | b64dec) -}}
  {{- end }}

  {{- $redisHost := (printf "%s-redis" $fullname) -}}
  {{- $redisPass := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-redis-creds" $fullname)) -}}
    {{- $redisPass = ((index .data "REDIS_PASSWORD") | b64dec) -}}
  {{- end }}

secret:
  mariadb-creds:
    enabled: true
    data:
      MARIADB_USER: {{ $dbUser | quote }}
      MARIADB_DATABASE: {{ $dbName | quote }}
      MARIADB_PASSWORD: {{ $dbPass | quote }}
      MARIADB_ROOT_PASSWORD: {{ $dbRootPass | quote }}
      MARIADB_HOST: {{ $dbHost | quote }}

  redis-creds:
    enabled: true
    data:
      REDIS_PASSWORD: {{ $redisPass | quote }}
      REDIS_HOST: {{ $redisHost | quote }}
      REDIS_PORT_NUMBER: "6379"

  mailcow-creds:
    enabled: true
    data:
      MAILCOW_HOSTNAME: {{ .Values.mailcowConfig.hostname | quote }}
      DBNAME: {{ $dbName | quote }}
      DBUSER: {{ $dbUser | quote }}
      DBPASS: {{ $dbPass | quote }}
      DBROOT: {{ $dbRootPass | quote }}
      DBHOST: {{ $dbHost | quote }}
      REDIS_PASS: {{ $redisPass | quote }}
      REDIS_HOST: {{ $redisHost | quote }}
      SKIP_CLAMD: {{ ternary "y" "n" .Values.mailcowConfig.skipClamd | quote }}
      SKIP_SOGO: {{ ternary "y" "n" .Values.mailcowConfig.skipSogo | quote }}
{{- end -}}
