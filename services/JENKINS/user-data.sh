#!/bin/bash

echo ECS_CLUSTER='${ecs_cluster_name}' > /etc/ecs/ecs.config

########## Fedora Based OS Dependencies ##########

export AWSCLI_VERSION="1.16.186"
export DOCKER_VERSION="3:19.03.13-3.el8"


##### AWS CLI

if ! aws --version 2>/dev/null && [[ $(cat /etc/os-release | grep "ID_LIKE") =~ "fedora" ]]; then
     yum -y install python3-pip
     pip3 install awscli --upgrade --user
fi


##### Docker-CE

if ! docker version 2>/dev/null && [[ $(cat /etc/os-release | grep "ID_LIKE") =~ "fedora" ]]; then
    yum install -y device-mapper-persistent-data lvm2 yum-utils
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum install -y containerd.io docker-ce-$DOCKER_VERSION
fi


systemctl enable docker.service
systemctl start docker.service

##### Jenkins
docker run -p 8080:8080 -p 50000:50000 jenkins
