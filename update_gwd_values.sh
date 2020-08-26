#!/bin/bash
GATEWAY_TAG=$1
MONITOR_TAG=$2
if [ -z "${GATEWAY_TAG}" ] || [ -z "${MONITOR_TAG}" ]; then
    echo "Usage: update_gwd_values.sh <datapower image tag> <monitor image tag>"
    echo "Example: ./update_gwd_values.sh 2018.4.1.13u-release-ubi-prod 2018.4.1.9-ubi-icp4i"
    exit 1
fi
sed -e 's|repository: ibmcom/datapower *$|repository: apic-dev-docker-local.artifactory.swg-devops.com/apiconnect/datapower-api-gateway|g' \
    -e "s|tag: 2018.4.1 *$|tag: ${GATEWAY_TAG}|g" \
    -e 's|licenseVersion: *$|licenseVersion: Developers|g' \
    -e 's|repository: *$|repository: apic-dev-docker-local.artifactory.swg-devops.com/k8s-datapower-monitor|g' \
    -e "s|tag: *$|tag: ${MONITOR_TAG}|g" \
    -i stable/dynamic-gateway-service/values.yaml
