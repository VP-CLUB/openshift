# hazelcast-openshift

## just some notes

vagrant box add openshift-bootstrap-1.0.6.box
vagrant up
vagrant ssh

oc login https://localhost:8443

docker build test
docker login -u username -e username@localhost.local -p `oc whoami -t` 172.30.152.84:5000

oc describe service hazelcast-cluster

kubectl get pods | egrep "(POD|hazelcast)"


web console: https://localhost:8443



oc login -n default -u system:admin

oc get images -n default | grep hazelcast

oc import-image hazelcast-openshift noctarius/hazelcast-openshift

oc describe service docker-registry --config=/openshift.local.config/master/admin.kubeconfig

oc create -f hazelcast-template.json -n hazelcast-cluster
oc replace -f hazelcast-template.json -n hazelcast-cluster

sudo su:
  oc delete ReplicationController <name-of-replication-controller>
  oc project hazelcast-cluster
  oc project hazelcast-client
