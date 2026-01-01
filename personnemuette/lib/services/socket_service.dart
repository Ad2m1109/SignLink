import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? socket;
  final ValueNotifier<String> predictionNotifier = ValueNotifier("");

  void connect(String baseUrl) {
    socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket?.connect();

    socket?.onConnect((_) {
      debugPrint('Connected to backend WebSocket');
    });

    socket?.on('prediction_result', (data) {
      if (data != null && data['prediction'] != null) {
        predictionNotifier.value = data['prediction'];
      }
    });

    socket?.onDisconnect((_) {
      debugPrint('Disconnected from backend WebSocket');
    });
  }

  void streamSequence(List<List<double>> sequence) {
    if (socket != null && socket!.connected) {
      socket?.emit('stream_data', {'sequence': sequence});
    }
  }

  void dispose() {
    socket?.disconnect();
    socket?.dispose();
  }
}
