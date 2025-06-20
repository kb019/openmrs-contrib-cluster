{{/*
Expand the name of the chart.
*/}}
{{- define "openmrs-backend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "openmrs-backend.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
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
{{- define "openmrs-backend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "openmrs-backend.labels" -}}
helm.sh/chart: {{ include "openmrs-backend.chart" . }}
{{ include "openmrs-backend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "openmrs-backend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "openmrs-backend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "openmrs-backend.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "openmrs-backend.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "infinispan-chart.name" -}}
{{- default .Release.Name .Values.infinispan.deploy.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "openmrs.default.serverOptions" -}}
{{- .Values.defaultOmrsServerOpts }}
{{- end }}

{{- define "infinispan.cache.jgroups.dnsQuery" -}}
{{- printf "%s-ping.%s.svc.%s" (include "infinispan-chart.name" .) .Release.Namespace .Values.infinispan.deploy.clusterDomain }}
{{- end }}

{{- define "infinispan.cache.jgroups_cfg" -}}
{{- .Values.infinispan.jgroups_cfg }}
{{- end }}


{{- define "infinispan.cache.args" }}
{{- printf "-Djgroups.dns.query=%s -Dhibernate.cache.infinispan.jgroups_cfg=%s -Dcache.type=%s" (include "infinispan.cache.jgroups.dnsQuery" .) (include "infinispan.cache.jgroups_cfg" .) "cluster" }}
{{- end }}

{{- define "openmrs.serverOptions" -}}
{{- printf "%s %s" (include "openmrs.default.serverOptions" .) (include "infinispan.cache.args" .) }}
{{- end }}
