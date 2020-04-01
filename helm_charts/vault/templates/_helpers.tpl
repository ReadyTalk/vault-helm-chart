{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "vault.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "vault.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "vault.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Compute the maximum number of unavailable Vault replicas for the PodDisruptionBudget.
This defaults to (n/2)-1 where n is the number of members of the server cluster.
Special case of replica equaling 3 and allowing a minor disruption of 1 otherwise
use the integer value
Add a special case for replicas=1, where it should default to 0 as well.
*/}}
{{- define "vault.pdb.maxUnavailable" -}}
{{- if eq (int .Values.Vault.Replicas) 1 -}}
{{ 0 }}
{{- else if .Values.Vault.maxUnavailable -}}
{{ .Values.Vault.maxUnavailable -}}
{{- else -}}
{{- if eq (int .Values.Vault.Replicas) 3 -}}
{{- 1 -}}
{{- else -}}
{{- sub (div (int .Values.Vault.Replicas) 2) 1 -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Compute the maximum number of unavailable Consul replicas for the PodDisruptionBudget.
This defaults to (n/2)-1 where n is the number of members of the server cluster.
Special case of replica equaling 3 and allowing a minor disruption of 1 otherwise
use the integer value
Add a special case for replicas=1, where it should default to 0 as well.
*/}}
{{- define "consul.pdb.maxUnavailable" -}}
{{- if eq (int .Values.Consul.Replicas) 1 -}}
{{ 0 }}
{{- else if .Values.Consul.maxUnavailable -}}
{{ .Values.Consul.maxUnavailable -}}
{{- else -}}
{{- if eq (int .Values.Consul.Replicas) 3 -}}
{{- 1 -}}
{{- else -}}
{{- sub (div (int .Values.Consul.Replicas) 2) 1 -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified cert-reload name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "vault.certReloader.fullname" -}}
{{- printf "%s-%s" (include "vault.fullname" .) .Values.Vault.Tls.CertManager.certReloader.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified preinstall name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "vault.preinstall.fullname" -}}
{{- printf "%s-%s" (include "vault.fullname" .) "preinstall" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
