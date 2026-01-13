from flask import Flask, jsonify

app = Flask(__name__)
healthy = True


@app.route("/health", methods=['GET'])
def health():
    if healthy:
        return jsonify(status="ok"), 200
    else:
        return jsonify(status="error"), 500


@app.route("/break", methods=['GET'])
def break_app():
    global healthy
    healthy = False
    return "Health probe will now fail", 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
