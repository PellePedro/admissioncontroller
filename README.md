# Admission Controller in Kubernetes

## Download tools (OSX)
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install kind
brew install kustomize
brew install kubectl
brew install go

```

## Lens IDE
```
https://k8slens.dev
```

## Start Kind and Deploy Cert Manager
[Cert-Manager](https://cert-manager.io)

```
pushd test/config
./start-cluster.sh
popd
```

## Build Admission Controller
```
make build-image
make push-image
```

## Deploy Manifests
```
kubectl create ns tsf-system
kustomize build deployments/default | kubectl apply -f -
```

## Deploy test Pod
```
kubectl apply -f test/deployments/toolbox.yaml

```
