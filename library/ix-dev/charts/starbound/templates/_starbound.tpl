{{- define "starbound.workload" -}}
workload:
  starbound:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.starboundNetwork.hostNetwork }}
      containers:
        starbound:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 1370
            runAsGroup: 1370
            runAsNonRoot: true
            readOnlyRootFilesystem: false
          {{ with .Values.starboundConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: tcp
              port: {{ .Values.starboundNetwork.serverPort }}
            readiness:
              enabled: true
              type: tcp
              port: {{ .Values.starboundNetwork.serverPort }}
            startup:
              enabled: true
              type: tcp
              port: {{ .Values.starboundNetwork.serverPort }}
{{- end -}}
