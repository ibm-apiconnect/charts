## Introduction

This chart can deploy one or more IBM DataPower Gateway nodes with a default configuration for API Connect to a Kubernetes environment.

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
The helm chart has the following Values that can be overriden using the install `--set` parameter or by providing your own values file. For example:

`helm install --set datapower.image.repository=<myimage> stable/dynamic-gateway-service`

| Value                                                           | Description                                       | Default             |
|-----------------------------------------------------------------|---------------------------------------------------|---------------------|
| `datapower.replicaCount`                                        | The replicaCount for the StatefulSet              | 3                   |
| `datapower.image.repository`                                    | The image to use for this deployment              | ibmcom/datapower    |
| `datapower.image.tag`                                           | The image tag to use for this deployment          | 7.7.0               |
| `datapower.image.pullPolicy`                                    | Determines when the image should be pulled        | IfNotPresent        |
| `datapower.env.workerThreads`                                   | Number of DataPower worker threads                |                     |
| `datapower.resources.limits.cpu`                                | Container CPU limit                               | 8                   |
| `datapower.resources.limits.memory`                             | Container memory limit                            | 8Gi                 |
| `datapower.resources.requests.cpu`                              | Container CPU requested                           | 8                   |
| `datapower.resources.requests.memory`                           | Container Memory requested                        | 8Gi                 |
| `datapower.quotaEnforcementTLSSecret`                           | Crypto material for quota enforcement             |                     |
| `datapower.apicGatewayTLSSecret`                                | REQUIRED: crypto material for API Connect gateway | N/A (required)      |
| `datapower.quotaEnforcementServerPort`                          | Port for quota enforcement server                 | 16379               |
| `datapower.quotaEnforcementMonitorPort`                         | Port for quota enforcement monitor                | 26379               |
| `datapower.gatewayPeeringLocalPort`                             | Port for gateway peering server                   | 16380               |
| `datapower.gatewayPeeringMonitorPort`                           | Port for gateway peering monitor                  | 26380               |
| `datapower.apicGatewayServiceLocalPort`                         | Port for API Connect Gateway Service              | 3000                |
| `datapower.apiGatewayLocalPort`                                 | Port for API Gateway                              | 9443                |
| `datapower.storage.quotaEnforcement.accessModes`                | Access mode for quota enforcement PV              | ReadWriteOnce       |
| `datapower.storage.quotaEnforcement.resources.requests.storage` | Size of quota enforcement PV                      | 10Gi                |
| `datapower.storage.gatewayPeering.accessModes`                  | Access mode for gateway peering PV                | ReadWriteOnce       |
| `datapower.storage.gatewayPeering.resources.requests.storage`   | Size of gateway peering PV                        | 50Gi                |
| `datapower.webGuiManagementState`                               | WebGUI Management admin state                     | disabled            |
| `datapower.webGuiManagementPort`                                | WebGUI Management port                            | 9090                |
| `datapower.gatewaySshState`                                     | SSH admin state                                   | disabled            |
| `datapower.gatewaySshPort`                                      | SSH Port                                          | 9022                |
| `datapower.restManagementState`                                 | REST Management admin state                       | disabled            |
| `datapower.restManagementPort`                                  | REST Management port                              | 5554                |
| `datapower.xmlManagementLocalPort`                              | XML Management port                               | 5550                |
| `service.type`                                                  | Service type                                      | ClusterIP           |


Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml stable/dynamic-gateway-service
```

[View the official IBM DataPower Gateway for Developers Docker Image in Docker Hub](https://hub.docker.com/r/ibmcom/datapower/)

[View the IBM DataPower Gateway Product Page](http://www-03.ibm.com/software/products/en/datapower-gateway)

[View the IBM DataPower Gateway Documentation](https://www.ibm.com/support/knowledgecenter/SS9H2Y)
