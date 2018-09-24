{{/* DataPower Configuration for the APIConnect Gateway  */}}
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

    domain debugDomain
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
      admin-state enabled
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
{{- end }}

{{- define "debugDomainConfig" }}
debugDomain.cfg: |
    top; configure terminal;

    %if% available "domain-settings"

    domain-settings
      admin-state enabled
      password-treatment masked
    exit

    %endif%
    logging event default-log "all" "error"
    logging event default-log "mgmt" "notice"

    user-agent "default"
      summary "Default User Agent"
      max-redirects 8
      timeout 300
    exit

    %if% available "urlmap"

    urlmap "default-attempt-stream-all"
      match "*"
    exit

    %endif%

    %if% available "compile-options"

    compile-options "default-attempt-stream"
      xslt-version XSLT10
      no strict
      try-stream default-attempt-stream-all
      stack-size 524288
      wsi-validate ignore
      wsdl-validate-body strict
      wsdl-validate-headers lax
      wsdl-validate-faults strict
      no wsdl-wrapped-faults
      no wsdl-strict-soap-version
      no xacml-debug
    exit

    %endif%

    %if% available "api-routing"

    api-routing "default-api-route"
    exit

    %endif%

    %if% available "api-rate-limit"

    api-rate-limit "default-api-ratelimit"
    exit

    %endif%

    %if% available "api-security"

    api-security "default-api-security"
    exit

    %endif%

    %if% available "api-context"

    api-context "default-api-context"
    exit

    %endif%

    %if% available "api-execute"

    api-execute "default-api-execute"
    exit

    %endif%

    %if% available "api-result"

    api-result "default-api-result"
      output "OUTPUT"
    exit

    %endif%

    action "loop-back-js_rule_0_gatewayscript_0"
      reset
      type gatewayscript
      input "INPUT"
      parse-settings-result-type none
      transform-language none
      gatewayscript-location "local:///log-msg.js"
      output "OUTPUT"
      named-inouts default
      ssl-client-type proxy
      no transactional
      soap-validation body
      sql-source-type static
      strip-signature
      no asynchronous
      results-mode first-available
      retry-count 0
      retry-interval 1000
      no multiple-outputs
      iterator-type XPATH
      timeout 0
      http-method GET
      http-method-limited POST
      http-method-limited2 POST
    exit

    rule "loop-back-js_rule_0"
      reset
        action "loop-back-js_rule_0_gatewayscript_0"
      type rule
      input-filter none
      output-filter none
      no non-xml-processing
      no unprocessed
    exit

    matching "all"
      urlmatch "*"
      no match-with-pcre
      no combine-with-or
    exit

    stylepolicy "default"
      reset
      summary "Default Processing Policy"
      filter "store:///filter-reject-all.xsl"
      xsldefault "store:///identity.xsl"
      xquerydefault "store:///reject-all-json.xq"
    exit

    stylepolicy "loop-back-js"
      reset
      filter "store:///filter-reject-all.xsl"
      xsldefault "store:///identity.xsl"
      xquerydefault "store:///reject-all-json.xq"
      match "all" "loop-back-js_rule_0"
    exit

    %if% available "metadata"

    metadata "ftp-usercert-metadata"
      meta-item "variable" "dn" "var://context/INPUT/ftp/tls/client-subject-dn"
      meta-item "variable" "issuer" "var://context/INPUT/ftp/tls/client-issuer-dn"
      meta-item "variable" "serial" "var://context/INPUT/ftp/tls/client-serial-number"
    exit

    metadata "ftp-username-metadata"
      meta-item "variable" "dn" "var://context/INPUT/ftp/tls/client-subject-dn"
      meta-item "variable" "issuer" "var://context/INPUT/ftp/tls/client-issuer-dn"
      meta-item "variable" "password" "var://context/INPUT/ftp/password"
      meta-item "variable" "serial" "var://context/INPUT/ftp/tls/client-serial-number"
      meta-item "variable" "username" "var://context/INPUT/ftp/username"
    exit

    metadata "oauth-scope-metadata"
      meta-item "variable" "scope" "var://context/INPUT/oauth/verified-scope"
    exit

    metadata "ssh-password-metadata"
      meta-item "variable" "password" "var://context/INPUT/ssh/password"
      meta-item "variable" "publickey" "var://context/INPUT/ssh/publickey"
      meta-item "variable" "username" "var://context/INPUT/ssh/username"
    exit

    %endif%

    xmlmgr "default"
    xsl cache size "default" "256"
    xsl checksummed cache default
    no tx-warn "default"
    memoization "default"

    xml parser limits "default"
     bytes-scanned 4194304
     element-depth 512
     attribute-count 128
     max-node-size 33554432
     forbid-external-references
     external-references forbid
     max-prefixes 1024
     max-namespaces 1024
     max-local-names 60000
    exit

    documentcache "default"
     no policy
     maxdocs "5000"
     size "0"
     max-writes "32768"
    exit
    no xml validate "default" *

    xml-manager "default"
      summary "Default XML-Manager"
      user-agent "default"
    exit

    xmlmgr "default-attempt-stream"
    xslconfig "default-attempt-stream" "default-attempt-stream"
    xsl cache size "default-attempt-stream" "256"
    xsl checksummed cache default-attempt-stream
    no tx-warn "default-attempt-stream"
    memoization "default-attempt-stream"

    xml parser limits "default-attempt-stream"
     bytes-scanned 268435456
     element-depth 512
     attribute-count 128
     max-node-size 268435456
     forbid-external-references
     external-references forbid
     max-prefixes 1024
     max-namespaces 1024
     max-local-names 60000
    exit

    documentcache "default-attempt-stream"
     no policy
     maxdocs "5000"
     size "0"
     max-writes "32768"
    exit
    no xml validate "default-attempt-stream" *

    xml-manager "default-attempt-stream"
      summary "Default Streaming XML-Manager"
      user-agent "default"
    exit

    xmlmgr "default-wsrr"
    xsl cache size "default-wsrr" "256"
    xsl checksummed cache default-wsrr
    no tx-warn "default-wsrr"
    memoization "default-wsrr"

    xml parser limits "default-wsrr"
     bytes-scanned 4194304
     element-depth 512
     attribute-count 128
     max-node-size 33554432
     forbid-external-references
     external-references forbid
     max-prefixes 1024
     max-namespaces 1024
     max-local-names 60000
    exit

    documentcache "default-wsrr"
     no policy
     maxdocs "5000"
     size "0"
     max-writes "32768"
    exit
    no xml validate "default-wsrr" *

    xml-manager "default-wsrr"
      summary "WSRR XML-Manager"
      user-agent "default"
    exit

    %if% available "source-http"

    source-http "loop-back-js"
      local-address 0.0.0.0
      port 8080
      http-client-version HTTP/1.1
      allowed-features "HTTP-1.0+HTTP-1.1+POST+PUT+QueryString+FragmentIdentifiers"
      persistent-connections
      max-persistent-reuse 0
      no compression
      no websocket-upgrade
      websocket-idle-timeout 0
      max-url-len 16384
      max-total-header-len 128000
      max-header-count 0
      max-header-name-len 0
      max-header-value-len 0
      max-querystring-len 0
      credential-charset protocol
      http2-max-streams 100
      http2-max-frame 16384
      no http2-stream-header
      chunked-encoding
    exit

    %endif%

    %if% available "wsm-stylepolicy"

    wsm-stylepolicy "default"
      summary "Default Processing Policy"
      filter "store:///filter-reject-all.xsl"
      xsldefault "store:///identity.xsl"
    exit

    %endif%

    %if% available "api-client-identification"

    api-client-identification "default-api-client-identification"
    exit

    %endif%

    %if% available "api-cors"

    api-cors "default-api-cors"
    exit

    %endif%

    %if% available "api-rule"

    api-rule "default-api-error-rule"
      action default-api-result
    exit

    api-rule "default-api-rule"
      action default-api-route
      action default-api-cors
      action default-api-client-identification
      action default-api-ratelimit
      action default-api-security
      action default-api-context
      action default-api-execute
      action default-api-result
    exit

    %endif%

    no statistics

    %if% available "control-list"

    control-list "default-accept-all"
      type blacklist
      no case-insensitive
    exit

    control-list "default-reject-all"
      type whitelist
      no case-insensitive
    exit

    %endif%

    crypto

    %if% available "sshdomainclientprofile"

    sshdomainclientprofile
      no ciphers
      no kex-alg
      no mac-alg
      admin-state enabled
      ciphers CHACHA20-POLY1305_AT_OPENSSH.COM
      ciphers AES128-CTR
      ciphers AES192-CTR
      ciphers AES256-CTR
      ciphers AES128-GCM_AT_OPENSSH.COM
      ciphers AES256-GCM_AT_OPENSSH.COM
      ciphers ARCFOUR256
      ciphers ARCFOUR128
      ciphers AES128-CBC
      ciphers 3DES-CBC
      ciphers BLOWFISH-CBC
      ciphers CAST128-CBC
      ciphers AES192-CBC
      ciphers AES256-CBC
      ciphers ARCFOUR
      ciphers RIJNDAEL-CBC_AT_LYSATOR.LIU.SE
      kex-alg CURVE25519-SHA256_AT_LIBSSH.ORG
      kex-alg ECDH-SHA2-NISTP256
      kex-alg ECDH-SHA2-NISTP384
      kex-alg ECDH-SHA2-NISTP521
      kex-alg DIFFIE-HELLMAN-GROUP-EXCHANGE-SHA256
      kex-alg DIFFIE-HELLMAN-GROUP14-SHA1
      mac-alg UMAC-64-ETM_AT_OPENSSH.COM
      mac-alg UMAC-128-ETM_AT_OPENSSH.COM
      mac-alg HMAC-SHA2-256-ETM_AT_OPENSSH.COM
      mac-alg HMAC-SHA2-512-ETM_AT_OPENSSH.COM
      mac-alg HMAC-SHA1-ETM_AT_OPENSSH.COM
      mac-alg UMAC-64_AT_OPENSSH.COM
      mac-alg UMAC-128_AT_OPENSSH.COM
      mac-alg HMAC-SHA2-256
      mac-alg HMAC-SHA2-512
      mac-alg HMAC-SHA1
      enable-legacy-kex no
    exit

    %endif%

    exit

    crypto

    %if% available "sshserverprofile"

    sshserverprofile
      no ciphers
      no kex-alg
      no mac-alg
      admin-state enabled
      ciphers CHACHA20-POLY1305_AT_OPENSSH.COM
      ciphers AES128-CTR
      ciphers AES192-CTR
      ciphers AES256-CTR
      ciphers AES128-GCM_AT_OPENSSH.COM
      ciphers AES256-GCM_AT_OPENSSH.COM
      ciphers ARCFOUR256
      ciphers ARCFOUR128
      ciphers AES128-CBC
      ciphers 3DES-CBC
      ciphers BLOWFISH-CBC
      ciphers CAST128-CBC
      ciphers AES192-CBC
      ciphers AES256-CBC
      ciphers ARCFOUR
      ciphers RIJNDAEL-CBC_AT_LYSATOR.LIU.SE
      kex-alg CURVE25519-SHA256_AT_LIBSSH.ORG
      kex-alg ECDH-SHA2-NISTP256
      kex-alg ECDH-SHA2-NISTP384
      kex-alg ECDH-SHA2-NISTP521
      kex-alg DIFFIE-HELLMAN-GROUP-EXCHANGE-SHA256
      kex-alg DIFFIE-HELLMAN-GROUP14-SHA1
      mac-alg UMAC-64-ETM_AT_OPENSSH.COM
      mac-alg UMAC-128-ETM_AT_OPENSSH.COM
      mac-alg HMAC-SHA2-256-ETM_AT_OPENSSH.COM
      mac-alg HMAC-SHA2-512-ETM_AT_OPENSSH.COM
      mac-alg HMAC-SHA1-ETM_AT_OPENSSH.COM
      mac-alg UMAC-64_AT_OPENSSH.COM
      mac-alg UMAC-128_AT_OPENSSH.COM
      mac-alg HMAC-SHA2-256
      mac-alg HMAC-SHA2-512
      mac-alg HMAC-SHA1
      enable-legacy-kex no
      send-preauth-msg no
    exit

    %endif%

    exit

    %if% available "policy-attachments"

    policy-attachments "loop-back-js"
      enforcement-mode enforce
      policy-references
      sla-enforcement-mode allow-if-no-sla
    exit

    %endif%

    %if% available "mpgw"

    mpgw "loop-back-js"
      no policy-parameters
      priority normal
      front-protocol loop-back-js
      xml-manager default
      ssl-client-type proxy
      default-param-namespace "http://www.datapower.com/param/config"
      query-param-namespace "http://www.datapower.com/param/query"
      propagate-uri
      monitor-processing-policy terminate-at-first-throttle
      request-attachments strip
      response-attachments strip
      no request-attachments-flow-control
      no response-attachments-flow-control
      root-part-not-first-action process-in-order
      front-attachment-format dynamic
      back-attachment-format dynamic
      mime-front-headers
      mime-back-headers
      stream-output-to-back buffer-until-verification
      stream-output-to-front buffer-until-verification
      max-message-size 0
      no gateway-parser-limits
      element-depth 512
      attribute-count 128
      max-node-size 33554432
      forbid-external-references
      external-references forbid
      max-prefixes 1024
      max-namespaces 1024
      max-local-names 60000
      attachment-byte-count 2000000000
      attachment-package-byte-count 0
      debugger-type internal
      debug-history 25
      no flowcontrol
      soap-schema-url "store:///schemas/soap-envelope.xsd"
      front-timeout 120
      back-timeout 120
      front-persistent-timeout 180
      back-persistent-timeout 180
      no include-content-type-encoding
      http-server-version HTTP/1.1
      persistent-connections
      no loop-detection
      host-rewriting
      no chunked-uploads
      process-http-errors
      http-client-ip-label "X-Client-IP"
      http-global-tranID-label "X-Global-Transaction-ID"
      inorder-mode ""
      wsa-mode sync2sync
      wsa-require-aaa
      wsa-strip-headers
      wsa-default-replyto "http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous"
      wsa-default-faultto "http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous"
      no wsa-force
      wsa-genstyle sync
      wsa-http-async-response-code 204
      wsa-timeout 120
      no wsrm
      wsrm-sequence-expiration 3600
      wsrm-destination-accept-create-sequence
      wsrm-destination-maximum-sequences 400
      no wsrm-destination-inorder
      wsrm-destination-maximum-inorder-queue-length 10
      no wsrm-destination-accept-offers
      no wsrm-request-force
      no wsrm-response-force
      no wsrm-source-request-create-sequence
      no wsrm-source-response-create-sequence
      no wsrm-source-make-offer
      no wsrm-source-sequence-ssl
      wsrm-source-maximum-sequences 400
      wsrm-source-retransmission-interval 10
      wsrm-source-exponential-backoff
      wsrm-source-retransmit-count 4
      wsrm-source-maximum-queue-length 30
      wsrm-source-request-ack-count 1
      wsrm-source-inactivity-close-interval 360
      no force-policy-exec
      rewrite-errors
      delay-errors
      delay-errors-duration 1000
      request-type soap
      response-type soap
      follow-redirects
      no rewrite-location-header
      stylepolicy loop-back-js
      type dynamic-backend
      no compression
      no allow-cache-control
      policy-attachments loop-back-js
      no wsmagent-monitor
      wsmagent-monitor-capture-mode all-messages
      no proxy-http-response
      transaction-timeout 0
    exit

    %endif%

    %if% available "domain-availability"

    domain-availability
      admin-state disabled
    exit

    %endif%

    %if% available "nfs-dynamic-mounts"

    nfs-dynamic-mounts
      admin-state disabled
      version 3
      transport tcp
      mount-type hard
      no read-only
      rsize 4096
      wsize 4096
      timeo 7
      retrans 3
      inactivity-timeout 900
      mount-timeout 30
    exit

    %endif%

    %if% available "slm-action"

    slm-action "notify"
      type log-only
      log-priority warn
    exit

    slm-action "shape"
      type shape
      log-priority debug
    exit

    slm-action "throttle"
      type reject
      log-priority debug
    exit

    %endif%

    %if% available "wsm-agent"

    wsm-agent
      admin-state disabled
      max-records 3000
      max-memory 64000
      capture-mode faults
      buffer-mode discard
      no mediation-enforcement-metrics
      max-payload-size 0
      push-interval 100
      push-priority normal
    exit

    %endif%
{{- end }}
