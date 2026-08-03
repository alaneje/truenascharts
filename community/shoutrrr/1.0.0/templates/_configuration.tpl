{{- define "shoutrrr.configuration" -}}

  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $appKey := (.Values.shoutrrrConfig | default dict).appKey -}}
  {{- if not $appKey -}}
    {{- $appKey = (printf "base64:%s" (randAlphaNum 32 | b64enc)) -}}
    {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-shoutrrr-creds" $fullname)) -}}
      {{- $appKey = ((index .data "APP_KEY") | b64dec) -}}
    {{- end -}}
  {{- end }}

secret:
  shoutrrr-creds:
    enabled: true
    data:
      APP_KEY: {{ $appKey }}

configmap:
  shoutrrr-config:
    enabled: true
    data:
      APP_NAME: {{ (.Values.shoutrrrConfig | default dict).appName | default "Shoutrrr" | quote }}
      APP_URL: {{ (.Values.shoutrrrConfig | default dict).appUrl | default "http://localhost:31014" | trimSuffix "/" | quote }}
      APP_ENV: production
      PORT: "8080"
      SESSION_SECURE_COOKIE: {{ (.Values.shoutrrrConfig | default dict).sessionSecureCookie | default false | quote }}
      TRUSTED_PROXIES: {{ (.Values.shoutrrrConfig | default dict).trustedProxies | default "*" | quote }}
      FILESYSTEM_DISK: {{ (.Values.shoutrrrConfig | default dict).filesystemDisk | default "public" | quote }}
{{- end -}}
