{{- define "pgweb.workload" -}}
workload:
  pgweb:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.pgwebNetwork.hostNetwork }}
      containers:
        pgweb:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - NET_BIND_SERVICE
          args:
            - --bind=0.0.0.0
            - --listen={{ .Values.pgwebNetwork.webPort }}
          env:
            {{ if .Values.pgwebConfig.databaseUrl }}
            DATABASE_URL: {{ .Values.pgwebConfig.databaseUrl }}
            {{ end }}
          {{ with .Values.pgwebConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            {{- $protocol := "http" -}}
            {{- if .Values.pgwebNetwork.certificateID -}}
              {{- $protocol = "https" -}}
            {{- end }}
            liveness:
              enabled: true
              type: {{ $protocol }}
              port: "{{ .Values.pgwebNetwork.webPort }}"
              path: /
            readiness:
              enabled: true
              type: {{ $protocol }}
              port: "{{ .Values.pgwebNetwork.webPort }}"
              path: /
            startup:
              enabled: true
              type: {{ $protocol }}
              port: "{{ .Values.pgwebNetwork.webPort }}"
              path: /
{{- end -}}
