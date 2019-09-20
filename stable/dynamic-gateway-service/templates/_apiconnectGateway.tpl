{{/* DataPower Configuration for the APIConnect Gateway  */}}
{{- define "defaultDomainConfig" }}
auto-startup.cfg: |
    top; configure terminal;

{{- if .Values.datapower.adminUserSecret }}
    %if% available "include-config"

    include-config "auto-user-cfg"
      config-url "config:///auto-user.cfg"
      auto-execute
      no interface-detection
    exit

    exec "config:///auto-user.cfg"

    %endif%
{{- end }}

{{- if .Values.datapower.gatewaySshState }}
{{- if eq .Values.datapower.gatewaySshState "enabled" }}
    ssh {{ .Values.datapower.gatewaySshLocalAddress }} {{ .Values.datapower.gatewaySshPort }}
{{- end }}
{{- end }}

    xml-mgmt
      admin-state enabled
      local-address {{ .Values.datapower.xmlManagementLocalAddress }} {{ .Values.datapower.xmlManagementLocalPort }}
      ssl-config-type server
    exit

{{- if or (eq (.Values.datapower.restManagementState | default "disabled") "enabled") (eq (.Values.datapower.apiDebugProbe | default "disabled") "enabled") }}
{{  if eq (.Values.datapower.restManagementState | default "disabled") "enabled" }}
    # REST Management explicitly enabled
{{  else }}
    # REST Management implicitly enabled because an API Debug Probe is enabled
{{- end }}
    rest-mgmt
      admin-state enabled
      local-address {{ .Values.datapower.restManagementLocalAddress }}
      port {{ .Values.datapower.restManagementPort }}
      ssl-config-type server
    exit
{{- end }}

{{- if .Values.datapower.webGuiManagementState }}
{{- if eq .Values.datapower.webGuiManagementState "enabled" }}
    web-mgmt
      admin-state {{ .Values.datapower.webGuiManagementState }}
      local-address {{ .Values.datapower.webGuiManagementLocalAddress }}
      port {{ .Values.datapower.webGuiManagementPort }}
      save-config-overwrite
      idle-timeout 9000
      ssl-config-type server
    exit
{{- end }}
{{- end }}

    %if% available "timezone"
      timezone "UTC"
    %endif%

{{- if .Values.datapower.snmpState }}
{{- if eq .Values.datapower.snmpState "enabled" }}
    %if% available "snmp"
    snmp
      admin-state {{ .Values.datapower.snmpState }}
      version 2c
      ip-address {{ .Values.datapower.snmpLocalAddress }}
      port {{ .Values.datapower.snmpPort }}
      community public default read-only 0.0.0.0/0
      trap-default-subscriptions
      trap-priority warn
      trap-code 0x00030002
      trap-code 0x00230003
      trap-code 0x00330002
      trap-code 0x00b30014
      trap-code 0x00e30001
      trap-code 0x00e40008
      trap-code 0x00f30008
      trap-code 0x01530001
      trap-code 0x01a2000e
      trap-code 0x01a40001
      trap-code 0x01a40005
      trap-code 0x01a40008
      trap-code 0x01b10006
      trap-code 0x01b10009
      trap-code 0x01b20002
      trap-code 0x01b20004
      trap-code 0x01b20008
      trap-code 0x02220001
      trap-code 0x02220003
      trap-code 0x02240002
    exit
    %endif%
{{- end }}
{{- end }}

{{- if eq (.Values.datapower.env.enableTMS | default "off") "on" }}
    raid-volume raid0
      admin-state enabled
      directory tms
    exit

{{- if ne (.Values.datapower.apicGatewayServiceV5CompatibilityMode | default "on") "off" }}
{{- if ne (.Values.datapower.env.tmsPeeringEnableSSL | default "on") "off" }}
    crypto
      key tms_key cert:///apiconnect/gwd/peering_key.pem
    exit

    crypto
      certificate tms_cert cert:///apiconnect/gwd/peering_cert.pem
    exit
{{- end }}

    %if% available "include-config"

    include-config "tms-peering-apic"
      config-url "config:///tms-peering.cfg"
      auto-execute
      no interface-detection
    exit

    exec "config:///tms-peering.cfg"

    %endif%
{{- end }}
{{- end }}

    domain apiconnect
      visible-domain default
    exit


    failure-notification
      admin-state "enabled"
      no upload-report
      no use-smtp
      internal-state
      no ffdc packet-capture
      no ffdc event-log
      no ffdc memory-trace
      no always-on-startup
      always-on-shutdown
      protocol ftp
      report-history 5
    exit

    %if% isfile temporary:///backtrace
    save error-report
    %endif%

