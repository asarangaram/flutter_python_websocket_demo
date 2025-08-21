import socketio

sio = socketio.Client()

@sio.on("connect")
def on_connect():
    print("Connected to server")

@sio.on("message")
def on_message(data):
    msg = data["msg"]
    print("Message from server:", msg)
    if msg == "close_connection":
        print("Server asked to close connection. Disconnecting...")
        sio.disconnect()

@sio.on("disconnect")
def on_disconnect():
    print("Disconnected from server")

sio.connect("http://localhost:5002")
sio.wait()  # Wait for server messages
