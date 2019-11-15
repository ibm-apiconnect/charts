/********************************************************* {COPYRIGHT-TOP} ***
 Licensed Materials - Property of IBM
 5725-Z22, 5725-Z63, 5725-U33 *
 (C) Copyright IBM Corporation 2018 *
 All Rights Reserved.
 US Government Users Restricted Rights - Use, duplication or disclosure
 restricted by GSA ADP Schedule Contract with IBM Corp.
 ********************************************************** {COPYRIGHT-END} **/

'use strict';

const util = require('util');
const fs = require('fs');

const HOSTNAME                         = process.env.HOSTNAME;
const APICONNECT_DATAPOWER_DOMAIN      = process.env.APICONNECT_DATAPOWER_DOMAIN || 'apiconnect';
const APICONNECT_K8S_NAMESPACE         = process.env.APICONNECT_K8S_NAMESPACE || 'default';
const DATAPOWER_SYSLOG_TCP_STATE       = process.env.DATAPOWER_SYSLOG_TCP_STATE;
const DATAPOWER_SYSLOG_TCP_REMOTE_HOST = process.env.DATAPOWER_SYSLOG_TCP_REMOTE_HOST;
const DATAPOWER_SYSLOG_TCP_REMOTE_PORT = process.env.DATAPOWER_SYSLOG_TCP_REMOTE_PORT;
const DATAPOWER_SYSLOG_TCP_TLS_SECRET  = process.env.DATAPOWER_SYSLOG_TCP_TLS_SECRET;

const writeFile = util.promisify(fs.writeFile);

const log = (...args) => {
  console.log(`${(new Date()).toUTCString()}:`, ...args);
}

const generateSyslogConfig = cfg => `top; co
%if% available "logging target"
logging target ${cfg.name}
  admin-state enabled
  type syslog-tcp
  priority normal
  format text
  timestamp zulu
  no fixed-format 
  local-ident "${cfg.localIdent}"
  no ansi-color 
  remote-address "${cfg.remoteHost}" "${cfg.remotePort}"
  local-address eth0_ipv4_1
  facility user
  rate-limit 100
  connect-timeout 60
  idle-timeout 15
  active-timeout 0
  no feedback-detection 
  no event-detection 
  suppression-period 10
  ${cfg.enableSSL === true ? `
  ssl-client syslog_ssl_client 
  ssl-client-type client
  ` : ''}
  retry-interval 1
  retry-attempts 1
  long-retry-interval 20
  precision microsecond
  event apic-gw-service debug
  event mgmt debug
exit
%endif%`.replace(/\n\s*\n/g, '\n');


(async () => {

  if (DATAPOWER_SYSLOG_TCP_STATE !== 'enabled') {
    return;
  }

  try {

    let syslogConfig = generateSyslogConfig({
      name: 'syslog_tcp',

      // e.g., prod-domain/r6bd958b99b-dynamic-gateway-service-0_1566392200993
      localIdent: `${APICONNECT_K8S_NAMESPACE}/${HOSTNAME}_${Date.now()}`,

      remoteHost: DATAPOWER_SYSLOG_TCP_REMOTE_HOST,
      remotePort: DATAPOWER_SYSLOG_TCP_REMOTE_PORT,
      enableSSL: typeof DATAPOWER_SYSLOG_TCP_TLS_SECRET === 'string' && DATAPOWER_SYSLOG_TCP_TLS_SECRET !== ''
    });

    let syslogConfigPath = `/opt/ibm/datapower/drouter/config/${APICONNECT_DATAPOWER_DOMAIN}/syslog.cfg`;
    await writeFile(syslogConfigPath, syslogConfig);
    log(`Generated ${syslogConfigPath}:\n${syslogConfig}`);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
})();
