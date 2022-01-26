# Admission Controller in Kubernetes

## Deploy Cert Manager
[Cert-Manager](https://cert-manager.io)

```
export CERT_MANAGER_VERSION=1.7.0
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v$CERT_MANAGER_VERSION/cert-manager.yaml

kubectl rollout status deploy -n cert-manager cert-manager
kubectl rollout status deploy -n cert-manager cert-manager-cainjector
kubectl rollout status deploy -n cert-manager cert-manager-webhook

```

## Build Admission Controller
```
make build-image
make push-image
```

## Deploy Manifests
```
kustomize build deployments/default | kubectl apply -f -
```