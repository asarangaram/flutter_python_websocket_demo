import time
from flask import Flask, request
from flask_socketio import SocketIO, emit
from threading import Thread

app = Flask(__name__)
socketio = SocketIO(
    app,
    cors_allowed_origins="*",
    ping_interval=25,   # server pings every 25s
    ping_timeout=60*10     # disconnect if no pong in 60s
)

# store last activity time per client
last_activity = {}

IDLE_TIMEOUT = 3600  # 1 hour

@app.route("/")
def home():
    return "Server running"

@socketio.on("connect")
def handle_connect():
    print("Client connected:", request.sid)
    last_activity[request.sid] = time.time()
    socketio.start_background_task(target=send_messages, sid=request.sid)

@socketio.on("message")
def handle_message(msg):
    last_activity[request.sid] = time.time()  # update last activity
    print("Received:", msg)
    emit("message", {"msg": f"Echo: {msg}"})



def check_idle_clients():
    while True:
        now = time.time()
        for sid, last in list(last_activity.items()):
            if now - last > IDLE_TIMEOUT:
                if sid in socketio.server.manager.rooms.get('/', {}):
                    print(f"Disconnecting idle client: {sid}")
                    socketio.server.disconnect(sid)
                else:
                    print(f"Client {sid} already disconnected")
                last_activity.pop(sid, None)
        time.sleep(60)  # check every minute

def send_messages(sid):
    for i in range(1, 11):
        socketio.emit("message", {"msg": f"Tick {i}"}, to=sid)
        time.sleep(1)
    socketio.emit("message", {"msg": "close_connection"}, to=sid)
@socketio.on("disconnect")
def handle_disconnect():
    print("Client disconnected:", request.sid)
    last_activity.pop(request.sid, None)
    
if __name__ == "__main__":
    Thread(target=check_idle_clients, daemon=True).start()
    socketio.run(app, host="0.0.0.0", port=5002)
