#!/bin/sh
###############################################################################
# additional-cert-handler.sh
#
# This script moves the added certs from their volume mounted locations into
# the correct domain in /opt/ibm/datapower/root/secure/usrcerts/
#
###############################################################################

INITCERTS="/opt/ibm/datapower/init/certs"

for domain in $(ls $INITCERTS)
do
  for secret in $(ls $INITCERTS/$domain)
  do
    # default domain is top level
    if [ "$domain" == "default" ]
    then
      cp -rL $INITCERTS/$domain/$secret/* /opt/ibm/datapower/root/secure/usrcerts/
      continue
    fi
    if [ ! -d "/opt/ibm/datapower/root/secure/usrcerts/$domain" ]
    then
      mkdir /opt/ibm/datapower/root/secure/usrcerts/$domain
    fi
    cp -rL $INITCERTS/$domain/$secret/* /opt/ibm/datapower/root/secure/usrcerts/$domain/
  done
done

