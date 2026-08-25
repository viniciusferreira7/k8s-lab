#!/bin/bash
# Cluster stress test

echo "Creating and generating stress test using Fortio"

kubectl run fortio \
    -n k8s-lab-ns \
    --rm -it \
    --image=fortio/fortio:1.75.2 \
    -- \
    load \
    -qps 6000 \
    -t 120s \
    -c 100 \
    -loglevel info \
    http://fast-feet-api-svc/api/health/live

echo "Stress test finished"