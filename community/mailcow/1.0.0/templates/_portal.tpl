{{- define "mailcow.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  port: {{ .Values.mailcowNetwork.webPort | quote }}
  path: "/"
  protocol: "http"
  host: "$node_ip"
{{- end -}}
