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
const _lookup = util.promisify(dns.lookup);
const writeFile = util.promisify(fs.writeFile);

const HOSTNAME                      = process.env.HOSTNAME;

const APICONNECT_K8S_NAMESPACE      = process.env.APICONNECT_K8S_NAMESPACE || 'default';
const APICONNECT_K8S_CLUSTER_DOMAIN = process.env.APICONNECT_K8S_CLUSTER_DOMAIN || 'cluster.local';
const APICONNECT_K8S_PEERS_SVC_PQDN = `${APICONNECT_K8S_NAMESPACE}.svc.${APICONNECT_K8S_CLUSTER_DOMAIN}`;
const APICONNECT_K8S_PEERS_SVC_NAME = process.env.APICONNECT_K8S_PEERS_SVC_NAME || 'datapower';
const APICONNECT_K8S_PEERS_SVC_FQDN = process.env.APICONNECT_K8S_PEERS_SVC_FQDN || `${APICONNECT_K8S_PEERS_SVC_NAME}.${APICONNECT_K8S_PEERS_SVC_PQDN}`;
const APICONNECT_DATAPOWER_DOMAIN   = process.env.APICONNECT_DATAPOWER_DOMAIN || 'apiconnect';
const APICONNECT_V5_COMPAT_MODE     = process.env.APICONNECT_V5_COMPAT_MODE || 'on';
const APICONNECT_ENABLE_TMS         = process.env.APICONNECT_ENABLE_TMS || 'off';
const APICONNECT_API_DEBUG_PROBE    = process.env.APICONNECT_API_DEBUG_PROBE || 'off';
const APICONNECT_DEDICATED_RL_PEERING   = process.env.APICONNECT_DEDICATED_RL_PEERING || 'off';
const APICONNECT_DEDICATED_SUBS_PEERING = process.env.APICONNECT_DEDICATED_SUBS_PEERING || 'off';

const GATEWAY_PEERING_CONFIG_NAME   = process.env.GATEWAY_PEERING_CONFIG_NAME || 'gwd';
const GATEWAY_PEERING_LOCAL_ADDRESS = process.env.GATEWAY_PEERING_LOCAL_ADDRESS || 'eth0_ipv4_1';
const GATEWAY_PEERING_LOCAL_PORT    = process.env.GATEWAY_PEERING_LOCAL_PORT || '15380';
const GATEWAY_PEERING_MONITOR_PORT  = process.env.GATEWAY_PEERING_MONITOR_PORT || '25380';
const GATEWAY_PEERING_ENABLE_SSL    = process.env.GATEWAY_PEERING_ENABLE_SSL !== 'off';
const GATEWAY_PEERING_SSL_KEY       = process.env.GATEWAY_PEERING_SSL_KEY || 'peering_key';
const GATEWAY_PEERING_SSL_CERT      = process.env.GATEWAY_PEERING_SSL_CERT || 'peering_cert';

const TMS_PEERING_CONFIG_NAME       = process.env.TMS_PEERING_CONFIG_NAME || 'tms';
const TMS_PEERING_LOCAL_ADDRESS     = process.env.TMS_PEERING_LOCAL_ADDRESS || 'eth0_ipv4_1';
const TMS_PEERING_LOCAL_PORT        = process.env.TMS_PEERING_LOCAL_PORT || '15381';
const TMS_PEERING_MONITOR_PORT      = process.env.TMS_PEERING_MONITOR_PORT || '25381';
const TMS_PEERING_ENABLE_SSL        = process.env.TMS_PEERING_ENABLE_SSL ? process.env.TMS_PEERING_ENABLE_SSL !== 'off' : GATEWAY_PEERING_ENABLE_SSL;
const TMS_PEERING_SSL_KEY           = process.env.TMS_PEERING_SSL_KEY || 'tms_key';
const TMS_PEERING_SSL_CERT          = process.env.TMS_PEERING_SSL_CERT || 'tms_cert';

