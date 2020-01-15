source ./conf/.env.sh

PUMP_RUN_TIME=$1

function getToken() {
    msg=$(curl --header "Content-Type: application/json" \
        --request POST \
        --data '{
                    "method": "login",
                    "params": {
                        "appType": "Kasa_Android",
                        "cloudUserName": "",
                        "cloudPassword": "",
                        "terminalUUID": ""
                    }
                }' \
        https://wap.tplinkcloud.com/)
    echo $msg
}  

function startpump() {

    local msg=$(curl -Ss --request POST "https://use1-wap.tplinkcloud.com/?token=${API_TOKEN} HTTP/1.1" \
    --data '{"method":"passthrough", "params": {"deviceId": '${PUMP_PLUG_ID}', "requestData": "{\"system\":{\"set_relay_state\":{\"state\":1}}}" }}' \
    --header "Content-Type: application/json")
    echo $msg
}


function stoppump() {
    local msg=$(curl --request POST "https://use1-wap.tplinkcloud.com/?token=${API_TOKEN} HTTP/1.1" \
    --data '{"method":"passthrough", "params": {"deviceId": '${PUMP_PLUG_ID}', "requestData": "{\"system\":{\"set_relay_state\":{\"state\":0}}}" }}' \
    --header "Content-Type: application/json")
    echo $mgs
}

# controlPump takes an parameter of minutes to run the pump
function controlPump() {
    while [ true ]
    do
        PUMP_RUN_TIME=$1

        startpump

        sleep $PUMP_RUN_TIME

        stoppump
        
        sleep 30m
    done      

}

DEFAULT_PUMP_RUNTIME=4m

main() {
    PUMP_RUN_TIME=$1
    if [ -n $PUMP_RUN_TIME ];
    then
        echo "running custom pump time"
        # Run the pump for n amount for minutes
        controlPump $PUMP_RUN_TIME
    else
        # default the pump to run for 4 minutes
        echo "running pump for 4 minutes"
        controlPump $DEFAULT_PUMP_RUNTIME
    fi
}

main "5m"

