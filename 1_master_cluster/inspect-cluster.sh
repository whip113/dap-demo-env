#!/bin/bash 

printf "\n\nLoad balancer config:\n----------------\n"
docker exec -it conjur-haproxy cat /usr/local/etc/haproxy/haproxy.cfg

printf "\n\nRunning containers:\n----------------\n"
docker ps -f "label=role=conjur_node"

printf "\n\nStateful node info:\n----------------\n"
cont_list=$(docker ps -f "label=role=conjur_node" --format "{{ .Names }}")
for cname in $cont_list; do
	crole=$(docker exec $cname evoke role)
	cip=$(docker inspect $cname --format "{{ .NetworkSettings.IPAddress }}")
	printf "%s, %s, %s\n" $cname $crole $cip
done
printf "\n\n"
