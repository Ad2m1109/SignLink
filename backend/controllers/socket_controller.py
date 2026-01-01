from flask import request
from modules.sign_language_module import sign_language_model

def register_socket_handlers(socketio):
    @socketio.on('connect')
    def handle_connect():
        print(f"Client connected: {request.sid}")

    @socketio.on('disconnect')
    def handle_disconnect():
        print(f"Client disconnected: {request.sid}")

    @socketio.on('stream_data')
    def handle_stream_data(data):
        """
        data: {'sequence': [[x1,y1,z1...], [x2,y2,z2...], ...]}
        """
        sequence = data.get('sequence')
        if sequence and len(sequence) == 30:
            # Run inference
            prediction = sign_language_model.predict(sequence)
            
            # Emit result back to the specific client
            socketio.emit('prediction_result', {'prediction': prediction}, room=request.sid)
        else:
            print(f"Invalid sequence received from {request.sid}")
