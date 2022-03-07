#!/usr/bin/env bats

: "${MANAGEMENT_URL:?required environment value not set}"
: "${FRONTEND_URL:?required environment value not set}"
: "${WIREMOCK_URL:?required environment value not set}"

GROUP=testgroup
TOPIC=testtopic

function curl_get() {
  curl -f -k -v -X GET "$@"
}

function curl_delete() {
  curl -f -k -v -X DELETE "$@"
}

function curl_post() {
  curl -f -k -v -H "Content-type: application/json" -X POST "$@"
}

# timeout command has different syntax in Ubuntu and BusyBox
if [[ $(realpath $(which timeout)) =~ "busybox" ]]; then
  function timeout() {
    $(which timeout) -t "$@"
  }
fi

function setup() {
  # given a group
  curl_get ${MANAGEMENT_URL%/}/groups/${GROUP} ||
    curl_post -d "{\"groupName\": \"${GROUP}\"}" ${MANAGEMENT_URL%/}/groups

  sleep 10
  echo "Creating topic"
  # and a topic
  curl_get ${MANAGEMENT_URL%/}/topics/${GROUP}.${TOPIC} ||
    cat  << _END | curl -k -v -H "Content-type: application/json"  -d @- ${MANAGEMENT_URL%/}/topics/
{
    "name": "${GROUP}.${TOPIC}",
    "description": "This is a test topic",
    "contentType": "AVRO",
    "retentionTime": {
        "duration": 1
    },
    "owner": {
        "source": "Plaintext",
        "id": "Test"
    },
    "schema":	"{\n \"namespace\": \"${GROUP}\",\n \"name\": \"${TOPIC}\",\n \"type\": \"record\",\n \"doc\": \"This is a sample schema definition for some Hermes message\",\n \"fields\": [\n {\n \"name\": \"id\",\n \"type\": \"string\",\n \"doc\": \"Message id\"\n },\n {\n \"name\": \"content\",\n \"type\": \"string\",\n \"doc\": \"Message content\"\n },\n {\n \"name\": \"tags\",\n \"type\": { \"type\": \"array\", \"items\": \"string\" },\n \"doc\": \"Message tags\"\n },\n {\n \"name\": \"__metadata\",\n \"type\": [\n \"null\",\n {\n \"type\": \"map\",\n \"values\": \"string\"\n }\n ],\n \"default\": null,\n \"doc\": \"Field used in Hermes internals to propagate metadata like hermes-id\"\n }\n ]\n}"
}
_END
  echo "Once again??" >&2
  sleep 10
  curl_get ${MANAGEMENT_URL%/}/topics/${GROUP}.${TOPIC} ||
    cat  << _END | curl -k -v -H "Content-type: application/json" -d @- ${MANAGEMENT_URL%/}/topics/
{
    "name": "${GROUP}.${TOPIC}",
    "description": "This is a test topic",
    "contentType": "AVRO",
    "retentionTime": {
        "duration": 1
    },
    "owner": {
        "source": "Plaintext",
        "id": "Test"
    },
    "schema":	"{\n \"namespace\": \"${GROUP}\",\n \"name\": \"${TOPIC}\",\n \"type\": \"record\",\n \"doc\": \"This is a sample schema definition for some Hermes message\",\n \"fields\": [\n {\n \"name\": \"id\",\n \"type\": \"string\",\n \"doc\": \"Message id\"\n },\n {\n \"name\": \"content\",\n \"type\": \"string\",\n \"doc\": \"Message content\"\n },\n {\n \"name\": \"tags\",\n \"type\": { \"type\": \"array\", \"items\": \"string\" },\n \"doc\": \"Message tags\"\n },\n {\n \"name\": \"__metadata\",\n \"type\": [\n \"null\",\n {\n \"type\": \"map\",\n \"values\": \"string\"\n }\n ],\n \"default\": null,\n \"doc\": \"Field used in Hermes internals to propagate metadata like hermes-id\"\n }\n ]\n}"
}
_END

  timeout 20 /bin/sh -c "until curl --output /dev/null --max-time 5 --silent --fail ${WIREMOCK_URL%/}/__admin/; do sleep 1 && echo -n .; done;"

  # and a subscriber
  SUBSCRIBER_NAME=$(head /dev/urandom | tr -dc a-z | head -c 16)
  SUBSCRIBER_URL=${WIREMOCK_URL%/}/${SUBSCRIBER_NAME}
  cat << _END | curl_post -d @- ${WIREMOCK_URL%/}/__admin/mappings
{
  "request": {
    "method": "POST",
    "url": "/${SUBSCRIBER_NAME}"
  },
  "response": {
    "status": 202
  }
}
_END
  cat << _END | curl_post -d @- ${MANAGEMENT_URL%/}/topics/${GROUP}.${TOPIC}/subscriptions
{
    "contentType": "JSON",
    "description": "test",
    "endpoint": "${SUBSCRIBER_URL%/}",
    "name": "${SUBSCRIBER_NAME}",
    "owner": { "id": "test", "source": "Plaintext" },
    "topicName": "${GROUP}.${TOPIC}"
}
_END
}

function teardown() {
  # afterwards remove the subscription
  curl_delete ${MANAGEMENT_URL%/}/topics/${GROUP}.${TOPIC}/subscriptions/${SUBSCRIBER_NAME}
  # the group and topic are left as an example
}

@test "message should be sent to subscriber" {
  # when a message has been posted on the topic
  cat << _END | curl_post -d @- ${FRONTEND_URL%/}/topics/${GROUP}.${TOPIC}
{
  "id": "an id",
  "content": "a content",
  "tags": []
}
_END

  # then the message is received by the subscriber
  export -f curl_post
  cat << _END | timeout 90 bash -c "until curl_post -d '$(cat)' ${WIREMOCK_URL%/}/__admin/requests/count | grep '\"count\" : 1'; do sleep 10; done"
{
    "method": "POST",
    "url": "/${SUBSCRIBER_NAME}"
}
_END

}
