from flask import Flask
from flask_socketio import SocketIO, emit

# Create a Flask web server instance
app = Flask(__name__)

# Initialize SocketIO with the Flask app
# The 'cors_allowed_origins' is important for allowing the Flutter app
# to connect from a different origin (e.g., your local machine's IP)
socketio = SocketIO(app, cors_allowed_origins="*")

# This is an event handler for when a client connects to the server
@socketio.on('connect')
def handle_connect():
    print('Client connected!')
    # 'emit' sends a message back to the connected client
    emit('my_response', {'data': 'Connected to server!'})

# This is an event handler for when a client sends a message
# The event name is 'my_message', which we will use in our Flutter app
@socketio.on('my_message')
def handle_message(message):
    print(f'Received message: {message}')
    # 'emit' sends a message back to the client that sent the message
    emit('my_response', {'data': f'Server received your message: {message["data"]}'})

# This is an event handler for when a client disconnects
@socketio.on('disconnect')
def handle_disconnect():
    print('Client disconnected.')

# This is a standard route for the root URL
@app.route('/')
def index():
    return '<h1>Welcome to the WebSocket Server!</h1>'

if __name__ == '__main__':
    # 'socketio.run' starts the server on host '0.0.0.0' so it's accessible
    # from other devices on your network. The default port is 5000.
    socketio.run(app, host='0.0.0.0', port=5002)