#!/bin/bash

source log.sh

NAMESPACE=vpclub
echo $NAMESPACE

log "check prerequisites ..."

if [ $(more /etc/redhat-release | grep "CentOS Linux release 7" | wc -l) == 0 ]; then
	log "This installation script is for CentOS 7.x only"
	exit
fi

systemctl disable firewalld
#if [ $(systemctl status firewalld | grep "firewalld.service; disabled;" | wc -l) == 0 ]; then
#	log "please make sure firewall is disabled, run systemctl status firewalld to check."
#	exit
#fi
systemctl stop firewalld
if [ $(systemctl status iptables | grep "Active: inactive (dead)" | wc -l) == 0 ]; then
	log "please disabled iptables first"
	exit
fi

if [ $(cat /etc/selinux/config | grep "SELINUX=enforcing" | wc -l) == 0 ]; then
	log "please make sure selinux is set to enforcing, check /etc/selinux/config"
	exit
fi

if [ $(getenforce | grep "Enforcing" | wc -l) == 0 ]; then
	log "please make sure selinux is set to enforcing, check /etc/selinux/config"
	exit
fi

yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion pyOpenSSL NetworkManager

systemctl enable NetworkManager.service
systemctl start NetworkManager

if [ $(systemctl status NetworkManager | grep "active (running)" | wc -l) == 0 ]; then
	log "please make sure NetworkManager is running."
	exit
fi

rm -rf /etc/ansible/hosts

tee /etc/ansible/hosts <<-'EOF'
# Create an OSEv3 group that contains the masters, nodes, and etcd groups
[OSEv3:children]
masters
nodes
etcd
 
# Set variables common for all OSEv3 hosts
[OSEv3:vars]
ansible_ssh_user=root
deployment_type=origin
openshift_release=v1.4
openshift_image_tag=v1.4.0-alpha.0
openshift_install_examples=true

osm_use_cockpit=true
osm_cockpit_plugins=['cockpit-kubernetes']

containerized=true

log_path=/var/log/ansible.log

[masters]
master.openshift.vpclub.local
 
# host group for etcd
[etcd]
etcd.openshift.vpclub.local
 
# host group for nodes, includes region info
[nodes]
master.openshift.vpclub.local openshift_node_labels="{'region': 'infra', 'zone': 'default'}"
EOF

log "iterate servers"

ANSIBLE_SERVERS=
cat config/cluster-ip.conf | { while read server; do
	echo $server
	IP=$(echo $server | awk '{print $1;}')
	SERVER_NAME=$(echo $server | awk '{print $2;}')
	HOST_ITEM="${IP} ${SERVER_NAME}.openshift.${NAMESPACE}.local"
	echo $HOST_ITEM

	echo "add ${IP} ${SERVER_NAME} to trust list"
	if [ $(cat /etc/hosts | grep "${HOST_ITEM}" | wc -l) == 0 ]; then
		echo $HOST_ITEM >> /etc/hosts
	fi

	ssh-copy-id -i ${HOME}/.ssh/id_rsa.pub ${IP}

	if [ $(echo $SERVER_NAME | grep node | wc -l) == 1 ]; then
		log "added node to /etc/ansible/hosts"
		echo "${SERVER_NAME}.openshift.${NAMESPACE}.local openshift_node_labels=\"{'region': 'primary', 'zone': '$SERVER_NAME'}\"" >> /etc/ansible/hosts
        fi
        
    done
} 

if [ ! -d ./openshift-ansible ]; then
	proxychains4 git clone https://github.com/openshift/openshift-ansible
fi

ansible all -m ping

ansible-playbook openshift-ansible/playbooks/byo/config.yml

oadm policy add-cluster-role-to-user cluster-admin admin --config=/etc/origin/master/admin.kubeconfig

oc get nodes

log "Done"
