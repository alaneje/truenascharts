{{- define "mariadb.workload" -}}
workload:
  mariadb:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.mariadbNetwork.hostNetwork }}
      containers:
        mariadb:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 999
            runAsGroup: 999
            runAsNonRoot: true
            readOnlyRootFilesystem: false
          env:
            MARIADB_USER: {{ .Values.mariadbConfig.user | quote }}
            MARIADB_PASSWORD: {{ .Values.mariadbConfig.password | quote }}
            MARIADB_DATABASE: {{ .Values.mariadbConfig.database | quote }}
            MARIADB_ROOT_PASSWORD: {{ .Values.mariadbConfig.password | quote }}
          {{ with .Values.mariadbConfig.additionalEnvs }}
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
              port: 3306
            readiness:
              enabled: true
              type: tcp
              port: 3306
            startup:
              enabled: true
              type: tcp
              port: 3306
{{- end -}}
