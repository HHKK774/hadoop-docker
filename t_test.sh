#!/bin/bash

# please run "docker build -t eg_sshd" to build the eg_sshd image first
# then run "docker run -d -P --name test_sshd eg_sshd"
# and you should load the image in this package by running "docker load --input hadoop-docker.tar"
# you can also tag the image and push it to your docker hub if you can

#define number of nodes
N=$1
if [ $# == 0 ]
then
	N=3
fi

#start master node
docker run -idt -h mastert --name mastert hadoop-docker
MASTER_ID=$(docker inspect -f '{{.Id}}' mastert)

#start slaves
i=1
echo "">slaves
echo $N
echo $i
while [ $i -lt $N ]
do	
	docker run -idt -h node${i}t --name node${i}t hadoop-docker
	NODE_ID[i]=$(docker inspect -f '{{.Id}}' node${i}t)
	echo "node${i}t">>slaves
	((i++))
done
#FIRST_IP=$(docker inspect --format="{{.NetworkSettings.IPAddress}}" mastert)

#put neccessary files in each nodes
#put neccessary files in master
cp core-site.xml /var/lib/docker/aufs/mnt/**${MASTER_ID}**/usr/local/hadoop/etc/hadoop/core-site.xml
cp yarn-site.xml /var/lib/docker/aufs/mnt/**${MASTER_ID}**/usr/local/hadoop/etc/hadoop/yarn-site.xml
cp slaves /var/lib/docker/aufs/mnt/**${MASTER_ID}**/usr/local/hadoop/etc/hadoop/slaves

#put neccessary files in slaves
j=1
while [ $j -lt $N ]
do
	cp core-site.xml /var/lib/docker/aufs/mnt/**${NODE_ID[j]}**/usr/local/hadoop/etc/hadoop/core-site.xml
	cp yarn-site.xml /var/lib/docker/aufs/mnt/**${NODE_ID[j]}**/usr/local/hadoop/etc/hadoop/yarn-site.xml
	cp slaves /var/lib/docker/aufs/mnt/**${NODE_ID[j]}**/usr/local/hadoop/etc/hadoop/slaves
	((j++))
done

docker exec -it mastert bash
