import subprocess
from flask import Flask

app = Flask(__name__)

# Just call the script using default params
@app.route('/')
def default():
    return subprocess.call('pumpctrl.sh')

@app.route('/start')
def start():
    return subprocess.check_call("./pumpctrl.sh '%s'" % start,  stdout=subprocess.PIPE, stderr=subprocess.PIPE)


@app.route('/stop')
def stop():
    return subprocess.check_call("./pumpctrl.sh '%s'" % stop, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')