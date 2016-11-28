#!/bin/bash
source ../../log.sh
source ../../clap.sh

echo $CMD_LINE
FABRIC8_OS=linux;
#FABRIC8_VERSION=$ver
GOFABRIC_SRC=/usr/local/bin/gofabric8
log 'migrate docker image first' 

#./exec-migrate-fabric8-2.1.19-image registry=$registry
if [ $? == 1 ]; then
  log 'please migrate docker image first,e.g. ./exec-migrate-fabric8-2.1.19-image registry=172.16.5.60:5000'
  exit 1
fi


if [ "" == "$ver" ]; then
  ver=0.4.105;
fi
log "download fabric8 binary"
if [ ! -f "$GOFABRIC_SRC" ]; then
  log "downloading gofabric client..."
  wget -O /usr/local/bin/gofabric8 https://github.com/fabric8io/gofabric8/releases/download/v$ver/gofabric8-$FABRIC8_OS-amd64; 
  chmod +x /usr/local/bin/gofabric8
fi
gofabric8 version

# svc.cluster.local
if [ "" == "$domain" ]; then
  log 'please specify domain=yourdomain, e.g. ./install-fabric8.sh domain=172.16.5.60.nip.io'
  exit
fi
log 'create project fabric8...'
oc new-project fabric8
log 'note that the nfs server ip is hard coded so far'
oc create -f storage-pv-oc.yml
#specify version
log 'specify fabric8  version'
gofabric8 deploy -y --version-console=2.2.190 --version-devops=2.3.60 --version-ipaas=2.2.190 --version-kubeflix=1.0.23 --version-zipkin=0.1.5 --namespace=fabric8 --domain=$domain --pv=true --package=fabric8-platform-2.2.19-openshift.yml
#gofabric8 deploy -y --domain=$domain --pv=true
gofabric8 secrets -y
# add fabric8 registry anonymous privilege
oadm policy add-role-to-user system:image-puller system:anonymous -n fabric8
