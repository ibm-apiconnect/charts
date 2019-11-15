
if [ -d /opt/ibm/datapower/drouter/ramdisk2/mnt/raid-volume/raid0 ] ; then
  cd /opt/ibm/datapower/drouter/ramdisk2/mnt/raid-volume/raid0
  if [ ! -f .2018.4.1.8-migrated ] ; then
    [ ! -d local      ] && mkdir         local
    [   -d apiconnect ] && mv apiconnect local
    [   -d default    ] && mv default    local
    touch .2018.4.1.8-migrated
  fi
  cd /
fi
