{{- define "horilla.workload" -}}
workload:
  horilla:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.horillaNetwork.hostNetwork }}
      containers:
        horilla:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.horillaRunAs.user }}
            runAsGroup: {{ .Values.horillaRunAs.group }}
          args:
            - "python3"
            - "manage.py"
            - "runserver"
            - "0.0.0.0:8000"
          env:
            PORT: "8000"
          {{ with .Values.horillaConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          {{- $proto := "http" -}}
          {{- if .Values.horillaNetwork.certificateID -}}
            {{- $proto = "https" -}}
          {{- end }}
          probes:
            liveness:
              enabled: true
              type: tcp
              port: 8000
            readiness:
              enabled: true
              type: tcp
              port: 8000
            startup:
              enabled: true
              type: tcp
              port: 8000
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.horillaRunAs.user
                                                        "GID" .Values.horillaRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
