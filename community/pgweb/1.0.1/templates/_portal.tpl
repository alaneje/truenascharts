{{- define "pgweb.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  {{- $protocol := "http" -}}
  {{- if .Values.pgwebNetwork.certificateID -}}
    {{- $protocol = "https" -}}
  {{- end }}
  path: "/"
  port: {{ .Values.pgwebNetwork.webPort | quote }}
  protocol: {{ $protocol }}
  host: $node_ip
{{- end -}}
