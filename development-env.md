
# Install kind
```
brew install kind
```

# Create kind configuration (kind.conf)
```
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
```

# Start cluster
```
kind create cluster --config kind.conf
``

# kubectl for operation
```
kubectl get nodes
```


