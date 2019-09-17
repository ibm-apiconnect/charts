{{- define "odTracing.collector.host-port" -}}
{{- printf "%s:%s" "localhost" "14267" }}
{{- end -}}

{{- define "odTracing.collector.grpc-host-port" -}}
{{- printf "%s:%s" "localhost" "14250" }}
{{- end -}}

{{- define "odTracing.collector.elasticsearch-secret-name" -}}
{{- printf "%s" "icp4i-od-store-cred"  }}
{{- end -}}

{{- define "odTracing.collector.elasticsearch-url" -}}
{{- printf "%s%s:%s" "https://" .Values.odTracing.odTracingDataHostname "9200" }}
{{- end -}}

{{- define "icp4i-od.manager.registration-host" -}}
{{- printf "%s" .Values.odTracing.odTracingRegistrationHostname }}
{{- end -}}


