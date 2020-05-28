#/bin/sh
###############################################################################
# unpack-local-files.sh
#
# This script takes the packed local files and unpacks them into the drouter
# local: directory. The expectation is that the tar file contains a proper
# DataPower directory structure for domains, where files in the top level
# are intended for the default domain and files intended for other domains
# are contained in subdirectories like /drouter/local/apiconnect/
#
###############################################################################

# Copy current directory
return_dir="$(pwd)"

# Create extraction directory
mkdir /opt/ibm/datapower/init/local-extract
cd /opt/ibm/datapower/init/local-extract

# Copy tarball to unpack directory
cp /opt/ibm/datapower/init/additional-local/* local.tar

# extract
tar xf local.tar
rm local.tar

# If top level is local, move into local
if ls | grep -q 'local'
then
  cd local/
fi

# Copy all files over to local path
cp -r * /drouter/local/

cd $return_dir
