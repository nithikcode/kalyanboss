import 'package:kalyanboss/config/constants.dart';
import 'package:kalyanboss/services/session_manager.dart';
import 'package:kalyanboss/utils/helpers/helpers.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


class SocketService {
  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;

  late IO.Socket _socket;
  final SessionManager session = SessionManager.instance;

  SocketService._internal() {
    initSocket();
  }

  Future<void> initSocket() async {
    String token = session.jwtAccessToken ?? '';
    const String socketNamespace = '/api/v1';

    final String fullSocketUrl = AppUrl.url + socketNamespace;

    _socket = IO.io(
      fullSocketUrl, // Connects to: 'https://apiv1.teamwoodenstreet.com/api/v1'
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .build(),
    );

    _socket.connect();

    _socket.onConnect((_) {
      createLog('Socket Connected: ${_socket.id}');
    });

    _socket.onReconnect((_) {
      createLog('Socket Reconnected: ${_socket.id}');
    });

    _socket.onReconnectAttempt((attempt) {
      createLog('Socket Reconnection Attempt: $attempt');
    });

    _socket.onDisconnect((_) {
      createLog('Socket Disconnected: ${_socket.id}');
    });

    _socket.onConnectError((error) {
      createLog('Socket Connection Error: $error');
    });
  }

  void joinChat(int chatRoomId) {
    final roomId = chatRoomId.toString(); // Convert to string
    _socket.emit('joinChat', roomId);
    createLog('Join event emitted for room: $roomId');
  }

  // Leave a specific supportChat
  void leaveChat(int chatRoomId) {
    _socket.emit('leaveChat', chatRoomId); // Emit leaveChat event
  }

  // Get the current socket instance
  IO.Socket get socket => _socket;

  // Disconnect the socket manually if needed
  void disconnect() {
    _socket.disconnect();
  }
}