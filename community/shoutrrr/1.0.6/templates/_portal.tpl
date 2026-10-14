{{- define "shoutrrr.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/"
  port: {{ ((.Values.shoutrrrNetwork | default dict).webPort | default 31014) | quote }}
  protocol: http
  host: $node_ip
{{- end -}}
