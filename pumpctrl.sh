source ./conf/.env.sh

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
        local PUMP_RUN_TIME=$1
        local PUMP_SLEEPTIME=$2
            
        startpump

        sleep $PUMP_RUN_TIME

        stoppump
        
        sleep $PUMP_SLEEPTIME
    done      

}

DEFAULT_PUMP_RUNTIME=4m
DEFAULT_PUMP_SLEEPTIME=30m

main() {
    PUMP_RUN_TIME=$1
    PUMP_SLEEPTIME=$2
    if [ -n $PUMP_RUN_TIME ];
    then
        echo "running custom pump time"
        # Run the pump for n amount for minutes and sleep for n minutes
        controlPump $PUMP_RUN_TIME $PUMP_SLEEPTIME
    else
        # default the pump to run for 4 minutes
        echo "running pump for 4 minutes"
        controlPump $DEFAULT_PUMP_RUNTIME $DEFAULT_PUMP_RUNTIME
    fi
}

# call the script with the main function and two args
# runtime and sleep time... Default is 4mins and 30 mins
# ex: . ./pumpctrl.sh && main 5m 20m

main 

