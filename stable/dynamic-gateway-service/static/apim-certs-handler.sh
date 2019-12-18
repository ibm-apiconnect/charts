#!/bin/sh
###############################################################################
# This script handles the logic behind copying certificates provided by the
# secret specified in .Values.datapower.apimVeloxCertsSecret and configuring
# the `crypto certificate` and `crypto valcred` objects that use them to
# enable support for mutual TLS between APIM and the APIC Gateway Service.
###############################################################################


TYPE=$1

case $TYPE in
  client|server)
    echo "Generating configuration to validate TLS connections with API Manager $TYPE"
    ;;
  *)
    echo "Cannot generate TLS validation configuration. Invalid type: $TYPE"
    exit 1
    ;;
esac


INIT_CERTS_DIR=/opt/ibm/datapower/init/apim-certs/$TYPE
APIM_CERTS_DIR=/root/secure/usrcerts/apiconnect/apim/$TYPE
APIC_CFG_DIR=/drouter/config/apiconnect
TMP_CERTS_CFG=$APIC_CFG_DIR/apim-$TYPE-certs-cfg.tmp
TMP_VALCRED_CFG=$APIC_CFG_DIR/apim-$TYPE-valcred-cfg.tmp
APIC_VALCRED_CFG=$APIC_CFG_DIR/apim-$TYPE-valcred.cfg

mkdir -p $APIM_CERTS_DIR
cp -rL $INIT_CERTS_DIR/*.pem $APIM_CERTS_DIR/

# Start temp certs file with opening `crypto` command
echo "crypto" > $TMP_CERTS_CFG

# Start temp valcreds file with opening `crypto valcred` command
(
  cat <<EOF

crypto
valcred apim_${TYPE}_valcred
  admin-state enabled
EOF
) > $TMP_VALCRED_CFG

# Start apim-valcred.cfg with usual reset
(
  cat <<EOF
top; configure terminal;

EOF
) > $APIC_VALCRED_CFG

# Loop over all .pem files in /root/secure/usrcerts/apiconnect/apim/$TYPE
for certfile in $APIM_CERTS_DIR/*.pem
do
  # Get certificate name by stripping path and extension
  certname="$(echo $certfile | sed -e 's|'${APIM_CERTS_DIR}'/||g' -e 's|.pem||g')"

  # Create `crypto certificate` object for the certificate
  echo "certificate apim_${TYPE}_cert_${certname} cert:///apim/${TYPE}/${certname}.pem" >> $TMP_CERTS_CFG

  # Add certificate to the valcred config
  echo "  certificate apim_${TYPE}_cert_${certname}" >> $TMP_VALCRED_CFG
done

# Close `crypto` command in temp certs file
(
  cat <<EOF
exit

EOF
) >> $TMP_CERTS_CFG

# Close `crypto valcred` command in temp certs file
(
  cat <<EOF
exit
exit

EOF
) >> $TMP_VALCRED_CFG

# Concatenate temp files and append to apim-valcred.cfg
cat $TMP_CERTS_CFG $TMP_VALCRED_CFG >> $APIC_VALCRED_CFG

# Clean up temp files
rm $TMP_CERTS_CFG $TMP_VALCRED_CFG
