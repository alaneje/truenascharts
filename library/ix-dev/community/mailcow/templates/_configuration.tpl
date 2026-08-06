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
      MARIADB_USER: {{ $dbUser }}
      MARIADB_DATABASE: {{ $dbName }}
      MARIADB_PASSWORD: {{ $dbPass }}
      MARIADB_ROOT_PASSWORD: {{ $dbRootPass }}
      MARIADB_HOST: {{ $dbHost }}

  redis-creds:
    enabled: true
    data:
      REDIS_PASSWORD: {{ $redisPass }}
      REDIS_HOST: {{ $redisHost }}
      REDIS_PORT_NUMBER: 6379

  mailcow-creds:
    enabled: true
    data:
      MAILCOW_HOSTNAME: {{ .Values.mailcowConfig.hostname }}
      DBNAME: {{ $dbName }}
      DBUSER: {{ $dbUser }}
      DBPASS: {{ $dbPass }}
      DBROOT: {{ $dbRootPass }}
      DBHOST: {{ $dbHost }}
      REDIS_PASS: {{ $redisPass }}
      REDIS_HOST: {{ $redisHost }}
      SKIP_CLAMD: {{ ternary "y" "n" .Values.mailcowConfig.skipClamd }}
      SKIP_SOGO: {{ ternary "y" "n" .Values.mailcowConfig.skipSogo }}
{{- end -}}
