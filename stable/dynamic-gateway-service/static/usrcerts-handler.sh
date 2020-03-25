#!/bin/sh
###############################################################################
# usrcerts-handler.sh
#
# This script moves the added certs from their volume mounted locations into
# the correct location under /root/secure/usrcerts/apiconnect.
# This script is used so we can avoid mounting secrets directly to `apiconnect`
#
###############################################################################

TYPE=$1
CERTS_DIR="/opt/ibm/datapower/init/usrcerts/${TYPE}"

if [ ! -d "/root/secure/usrcerts/apiconnect/${TYPE}" ]
then
  mkdir "/root/secure/usrcerts/apiconnect/${TYPE}"
fi
cp -rL $CERTS_DIR/* "/root/secure/usrcerts/apiconnect/${TYPE}"
