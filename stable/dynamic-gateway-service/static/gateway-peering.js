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
const dns = require('dns');
const fs = require('fs');

const wait = ms => new Promise(resolve => setTimeout(resolve, ms));
const lookup = util.promisify(dns.lookup);
const writeFile = util.promisify(fs.writeFile);

const HOSTNAME                      = process.env.HOSTNAME;
const APICONNECT_K8S_NAMESPACE      = process.env.APICONNECT_K8S_NAMESPACE || 'default';
const APICONNECT_K8S_CLUSTER_DOMAIN = process.env.APICONNECT_K8S_CLUSTER_DOMAIN || 'cluster.local';
const APICONNECT_K8S_PEERS_SVC_PQDN = `${APICONNECT_K8S_NAMESPACE}.svc.${APICONNECT_K8S_CLUSTER_DOMAIN}`;
const APICONNECT_K8S_PEERS_SVC_NAME = process.env.APICONNECT_K8S_PEERS_SVC_NAME || 'datapower';
const APICONNECT_K8S_PEERS_SVC_FQDN = process.env.APICONNECT_K8S_PEERS_SVC_FQDN || `${APICONNECT_K8S_PEERS_SVC_NAME}.${APICONNECT_K8S_PEERS_SVC_PQDN}`;
const APICONNECT_DATAPOWER_DOMAIN   = process.env.APICONNECT_DATAPOWER_DOMAIN || 'apiconnect';
const GATEWAY_PEERING_CONFIG_NAME   = process.env.GATEWAY_PEERING_CONFIG_NAME || 'gwd';
const GATEWAY_PEERING_LOCAL_ADDRESS = process.env.GATEWAY_PEERING_LOCAL_ADDRESS || 'eth0_ipv4_1';
const GATEWAY_PEERING_LOCAL_PORT    = process.env.GATEWAY_PEERING_LOCAL_PORT || '15380';
const GATEWAY_PEERING_MONITOR_PORT  = process.env.GATEWAY_PEERING_MONITOR_PORT || '25380';
const GATEWAY_PEERING_ENABLE_SSL    = process.env.GATEWAY_PEERING_ENABLE_SSL !== 'off';
const GATEWAY_PEERING_SSL_KEY       = process.env.GATEWAY_PEERING_SSL_KEY || 'peering_key';
const GATEWAY_PEERING_SSL_CERT      = process.env.GATEWAY_PEERING_SSL_CERT || 'peering_cert';

const getLocalIp = async () => {
  return (await lookup(`${HOSTNAME}.${APICONNECT_K8S_PEERS_SVC_FQDN}`)).address;
}

const getPeers = async () => {
  return (await lookup(APICONNECT_K8S_PEERS_SVC_FQDN, { all: true })).map(a => a.address)
};

const writeCert = async (name) => {
  let data = process.env[`APICONNECT_CERT_${name.replace(/\//g, '__')}`];
  if (data) {
    await writeFile(`/root/secure/usrcerts/${APICONNECT_DATAPOWER_DOMAIN}/${name}.pem`, data);
  }
}

const generateConfig = (priority, peers) => `top; co
%if% available "gateway-peering"
gateway-peering ${GATEWAY_PEERING_CONFIG_NAME}
  admin-state enabled
  local-address ${GATEWAY_PEERING_LOCAL_ADDRESS}
  local-port ${GATEWAY_PEERING_LOCAL_PORT}
  monitor-port ${GATEWAY_PEERING_MONITOR_PORT}
  priority ${priority}
  ${peers.map(p => `peer ${p}`).join('\n')}
  enable-ssl ${GATEWAY_PEERING_ENABLE_SSL ? `on
  ssl-key ${GATEWAY_PEERING_SSL_KEY}
  ssl-cert ${GATEWAY_PEERING_SSL_CERT}` : 'off'}
  enable-peer-group on
exit
%endif%`.replace(/\n\s*\n/g, '\n');

(async () => {
  try {
    // Give service DNS entries time to be populated
    await wait(10000);

    let [ , ordinal ] = HOSTNAME.match(/^.*-(\d+)$/);
    let priority = 1 + Math.min(parseInt(ordinal), 254);
    let localip = await getLocalIp();
    let peers = (await getPeers()).filter(ip => ip !== localip);
    let config = generateConfig(priority, peers);

    await writeFile(`/drouter/config/${APICONNECT_DATAPOWER_DOMAIN}/gateway-peering.cfg`, config);
    console.log(config);

    if (ordinal > 0) {
      // Give the master gateway time to come online
      await wait(10000);
    }
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
})();
