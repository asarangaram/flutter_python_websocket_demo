import time
from flask import Flask, request
from flask_socketio import SocketIO

app = Flask(__name__)
socketio = SocketIO(
    app,
    cors_allowed_origins="*",
    ping_interval=25,   # server pings every 25s
    ping_timeout=60*10     # disconnect if no pong in 60s
)


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
    
    socketio.emit("message", {"msg": "close_connection"}, to=sid)
    # server initiates disconnect
    socketio.server.disconnect(sid)

@socketio.on("disconnect")
def handle_disconnect():
    print("Client disconnected:", request.sid)

if __name__ == "__main__":
    socketio.run(app, host="0.0.0.0", port=5002)
