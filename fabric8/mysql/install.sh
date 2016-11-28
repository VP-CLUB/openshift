#!/bin/bash
ns=$1
if [ "" == $1 ]; then
 echo 'namespace must not be null or "" do it like eg ./install.sh fabric8-staging'
 exit
fi
oc apply -n $ns  -f . 
