if [ $DP_REQ_VALID_LICENSE_VERSION == "false" ] ; then
  echo "ERROR: USER MUST SPECIFY A LICENSE VERSION"
  echo "Please set datapower.licenseVersion"
fi

if [ $DP_REQ_VALID_DPM_IMAGE_SET == "false" ] ; then
  echo "ERROR: USER MUST SPECIFY A DATAPOWER MONITOR IMAGE"
  echo "Please set datapowerMonitor.image.repository and datapowerMonitor.image.tag"
  echo "For more information, please see the following IBM Knowledge Center articles:"
  echo "https://www.ibm.com/support/knowledgecenter/SSMNED_2018/com.ibm.apic.install.doc/tapic_upgrade_Kubernetes_gateway_monitor.html"
  echo "https://www.ibm.com/support/knowledgecenter/SSMNED_2018/com.ibm.apic.install.doc/tapic_install_Kubernetes_gwy.html"
fi

if [ $DP_REQ_HP_PEERING_OPTION_SET == "false" ] ; then
  echo "ERROR: USER MUST SPECIFY WHETHER TO ENABLE HIGH PERFORMANCE PEERING OR NOT"
  echo "Please set datapower.env.highPerformancePeering to either \"on\" or \"off\""
  echo "For more information, please see the following IBM Knowledge Center articles:"
  echo "https://www.ibm.com/support/knowledgecenter/SSMNED_2018/com.ibm.apic.install.doc/tapic_install_Kubernetes_gwy_peering.html"
  echo "https://www.ibm.com/support/knowledgecenter/SSMNED_2018/com.ibm.apic.install.doc/tapic_install_Kubernetes_gwy.html"
fi