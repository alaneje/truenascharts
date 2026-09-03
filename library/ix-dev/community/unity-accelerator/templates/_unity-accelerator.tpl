{{- define "unity-accelerator.workload" -}}
workload:
  unity-accelerator:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.unityAcceleratorNetwork.hostNetwork }}
      securityContext:
        fsGroup: 568
      containers:
        unity-accelerator:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 568
            runAsGroup: 568
            runAsNonRoot: false
            readOnlyRootFilesystem: false
          probes:
            liveness:
              enabled: true
              type: http
              port: "{{ .Values.unityAcceleratorNetwork.webPort }}"
              path: /
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.unityAcceleratorNetwork.webPort }}"
              path: /
            startup:
              enabled: true
              type: http
              port: "{{ .Values.unityAcceleratorNetwork.webPort }}"
              path: /
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 568
                                                        "GID" 568
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}
{{/* Service */}}
service:
  unity-accelerator:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: unity-accelerator
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.unityAcceleratorNetwork.webPort }}
        nodePort: {{ .Values.unityAcceleratorNetwork.webPort }}
        targetSelector: unity-accelerator

{{/* Persistence */}}
persistence:
  data:
    enabled: true
    type: {{ .Values.unityAcceleratorStorage.data.type }}
    datasetName: {{ .Values.unityAcceleratorStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.unityAcceleratorStorage.data.hostPath | default "" }}
    targetSelector:
      unity-accelerator:
        unity-accelerator:
          mountPath: /agent
        01-permissions:
          mountPath: /mnt/directories/data
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      unity-accelerator:
        unity-accelerator:
          mountPath: /tmp
{{- end -}}
