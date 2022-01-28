# Admission Controller in Kubernetes

## Start Kind and Deploy Cert Manager
[Cert-Manager](https://cert-manager.io)

```
cd test/config
./start-cluster.sh
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

## Deploy test Pod
```
kubectl apply -f test/deployments/toolbox.yaml

```