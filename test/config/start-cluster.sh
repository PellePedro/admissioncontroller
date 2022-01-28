#!/bin/bash
set -ex

cat <<EOF | kind create cluster -v7 --wait 1m --retain --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  disableDefaultCNI: false
  podSubnet: 10.10.0.0/16
  ipFamily: ipv4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
  kubeadmConfigPatches:
  - |
    kind: JoinConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "special-node=true"
EOF

kubectl wait --for=condition=ready pods --namespace=kube-system -l k8s-app=kube-dns
kubectl get nodes -o wide
kubectl get pods -A

# shellcheck disable=SC2086
export CERT_MANAGER_VERSION=1.7.0
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v$CERT_MANAGER_VERSION/cert-manager.yaml
kubectl rollout status deploy -n cert-manager cert-manager
kubectl rollout status deploy -n cert-manager cert-manager-cainjector
kubectl rollout status deploy -n cert-manager cert-manager-webhook
