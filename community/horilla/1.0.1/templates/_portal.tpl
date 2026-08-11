{{- define "horilla.portal" -}}
{{- $proto := "http" -}}
{{- if .Values.horillaNetwork.certificateID -}}
  {{- $proto = "https" -}}
{{- end }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/"
  port: {{ .Values.horillaNetwork.webPort | quote }}
  protocol: {{ $proto }}
  host: $node_ip
{{- end -}}
