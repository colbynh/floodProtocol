exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>sumplog.out 2>&1

export WERKZEUG_DEBUG_PIN=off
. ../conf/.env.sh

DEFAULT_PUMP_RUNTIME=4m
DEFAULT_PUMP_SLEEPTIME=25m


function getToken() {
    msg=$(curl -Ss --header "Content-Type: application/json" \
        --request POST \
        --data '{
                    "method": "login",
                    "params": {
                        "appType": "Kasa_Android",
                        "cloudUserName": "${CLOUD_USER}",
                        "cloudPassword": "${CLOUD_PASS}",
                        "terminalUUID": ""
                    }
                }' \
        https://wap.tplinkcloud.com/)
    echo $msg
}  

function refreshToken() {
    echo "refreshing token"
    API_TOKEN=$(getToken | jq -r '.result.token')
    sed -i "$ d" ../conf/.env.sh
    echo "export API_TOKEN='${API_TOKEN}'" >> "../conf/.env.sh"
}

function startpump() {

    local msg=$(curl -Ss --request POST "https://use1-wap.tplinkcloud.com/?token=${API_TOKEN} HTTP/1.1" \
    --data '{"method":"passthrough", "params": {"deviceId": '${PUMP_PLUG_ID}', "requestData": "{\"system\":{\"set_relay_state\":{\"state\":1}}}" }}' \
    --header "Content-Type: application/json")
    echo $msg
    exit 0
}


function stoppump() {
    local msg=$(curl -Ss --request POST "https://use1-wap.tplinkcloud.com/?token=${API_TOKEN} HTTP/1.1" \
    --data '{"method":"passthrough", "params": {"deviceId": '${PUMP_PLUG_ID}', "requestData": "{\"system\":{\"set_relay_state\":{\"state\":0}}}" }}' \
    --header "Content-Type: application/json")
    echo $msg
    exit 0
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

default() { 
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
            echo "starting pump"
            msg=$(startpump)
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
    exit 0
}
main