const ADP_PEERING_CONFIG_NAME       = process.env.ADP_PEERING_CONFIG_NAME || 'api-probe';
const ADP_PEERING_LOCAL_ADDRESS     = process.env.ADP_PEERING_LOCAL_ADDRESS || 'eth0_ipv4_1';
const ADP_PEERING_LOCAL_PORT        = process.env.ADP_PEERING_LOCAL_PORT || '15382';
const ADP_PEERING_MONITOR_PORT      = process.env.ADP_PEERING_MONITOR_PORT || '25382';
const ADP_PEERING_ENABLE_SSL        = process.env.ADP_PEERING_ENABLE_SSL ? process.env.ADP_PEERING_ENABLE_SSL !== 'off' : GATEWAY_PEERING_ENABLE_SSL;
const ADP_PEERING_SSL_KEY           = process.env.ADP_PEERING_SSL_KEY || 'api_probe_key';
const ADP_PEERING_SSL_CERT          = process.env.ADP_PEERING_SSL_CERT || 'api_probe_cert';

const RL_PEERING_CONFIG_NAME        = process.env.RL_PEERING_CONFIG_NAME || 'rate-limit';
const RL_PEERING_LOCAL_ADDRESS      = process.env.RL_PEERING_LOCAL_ADDRESS || 'eth0_ipv4_1';
const RL_PEERING_LOCAL_PORT         = process.env.RL_PEERING_LOCAL_PORT || '15383';
const RL_PEERING_MONITOR_PORT       = process.env.RL_PEERING_MONITOR_PORT || '25383';
const RL_PEERING_ENABLE_SSL         = process.env.RL_PEERING_ENABLE_SSL ? process.env.RL_PEERING_ENABLE_SSL !== 'off' : GATEWAY_PEERING_ENABLE_SSL;
const RL_PEERING_SSL_KEY            = process.env.RL_PEERING_SSL_KEY ||  'rate_limit_key';
const RL_PEERING_SSL_CERT           = process.env.RL_PEERING_SSL_CERT || 'rate_limit_cert';

const SUBS_PEERING_CONFIG_NAME      = process.env.SUBS_PEERING_CONFIG_NAME || 'subs';
const SUBS_PEERING_LOCAL_ADDRESS    = process.env.SUBS_PEERING_LOCAL_ADDRESS || 'eth0_ipv4_1';
const SUBS_PEERING_LOCAL_PORT       = process.env.SUBS_PEERING_LOCAL_PORT || '15384';
const SUBS_PEERING_MONITOR_PORT     = process.env.SUBS_PEERING_MONITOR_PORT || '25384';
const SUBS_PEERING_ENABLE_SSL       = process.env.SUBS_PEERING_ENABLE_SSL ? process.env.SUBS_PEERING_ENABLE_SSL !== 'off' : GATEWAY_PEERING_ENABLE_SSL;
const SUBS_PEERING_SSL_KEY          = process.env.SUBS_PEERING_SSL_KEY || 'subs_key';
const SUBS_PEERING_SSL_CERT         = process.env.SUBS_PEERING_SSL_CERT || 'subs_cert';

const PEERING_LOG_LEVEL             = process.env.PEERING_LOG_LEVEL || 'internal';

const log = (...args) => {
  console.log(`${(new Date()).toUTCString()}:`, ...args);
}

/**
 * Due to what we consider a bug in the Kubernetes StatefulSet implementation, it appears to be possible for pods managed by a StatefulSet
 * to begin running before their DNS records are made available by the corresponding headless service. We consider this to be a bug as
 * "stable network identities" are a feature of StatefulSets.
 * 
 * As a workaround, the lookup() function below will loop indefinitely until it is successful, or encounters any error other than ENOTFOUND.
 */
const lookup = async (fqdn, all) => {
  for (let attempts = 1; ; attempts++) {
    log(`Resolving ${fqdn} (attempt #${attempts})`);
    try {
      return await _lookup(fqdn, { all: all === true });
    } catch (err) {
      if (err.code === 'ENOTFOUND') {
        await wait(10000);
        continue;
      } else {
        throw err;
      }
    }
  }
};

