# k8s-lab

> 🚧 **WIP** — Work in progress.

A study project for learning **Kubernetes** using [kind](https://kind.sigs.k8s.io/) (Kubernetes IN Docker) to run local clusters.

The lab deploys a sample API (`fast-feet-api`) into a dedicated namespace, exposes it through a
ClusterIP Service, and scales it with a Horizontal Pod Autoscaler backed by metrics-server.

## Goals

- Spin up a local Kubernetes cluster with kind
- Practice core concepts: Namespaces, Pods, Deployments, Services, ConfigMaps, and Secrets
- Configure health checks (startup, readiness, and liveness probes)
- Set resource requests/limits and autoscale with HPA (`autoscaling/v2`)
- Experiment with `kubectl` workflows and load testing

## Requirements

- [Docker](https://www.docker.com/)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)

## Repository layout

```
infra/
  kind/
    kind.yaml            # kind cluster: 1 control-plane + 1 worker
    metrics-server.yaml  # metrics-server v0.9.0 (with --kubelet-insecure-tls for kind)
  scripts/
    test.sh              # Fortio load test against the Service
k8s/
  namespace.yaml         # k8s-lab-ns
  confimap.yaml          # non-sensitive app config (SERVICE_NAME, PORT, NODE_ENV)
  secret.yaml            # app secrets (git-ignored)
  deployment.yaml        # fast-feet-api Deployment (probes, resources, RollingUpdate)
  service.yaml           # ClusterIP Service
  hpa.yaml               # HPA autoscaling/v2 (CPU + memory, with scale behavior)
  hpa-v1.yaml            # HPA autoscaling/v1 (kept for reference — deprecated)
```

> `k8s/secret.yaml` is listed in `.gitignore`, so it is not committed. Create it locally before
> applying the Deployment, since the pod loads it via `envFrom.secretRef`.

## Getting started

### 1. Create the cluster

```bash
kind create cluster --name k8s-lab --config infra/kind/kind.yaml

# Check the cluster
kubectl cluster-info --context kind-k8s-lab
kubectl get nodes
```

### 2. Install metrics-server (required by the HPA)

```bash
kubectl apply -f infra/kind/metrics-server.yaml

kubectl -n kube-system rollout status deployment/metrics-server
kubectl top nodes
```

### 3. Deploy the application

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/confimap.yaml
kubectl apply -f k8s/secret.yaml      # create this file locally first
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml
```

### 4. Inspect the workload

```bash
kubectl get all -n k8s-lab-ns
kubectl describe deployment fast-feet-api -n k8s-lab-ns
kubectl logs -f -l app=fast-feet-api -n k8s-lab-ns
kubectl get hpa -n k8s-lab-ns -w
```

### 5. Access the API locally

```bash
kubectl port-forward svc/fast-feet-api-svc 8080:80 -n k8s-lab-ns
curl http://localhost:8080/api/health/live
```

## Load testing

`infra/scripts/test.sh` runs a temporary [Fortio](https://fortio.org/) pod inside the cluster and
hammers the health endpoint, which is enough to make the HPA scale the Deployment up and down.

```bash
chmod +x infra/scripts/test.sh
./infra/scripts/test.sh

# watch the autoscaler react (in another terminal)
kubectl get hpa,pods -n k8s-lab-ns -w
```

## Health endpoints

| Probe     | Path                   | Purpose                                        |
| --------- | ---------------------- | ---------------------------------------------- |
| Startup   | `/api/health/startup`  | Gives the container time to boot before others |
| Readiness | `/api/health/ready`    | Controls whether the pod receives traffic      |
| Liveness  | `/api/health/live`     | Restarts the container when it becomes stuck   |

## Teardown

```bash
kubectl delete -f k8s/ --ignore-not-found
kind delete cluster --name k8s-lab
```

## License

Study project — for learning purposes only.
