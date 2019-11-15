{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "dynamic-gateway-service.name" -}}
{{- if ne (.Values.datapower.apicGatewayServiceV5CompatibilityMode | default "on") "off" -}}
v5c-gateway-service
{{- else -}}
api-gateway-service
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dynamic-gateway-service.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default (include "dynamic-gateway-service.name" .) .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{ .Release.Name }}-{{ template "dynamic-gateway-service.name" . }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "dynamic-gateway-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Determine whether a valid DataPower license version is set
*/}}
{{- define "datapower-requirements.validLicenseVersion" -}}
{{ $licenseVersion := quote .Values.datapower.licenseVersion }}
{{- if and .Values.datapower.licenseVersion (or (eq $licenseVersion ("Production" | quote)) (eq $licenseVersion ("Nonproduction" | quote)) (eq $licenseVersion ("Developers" | quote))) -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Determine whether the DataPower Monitor image has been set
*/}}
{{- define "datapower-requirements.dpmImageSet" -}}
{{- if and .Values.datapowerMonitor.image.repository .Values.datapowerMonitor.image.tag -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Determine whether the high-performance peering option has been set to "on" or "off"
*/}}
{{- define "datapower-requirements.hpPeeringOptionSet" -}}
{{- $v5cMode := quote .Values.datapower.apicGatewayServiceV5CompatibilityMode -}}
{{- $hpPeeringOption := quote .Values.datapower.env.highPerformancePeering -}}
{{- if or (ne $v5cMode ("off" | quote)) (eq $hpPeeringOption ("on" | quote)) (eq $hpPeeringOption ("off" | quote)) -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Determine whether conditions for DataPower pods have been satisfied
*/}}
{{- define "datapower-requirements.satisfied" -}}
{{- if and (eq (include "datapower-requirements.validLicenseVersion" .) "true") (eq (include "datapower-requirements.hpPeeringOptionSet" .) "true") (eq (include "datapower-requirements.dpmImageSet" .) "true") -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}
