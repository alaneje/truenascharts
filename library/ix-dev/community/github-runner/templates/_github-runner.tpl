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
      containers:
        github-runner:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.githubRunnerRunAs.user }}
            runAsGroup: {{ .Values.githubRunnerRunAs.group }}
            readOnlyRootFilesystem: false
          env:
            REPO_URL: {{ .Values.githubRunnerConfig.url }}
            RUNNER_TOKEN: {{ .Values.githubRunnerConfig.token }}
            RUN_AS_ROOT: "false"
            {{- if .Values.githubRunnerConfig.name }}
            RUNNER_NAME: {{ .Values.githubRunnerConfig.name }}
            {{- end }}
            {{- if .Values.githubRunnerConfig.labels }}
            RUNNER_LABELS: {{ .Values.githubRunnerConfig.labels }}
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
