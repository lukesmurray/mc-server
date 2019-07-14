"""The flask application for the lambda functions.

Flask ask prompts for a password. If the password is correct the flask
app turns the server on and displays the server ip.
"""

import functools
import os

import boto3
from botocore.exceptions import ClientError
from flask import abort, Flask, flash, redirect, render_template, request, session, url_for


app = Flask(__name__)
app.secret_key = b'tC89[Di0{h_%tpFbT@*;|iozg]b{1>'
app.debug = False


@functools.lru_cache(maxsize=1, typed=True)
def get_ec2_client():
    """Get a boto3 client for interacting with ec2."""
    return boto3.client('ec2')


def get_instance_id():
    """Get the id of the mc server ec2 instance.

    Raises:
        RuntimeError: If the instance id is not set in the environment.

    Returns:
        str: the id of the instance.

    """
    instance_id = os.getenv('MC_SERVER_INSTANCE_ID')
    if instance_id is None:
        raise RuntimeError("get_instance_id(): Instance id env var not set")
    return instance_id


def get_instance_ip():
    """Get the public ip address of the instance.

    Raises:
        RuntimeError: If there is an issue getting the instance ip.

    Returns:
        str: the public ip of the instance if one is assigned. Otherwise None.

    """
    client = get_ec2_client()

    instance_id = get_instance_id()
    try:
        instances = client.describe_instances(
            InstanceIds=[
                instance_id,
            ]
        )['Reservations'][0]['Instances']
    except ClientError as e:
        raise RuntimeError(
            "get_instance_ip(): Failed to get instance ip {}".format(str(e)))
    return instances[0].get('PublicIpAddress')


def get_instance_status():
    """Get the status of the instance.

    Status is one of
        pending - preparing to enter a running state.
        running - running and ready for use.
        shutting-down - preparing to enter a terminated state.
        terminated - instance is terminated and cannot be restarted.
        stopping - preparing to enter a stopped state.
        stopped - instance is stopped and can be restarted.

    Raises:
        RuntimeError: If there is an issue getting the instance status.
        RuntimeError: If the instance id is not set in the environment.

    Returns:
        str: The status of the instance.

    """
    client = get_ec2_client()

    instance_id = get_instance_id()
    try:
        instances = client.describe_instance_status(
            InstanceIds=[
                instance_id,
            ],
            IncludeAllInstances=True
        )["InstanceStatuses"]
    except ClientError as e:
        raise RuntimeError(
            "get_instance_status(): Failed to get instance status {}".format(str(e)))
    return instances[0]["InstanceState"]["Name"]


def do_start_server():
    """Start the server.

    Raises:
        RuntimeError: If there is an issue starting the server.

    """
    client = get_ec2_client()

    instance_id = get_instance_id()
    try:
        client.start_instances(
            InstanceIds=[
                instance_id,
            ]
        )
    except ClientError as e:
        raise RuntimeError(
            "do_start_server(): Failed to start instance {}".format(str(e)))


def do_stop_server():
    """Stop the server.

    Raises:
        RuntimeError: If there is an issue stopping the server.

    """
    client = get_ec2_client()

    instance_id = get_instance_id()
    try:
        client.stop_instances(
            InstanceIds=[
                instance_id,
            ]
        )
    except ClientError as e:
        raise RuntimeError(
            "do_stop_server(): Failed to stop instance {}".format(str(e)))


def do_the_login():
    """Log the user in.

    Raises:
        RuntimeError: If the password variable has not been set

    Returns:
        Route: Redirects to home page on successful login. Otherwise
            shows login with error message.

    """
    # TODO set the password somewhere
    password = os.getenv('MC_LAMBDA_PASSWORD')
    if password is None:
        raise RuntimeError("do_the_login(): password env var not set")
    if request.form['password'] == password:
        session['logged_in'] = True
    else:
        flash('wrong password!')
        return login()
    return redirect(url_for('home'))


@app.route('/login', methods=['GET', 'POST'])
def login():
    """Route for logging the user in."""
    try:
        if request.method == 'POST':
            return do_the_login()
        if session.get('logged_in'):
            return redirect(url_for('home'))
        return render_template('login.html')
    except Exception as e:
        abort(500, {'message': str(e)})


@app.route('/')
def home():
    """Home page displays information."""
    try:
        if not session.get('logged_in'):
            return redirect(url_for('login'))
        else:
            return render_template('index.html',
                                   status=get_instance_status(),
                                   ip=get_instance_ip())
    except Exception as e:
        abort(500, {'message': str(e)})


@app.route('/stop', methods=['POST'])
def stop():
    """Route for stopping the server."""
    try:
        if not session.get('logged_in'):
            return redirect(url_for('login'))
        else:
            do_stop_server()
        return redirect(url_for('home'))
    except Exception as e:
        abort(500, {'message': str(e)})


@app.route('/start', methods=['POST'])
def start():
    """Route for starting the server."""
    try:
        if not session.get('logged_in'):
            return redirect(url_for('login'))
        else:
            do_start_server()
        return redirect(url_for('home'))
    except Exception as e:
        abort(500, {'message': str(e)})


@app.route('/logout', methods=['POST'])
def logout():
    """Route for logging the user out."""
    try:
        session['logged_in'] = False
        return redirect(url_for('login'))
    except Exception as e:
        abort(500, {'message': str(e)})


@app.errorhandler(500)
def internal_error(error):
    """Template for when an error has occurred."""
    return render_template('500.html', error=error), 500
