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
{{- define "hermes.kafkaUrl" -}}
{{- if .Values.kafka.enabled -}}
    {{ .Release.Name }}-kafka:9092
{{- else -}}
    {{ required "Enable kafka or provide a valid .Values.kafka.url entry!" ( tpl .Values.kafka.url . ) }}
{{- end -}}
{{- end -}}

{{/*
Define zookeper URL based on user provided values
*/}}
{{- define "hermes.zookeeperUrl" -}}
{{- if and .Values.kafka.enabled .Values.kafka.zookeeper.enabled -}}
    {{ .Release.Name }}-zookeeper:2181
{{- else -}}
    {{ required "Enable zookeeper or provide a valid .Values.kafka.zookeeper.url entry!" ( tpl .Values.kafka.zookeeper.url . ) }}
{{- end -}}
{{- end -}}

{{/*
Define schema registry URL based on user provided values
*/}}
{{- define "hermes.schemaRegistryUrl" -}}
{{- if index .Values "schema-registry" "enabled" -}}
    http://{{ .Release.Name }}-schema-registry:8081
{{- else -}}
    {{ required "Enable schema-registry or provide a valid .Values.schema-registry.url entry!" ( tpl ( index .Values "schema-registry" "url" ) . ) }}
{{- end -}}
{{- end -}}

{{/*
Define zookeeper storage path based on namespace
*/}}
{{- define "hermes.zookeeperRoot" -}}
{{- if .Values.kafka.namespace -}}
    /hermes-{{ tpl .Values.kafka.namespace . }}
{{- else -}}
    /hermes
{{- end -}}
{{- end -}}
