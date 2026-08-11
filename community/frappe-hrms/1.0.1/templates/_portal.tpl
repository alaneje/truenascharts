{{- define "frappeHrms.portal" -}}
{{- $proto := "http" -}}
{{- if .Values.frappeHrmsNetwork.certificateID -}}
  {{- $proto = "https" -}}
{{- end }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/"
  port: {{ .Values.frappeHrmsNetwork.webPort | quote }}
  protocol: {{ $proto }}
  host: $node_ip
{{- end -}}
