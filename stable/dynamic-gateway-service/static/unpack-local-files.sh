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


# Create extraction directory
mkdir local-extract
cd local-extract

# Decode tar
base64 -d /init/additional-local/* > local.tar

# extract
tar xf local.tar

# If top level is local, move into local
if ls | grep -q 'local/'
then
  cd local/
fi

# Copy all files over to local path
cp -r * /drouter/local/
