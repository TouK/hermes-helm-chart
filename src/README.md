# Hermes Helm Chart

[Hermes](https://hermes.allegro.tech/) is a message broker that greatly simplifies communication between services
using publish-subscribe pattern. It is HTTP-native, exposing REST endpoints for message publishing as well as pushing
messages to subscribers REST endpoints. Under the hood, [Apache Kafka](http://kafka.apache.org/) is used. [(...)](https://hermes-pubsub.readthedocs.io/)

## TL;DR;

```console
$ helm repo add touk https://helm-charts.touk.pl/public/
$ helm install my-release touk/hermes
```

## Prerequisites

* Kubernetes 1.16+
* Helm 3.0+
* PV support on underlying infrastructure (if Kafka dependency is enabled)

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release touk/hermes
```

You can configure the chart with a couple of `--set param=value` with configuration parameters shown below,
but using a file is recommended.

```console
$ helm install --name my-release touk/hermes -f values.yaml
```

The chart contains 3 deployments - for frontend, consumers and managment components.
The default configuration installs Kafka and Zookeeper as well.

## Testing after installation

You can test your installation by running:
```console
$ helm test my-release
```
It will create a group, topic, and a sample subscriber. Then it will send a message and check if it reaches 
the subscriber. The subscription will be removed afterwards, but the group and topic will be left intact
as an example.   

## Uninstalling the Chart

To uninstall/delete the my-release deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Upgrading an existing Release to a new major version

A major chart version change (like v1.2.3 -> v2.0.0) indicates that there is an
incompatible breaking change needing manual actions.

## Configuration

| Parameter                                 | Description                                                           | Default
|-------------------------------------------|-----------------------------------------------------------------------|------------------------
| `kafka.enabled`                           | If True, Kafka is installed from a dependency chart                   | `true`
| `global.kafka.bootstrapServers`           | Kafka cluster address (if the dependency disabled)                    | `[]`
| `global.kafka.name`                       | Name of a Kafka service without a release name (if the dependency disabled and server not provided) | `kafka`
| `global.kafka.fullname`                   | Name of a Kafka service with a release name (an alternative to the above) | `null`
| `global.kafka.port`                       | Port of a Kafka service (if the dependency disabled and server not provided) | `9092`
| `kafka.zookeeper.enabled`                 | If True, Zookeeper is installed from a dependency chart along with Kafka | `true`
| `global.zookeeper.servers`                | Zookeeper cluster address (if the dependency disabled)                | `[]`
| `global.zookeeper.name`                   | Name of a Zookeeper service without a release name (if the dependency disabled and server not provided) | `zookeeper`
| `global.zookeeper.fullname`               | Name of a Zookeeper service with a release name (an alternative to the above) | `null`
| `global.zookeeper.port`                   | Port of a Zookeeper service (if the dependency disabled and server not provided)                                          | `2181`
| `kafkaNamespace`                          | The prefix added to all Kafka topic names managed by Hermes           | `null`
| `kafka.*` `kafka.zookeeper.*`             | Kafka and Zookeeper dependencies' properties                          | [See incubator/kafka chart](https://hub.helm.sh/charts/incubator/kafka)
| `management.ingress.enabled`              |                                                                       | `false`
| `management.ingress.annotations`          | Use this to restrict access to Mangement GUI                          | `{}`
| `management.ingress.domain`               |                                                                       | `null`
| `management.ingress.host`                 |                                                                       | `(Release.Name)-(Chart.Name)`
| `frontend.ingress.enabled`                |                                                                       | `false`
| `frontend.ingress.annotations`            | Use this to restrict access to Frontend API                           | `{}`
| `frontend.ingress.domain`                 |                                                                       | `null`
| `frontend.additionalConfig`               | Additional config values                                              | `{}`
| `frontend.secretConfig`                   | Additional config values, mounted as a secret                         | `{}`


## TODO

* There is no Graphite configuration available yet.
* Since security rules in Hermes require coding they are currently not available for configuration.  
