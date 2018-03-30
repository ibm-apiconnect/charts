{{/* DataPower Configuration for the APIConnect Gatway  */}}
{{- define "defaultDomainConfig" }}
auto-startup.cfg: |
    top; configure terminal;

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

{{- if .Values.datapower.restManagementState }}
{{- if eq .Values.datapower.restManagementState "enabled" }}
    rest-mgmt
      admin-state {{ .Values.datapower.restManagementState }}
      local-address {{ .Values.datapower.restManagementLocalAddress }} 
      port {{ .Values.datapower.restManagementPort }}
      ssl-config-type server
    exit
{{- end }}
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

    domain apiconnect
      visible-domain default
    exit

auto-user.cfg: |
    top; configure terminal;

    %if% available "user"

    user "admin"
      summary "Administrator"
      password-hashed "$1$12345678$kbapHduhihjieYIUP66Xt/"
      access-level privileged
    exit

    %endif%
{{- end }}
{{- define "apiconnectDomainConfig" }}
apiconnect.cfg: |
    top; configure terminal;

    statistics;

    logging target gwd-log
      type file
      format text
      timestamp syslog
      size 50000
      local-file logtemp:///gwd-log.log
      event apic-gw-service debug
    exit

    crypto
    key gwd_key cert:///gwd_key.pem
    exit
    
    crypto
    certificate gwd_cert cert:///gwd_cert.pem
    exit

    crypto
    certificate gwd_ca cert:///gwd_ca.pem
    exit
    
    crypto
    key peering_key cert:///peering_key.pem
    exit

    crypto
    certificate peering_cert cert:///peering_cert.pem
    exit

    crypto
    idcred gwd_id_cred gwd_key gwd_cert ca gwd_ca
    exit

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
      no validate-server-cert
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
      no request-client-auth
      no require-client-auth
      no validate-client-cert
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
    
    %if% available "include-config"

    include-config "gateway-peering-apic"
      config-url "config:///gateway-peering.cfg"
      auto-execute 
      no interface-detection 
    exit

    exec "config:///gateway-peering.cfg"

    %endif%

    apic-gw-service
      v5-compatibility-mode on
      admin-state enabled
      ssl-client gwd_client
      ssl-server gwd_server
      local-address {{ .Values.datapower.apicGatewayServiceLocalAddress }}
      local-port {{ .Values.datapower.apicGatewayServiceLocalPort }}
      api-gw-address {{ .Values.datapower.apiGatewayLocalAddress }}
      api-gw-port {{ .Values.datapower.apiGatewayLocalPort }}
      gateway-peering gwd
    exit
    
{{- end }}
