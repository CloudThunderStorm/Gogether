from flask import Flask, request, abort, render_template, jsonify
from flask_bootstrap import Bootstrap
from flask_jsglue import JSGlue

import string, sys

app = Flask(__name__)
Bootstrap(app)
JSGlue(app)

@app.route('/')
def index():
	data = refresh()
	return render_template('index.html')

@app.route('/create')
def create():
	return render_template('create.html')

@app.route('/myevents')
def myevents():
	return render_template('myevents.html')
#
@app.route('/loginsignup')
def loginsignup():
	return render_template('loginsignup.html')

@app.errorhandler(404)
def page_not_found(e):
	return render_template('404.html'), 404

@app.errorhandler(500)
def internal_server_error(e):
	return render_template('index.html')

if __name__ == "__main__":
	app.run()
