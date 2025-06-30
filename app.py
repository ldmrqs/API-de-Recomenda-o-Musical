from flask import Flask, jsonify
import random

app = Flask(__name__)

songs = [
    "Bohemian Rhapsody - Queen",
    "Billie Jean - Michael Jackson",
    "Like a Rolling Stone - Bob Dylan",
    "Smells Like Teen Spirit - Nirvana",
    "Imagine - John Lennon",
    "What's Going On - Marvin Gaye",
    "Clocks - Coldplay",
    "Heroes - David Bowie"
]

@app.route("/recommend")
def recommend():
    return jsonify({"song": random.choice(songs)})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)