## Introduction

This chart can deploy one or more IBM DataPower Gateway nodes with a default configuration for API Connect to a Kubernetes environment.

This specific chart is a debug chart. Its purpose is to provide a basic debugging setup for developers and customers alike. As such, it should only ever be used in a develoment or testing context. The configurations included here are not intended to be example configurations for production use. The current configuration is a basic "loopback" test. When curling to the Service port, you should receive the data you sent as a response. This is to test the responsiveness of the deployed cluster. Run this loopback test using: `echo "<test123/>" | curl -k -u admin:admin --data-binary @- http://<host>:8080`

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

| Value                                                           | Description                                        | Default               |
|-----------------------------------------------------------------|----------------------------------------------------|-----------------------|
| `datapower.replicaCount`                                        | The replicaCount for the StatefulSet               | 3                     |
| `datapower.image.repository`                                    | The image to use for this deployment               | ibmcom/datapower      |
| `datapower.image.tag`                                           | The image tag to use for this deployment           | 7.7.1.1.300826        |
| `datapower.image.pullPolicy`                                    | Determines when the image should be pulled         | IfNotPresent          |
| `datapower.env.workerThreads`                                   | Number of DataPower worker threads                 |                       |
| `datapower.resources.limits.cpu`                                | Container CPU limit                                | 8                     |
| `datapower.resources.limits.memory`                             | Container memory limit                             | 8Gi                   |
| `datapower.resources.requests.cpu`                              | Container CPU requested                            | 8                     |
| `datapower.resources.requests.memory`                           | Container Memory requested                         | 8Gi                   |
| `datapower.apicGatewayTLSSecret`                                | REQUIRED: crypto material for API Connect gateway  | N/A (required)        |
| `datapower.gatewayPeeringLocalPort`                             | Port for gateway peering server                    | 16380                 |
| `datapower.gatewayPeeringMonitorPort`                           | Port for gateway peering monitor                   | 26380                 |
| `datapower.apicGatewayServiceLocalPort`                         | Port for API Connect Gateway Service               | 3000                  |
| `datapower.apiGatewayLocalPort`                                 | Port for API Gateway                               | 9443                  |
| `datapower.webGuiManagementState`                               | WebGUI Management admin state                      | disabled              |
| `datapower.webGuiManagementPort`                                | WebGUI Management port                             | 9090                  |
| `datapower.gatewaySshState`                                     | SSH admin state                                    | disabled              |
| `datapower.gatewaySshPort`                                      | SSH Port                                           | 9022                  |
| `datapower.restManagementState`                                 | REST Management admin state                        | disabled              |
| `datapower.restManagementPort`                                  | REST Management port                               | 5554                  |
| `datapower.xmlManagementLocalPort`                              | XML Management port                                | 5550                  |
| `datapower.snmpState`                                           | SNMP Service State(used for Prometheus monitoring) | enabled               |
| `datapower.snmpPort`                                            | SNMP Service Port(used for Prometheus monitoring)  | 1161                  |
| `datapower.storage.tmsPeering.accessModes`                      | Access Modes for the Token Management Service Disk | [ReadWriteOnce]       |
| `datapower.storage.tmsPeering.resources.requests.storage`       | Size for the Token Management Service Disk         | 10Gi                  |
| `service.type`                                                  | Service type                                       | ClusterIP             |
| `ingressType`                                                   | Type of ingress controller                         | ingress               |
| `ingress.gateway.enabled`                                       | API gateway ingress enabled                        | true                  |
| `ingress.gateway.enableTLS`                                     | API gateway ingress TLS enabled                    | false                 |
| `ingress.gateway.hosts.name`                                    | API gateway ingress host matches                   | [gateway.example.com] |
| `ingress.gateway.annotations`                                   | API gateway ingress annotations                    | []                    |
| `ingress.gwd.enabled`                                           | APIC gateway service ingress enabled               | true                  |
| `ingress.gwd.enableTLS`                                         | APIC gateway service ingress TLS enabled           | false                 |
| `ingress.gwd.hosts.name`                                        | APIC gateway service ingress host matches          | [gwd.example.com]     |
| `ingress.gwd.annotations`                                       | APIC gateway service ingress annotations           | []                    |


Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml stable/dynamic-gateway-service
```

[View the official IBM DataPower Gateway for Developers Docker Image in Docker Hub](https://hub.docker.com/r/ibmcom/datapower/)

[View the IBM DataPower Gateway Product Page](http://www-03.ibm.com/software/products/en/datapower-gateway)

[View the IBM DataPower Gateway Documentation](https://www.ibm.com/support/knowledgecenter/SS9H2Y)
