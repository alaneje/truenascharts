{{- define "pgweb.validation" -}}
  {{- if not .Values.pgwebConfig.adminEmail -}}
    {{- fail "pgweb - Admin Email is required" -}}
  {{- end -}}
  {{- if not .Values.pgwebConfig.adminPassword -}}
    {{- fail "pgweb - Admin Password is required" -}}
  {{- end -}}
{{- end -}}
