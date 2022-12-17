import 'package:boltz_auth/src/controllers/auth_controller.dart';
import 'package:boltz_auth/src/models/ResponseModel.dart';
import 'package:boltz_auth/src/repository/auth_repo.dart';
import 'package:boltz_auth/src/utils/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:shared_preferences/shared_preferences.dart';

// remote app auth controller
class BoltzRemoteAuthController extends GetxController implements GetxService {
  final AuthRepo authRepo;
  final FlutterSecureStorage storage;
  BoltzRemoteAuthController({required this.authRepo, required this.storage});

  IO.Socket? _socket;
  IO.Socket? get socket => _socket;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _socketConnected = false;
  bool get socketConnected => _socketConnected;

  Future<void> initializeAuth() async {
    final token = Get.find<AuthController>().session;
    var userToken = await storage.read(key: 'userToken');

    _socket = IO.io(AppConstants.authSocketURL, <String, dynamic>{
      'transports': ['websocket'],
      'extraHeaders': {'Authorization': 'Bearer $token'} // optional
    }).connect();
    listenSocketConnection();
    update();
  }

  IO.Socket connectSocket() {
    return socket!.connect();
  }

  void listenSocketConnection() {
    socket!.onConnect((_) {
      _socketConnected = true;
      update();
    });
    socket!.onDisconnect((_) {
      // Future.microtask(() => setState(() => socketConnected = false));
      _socketConnected = false;
      update();
    });
  }

  Future<void> dispose() async {
    socket!.dispose();
    socket!.disconnect();
    update();
  }
}