auto-user.cfg: |
    top; configure terminal;

{{- end }}
{{- define "apiconnectDomainConfig" }}
apiconnect.cfg: |
    top; configure terminal;

{{/*
  Enable statistics if either of the following is true:
  - apicGatewayServiceV5CompatibilityMode is defined and set to anything other than 'off'
  - apicGatewayServiceV5CompatibilityMode is not defined
*/}}
{{- if .Values.datapower.apicGatewayServiceV5CompatibilityMode }}
{{- if ne .Values.datapower.apicGatewayServiceV5CompatibilityMode "off" }}
    statistics;
{{- end }}
{{- else }}
    statistics;
{{- end }}

    logging target gwd-log
      type file
      format text
      timestamp zulu
      size 50000
      local-file logtemp:///gwd-log.log
      event apic-gw-service debug
      event mgmt debug
    exit

    crypto
    key gwd_key cert:///gwd/gwd_key.pem
    exit

    crypto
    certificate gwd_cert cert:///gwd/gwd_cert.pem
    exit

    crypto
    certificate gwd_ca cert:///gwd/gwd_ca.pem
    exit

    crypto
    key peering_key cert:///gwd/peering_key.pem
    exit

    crypto
    certificate peering_cert cert:///gwd/peering_cert.pem
    exit

    crypto
    idcred gwd_id_cred gwd_key gwd_cert ca gwd_ca
    exit

