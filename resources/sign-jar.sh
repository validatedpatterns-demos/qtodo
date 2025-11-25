#!/bin/sh

set -euo pipefail

test -n "${1}" || { echo "Usage: $0 <artifact>"; exit 1; }
test -f "${1}" || { echo "Artifact not found: ${1}"; exit 1; }

workdir="$(mktemp -d)"

case "$(uname)" in
  Darwin)
    os="darwin"
    os_arch="arm64"
    ;;
  Linux)
    os="linux"
    os_arch="amd64"
    ;;
  *)
    echo "Unsupported OS: $(uname)"
    exit 1
    ;;
esac

# Download cosign client
download_cosign_client() {
  cli_server_url=$(oc get route -n trusted-artifact-signer -l app.kubernetes.io/component=client-server -o jsonpath='{.items[0].spec.host}')

  filename="cosign-${os_arch}.gz"
  url="https://${cli_server_url}/clients/${os}/${filename}"

  curl -sk "${url}" -o "${workdir}/${filename}"
  gunzip "${workdir}/${filename}"
  chmod +x "${workdir}/${filename%.gz}"
}

# Sign the artifact
sign_artifact() {
  fulcio_url=$(oc get route -n trusted-artifact-signer -l app.kubernetes.io/component=fulcio -o jsonpath='{.items[0].spec.host}')
  rekor_url=$(oc get route -n trusted-artifact-signer -l app.kubernetes.io/component=rekor-server -o jsonpath='{.items[0].spec.host}')
  tuf_url=$(oc get route -n trusted-artifact-signer -l app.kubernetes.io/component=tuf -o jsonpath='{.items[0].spec.host}')
  keycloak_url=$(oc get route -n keycloak-system -l app=keycloak -o jsonpath='{.items[0].spec.host}')

  rhtas_user="rhtas-user"
  rhtas_user_pass="$(oc get secret -n keycloak-system keycloak-users -o jsonpath='{.data.rhtas-user-password}' | base64 -d)"

  bundle="${1}.bundle"

  curl -sk "https://${tuf_url}/root.json" -o "${workdir}/tuf-root.json"

  "${workdir}/cosign-${os_arch}" initialize \
    --mirror="https://${tuf_url}" \
    --root="https://${tuf_url}/root.json" \
    --root-checksum="$(sha256sum "${workdir}/tuf-root.json" | cut -d' ' -f1)"

  TOKEN="$(python3 /usr/local/bin/get-keycloak-token.py \
    "https://${keycloak_url}" \
    "ztvp" \
    "trusted-artifact-signer" \
    "${rhtas_user}" \
    "${rhtas_user_pass}")"

  export COSIGN_FULCIO_URL="https://${fulcio_url}"
  export COSIGN_REKOR_URL="https://${rekor_url}"

  "${workdir}/cosign-${os_arch}" sign-blob "${1}" \
    --identity-token "${TOKEN}" \
    --bundle "${bundle}" \
    --yes
}

# Import Openshift Ingress CA certificate
import_ingress_ca() {
  oc get secret router-ca -n openshift-ingress-operator -o jsonpath='{.data.tls\.crt}' | base64 -d > "${workdir}/openshift-ingress-ca.crt"
  cp "${workdir}/openshift-ingress-ca.crt" /etc/pki/ca-trust/source/anchors/
  update-ca-trust
}

download_cosign_client
import_ingress_ca
sign_artifact "${1}"