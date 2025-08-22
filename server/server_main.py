
import eventlet
eventlet.monkey_patch()  # <-- must come first

import time # noqa: E402
from threading import Thread # noqa: E402
from flask import Flask, request # noqa: E402
from flask_socketio import SocketIO # noqa: E402

app = Flask(__name__)
socketio = SocketIO(
    app,
    cors_allowed_origins="*",
    ping_interval=25,   # server pings every 25s
    ping_timeout=60*10     # disconnect if no pong in 60s
)

last_activity = {}

NO_ACTIVITY_TIMEOUT = 60 * 60  # seconds

@app.route("/")
def home():
    return "Server running."

@socketio.on("connect")
def handle_connect():
    sid = request.sid
    last_activity[sid] = time.time()
    print(f"Client connected: {sid}")

@socketio.on("message")
def handle_message(msg):
    sid = request.sid
    last_activity[sid] = time.time()  # update activity timestamp
    print(f"Received from {sid}: {msg}")

    if msg == "process":
        socketio.start_background_task(target=process_task, sid=sid)

def process_task(sid):
    for i in range(1, 11):
        socketio.emit("message", {"msg": f"Tick {i}"}, to=sid)
        eventlet.sleep(1)
    socketio.emit("message", {"msg": "done"}, to=sid)

@socketio.on("disconnect")
def handle_disconnect():
    sid = request.sid
    print(f"Client disconnected: {sid}")
    last_activity.pop(sid, None)

# Background thread to enforce activity timeout
def check_idle_clients():
    while True:
        now = time.time()
        for sid, last in list(last_activity.items()):
            if now - last > NO_ACTIVITY_TIMEOUT:
                print(f"No activity for 1 hour, disconnecting {sid}")
                if sid in socketio.server.manager.rooms.get('/', {}):
                    socketio.server.disconnect(sid)
                last_activity.pop(sid, None)
        time.sleep(60) 

if __name__ == "__main__":
    Thread(target=check_idle_clients, daemon=True).start()
    
    socketio.run(app, host="0.0.0.0", port=5002, debug=True)
    