{{- if .Values.datapower.apimVeloxCertsSecret }}
    crypto
    certificate apim_public_cert cert:///apim/apim_client_public.cert.pem
    exit

    crypto
    certificate apim_ca cert:///apim/cacert.pem
    exit

    crypto
    valcred apim_valcred
      admin-state enabled
      certificate apim_public_cert
      certificate apim_ca
    exit
    exit
{{- end}}

    crypto
    ssl-client gwd_client
      reset
      protocols TLSv1d2
      ciphers ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
      ciphers ECDHE_RSA_WITH_AES_256_GCM_SHA384
      ciphers ECDHE_ECDSA_WITH_AES_256_CBC_SHA384
      ciphers ECDHE_RSA_WITH_AES_256_CBC_SHA384
      ciphers ECDHE_ECDSA_WITH_AES_256_CBC_SHA
      ciphers ECDHE_RSA_WITH_AES_256_CBC_SHA
      ciphers DHE_DSS_WITH_AES_256_GCM_SHA384
      ciphers DHE_RSA_WITH_AES_256_GCM_SHA384
      ciphers DHE_RSA_WITH_AES_256_CBC_SHA256
      ciphers DHE_DSS_WITH_AES_256_CBC_SHA256
      ciphers DHE_RSA_WITH_AES_256_CBC_SHA
      ciphers DHE_DSS_WITH_AES_256_CBC_SHA
      ciphers RSA_WITH_AES_256_GCM_SHA384
      ciphers RSA_WITH_AES_256_CBC_SHA256
      ciphers RSA_WITH_AES_256_CBC_SHA
      ciphers ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
      ciphers ECDHE_RSA_WITH_AES_128_GCM_SHA256
      ciphers ECDHE_ECDSA_WITH_AES_128_CBC_SHA256
      ciphers ECDHE_RSA_WITH_AES_128_CBC_SHA256
      ciphers ECDHE_ECDSA_WITH_AES_128_CBC_SHA
      ciphers ECDHE_RSA_WITH_AES_128_CBC_SHA
      ciphers DHE_DSS_WITH_AES_128_GCM_SHA256
      ciphers DHE_RSA_WITH_AES_128_GCM_SHA256
      ciphers DHE_RSA_WITH_AES_128_CBC_SHA256
      ciphers DHE_DSS_WITH_AES_128_CBC_SHA256
      ciphers DHE_RSA_WITH_AES_128_CBC_SHA
      ciphers DHE_DSS_WITH_AES_128_CBC_SHA
      ciphers RSA_WITH_AES_128_GCM_SHA256
      ciphers RSA_WITH_AES_128_CBC_SHA256
      ciphers RSA_WITH_AES_128_CBC_SHA
      ciphers ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA
      ciphers ECDHE_RSA_WITH_3DES_EDE_CBC_SHA
      ciphers DHE_RSA_WITH_3DES_EDE_CBC_SHA
      ciphers DHE_DSS_WITH_3DES_EDE_CBC_SHA
      ciphers RSA_WITH_3DES_EDE_CBC_SHA
      idcred gwd_id_cred
{{- if .Values.datapower.apimVeloxCertsSecret }}
      valcred apim_valcred
      validate-server-cert
{{ else }}
      no validate-server-cert
{{- end }}
      caching
      cache-timeout 300
      cache-size 100
      ssl-client-features use-sni
      curves secp521r1
      curves secp384r1
      curves secp256k1
      curves secp256r1
      use-custom-sni-hostname no
    exit
    exit

    crypto
    ssl-server gwd_server
      reset
      protocols TLSv1d2
      ciphers ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
      ciphers ECDHE_RSA_WITH_AES_256_GCM_SHA384
      ciphers ECDHE_ECDSA_WITH_AES_256_CBC_SHA384
      ciphers ECDHE_RSA_WITH_AES_256_CBC_SHA384
      ciphers ECDHE_ECDSA_WITH_AES_256_CBC_SHA
      ciphers ECDHE_RSA_WITH_AES_256_CBC_SHA
      ciphers DHE_DSS_WITH_AES_256_GCM_SHA384
      ciphers DHE_RSA_WITH_AES_256_GCM_SHA384
      ciphers DHE_RSA_WITH_AES_256_CBC_SHA256
      ciphers DHE_DSS_WITH_AES_256_CBC_SHA256
      ciphers DHE_RSA_WITH_AES_256_CBC_SHA
      ciphers DHE_DSS_WITH_AES_256_CBC_SHA
      ciphers RSA_WITH_AES_256_GCM_SHA384
      ciphers RSA_WITH_AES_256_CBC_SHA256
      ciphers RSA_WITH_AES_256_CBC_SHA
      ciphers ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
      ciphers ECDHE_RSA_WITH_AES_128_GCM_SHA256
      ciphers ECDHE_ECDSA_WITH_AES_128_CBC_SHA256
      ciphers ECDHE_RSA_WITH_AES_128_CBC_SHA256
      ciphers ECDHE_ECDSA_WITH_AES_128_CBC_SHA
      ciphers ECDHE_RSA_WITH_AES_128_CBC_SHA
      ciphers DHE_DSS_WITH_AES_128_GCM_SHA256
      ciphers DHE_RSA_WITH_AES_128_GCM_SHA256
      ciphers DHE_RSA_WITH_AES_128_CBC_SHA256
      ciphers DHE_DSS_WITH_AES_128_CBC_SHA256
      ciphers DHE_RSA_WITH_AES_128_CBC_SHA
      ciphers DHE_DSS_WITH_AES_128_CBC_SHA
      ciphers RSA_WITH_AES_128_GCM_SHA256
      ciphers RSA_WITH_AES_128_CBC_SHA256
      ciphers RSA_WITH_AES_128_CBC_SHA
      ciphers ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA
      ciphers ECDHE_RSA_WITH_3DES_EDE_CBC_SHA
      ciphers DHE_RSA_WITH_3DES_EDE_CBC_SHA
      ciphers DHE_DSS_WITH_3DES_EDE_CBC_SHA
      ciphers RSA_WITH_3DES_EDE_CBC_SHA
      idcred gwd_id_cred
{{- if .Values.datapower.apimVeloxCertsSecret }}
      valcred apim_valcred
      request-client-auth
      require-client-auth
      validate-client-cert
{{ else }}
      no request-client-auth
      no require-client-auth
      no validate-client-cert
{{- end }}
      send-client-auth-ca-list
      caching on
      cache-timeout 300
      cache-size 20
      ssl-options "max-renegotiation"
      max-duration 60
      max-renegotiation-allowed 0
      prohibit-resume-on-reneg off
      compression off
      allow-legacy-renegotiation off
      prefer-server-ciphers on
      curves secp521r1
      curves secp384r1
      curves secp256k1
    exit
    exit

