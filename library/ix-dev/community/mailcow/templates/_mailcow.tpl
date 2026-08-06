{{- define "mailcow.workload" -}}
workload:
  mailcow:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        dovecot:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - NET_BIND_SERVICE
                - CHOWN
                - DAC_OVERRIDE
                - FOWNER
                - SETGID
                - SETUID
          resources:
            limits:
              cpu: {{ .Values.resources.limits.cpu }}
              memory: {{ .Values.resources.limits.memory }}
          envFrom:
            - secretRef:
                name: mailcow-creds
          {{ with .Values.mailcowConfig.additionalEnvs }}
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
              port: {{ .Values.mailcowNetwork.imapPort }}
            readiness:
              enabled: true
              type: tcp
              port: {{ .Values.mailcowNetwork.imapPort }}
            startup:
              enabled: true
              type: tcp
              port: {{ .Values.mailcowNetwork.imapPort }}
      initContainers:
      {{- include "ix.v1.common.app.mariadbWait" (dict "name" "01-mariadb-wait"
                                                       "secretName" "mariadb-creds") | nindent 8 }}
      {{- include "ix.v1.common.app.redisWait" (dict "name" "02-redis-wait"
                                                     "secretName" "redis-creds") | nindent 8 }}
{{- end -}}

{{- define "mailcow.mariadb.workload" -}}
workload:
{{- include "ix.v1.common.app.mariadb" (dict "secretName" "mariadb-creds"
                                             "resources" .Values.resources
                                             "ixChartContext" .Values.ixChartContext) | nindent 2 }}
{{- end -}}

{{- define "mailcow.redis.workload" -}}
workload:
{{- include "ix.v1.common.app.redis" (dict "secretName" "redis-creds"
                                           "resources" .Values.resources) | nindent 2 }}
{{- end -}}
