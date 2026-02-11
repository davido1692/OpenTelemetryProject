from flask import Flask, render_template

app = Flask(__name__)

@app.get("/")
def home():
    return render_template("index.html")

@app.get("/healthz")
def healthz():
    return {"status": "ok"}, 200

if __name__ == "__main__":
    # Flask in container: listen on all interfaces
    app.run(host="0.0.0.0", port=8080)
