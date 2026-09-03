{{- define "droposs.workload" -}}
workload:
  droposs:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.dropossNetwork.hostNetwork }}
      containers:
        droposs:
          enabled: true
          primary: true
          imageSelector: {{ .Values.dropossConfig.imageSelector | default "image" }}
          securityContext:
            runAsUser: {{ .Values.dropossRunAs.user }}
            runAsGroup: {{ .Values.dropossRunAs.group }}
            readOnlyRootFilesystem: false
          envFrom:
            - secretRef:
                name: droposs
            - configMapRef:
                name: droposs
          {{ with .Values.dropossConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: http
              port: {{ .Values.dropossNetwork.webPort }}
              path: /
            readiness:
              enabled: true
              type: http
              port: {{ .Values.dropossNetwork.webPort }}
              path: /
            startup:
              enabled: true
              type: http
              port: {{ .Values.dropossNetwork.webPort }}
              path: /
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                    "UID" .Values.dropossRunAs.user
                                                    "GID" .Values.dropossRunAs.group
                                                    "mode" "check"
                                                    "type" "install") | nindent 8 }}
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "01-postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
{{- end -}}
