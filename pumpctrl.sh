source ./conf/.env.sh

PUMP_RUN_TIME=$1


function startpump() {

    curl --request POST "https://use1-wap.tplinkcloud.com/?token=${API_TOKEN} HTTP/1.1" \
    --data '{"method":"passthrough", "params": {"deviceId": '${PUMP_ONE_ID}', "requestData": "{\"system\":{\"set_relay_state\":{\"state\":1}}}" }}' \
    --header "Content-Type: application/json"
}


function stoppump() {
    curl --request POST "https://use1-wap.tplinkcloud.com/?token=${API_TOKEN} HTTP/1.1" \
    --data '{"method":"passthrough", "params": {"deviceId": '${PUMP_ONE_ID}', "requestData": "{\"system\":{\"set_relay_state\":{\"state\":0}}}" }}' \
    --header "Content-Type: application/json"
}


# WIP 
function lightOn() {
    curl --request POST "https://use1-wap.tplinkcloud.com/?token=${API_TOKEN} HTTP/1.1" \
    --data '{"method":"passthrough", "params": {"deviceId": , "requestData": "{\"system\":{\"set_relay_state\":{\"state\":1}}}" }}' \
    --header "Content-Type: application/json"
}

function lightOff() {
    curl --request POST "https://use1-wap.tplinkcloud.com/?token=${API_TOKEN} HTTP/1.1" \
    --data '{"method":"passthrough", "params": {"deviceId": , "requestData": "{\"system\":{\"set_relay_state\":{\"state\":0}}}" }}' \
    --header "Content-Type: application/json"
}

# controlPump takes an parameter of minutes to run the pump
function controlPump() {
    $PUMP_RUN_TIME=$1
    
    startpump

    sleep $PUMP_RUN_TIME

    stoppump
}

DEFAULT_PUMP_RUNTIME=4m

main() {
    if [ -n $PUMP_RUN_TIME ];
    then
        # Run the pump for n amount for minutes
        controlPump $PUMP_RUN_TIME
    else
        # default the pump to run for 4 minutes
        controlPump $DEFAULT_PUMP_RUNTIME
    fi
}



