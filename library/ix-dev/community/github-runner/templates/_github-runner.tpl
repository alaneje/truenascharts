{{- define "github-runner.workload" -}}
{{- if not .Values.githubRunnerConfig.url -}}
  {{- fail "GitHub Runner - Repository or Organization URL is required" -}}
{{- end -}}
{{- if not .Values.githubRunnerConfig.token -}}
  {{- fail "GitHub Runner - Runner Token is required" -}}
{{- end -}}
workload:
  github-runner:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.githubRunnerNetwork.hostNetwork }}
      securityContext:
        fsGroup: {{ .Values.githubRunnerRunAs.group }}
      containers:
        github-runner:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            readOnlyRootFilesystem: false
            runAsNonRoot: false
            {{- if .Values.githubRunnerStorage.enableDockerInDocker }}
            privileged: true
            allowPrivilegeEscalation: true
            {{- end }}
            capabilities:
              add:
                - SETUID
                - SETGID
                - CHOWN
                - FOWNER
                - DAC_OVERRIDE
          env:
            {{- if .Values.githubRunnerStorage.enableDockerInDocker }}
            START_DOCKER_SERVICE: "true"
            {{- end }}
            REPO_URL: {{ .Values.githubRunnerConfig.url }}
            {{- if or (hasPrefix "ghp_" .Values.githubRunnerConfig.token) (hasPrefix "github_pat_" .Values.githubRunnerConfig.token) }}
            ACCESS_TOKEN: {{ .Values.githubRunnerConfig.token }}
            {{- else }}
            RUNNER_TOKEN: {{ .Values.githubRunnerConfig.token }}
            {{- end }}
            REPLACE_EXISTING_RUNNER: "true"
            DOTNET_SYSTEM_NET_DISABLEIPV6: "1"
            {{- if .Values.githubRunnerConfig.name }}
            RUNNER_NAME: {{ .Values.githubRunnerConfig.name }}
            {{- end }}
            {{- if .Values.githubRunnerConfig.labels }}
            RUNNER_LABELS: {{ replace " " "" .Values.githubRunnerConfig.labels | quote }}
            {{- end }}
          {{ with .Values.githubRunnerConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: false
            readiness:
              enabled: false
            startup:
              enabled: false
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.githubRunnerRunAs.user
                                                        "GID" .Values.githubRunnerRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
