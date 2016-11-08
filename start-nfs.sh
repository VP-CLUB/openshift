#!/bin/bash

if [ $(docker inspect nfs-data-container | grep nfs-data-container | wc -l) == 0 ]; then
	docker create -v /to/share --name nfs-data-container macadmins/unfs3 /bin/true
fi

if [ $(docker ps | grep unfs3 | wc -l) == 1 ]; then
	docker rm -f unfs3
fi

docker run -it -d -p 111:111/udp -p 111:111/tcp -p 2049:2049/udp -p 2049:2049/tcp --volumes-from nfs-data-container -v /data/nfs/exports:/etc/exports --name unfs3 macadmins/unfs3

