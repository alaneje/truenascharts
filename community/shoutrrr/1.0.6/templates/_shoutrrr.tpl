{{- define "shoutrrr.workload" -}}
workload:
  shoutrrr:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ (.Values.shoutrrrNetwork | default dict).hostNetwork | default false }}
      containers:
        shoutrrr:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            allowPrivilegeEscalation: true
            capabilities:
              add:
                - NET_BIND_SERVICE
                - CHOWN
                - DAC_OVERRIDE
                - FOWNER
                - SETUID
                - SETGID
                - SETPCAP
                - SETFCAP
                - KILL
                - SYS_PTRACE
          envFrom:
            - secretRef:
                name: shoutrrr-creds
            - configMapRef:
                name: shoutrrr-config
          {{ with (.Values.shoutrrrConfig | default dict).additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value | quote }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: http
              port: 8080
              path: /up
            readiness:
              enabled: true
              type: http
              port: 8080
              path: /up
            startup:
              enabled: true
              type: http
              port: 8080
              path: /up
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 9999
                                                        "GID" 9999
                                                        "mode" "always"
                                                        "chmod" "775"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
