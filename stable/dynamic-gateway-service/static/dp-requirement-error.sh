if [ $DP_REQ_VALID_LICENSE_VERSION == "false" ] ; then
  echo "ERROR: USER MUST SPECIFY A LICENSE VERSION"
  echo "Please set datapower.licenseVersion"
fi

if [ $DP_REQ_VALID_DPM_IMAGE_SET == "false" ] ; then
  echo "ERROR: USER MUST SPECIFY A DATAPOWER MONITOR IMAGE"
  echo "Please set datapowerMonitor.image.repository and datapowerMonitor.image.tag"
fi
