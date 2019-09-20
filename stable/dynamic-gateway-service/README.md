## Introduction

This chart can deploy one or more IBM DataPower Gateway nodes with a default configuration for API Connect to a Kubernetes environment.

## Prerequisites
Before you can install this chart you need to create a kubernetes secret containing 5 certificates. These certificates can be created using `openssl`. You can create the secret using the following command `kubectl create secret generic gw-certs --from-file=.`, where `gw-certs` is the name of the secret and the from-file is current directory. The name `gw-certs` needs to be set for the required field `datapower.apicGatewayTLSSecret`. The directory needs to contains the files named below.
```
peering_key.pem
gwd_ca.pem       
gwd_cert.pem
gwd_key.pem      
peering_cert.pem
```

 ## Installing the Chart
 To install the chart with the release name `my-release`.
 ```bash
$ helm install --name my-release stable/dynamic-gateway-service
```


> **Tip**: List all releases using `helm list`

 ## Uninstalling the Chart
To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```

## Configuration
The helm chart has the following Values that can be overridden using the install `--set` parameter or by providing your own values file. For example:

`helm install --set datapower.image.repository=<myimage> stable/dynamic-gateway-service`

| Value                                                           | Description                                              | Default               |
|-----------------------------------------------------------------|----------------------------------------------------------|-----------------------|
| `datapower.licenseVersion`                                      | License version of DataPower to be deployed              | N/A                   |
| `datapower.replicaCount`                                        | The replicaCount for the StatefulSet                     | 3                     |
| `datapower.image.repository`                                    | The image to use for this deployment                     | ibmcom/datapower      |
| `datapower.image.tag`                                           | The image tag to use for this deployment                 | 2018.4.1              |
| `datapower.image.pullPolicy`                                    | Determines when the image should be pulled               | IfNotPresent          |
| `datapower.env.workerThreads`                                   | Number of DataPower worker threads                       |                       |
| `datapower.resources.limits.cpu`                                | Container CPU limit                                      | 8                     |
| `datapower.resources.limits.memory`                             | Container memory limit                                   | 8Gi                   |
| `datapower.resources.requests.cpu`                              | Container CPU requested                                  | 8                     |
| `datapower.resources.requests.memory`                           | Container Memory requested                               | 8Gi                   |
| `datapower.apicGatewayTLSSecret`                                | REQUIRED: crypto material for API Connect gateway        | N/A (required)        |
| `datapower.gatewayPeeringLocalPort`                             | Port for gateway peering server                          | 16380                 |
| `datapower.gatewayPeeringMonitorPort`                           | Port for gateway peering monitor                         | 26380                 |
| `datapower.apicGatewayServiceLocalPort`                         | Port for API Connect Gateway Service                     | 3000                  |
| `datapower.apiGatewayLocalPort`                                 | Port for API Gateway                                     | 9443                  |
| `datapower.apiDebugProbe`                                       | Whether to enable API Debug Probe                        | disabled              |
| `datapower.apiDebugProbeMaxRecords`                             | Maximum number of API Debug Probe records to keep        | 1000                  |
| `datapower.apiDebugProbeExpiration`                             | Number of minutes before API Debug Probe records expire  | 60                    |
| `datapower.apiDebugProbePeeringLocalPort`                       | Port for API Debug Probe peering server                  | 16382                 |
| `datapower.apiDebugProbePeeringMonitorPort`                     | Port for API Debug Probe peering monitor                 | 26382                 |
| `datapower.webGuiManagementState`                               | WebGUI Management admin state                            | disabled              |
| `datapower.webGuiManagementPort`                                | WebGUI Management port                                   | 9090                  |
| `datapower.gatewaySshState`                                     | SSH admin state                                          | disabled              |
| `datapower.gatewaySshPort`                                      | SSH Port                                                 | 9022                  |
| `datapower.restManagementState`                                 | REST Management admin state                              | disabled              |
| `datapower.restManagementPort`                                  | REST Management port                                     | 5554                  |
| `datapower.xmlManagementLocalPort`                              | XML Management port                                      | 5550                  |
| `datapower.snmpState`                                           | SNMP Service State(used for Prometheus monitoring)       | enabled               |
| `datapower.snmpPort`                                            | SNMP Service Port(used for Prometheus monitoring)        | 1161                  |
| `datapower.flexpointBundle`                                     | Flexpoint Bundle type for ILMT scanning                  | N/A                   |
| `datapower.additionalConfig`                                    | List of domains and config files                         |                       |
| `datapower.additionalLocalTar`                                  | Path to local directory tar file                         |                       |
| `datapower.additionalCerts`                                     | List of domains and cert secrets                         |                       |
| `datapower.storage.tmsPeering.accessModes`                      | Access Modes for the Token Management Service Disk       | [ReadWriteOnce]       |
| `datapower.storage.tmsPeering.resources.requests.storage`       | Size for the Token Management Service Disk               | 10Gi                  |
| `datapower.customDatapowerConfig`                               | Name of ConfigMap with one or more DataPower .cfg files  |                       |
| `service.type`                                                  | Service type                                             | ClusterIP             |
| `ingressType`                                                   | Type of ingress controller                               | ingress               |
| `ingress.gateway.enabled`                                       | API gateway ingress enabled                              | true                  |
| `ingress.gateway.enableTLS`                                     | API gateway ingress TLS enabled                          | false                 |
| `ingress.gateway.hosts.name`                                    | API gateway ingress host matches                         | [gateway.example.com] |
| `ingress.gateway.annotations`                                   | API gateway ingress annotations                          | []                    |
| `ingress.gwd.enabled`                                           | APIC gateway service ingress enabled                     | true                  |
| `ingress.gwd.enableTLS`                                         | APIC gateway service ingress TLS enabled                 | false                 |
| `ingress.gwd.hosts.name`                                        | APIC gateway service ingress host matches                | [gwd.example.com]     |
| `ingress.gwd.annotations`                                       | APIC gateway service ingress annotations                 | []                    |


Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml stable/dynamic-gateway-service
```


