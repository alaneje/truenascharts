{{- define "frappeHrms.workload" -}}
workload:
  actual:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.frappeHrmsNetwork.hostNetwork }}
      containers:
        actual:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.frappeHrmsRunAs.user }}
            runAsGroup: {{ .Values.frappeHrmsRunAs.group }}
          env:
            PORT: {{ .Values.frappeHrmsNetwork.webPort | quote }}
            FRAPPE_SITE_NAME_HEADER: host
            {{- if .Values.frappeHrmsNetwork.certificateID }}
            HTTPS_KEY: /certs/tls.key
            HTTPS_CERT: /certs/tls.crt
            {{- end }}
          {{ with .Values.frappeHrmsConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          {{- $proto := "http" -}}
          {{- if .Values.frappeHrmsNetwork.certificateID -}}
            {{- $proto = "https" -}}
          {{- end }}
          probes:
            liveness:
              enabled: true
              type: {{ $proto }}
              port: {{ .Values.frappeHrmsNetwork.webPort }}
              path: /api/method/ping
            readiness:
              enabled: true
              type: {{ $proto }}
              port: {{ .Values.frappeHrmsNetwork.webPort }}
              path: /api/method/ping
            startup:
              enabled: true
              type: {{ $proto }}
              port: {{ .Values.frappeHrmsNetwork.webPort }}
              path: /api/method/ping
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.frappeHrmsRunAs.user
                                                        "GID" .Values.frappeHrmsRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
