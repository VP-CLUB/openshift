#!/bin/bash
oc policy add-role-to-user edit system:serviceaccount:fabric8-staging:deployer -n fabric8-staging