### Adding new config
New DataPower configuration can be added into the gateway by use of the `datapower.additionalConfig` value. This value takes the form of a list of domain-config pairs, like so:
```
datapower:
  additionalConfig:
  - domain: "default"
    config: "config/default.cfg
  - domain: "apiconnect"
    config: "config/apiconnect.cfg"
```
The paths to config files must be inside the chart directory. These config files should be standard DataPower CLI config.

### Adding local files
Local files can be added into the gateway deployment by use of the `datapower.additionalLocalTar` value. This value is a path to a tar file which contains all the files you wish to add. This tar file should be a well formatted DataPower `local:` directory where files intended for the `default` domain are on the top level and all files intended for a different domain are in a subdirectory named for that domain.

### Adding certificates
Certificates and other crypto files can be added to the `cert:` directory by use of the `datapower.additionalCerts` value. This value takes the form of a list of domain-secret pairs, like so:
```
datapower:
  additionalCerts:
  - domain: "default"
    secret: "some-default-cert-secret"
  - domain: "apiconnect"
    secret: "some-apiconnect-cert-secret"
```
The secrets are Kubernetes secrets which contain the crypto files you wish to use. To create the secret from an existing crypto key-cert pair:
```
kubectl create secret generic my-secret --from-file=/path/to/key.pem --from-file=/path/to/cert.pem
```



[View the official IBM DataPower Gateway for Developers Docker Image in Docker Hub](https://hub.docker.com/r/ibmcom/datapower/)

[View the IBM DataPower Gateway Product Page](http://www-03.ibm.com/software/products/en/datapower-gateway)

[View the IBM DataPower Gateway Documentation](https://www.ibm.com/support/knowledgecenter/SS9H2Y)
