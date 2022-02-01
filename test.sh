#!/bin/bash

set -e 

RELEASE=$1

function logOnExit {
    kubectl get pod
    kubectl logs job/$RELEASE-test-job test-job || echo "Failed to log job..."
    kubectl describe job/$RELEASE-test-job || echo "Failed to describe job..."
}
trap 'logOnExit' EXIT

helm test "$RELEASE"