#/bin/bash

source log.sh
source clap.sh

echo $(docker images | grep $src) | { while read row; do
	
	docker_image=$(echo $row | awk -v N=1 '{print $N}')
	docker_tag=$(echo $row | awk -v N=2 '{print $N}')

	docker tag $docker_image:$docker_tag $dest/$docker_image:$docker_tag

	docker push $dest/$docker_image:$docker_tag
        
    done
} 