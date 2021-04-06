#!/bin/bash

set -e

# set username and password
UNAME="guitaristcolby"
UPASS=$DOCKER_PASS

# get token to be able to talk to Docker Hub
TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${UNAME}'", "password": "'${UPASS}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)

# get list of repos for that user account
REPO_LIST=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${UNAME}/?page_size=10000 | jq -r '.results|.[]|.name')

getImageList() {
    # build a list of all images & tags
    for i in ${REPO_LIST}
    do
        # get tags for repo
        IMAGE_TAGS=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${UNAME}/${i}/tags/?page_size=10000 | jq -r '.results|.[]|.name')

        # build a list of images from tags
        for j in ${IMAGE_TAGS}
        do
            # add each tag to list
            FULL_IMAGE_LIST="${FULL_IMAGE_LIST} ${UNAME}/${i}:${j}"
        done
    done

    # output list of all docker images
    ILIST=()
    count=0
    for i in ${FULL_IMAGE_LIST}
    do 
        #   echo $i
        ILIST+=($(echo $i | grep flood-control | cut -d ":" -f 2))
    done

    maxtag=${ILIST[0]}
    for n in "${ILIST[@]}" ; do
        ((n > maxtag)) && maxtag=$n
    done
    echo $maxtag
}


while [ true ]
do 
    maxtag=$(getImageList)
    svctag=$(docker service ls | awk '{print $5}' | grep flood | cut -d ":" -f 2 | tail -n 1)
    echo $maxtag
    echo $svctag
    if [[ "$maxtag" -gt "$svctag" ]]
    then    
        docker service update --force --image guitaristcolby/flood-control:$maxtag flood_web-app
    fi
    sleep 5
done




