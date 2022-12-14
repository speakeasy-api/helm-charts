{{/*
Expand the name of the chart.
*/}}
{{- define "speakeasy-registry.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Speakeasy registry server version.
*/}}
{{- define "speakeasy-registry.server-version" -}}
{{- default .Chart.AppVersion .Values.registry.image.tag | trunc 50 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "speakeasy-registry.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.fullnameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "speakeasy-registry.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "speakeasy-registry.labels" -}}
helm.sh/chart: {{ include "speakeasy-registry.chart" . }}
{{ include "speakeasy-registry.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Datadog labels
*/}}
{{- define "speakeasy-registry.datadog-labels" -}}
tags.datadoghq.com/env: {{ .env }}
tags.datadoghq.com/service: {{ .service }}
tags.datadoghq.com/version: {{ .version }}
{{- end}}

{{/*
Selector labels
*/}}
{{- define "speakeasy-registry.selectorLabels" -}}
app.kubernetes.io/name: {{ include "speakeasy-registry.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
