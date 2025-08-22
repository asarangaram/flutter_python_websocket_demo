# Flutter Python Websocket Demo

## What is in this?

    ├── server
    │   └── server_main.py
    └── client 
        ├── client_main.py
        ├── dart_app
        └── flutter_app

### server_main.py

A bare minimal server to demonstrate how to use flask_socketio to create a server with websocket feature.
Once a client connected,

1. When client sents a message with 'process', it sends tick for every seconds untill 10 sec (place holder process), then sends 'done'
2. If no handshake from client for more than 10min, it disconnects.
3. When there is a handshake, but no activity for more than 1hr, it disconnects.
