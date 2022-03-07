#!/bin/bash

set -e 

RELEASE=$1

function logOnExit {
    kubectl get pod
    kubectl logs job/$RELEASE-test-job test-job || echo "Failed to log job..."
    kubectl describe job/$RELEASE-test-job || echo "Failed to describe job..."

    MANAGEMENT_POD=$(kubectl get pod | grep -o -e "$RELEASE-management\-\w\+\-\w\+")
    kubectl logs "$MANAGEMENT_POD"
    kubectl logs $RELEASE-zookeeper-0
    kubectl logs $RELEASE-kafka-0
    kubectl exec -it $RELEASE-kafka-0 -- kafka-topics.sh --bootstrap-server $RELEASEkafka:9092 --create --topic t1
    kubectl exec -it $RELEASE-kafka-0 -- kafka-topics.sh --bootstrap-server $RELEASEkafka:9092 --list

}
trap 'logOnExit' EXIT

#kubectl exec -it $RELEASE-kafka-0 -- kafka-topics.sh --bootstrap-server $RELEASEkafka:9092 --list
helm test "$RELEASE"