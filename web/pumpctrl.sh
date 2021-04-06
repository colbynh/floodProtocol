#!/bin/bash
export WERKZEUG_DEBUG_PIN=off

. ./conf/.env.sh

DEFAULT_PUMP_RUNTIME=4m
DEFAULT_PUMP_SLEEPTIME=25m
JSON_MSG=`{"message":status}`


function getToken() {
    msg=$(curl -Ss --header "Content-Type: application/json" \
        --request POST \
        --data '{
                    "method": "login",
                    "params": {
                        "appType": "Kasa_Android",
                        "cloudUserName": "'$CLOUD_USER'",
                        "cloudPassword": "'$CLOUD_PASS'",
                        "terminalUUID": "4a345a52-d20a-46fb-a558-a05eb9157fab"
                    }
                }' \
        https://wap.tplinkcloud.com/)
    echo $msg
}  

function getDeviceInfo() {
    local deviceName="Floodpump1"
    local msg=$(curl -s --request POST "https://wap.tplinkcloud.com?token=${API_TOKEN} HTTP/1.1" \
    --data '{"method":"getDeviceList"}' \
    --header "Content-Type: application/json")
     echo $msg | jq '.' > tmp.json

    jq -c '.result.deviceList[]' tmp.json | while read i;
    do
        alias=$(echo $i | jq '.alias')

        if [[ $alias == "\"FloodPump1\"" ]]
        then    
            deviceid=$(echo $i | jq '.deviceId')
            echo $deviceid 
        fi
    done
}

function setDeviceId() {
    echo "getting device id"
    PUMP_PLUG_ID=$(getDeviceInfo)
    sed -i "s/PUMP_PLUG.*$/PUMP_PLUG_ID=${PUMP_PLUG_ID}/g" ../conf/.env.sh
}


function refreshToken() {
    echo "refreshing token"
    API_TOKEN=$(getToken | jq -r '.result.token')
    sed -i "s/API_TOKEN.*$/API_TOKEN=${API_TOKEN}/g" ../conf/.env.sh
}

function startpump() {
    local msg=$(curl -Ss --request POST "https://use1-wap.tplinkcloud.com/?token=${API_TOKEN} HTTP/1.1" \
    --data '{"method":"passthrough", "params": {"deviceId": '${PUMP_PLUG_ID}', "requestData": "{\"system\":{\"set_relay_state\":{\"state\":1}}}" }}' \
    --header "Content-Type: application/json")
    echo $msg
}


function stoppump() {
    local msg=$(curl -Ss --request POST "https://use1-wap.tplinkcloud.com/?token=${API_TOKEN} HTTP/1.1" \
    --data '{"method":"passthrough", "params": {"deviceId": '${PUMP_PLUG_ID}', "requestData": "{\"system\":{\"set_relay_state\":{\"state\":0}}}" }}' \
    --header "Content-Type: application/json")
    echo $msg
}


# controlPump takes an parameter of minutes to run the pump
function controlPump() {
    PUMP_RUN_TIME=$1
    PUMP_SLEEPTIME=$2
    totalRunTime=$3
    startTime=`date`
    endTime=$(date -d "$totalRunTime")

    echo "starting now $startTime" 
    echo "Pump program will end at: $endTime"
    echo "Running for $totalRunTime minutes"

    while [[ $(date) < "$endTime" ]]
    do  
        echo "Pump run time ${PUMP_RUN_TIME}"    
        startpump

        sleep $PUMP_RUN_TIME

        stoppump
        echo "Pump stopping for ${PUMP_SLEEPTIME}"
        sleep $PUMP_SLEEPTIME
    done      
    echo "done running"
}

function default() { 
    echo "Running pump with default params"
    controlPump $DEFAULT_PUMP_RUNTIME $DEFAULT_PUMP_SLEEPTIME
}

# call the script with the main function and two args for custom 
# runtime and sleep time... Default is 4mins and 25 mins
# custom ex: . ./pumpctrl.sh start

main() {
    echo $1
    msg=""
    case "$1" in

        start)
            controlPump $2 $3 $4 
            ;;

        stop)
            echo "stopping pump"
            msg=$(stoppump)
            ;;

        *)
            echo "defaulting"
            msg=$(default)
            ;;
    esac

    if [[ $msg == *"Token expired"* ]]; then
        refreshToken
        main $1
    fi
}

echo "args: $1 $2 $3" >> log.txt
main start $1 $2 $3  >> log.txt