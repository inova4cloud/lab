from flask import Flask

app = Flask(__name__)


@app.get("/")
def hello_world():
    return "Hello world from lab/04 Python App Service behind Application Gateway!"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
