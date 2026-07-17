{{/*
Base name for the chart's resources. Equivalent to var.service_name in the
original Terraform module — this chart is meant to be installed once per
service, so serviceName is required rather than derived from Release.Name.
*/}}
{{- define "common-service-chart.name" -}}
{{- required "serviceName is required" .Values.serviceName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Fully qualified name used for the Deployment/HPA/Ingress. Matches the
original module's Deployment name (plain var.service_name, no suffix).
*/}}
{{- define "common-service-chart.fullname" -}}
{{- include "common-service-chart.name" . -}}
{{- end -}}

{{/*
Service resource name: "${serviceName}${serviceSuffix}", matching the
original main.tf naming ("${var.service_name}${var.service_suffix}").
*/}}
{{- define "common-service-chart.serviceName" -}}
{{- printf "%s%s" (include "common-service-chart.name" .) .Values.serviceSuffix | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Selector labels. Must stay stable across releases — used in both the
Service selector and the Deployment's spec.selector/template labels.
*/}}
{{- define "common-service-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "common-service-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Common labels applied to every resource. Replaces the original module's
service.codegen.co.uk/name + service.codegen.co.uk/version labels with the
standard app.kubernetes.io/* set, so ArgoCD and other standard tooling
recognize ownership out of the box. Any extra labels from .Values.labels are
merged in last so callers can override.
*/}}
{{- define "common-service-chart.labels" -}}
{{ include "common-service-chart.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.serviceVersion | default .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- with .Values.labels }}
{{ toYaml . }}
{{- end }}
{{- end -}}
