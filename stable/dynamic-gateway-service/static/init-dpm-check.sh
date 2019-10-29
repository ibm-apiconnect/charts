export DPM_LIVENESS_URL="http://$DPM_FQDN:$DPM_LIVENESS_PORT/"
while [ true ] ; do
  echo "Checking for DataPower Monitor Pod at $DPM_LIVENESS_URL"
  wget --spider -T 5 $DPM_LIVENESS_URL &> /dev/null
  if [ $? -ne 0 ] ; then
    echo "Could not reach DataPower Monitor Pod at $DPM_LIVENESS_URL"
    echo "Trying again in 5 seconds"
    sleep 5
  else
    break
  fi
done
echo "DataPower Monitor Pod reached at $DPM_LIVENESS_URL"