{{- if and (eq (.Values.datapower.apicGatewayServiceV5CompatibilityMode | default "on") "off") (eq (.Values.datapower.env.highPerformancePeering | default "") "on") }}
    crypto
      key rate_limit_key cert:///gwd/peering_key.pem
    exit

    crypto
      certificate rate_limit_cert cert:///gwd/peering_cert.pem
    exit

    crypto
      key subs_key cert:///gwd/peering_key.pem
    exit

    crypto
      certificate subs_cert cert:///gwd/peering_cert.pem
    exit
{{- end }}


    %if% available "include-config"

    include-config "gateway-peering-apic"
      config-url "config:///gateway-peering.cfg"
      auto-execute
      no interface-detection
    exit

    exec "config:///gateway-peering.cfg"

    %endif%

    apic-gw-service
{{/* Enforce valid values for apicGatewayServiceV5CompatibilityMode as 'on' and 'off' (default: 'on') */}}
{{- if .Values.datapower.apicGatewayServiceV5CompatibilityMode }}
{{- if eq .Values.datapower.apicGatewayServiceV5CompatibilityMode "off" }}
      v5-compatibility-mode off
{{- else }}
      v5-compatibility-mode on
{{- end }}
{{- else }}
      v5-compatibility-mode on
{{- end }}
{{- if .Values.datapower.customDatapowerConfig }}
      admin-state disabled
{{- else }}
      admin-state enabled
{{- end }}
      ssl-client gwd_client
      ssl-server gwd_server
      local-address {{ .Values.datapower.apicGatewayServiceLocalAddress }}
      local-port {{ .Values.datapower.apicGatewayServiceLocalPort }}
      api-gw-address {{ .Values.datapower.apiGatewayLocalAddress }}
      api-gw-port {{ .Values.datapower.apiGatewayLocalPort }}
      gateway-peering gwd
    exit

{{- if eq (.Values.datapower.env.enableTMS | default "off") "on" }}
{{- if eq (.Values.datapower.apicGatewayServiceV5CompatibilityMode | default "on") "off" }}
{{- if ne (.Values.datapower.env.tmsPeeringEnableSSL | default "on") "off" }}
    crypto
      key tms_key cert:///gwd/peering_key.pem
    exit

    crypto
      certificate tms_cert cert:///gwd/peering_cert.pem
    exit
{{- end }}

    %if% available "include-config"

    include-config "tms-peering-apic"
      config-url "config:///tms-peering.cfg"
      auto-execute
      no interface-detection
    exit

    exec "config:///tms-peering.cfg"

    %endif%

    api-security-token-manager
      admin-state enabled
      gateway-peering tms
    exit
{{- end }}
{{- end }}

{{- if eq (.Values.datapower.apiDebugProbe | default "disabled") "enabled" }}
{{- if ne (.Values.datapower.env.apiDebugProbePeeringEnableSSL | default "on") "off" }}
    crypto
      key api_probe_key cert:///gwd/peering_key.pem
    exit

    crypto
      certificate api_probe_cert cert:///gwd/peering_cert.pem
    exit
{{- end }}

    %if% available "include-config"

    include-config "api-probe-peering-apic"
      config-url "config:///api-probe-peering.cfg"
      auto-execute
      no interface-detection
    exit

    exec "config:///api-probe-peering.cfg"

    %endif%

    api-debugprobe
      admin-state enabled
      max-records {{ .Values.datapower.apiDebugProbeMaxRecords }}
      expiration {{ .Values.datapower.apiDebugProbeExpiration }}
      gateway-peering api-probe
    exit
{{- end }}

{{- if .Values.datapower.apicGatewayServiceV5CompatibilityMode }}
{{- if eq .Values.datapower.apicGatewayServiceV5CompatibilityMode "off" }}
    config-sequence "apiconnect"
      location "local:///"
      watch "on"
      delete-unused "on"
      match "(.*)\.cfg$"
      summary "API Connect configuration"
      run-sequence-interval {{ .Values.datapower.configSequenceInterval | default 3000 }}
      optimize-for-apic on
    exit
{{- end }}
{{- end }}
{{- if .Values.datapower.customDatapowerConfig }}

    %if% available "include-config"

    include-config "custom-config-cfg"
      config-url "config:///custom-config.cfg"
      auto-execute
      no interface-detection
    exit

    exec "config:///custom-config.cfg"

    %endif%

    apic-gw-service
      admin-state enabled
    exit
{{- end }}
{{- end }}
