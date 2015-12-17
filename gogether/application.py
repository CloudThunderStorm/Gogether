from flask import Flask, request, abort, render_template, jsonify
from flask_bootstrap import Bootstrap
from flask_jsglue import JSGlue
from flask.ext.cors import CORS, cross_origin

import string
import sys

application = app = Flask(__name__)

Bootstrap(app)
JSGlue(app)
CORS(app)

@app.route('/')
@cross_origin()
def index():
    return render_template('index.html')


@app.route('/create')
@cross_origin()
def create():
    return render_template('create.html')


@app.route('/myevents')
@cross_origin()
def myevents():
    return render_template('myevents.html')

@app.route('/event/<eventId>')
@cross_origin()
def event(eventId):
    return render_template('event.html', eventId=eventId)

@app.route('/login')
@cross_origin()
def login():
    return render_template('login.html')

@app.route('/signup')
@cross_origin()
def signup():
    return render_template('signup.html')


@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404


if __name__ == "__main__":
    application.run(debug=True)
