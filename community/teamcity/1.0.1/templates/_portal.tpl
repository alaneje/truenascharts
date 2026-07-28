{{- define "teamcity.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  {{- $protocol := "http" -}}
  {{- if .Values.teamcityNetwork.certificateID -}}
    {{- $protocol = "https" -}}
  {{- end }}
  path: "/"
  host: $node_ip
  protocol: {{ $protocol }}
  port: {{ .Values.teamcityNetwork.webPort | quote }}
{{- end -}}
