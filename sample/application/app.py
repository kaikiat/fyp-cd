#!/usr/bin/env python3
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, Docker! 23 Aug 11.03pm'
