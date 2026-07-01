{{- define "teamcity.certContainer" -}}
enabled: true
type: init
imageSelector: image
securityContext:
  runAsUser: 1000
  runAsGroup: 1000
command:
  - /bin/sh
  - -c
args:
  - |
    {{- $key := printf "%v/%v" .Values.teamcityConstants.certsPath .Values.teamcityConstants.keyName -}}
    {{- $cert := printf "%v/%v" .Values.teamcityConstants.certsPath .Values.teamcityConstants.crtName -}}
    {{- $keystore := printf "%v/%v" .Values.teamcityConstants.keystorePath .Values.teamcityConstants.keystoreName }}
    # Create the directories for the certificates and keystore
    mkdir -p "{{ .Values.teamcityConstants.certsPath }}"
    mkdir -p "{{ .Values.teamcityConstants.keystorePath }}"

    if [ -f "/tmp/ix.p12" ]; then
      echo "Cleaning up old certificate"
      rm "/tmp/ix.p12"
    fi

    echo "Generating new certificate from key and cert"

    if [ -f "{{ $key }}" ] && [ -f "{{ $cert }}" ]; then
      echo "Found key and cert, creating p12 certificate"

      openssl pkcs12 -inkey "{{ $key }}" -in "{{ $cert }}" \
                      -export -out "/tmp/ix.p12" \
                      -password pass:{{ .Values.teamcityCertRandomPass }} || exit 1
      echo "P12 Certificate created"

      if [ -f "{{ $keystore }}" ]; then
        echo "Keystore already exists, removing and creating a new one"
        rm "{{ $keystore }}"
      fi

      echo "Importing certificate into a new java keystore"
      keytool -importkeystore -srckeystore "/tmp/ix.p12" -srcstoretype pkcs12 \
              -destkeystore "{{ $keystore }}" -deststoretype JKS \
              -srcstorepass {{ .Values.teamcityCertRandomPass }} \
              -deststorepass {{ .Values.teamcityCertRandomPass }} || exit 1

      echo "Certificate imported"
    fi
{{- end -}}
