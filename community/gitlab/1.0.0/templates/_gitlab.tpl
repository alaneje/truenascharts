{{- define "gitlab.workload" -}}
workload:
  gitlab:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.gitlabNetwork.hostNetwork }}
      containers:
        gitlab:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.gitlabRunAs.user }}
            runAsGroup: {{ .Values.gitlabRunAs.group }}
          env:
            {{ $protocol := "http" }}
            {{ if .Values.gitlabNetwork.certificateID }}
              {{ $protocol = "https" }}
            {{ end }}
            {{ $portStr := "" }}
            {{ if ne (int .Values.gitlabNetwork.webPort) 80 }}
              {{ $portStr = printf ":%v" .Values.gitlabNetwork.webPort }}
            {{ end }}
            {{ $rootURL := .Values.gitlabNetwork.rootURL }}
            {{ if not $rootURL }}
              {{ $rootURL = printf "%s://localhost%s" $protocol $portStr }}
            {{ end }}
            GITLAB_OMNIBUS_CONFIG: |
              external_url '{{ $rootURL }}'
              gitlab_rails['gitlab_shell_ssh_port'] = {{ .Values.gitlabNetwork.externalSshPort | default .Values.gitlabNetwork.sshPort }}
          {{ with .Values.gitlabConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: {{ $protocol }}
              path: /-/health
              port: 80
            readiness:
              enabled: true
              type: {{ $protocol }}
              path: /-/readiness
              port: 80
            startup:
              enabled: true
              type: {{ $protocol }}
              path: /-/health
              port: 80
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                    "UID" .Values.gitlabRunAs.user
                                                    "GID" .Values.gitlabRunAs.group
                                                    "mode" "check"
                                                    "type" "install") | nindent 8 }}
{{/* Service */}}
service:
  gitlab:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: gitlab
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.gitlabNetwork.webPort }}
        nodePort: {{ .Values.gitlabNetwork.webPort }}
        targetPort: 80
        targetSelector: gitlab
      ssh:
        enabled: true
        port: {{ .Values.gitlabNetwork.sshPort }}
        nodePort: {{ .Values.gitlabNetwork.sshPort }}
        targetPort: 22
        targetSelector: gitlab

{{/* Persistence */}}
persistence:
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.gitlabStorage.data) | nindent 4 }}
    targetSelector:
      gitlab:
        gitlab:
          mountPath: /var/opt/gitlab
        {{- if and (eq .Values.gitlabStorage.data.type "ixVolume")
                  (not (.Values.gitlabStorage.data.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/data
        {{- end }}
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.gitlabStorage.config) | nindent 4 }}
    targetSelector:
      gitlab:
        gitlab:
          mountPath: /etc/gitlab
        {{- if and (eq .Values.gitlabStorage.config.type "ixVolume")
                  (not (.Values.gitlabStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  logs:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.gitlabStorage.logs) | nindent 4 }}
    targetSelector:
      gitlab:
        gitlab:
          mountPath: /var/log/gitlab
        {{- if and (eq .Values.gitlabStorage.logs.type "ixVolume")
                  (not (.Values.gitlabStorage.logs.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/logs
        {{- end }}

  {{- range $idx, $storage := .Values.gitlabStorage.additionalStorages }}
  {{ printf "gitlab-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      gitlab:
        gitlab:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}

  {{ if .Values.gitlabNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: gitlab-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: private.key
      - key: tls.crt
        path: public.crt
    targetSelector:
      gitlab:
        gitlab:
          mountPath: /etc/certs/gitlab
          readOnly: true
  {{ end }}
{{- end -}}
