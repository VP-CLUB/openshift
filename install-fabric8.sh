#!/bin/bash
source log.sh
source clap.sh

echo $CMD_LINE
FABRIC8_OS=linux;
#FABRIC8_VERSION=$ver
GOFABRIC_SRC=/usr/local/bin/gofabric8
if [ "" == "$ver" ]; then
  ver=0.4.104;
fi
log "download fabric8 binary"
if [! -f "$GOFABRIC_SRC"]; then
  log "downloading gofabric client..."
  wget -O /usr/local/bin/gofabric8 https://github.com/fabric8io/gofabric8/releases/download/v$ver/gofabric8-$FABRIC8_OS-amd64; 
  chmod +x /usr/local/bin/gofabric8
fi
gofabric8 version
# svc.cluster.local
if [ "" == "$domain" ]; then
  domain=svc.cluster.local
fi
gofabric8 deploy -y --domain=$domain --pv=true
gofabric8 secrets -y
