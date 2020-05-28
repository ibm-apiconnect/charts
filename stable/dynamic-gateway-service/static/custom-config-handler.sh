#!/bin/sh
###############################################################################
# This script handles the logic behind dealing with the custom configuration
# specified in .Values.datapower.additionalConfig.
#
# All configuration files should be in the format <domain>.cfg in the directory
# /init/custom-config/
#
# This script will loop over the files in that directory and append the contents
# of each file into the existing configuration file for the applicable domain
# or create a new domain if one does not already exist.
###############################################################################


# Loop over all files in /init/additional-config/
for configdir in /opt/ibm/datapower/init/additional-config/*
do
  # Get domain name by stripping path and extension
  domain="$(echo $configdir | sed 's|/opt/ibm/datapower/init/additional-config/||g')"

  # Check for default domain, which is a special case
  if [ "$domain" == "default" ]
  then
    for configfile in $configdir/*; do
      # default domain is defined in auto-startup.cfg
      cat $configfile >> /drouter/config/auto-startup.cfg
    done
    # No further action needed for default domain
    continue
  fi

  # Check for existence of domain
  if [ -e "/drouter/config/$domain/$domain.cfg" ]
  then
    for configfile in $configdir/*; do
      # Append new configuration into existing domain
      cat $configfile >> /drouter/config/$domain/$domain.cfg
    done
    # No further action needed
    continue
  fi

  # Domain does not exist, so create it
  mkdir /drouter/config/$domain
  echo "top; configure terminal;" > /drouter/config/$domain/$domain.cfg
  for configfile in $configdir/*; do
    cat $configfile >> /drouter/config/$domain/$domain.cfg
  done

  # Append config execution to default domain
  (
  cat <<EOF

domain $domain
  visible-domain default
exit

%if% available "include-config"

include-config "$domain-cfg"
  config-url "config:///$domain/$domain.cfg"
  auto-execute
  no interface-detection
exit

%endif%
EOF
  ) >> /drouter/config/auto-startup.cfg

done

