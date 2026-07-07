# k8s-lab

> 🚧 **WIP** — Work in progress.

A study project for learning **Kubernetes** using [kind](https://kind.sigs.k8s.io/) (Kubernetes IN Docker) to run local clusters.

## Goals

- Spin up a local Kubernetes cluster with kind
- Practice core concepts: Pods, Deployments, Services, ConfigMaps, and Secrets
- Experiment with `kubectl` workflows

## Requirements

- [Docker](https://www.docker.com/)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)

## Getting started

```bash
# Create a cluster
kind create cluster --name k8s-lab

# Check the cluster
kubectl cluster-info --context kind-k8s-lab

# Delete the cluster
kind delete cluster --name k8s-lab
```

## License

Study project — for learning purposes only.
