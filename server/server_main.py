import time
from flask import Flask, request
from flask_socketio import SocketIO

app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins="*")

@app.route("/")
def home():
    return "WebSocket server is running."

@socketio.on("connect")
def handle_connect():
    print("Client connected:", request.sid)
    # Start background task to send messages
    socketio.start_background_task(target=send_messages, sid=request.sid)

def send_messages(sid):
    for i in range(1, 11):  # 10 seconds
        socketio.emit("message", {"msg": f"Tick {i}"}, to=sid)
        time.sleep(1)
    # Send final message before disconnect
    socketio.emit("message", {"msg": "close_connection"}, to=sid)
    # server initiates disconnect
    socketio.disconnect(sid)

@socketio.on("disconnect")
def handle_disconnect():
    print("Client disconnected:", request.sid)

if __name__ == "__main__":
    socketio.run(app, host="0.0.0.0", port=5002)
