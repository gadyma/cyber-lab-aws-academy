"""Deliberately vulnerable Flask app for the lab (SSTI -> RCE lesson).

DO NOT deploy outside the isolated lab VPC. The greeting is rendered by
feeding user input into render_template_string, which is a textbook
server-side template injection: `{{7*7}}` evaluates, and the Jinja object
graph can be walked to command execution. See lessons/vulnerable-flask/.
"""
from flask import Flask, request, render_template_string

app = Flask(__name__)

PAGE = """
<!doctype html><title>Greeting Service</title>
<h1>Greeting Service</h1>
<form action="/" method="get">
  <input name="name" value="world" autofocus>
  <button type="submit">Greet</button>
</form>
<p>Hello, %s!</p>
<hr><small>Lab target - SSTI practice. Isolated lab use only.</small>
"""


@app.route("/")
def index():
    name = request.args.get("name", "world")
    # VULNERABILITY (intentional): user input is concatenated into the template
    # source and then rendered, so the server evaluates it -> SSTI.
    return render_template_string(PAGE % name)


@app.route("/healthz")
def healthz():
    return "ok", 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
