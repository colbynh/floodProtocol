import subprocess
from flask import Flask, render_template, flash, request
from wtforms import Form, TextField, TextAreaField, validators, StringField, SubmitField
import asyncio

app = Flask(__name__)
app.config.from_object(__name__)
app.config['SECRET_KEY'] = '7d441f27d441f27567d441f2b6176a'

@app.route("/", methods=['GET'])
def home():
    return render_template('home.html', message='Welcome to the 111 Flood Page')

class ReusableForm(Form):
    duration = TextField('duration:', validators=[validators.DataRequired()])
    runtime = TextField('runtime:', validators=[validators.DataRequired(), validators.Length(min=1, max=10)])
    pumpsleep = TextField('pumpsleep:', validators=[validators.DataRequired(), validators.Length(min=1, max=30)])
    
    @app.route("/pump", methods=['GET', 'POST'])
    def pumprun():
        form = ReusableForm(request.form)
    
        print(form.errors)
        if request.method == 'POST':
            duration=request.form['duration']
            runtime=request.form['runtime']
            pumpsleep=request.form['pumpsleep']
    
        if form.validate():
        # Save the comment here.
            flash('The flood program will now run for '+duration+' minute(s)')
            flash('The pump will have an interval runtime of '+runtime+' minutes')
            flash('The pump will have a sleep time of '+ pumpsleep + 'minutes')
            start(runtime, pumpsleep, duration)
        else:
            flash('Error: All the form fields are required. ')
        
        return render_template('pump.html', form=form)





async def run(cmd):
    proc = await asyncio.create_subprocess_shell(
        cmd,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE)

    stdout, stderr = await proc.communicate()

    print(f'[{cmd!r} exited with {proc.returncode}]')
    if stdout:
        print(f'[stdout]\n{stdout.decode()}')
    if stderr:
        print(f'[stderr]\n{stderr.decode()}')


def start(arg, arg2, arg3):
    form = ReusableForm(request.form)
    print(arg, arg2, arg3)
    asyncio.run(run('./pumpctrl.sh ' +arg+' '+ arg2 + ' ' + arg3))
    return render_template('pump.html', form=form)


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')