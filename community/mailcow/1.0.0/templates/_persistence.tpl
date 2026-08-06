{{- define "mailcow.persistence" -}}
persistence:
  vmail:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.mailcowStorage.vmail) | nindent 4 }}
    targetSelector:
      mailcow:
        dovecot:
          mountPath: /var/vmail
  crypt:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.mailcowStorage.crypt) | nindent 4 }}
    targetSelector:
      mailcow:
        dovecot:
          mountPath: /mailcow/crypt
  rspamddata:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.mailcowStorage.rspamdData) | nindent 4 }}
    targetSelector:
      mailcow:
        rspamd:
          mountPath: /var/lib/rspamd
  redisdata:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.mailcowStorage.redisData) | nindent 4 }}
    targetSelector:
      redis:
        redis:
          mountPath: /data
  mariadbdata:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.mailcowStorage.mariadbData) | nindent 4 }}
    targetSelector:
      mariadb:
        mariadb:
          mountPath: /var/lib/mysql
        permissions:
          mountPath: /mnt/directories/mariadb_data
  mariadbbackup:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.mailcowStorage.mariadbBackup) | nindent 4 }}
    targetSelector:
      mariadbbackup:
        mariadbbackup:
          mountPath: /mariadb_backup
        permissions:
          mountPath: /mnt/directories/mariadb_backup
  {{- range $idx, $storage := .Values.mailcowStorage.additionalStorages }}
  {{ printf "mailcow-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      mailcow:
        dovecot:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
