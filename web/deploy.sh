#!/bin/bash
DEPLOY_ENV=$1
CLEAN=$2
PROD_TAG=$3
IMAGE_TAG=""

if [[ "$CLEAN" ==  "true" ]]
then    
    docker swarm leave --force
fi

if [[ "$DEPLOY_ENV" == "dev" ]]
then    
    IMAGE_TAG='latest'
    docker build -t guitaristcolby/flood-control:$IMAGE_TAG .
else 
    IMAGE_TAG=$(/home/colby/code/floodProtocol/update-service.sh && getLatestImageNum)
    docker pull guitaristcolby/flood-control:$IMAGE_TAG 
fi

if [[ "$DEPLOY_ENV" == "dev" ]]
then 
    docker swarm init --advertise-addr 192.168.50.69
    docker network create -d overlay flood-net


    docker service create \
    --publish published=5000,target=5000 \
    --mount type=bind,src="/home/colby/code/floodProtocol/web/conf",dst="/web/conf" \
    --network flood-net \
    --name flood-dev \
    guitaristcolby/flood-control:$IMAGE_TAG

    docker service logs flood-dev
fi 

if [[ "$DEPLOY_ENV" == "prod" ]]
then    
    docker swarm init --advertise-addr 192.168.50.69
    docker network create -d overlay flood-net


    docker service create \
    --publish published=5000,target=5000 \
    --mount type=bind,src="/home/colby/code/floodProtocol/web/conf",dst="/web/conf" \
    --network flood-net \
    --name flood-prod \
    guitaristcolby/flood-control:$IMAGE_TAG

    docker service logs flood-prod
    nohup ../update-service.sh >> service.log &
fi
