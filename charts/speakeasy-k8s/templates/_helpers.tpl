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

{{- define "speakeasy-plugins.selectorLabels" -}}
app.kubernetes.io/name: {{ include "speakeasy-registry.name" . }}-plugins
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
Registry Env Vars
*/}}
{{- define "speakeasy-registry.registryEnvVars" -}}
- name: BIGQUERY_PROJECT
  value: {{ .Values.bigquery.ProjectID }}
- name: BIGQUERY_DATASET
  value: {{ .Values.bigquery.DatasetID }}
{{- if .Values.registry.svcSecretKey }}
- name: GOOGLE_APPLICATION_CREDENTIALS
  value: "/secrets/{{ .Values.registry.svcSecretKey }}"
{{- end }}
{{- if .Values.registry.cache.redisAddr }}
- name: REDIS_ADDR
  value: {{ .Values.registry.cache.redisAddr }}
{{- end }}
{{- if .Values.registry.cache.redisPassword }}
- name: REDIS_PASSWORD
  value: {{ .Values.registry.cache.redisPassword }}
{{- end }}
- name: POSTGRES_DSN
  value: {{ .Values.postgresql.DSN }}
- name: POSTHOG_API_KEY
  value: phc_PjgvvGVRmAUE4NHxT6pz6VHZ3cmMIM6vM7rkQ04itLf
- name: POSTHOG_ENDPOINT
  value: https://metrics.speakeasyapi.dev
- name: SPEAKEASY_ENVIRONMENT
  value: {{ .Values.env }}
{{- if .Values.auth.SignInURL }}
- name: SIGN_IN_URL
  value: {{ .Values.auth.SignInURL }}
{{- end }}
- name: CLOUD_PROVIDER
  value: {{ .Values.cloud }}
{{- if .Values.auth.GithubClientId }}
- name: GITHUB_CLIENT_ID
  value: {{ .Values.auth.GithubClientId }}
{{- end }}
{{- if .Values.auth.GithubCallbackURL  }}
- name: GITHUB_CALLBACK_URL
  value: {{ .Values.auth.GithubCallbackURL }}
{{- end }}
{{- if .Values.registry.sendGridKey }}
- name: SENDGRID_API_KEY
  valueFrom:
    secretKeyRef:
      name: send-grid-key-secret
      key: sendGridKey
{{- end }}
{{- if .Values.auth.GithubClientSecretName }}
- name: GITHUB_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.auth.GithubClientSecretName }}
      key: {{ .Values.auth.GithubClientSecretKey }}
{{- end }}
- name: JWT_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: jwt-secret-key-secret
      key: jwtSecretKey
{{- if .Values.datadog.enabled }}
- name: DD_ENV
  valueFrom:
    fieldRef:
      apiVersion: v1
      fieldPath: metadata.labels['tags.datadoghq.com/env']
- name: DD_SERVICE
  valueFrom:
    fieldRef:
      apiVersion: v1
      fieldPath: metadata.labels['tags.datadoghq.com/service']
- name: DD_VERSION
  valueFrom:
    fieldRef:
      apiVersion: v1
      fieldPath: metadata.labels['tags.datadoghq.com/version']
{{- end }}
{{- if .Values.portal.enabled }}
- name: "HOST_TO_PORTAL_WORKSPACE_ID"
  value: {{ range $k, $v := .Values.portal.portalAdditionalHosts}}{{if $k }},{{end}}{{$v.host}}={{$v.workspaceId}}{{ end }}
- name: "PORTAL_DOMAIN"
  value: {{ first .Values.portal.portalWildcardDomains | trimPrefix "*" | quote }}
{{- end }}
{{- range $v := .Values.registry.envVars }}
- {{ $v | toYaml | nindent 2 | trim }}
{{- end }}
{{- end }}
