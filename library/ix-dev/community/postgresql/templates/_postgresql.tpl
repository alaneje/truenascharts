{{- define "postgresql.workload" -}}
workload:
  postgresql:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.postgresqlNetwork.hostNetwork }}
      containers:
        postgresql:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 999
            runAsGroup: 999
            runAsNonRoot: true
            readOnlyRootFilesystem: false
          env:
            POSTGRES_USER: {{ .Values.postgresqlConfig.user | quote }}
            POSTGRES_PASSWORD: {{ .Values.postgresqlConfig.password | quote }}
            POSTGRES_DB: {{ .Values.postgresqlConfig.database | quote }}
            PGDATA: /var/lib/postgresql/data/pgdata
          {{ with .Values.postgresqlConfig.additionalEnvs }}
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
              port: 5432
            readiness:
              enabled: true
              type: tcp
              port: 5432
            startup:
              enabled: true
              type: tcp
              port: 5432
{{- end -}}
