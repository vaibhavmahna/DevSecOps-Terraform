#!/usr/bin/env bash
# Installs the CLIs that have no devcontainer feature. Every binary is pinned
# and checked against the checksum file published with its release.
set -euo pipefail

KIND_VERSION="v0.33.0"
ARGOCD_VERSION="v3.5.6"
COSIGN_VERSION="v3.1.4"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"

# install_bin <name> <binary url> <checksum file url> <asset name in checksum file>
install_bin() {
  local name=$1 url=$2 sums_url=$3 asset=$4
  curl -fsSLo "$asset" "$url"
  curl -fsSLo sums.txt "$sums_url"
  grep -E "[[:space:]]\*?${asset}\$" sums.txt | sha256sum -c -
  sudo install -m 0755 "$asset" "/usr/local/bin/$name"
}

install_bin kind \
  "https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERSION}/kind-linux-amd64" \
  "https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERSION}/kind-linux-amd64.sha256sum" \
  kind-linux-amd64

install_bin argocd \
  "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64" \
  "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/cli_checksums.txt" \
  argocd-linux-amd64

install_bin cosign \
  "https://github.com/sigstore/cosign/releases/download/${COSIGN_VERSION}/cosign-linux-amd64" \
  "https://github.com/sigstore/cosign/releases/download/${COSIGN_VERSION}/cosign_checksums.txt" \
  cosign-linux-amd64

echo
kind version
argocd version --client --short
cosign version 2>/dev/null | grep GitVersion
kubectl version --client | head -1
helm version --short
