{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "hermes.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "hermes.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create unified labels for hermes components
*/}}
{{- define "hermes.common.labels" -}}
helm.sh/chart: {{ include "hermes.chart" . }}
{{ include "hermes.common.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "hermes.management.labels" -}}
component: {{ .Values.management.name | quote }}
{{ include "hermes.common.labels" . }}
{{- end -}}

{{- define "hermes.frontend.labels" -}}
component: {{ .Values.frontend.name | quote }}
{{ include "hermes.common.labels" . }}
{{- end -}}

{{- define "hermes.consumers.labels" -}}
component: {{ .Values.consumers.name | quote }}
{{ include "hermes.common.labels" . }}
{{- end -}}

{{/*
Create selector labels for hermes components
*/}}
{{- define "hermes.common.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hermes.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "hermes.management.selectorLabels" -}}
{{ include "hermes.common.selectorLabels" . }}
app.kubernetes.io/name: {{ .Values.management.name }}
{{- end -}}

{{- define "hermes.frontend.selectorLabels" -}}
{{ include "hermes.common.selectorLabels" . }}
app.kubernetes.io/name: {{ .Values.frontend.name }}
{{- end -}}

{{- define "hermes.consumers.selectorLabels" -}}
{{ include "hermes.common.selectorLabels" . }}
app.kubernetes.io/name: {{ .Values.consumers.name }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hermes.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified Management module name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hermes.management.fullname" -}}
{{- if .Values.management.fullnameOverride -}}
{{- .Values.management | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.management.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.management.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified Frontend module name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hermes.frontend.fullname" -}}
{{- if .Values.frontend.fullnameOverride -}}
{{- .Values.frontend | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.frontend.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.frontend.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified Consumers module name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hermes.consumers.fullname" -}}
{{- if .Values.consumers.fullnameOverride -}}
{{- .Values.consumers | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.consumers.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.consumers.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the management component
*/}}
{{- define "hermes.management.serviceAccountName" -}}
{{- if .Values.management.serviceAccount.create -}}
    {{ default (include "hermes.management.fullname" .) .Values.management.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.management.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the frontend component
*/}}
{{- define "hermes.frontend.serviceAccountName" -}}
{{- if .Values.frontend.serviceAccount.create -}}
    {{ default (include "hermes.frontend.fullname" .) .Values.frontend.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.frontend.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the consumers component
*/}}
{{- define "hermes.consumers.serviceAccountName" -}}
{{- if .Values.consumers.serviceAccount.create -}}
    {{ default (include "hermes.consumers.fullname" .) .Values.consumers.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.consumers.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Define kafka URL based on user provided values
*/}}
{{- define "hermes.kafkaBootstrapServers" -}}
{{- if .Values.kafka.enabled }}
{{- include "kafka.fullname" .Subcharts.kafka }}:{{- .Values.kafka.service.port }}
{{- else -}}
{{- required "Enable Kafka or provide global values for bootstrap servers." (include "hermes.globalKafkaBootstrapServers" . | trim) }}
{{- end }}
{{- end }}

{{- define "hermes.globalKafkaBootstrapServers" -}}
{{- if .Values.global.kafka.bootstrapServers }}
{{- tpl (join "," .Values.global.kafka.bootstrapServers) . }}
{{- else }}
{{- if .Values.global.kafka.fullname }}
{{- .Values.global.kafka.fullname | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- if .Values.global.kafka.name }}
{{- $name := .Values.global.kafka.name }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}
{{- if .Values.global.kafka.port }}
{{- printf ":%v" .Values.global.kafka.port }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Define zookeper URL based on user provided values
*/}}
{{- define "hermes.zookeeperConnectString" -}}
{{- if and .Values.kafka.enabled (index (.Values.kafka.zookeeper | default dict) "enabled") }}
{{- include "kafka.zookeeper.fullname" .Subcharts.kafka }}:{{- .Values.kafka.zookeeper.service.port }}
{{- else -}}
{{- required "Enable Zookeeper in the Kafka subchart or provide global values for a connection string." (include "hermes.globalZookeeperConnectString" . | trim) }}
{{- end }}
{{- end }}

{{- define "hermes.globalZookeeperConnectString" -}}
{{- if .Values.global.zookeeper.servers }}
{{- tpl (join "," .Values.global.zookeeper.servers) . }}
{{- else }}
{{- if .Values.global.zookeeper.fullname }}
{{- .Values.global.zookeeper.fullname | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- if .Values.global.zookeeper.name }}
{{- $name := .Values.global.zookeeper.name }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}
{{- if .Values.global.zookeeper.port }}
{{- printf ":%v" .Values.global.zookeeper.port }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Define schema registry URL based on user provided values
*/}}
{{- define "hermes.schemaRegistryUrl" -}}
{{- if index .Values "apicurio-registry" "enabled" -}}
http://{{ include "apicurio-registry.fullname" ( index .Subcharts "apicurio-registry" ) }}:{{ index .Values "apicurio-registry" "service" "port" }}/apis/ccompat/v6/
{{- else -}}
{{- required "Enable apicurio-registry or provide global values for a scheme registry url." (include "hermes.globalSchemaRegistryUrl" . | trim) }}
{{- end -}}
{{- end -}}

{{- define "hermes.globalSchemaRegistryUrl" -}}
{{- if .Values.global.schemaRegistry.url }}
{{- .Values.global.schemaRegistry.url }}
{{- else }}
{{- if .Values.global.schemaRegistry.fullname }}
{{- .Values.global.schemaRegistry.fullname | trunc 63 | trimSuffix "-" | printf "http://%s" }}
{{- else }}
{{- if .Values.global.schemaRegistry.name }}
{{- $name := .Values.global.schemaRegistry.name }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" | printf "http://%s" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" | printf "http://%s" }}
{{- end }}
{{- end }}
{{- end }}
{{- if .Values.global.schemaRegistry.port }}
{{- printf ":%d" .Values.global.schemaRegistry.port }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Define zookeeper storage path based on namespace
*/}}
{{- define "hermes.zookeeperRoot" -}}
{{- if .Values.kafkaNamespace -}}
    /hermes-{{ tpl .Values.kafkaNamespace . }}
{{- else -}}
    /hermes
{{- end -}}
{{- end -}}

{{/*
Define fully qualified domain name for Management module
*/}}
{{- define "hermes.management.fqdn" -}}
{{- $domain := required "Disable ingress for management or provide a domain name (management.ingress.domain)" .Values.management.ingress.domain -}}
{{- $fullName := default (include "hermes.management.fullname" .) .Values.management.ingress.host -}}
{{- printf "%s.%s" $fullName $domain -}}
{{- end -}}

{{/*
Define service port for Management module
*/}}
{{- define "hermes.management.svcPort" -}}
{{- .Values.management.service.port -}}
{{- end -}}

{{/*
Define service external url for Management module
*/}}
{{- define "hermes.management.svcExternalUrl" -}}
https://{{- include "hermes.management.fqdn" . -}}
{{- end -}}