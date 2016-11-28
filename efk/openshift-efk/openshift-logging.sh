#!/bin/bash

#Choose a Project
oadm new-project logging --node-selector=""
oc project logging
#Create missing templates
oc apply -n openshift -f https://raw.githubusercontent.com/openshift/origin-aggregated-logging/master/deployer/deployer.yaml
#Create Supporting Service Accounts and Permissions
# if In this case, you can create a "dummy" secret that does not specify a certificate value
oc secrets new logging-deployer nothing=/dev/null

oc new-app logging-deployer-account-template
oadm policy add-cluster-role-to-user oauth-editor system:serviceaccount:logging:logging-deployer

oadm policy add-scc-to-user privileged system:serviceaccount:logging:aggregated-logging-fluentd
oadm policy add-cluster-role-to-user cluster-reader system:serviceaccount:logging:aggregated-logging-fluentd

oadm policy add-cluster-role-to-user rolebinding-reader system:serviceaccount:logging:aggregated-logging-elasticsearch
#load sequence configMap secret 
#configmap config
oc create configmap logging-deployer --from-literal kibana-hostname=kibana.logging.172.16.5.60.nip.io --from-literal public-master-url=https://master.openshift.vpclub.local:8443 --from-literal es-cluster-size=3 -n logging

#Create Deployer Secret
oc new-app logging-deployer-template -p KIBANA_HOSTNAME=kibana.logging.172.16.5.60.nip.io -p KIBANA_OPS_HOSTNAME=kibana-ops.logging.172.16.5.60.nip.io -p ES_CLUSTER_SIZE=3 -p PUBLIC_MASTER_URL=https://master.openshift.vpclub.local:8443 -p IMAGE_VERSION=v1.4.0-alpha.1 -p MODE=install -n logging

#oc new-app logging-deployer-template \
#    --param KIBANA_HOSTNAME=kibana.logging.172.16.5.60.nip.io \
#    --param ES_CLUSTER_SIZE=1 \
#    --param PUBLIC_MASTER_URL=https://master.openshift.vpclub.local:8443

#create pv
oc apply -f es-pv.yml -n logging