const getLocalIp = async () => {
  let fqdn = `${HOSTNAME}.${APICONNECT_K8S_PEERS_SVC_FQDN}`;
  let localip = (await lookup(fqdn, false)).address;
  log('Resolved ', fqdn, 'to', localip); 
  return localip;
}

const getPeers = async () => {
  let fqdn = APICONNECT_K8S_PEERS_SVC_FQDN;
  let peers = (await lookup(APICONNECT_K8S_PEERS_SVC_FQDN, true)).map(a => a.address)
  log('Resolved ', fqdn, 'to', peers); 
  return peers;
};

const writeCert = async (name) => {
  let data = process.env[`APICONNECT_CERT_${name.replace(/\//g, '__')}`];
  if (data) {
    await writeFile(`/opt/ibm/datapower/root/secure/usrcerts/${APICONNECT_DATAPOWER_DOMAIN}/${name}.pem`, data);
  }
}

const generateGatewayPeeringConfig = cfg => `top; co
%if% available "gateway-peering"
gateway-peering ${cfg.name}
  admin-state enabled
  local-address ${cfg.localAddress}
  local-port ${cfg.localPort}
  monitor-port ${cfg.monitorPort}
  priority ${cfg.priority}
  ${cfg.peers.map(p => `peer ${p}`).join('\n  ')}
  enable-ssl ${cfg.enableSSL ? `on
  ssl-key ${cfg.sslKey}
  ssl-cert ${cfg.sslCert}` : 'off'}
  persistence ${cfg.persistence ? `local
  local-directory local:///tms` : 'memory'}
  enable-peer-group on
  log-level ${PEERING_LOG_LEVEL}
exit
%endif%`.replace(/\n\s*\n/g, '\n');

const generateGatewayPeeringManagerConfig = () => `top; co
%if% available "gateway-peering-manager"
gateway-peering-manager
  admin-state enabled
  apic-gw-service ${GATEWAY_PEERING_CONFIG_NAME}
  ${APICONNECT_DEDICATED_RL_PEERING   === 'on' ? `rate-limit ${RL_PEERING_CONFIG_NAME}` : ''}
  ${APICONNECT_DEDICATED_SUBS_PEERING === 'on' ? `subscription ${SUBS_PEERING_CONFIG_NAME}` : ''}
