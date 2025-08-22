import socketio

# Create a Socket.IO client
sio = socketio.Client()

@sio.event
def connect():
    print("✅ Connected to server")
    # Send 'process' immediately after connecting
    sio.emit("message", "process")

@sio.event
def message(data):
    msg = data.get("msg", "")
    print(f"📩 {msg}")
    if msg == "done":
        print("Process completed, disconnecting...")
        sio.disconnect()

@sio.event
def disconnect():
    print("❌ Disconnected from server")

if __name__ == "__main__":
    # Connect to your Flask-SocketIO server
    sio.connect("http://localhost:5002", transports=["websocket"])  # Force websocket, no polling
    sio.wait()
