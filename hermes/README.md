# Hermes Helm Chart

[Hermes](https://hermes.allegro.tech/) is a reliable and easy to use message broker built on top of Kafka. 

## TL;DR;

```console
$ helm repo add touk https://chartmuseum.carpinion.touk.pl/public/
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

| Parameter                                 | Description                                                           | Default                                                 |
|-------------------------------------------|-----------------------------------------------------------------------|------------------------
| `kafka.enabled`                           | If True, installs Kafka chart                                         | `true`                                                  
| `kafka.url`                               | URL of Kafka cluster (ignored when installing Kafka chart)            | `null` 
| `kafka.zookeeper.enabled`                 | If True, installs Zookeeper chart along with Kafka                    | `true`                                                  
| `kafka.zookeeper.url`                     | URL of Zookeeper cluster (ignored when installing Zookeper chart)     | `null`
| `kafka.*` `kafka.zookeeper.*`             | Kafka and Zookeeper properties                                        | [See incubator/kafka chart](https://hub.helm.sh/charts/incubator/kafka)
| `management.ingress.enabled`              |                                                                       | `false` 
| `management.ingress.annotations`          |                                                                       | `{}`
| `management.ingress.domain`               |                                                                       | `null`
| `management.ingress.host`                 |                                                                       | `(Release.Name)-(Chart.Name)`
| `frontend.ingress.enabled`                |                                                                       | `false`
| `frontend.ingress.annotations`            |                                                                       | `{}`
| `frontend.ingress.domain`                 |                                                                       | `null`
| `frontend.ingress.host`                   |                                                                       | `(Release.Name)-(Chart.Name)`