exit
%endif%`.replace(/\n\s*\n/g, '\n');

const generateQuotaEnforcementConfig = cfg => `top; co
%if% available "quota-enforcement-server"
quota-enforcement-server
  admin-state enabled
  ip-address ${cfg.localAddress}
  monitor-port ${cfg.monitorPort}
  server-port ${cfg.localPort}
  priority ${cfg.priority}
  ${cfg.peers.map(p => `peer ${p}`).join('\n')}
  enable-ssl ${cfg.enableSSL ? `on
  ssl-key ${cfg.sslKey}
  ssl-cert ${cfg.sslCert}` : 'off'}
  enable-peer-group on
  strict-mode on
  ${cfg.persistence ? 'raid-volume raid0' : ''}
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

    let gpConfigs = [];
    gpConfigs.push(generateGatewayPeeringConfig({
      name: GATEWAY_PEERING_CONFIG_NAME,
      localAddress: GATEWAY_PEERING_LOCAL_ADDRESS,
      localPort: GATEWAY_PEERING_LOCAL_PORT,
      monitorPort: GATEWAY_PEERING_MONITOR_PORT,
      priority: priority,
      peers: peers,
      enableSSL: GATEWAY_PEERING_ENABLE_SSL,
      sslKey: GATEWAY_PEERING_SSL_KEY,
      sslCert: GATEWAY_PEERING_SSL_CERT
    }));

    if (APICONNECT_DEDICATED_RL_PEERING === 'on') {
      gpConfigs.push(generateGatewayPeeringConfig({
        name: RL_PEERING_CONFIG_NAME,
        localAddress: RL_PEERING_LOCAL_ADDRESS,
        localPort: RL_PEERING_LOCAL_PORT,
        monitorPort: RL_PEERING_MONITOR_PORT,
        priority: priority,
        peers: peers,
        enableSSL: RL_PEERING_ENABLE_SSL,
        sslKey: RL_PEERING_SSL_KEY,
        sslCert: RL_PEERING_SSL_CERT
      }));
    }

    if (APICONNECT_DEDICATED_SUBS_PEERING === 'on') {
      gpConfigs.push(generateGatewayPeeringConfig({
        name: SUBS_PEERING_CONFIG_NAME,
        localAddress: SUBS_PEERING_LOCAL_ADDRESS,
        localPort: SUBS_PEERING_LOCAL_PORT,
        monitorPort: SUBS_PEERING_MONITOR_PORT,
        priority: priority,
        peers: peers,
        enableSSL: SUBS_PEERING_ENABLE_SSL,
        sslKey: SUBS_PEERING_SSL_KEY,
        sslCert: SUBS_PEERING_SSL_CERT
      }));
    }

    if (APICONNECT_DEDICATED_RL_PEERING === 'on' || APICONNECT_DEDICATED_SUBS_PEERING === 'on') {
      gpConfigs.push(generateGatewayPeeringManagerConfig());
    }

    let config = gpConfigs.join('\n\n');
    let gpConfigPath = `/opt/ibm/datapower/drouter/config/${APICONNECT_DATAPOWER_DOMAIN}/gateway-peering.cfg`;
    await writeFile(gpConfigPath, config);
    log(`Generated ${gpConfigPath}:\n${config}`);

    if (APICONNECT_ENABLE_TMS === 'on') {
      let generateTMSConfig;
      let tmsConfigPath;

      if (APICONNECT_V5_COMPAT_MODE === 'on') {
        generateTMSConfig = generateQuotaEnforcementConfig;
        tmsConfigPath = '/opt/ibm/datapower/drouter/config/tms-peering.cfg';
      } else {
        generateTMSConfig = generateGatewayPeeringConfig;
        tmsConfigPath = `/opt/ibm/datapower/drouter/config/${APICONNECT_DATAPOWER_DOMAIN}/tms-peering.cfg`;
      }

      let tmsConfig = generateTMSConfig({
        name: TMS_PEERING_CONFIG_NAME,
        localAddress: TMS_PEERING_LOCAL_ADDRESS,
        localPort: TMS_PEERING_LOCAL_PORT,
        monitorPort: TMS_PEERING_MONITOR_PORT,
        priority: priority,
        peers: peers,
        enableSSL: TMS_PEERING_ENABLE_SSL,
        sslKey: TMS_PEERING_SSL_KEY,
        sslCert: TMS_PEERING_SSL_CERT,
        persistence: true
      });

      await writeFile(tmsConfigPath, tmsConfig);
      log(`Generated ${tmsConfigPath}\n${tmsConfig}`);
    }

    if (APICONNECT_API_DEBUG_PROBE === 'enabled') {
      let adpConfig = generateGatewayPeeringConfig({
        name: ADP_PEERING_CONFIG_NAME,
        localAddress: ADP_PEERING_LOCAL_ADDRESS,
        localPort: ADP_PEERING_LOCAL_PORT,
        monitorPort: ADP_PEERING_MONITOR_PORT,
        priority: priority,
        peers: peers,
        enableSSL: ADP_PEERING_ENABLE_SSL,
        sslKey: ADP_PEERING_SSL_KEY,
        sslCert: ADP_PEERING_SSL_CERT
      });

      let adpConfigPath = `/opt/ibm/datapower/drouter/config/${APICONNECT_DATAPOWER_DOMAIN}/api-probe-peering.cfg`;
      await writeFile(adpConfigPath, adpConfig);
      log(`Generated ${adpConfigPath}\n${adpConfig}`);
    }

    if (ordinal > 0) {
      // Give the master gateway time to come online
      await wait(10000);
    }
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
})();
