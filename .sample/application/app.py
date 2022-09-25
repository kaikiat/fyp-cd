#!/usr/bin/env python3
from flask import Flask
app = Flask(__name__)
from datetime import datetime

@app.route('/')
def hello_world():
    return 'Hello, Docker! 10 ' + str(datetime.now())
