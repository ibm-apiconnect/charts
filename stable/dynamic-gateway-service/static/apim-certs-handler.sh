#!/bin/sh
###############################################################################
# This script handles the logic behind copying certificates provided by the
# secret specified in .Values.datapower.apimVeloxCertsSecret and configuring
# the `crypto certificate` and `crypto valcred` objects that use them to
# enable support for mutual TLS between APIM and the APIC Gateway Service.
#
# All certificate files should be in .pem format and mounted to the directory
# /root/secure/usrcerts/apiconnect/apim
###############################################################################

INIT_CERTS_DIR=/opt/ibm/datapower/init/apim-certs
APIM_CERTS_DIR=/root/secure/usrcerts/apiconnect/apim
APIC_CFG_DIR=/drouter/config/apiconnect
TMP_CERTS_CFG=$APIC_CFG_DIR/apim-certs-cfg.tmp
TMP_VALCRED_CFG=$APIC_CFG_DIR/apim-valcred-cfg.tmp
APIC_VALCRED_CFG=$APIC_CFG_DIR/apim-valcred.cfg

mkdir -p $APIM_CERTS_DIR
cp -rL $INIT_CERTS_DIR/*.pem $APIM_CERTS_DIR/

# Start temp certs file with opening `crypto` command
echo "crypto" > $TMP_CERTS_CFG

# Start temp valcreds file with opening `crypto valcred` command
(
  cat <<EOF

crypto
valcred apim_valcred
  admin-state enabled
EOF
) > $TMP_VALCRED_CFG

# Start apim-valcred.cfg with usual reset
(
  cat <<EOF
top; configure terminal;

EOF
) > $APIC_VALCRED_CFG

# Loop over all .pem files in /root/secure/usrcerts/apiconnect/apim
for certfile in $APIM_CERTS_DIR/*.pem
do
  # Get certificate name by stripping path and extension
  certname="$(echo $certfile | sed -e 's|'$APIM_CERTS_DIR'/||g' -e 's|.pem||g')"

  # Create `crypto certificate` object for the certificate
  echo "certificate apim_cert_$certname cert:///apim/$certname.pem" >> $TMP_CERTS_CFG

  # Add certificate to the valcred config
  echo "  certificate apim_cert_$certname" >> $TMP_VALCRED_CFG
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
