import 'package:boltz_auth/src/models/ResponseModel.dart';
import 'package:boltz_auth/src/models/User.dart';
import 'package:boltz_auth/src/repository/auth_repo.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
// app auth controller

class AuthController extends GetxController implements GetxService {
  final AuthRepo authRepo;
  final FlutterSecureStorage storage;
  AuthController({required this.authRepo, required this.storage});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _authorized = false;
  bool get isAuthorized => _authorized;
//
  User? _user;
  User? get user => _user;

  String? _session;
  String? get session => _session;

  Future<void> initAuthUser() async {
    final userSessionToken = await storage.read(key: "userSession");
    if (userSessionToken != null) {
      var _user = await getCurrentUser();
      _authorized = _user.isSuccess;
      _session = userSessionToken;
    }
  }

  Future<ResponseModel> loginUser(String email, String password) async {
    _isLoading = true;
    update();
    late ResponseModel responseModel;

    Response response = await authRepo.login(email, password);
    responseModel = ResponseModel(false, "failed");
    if (response.statusCode == 200) {
      if (response.body["verify"]) {
        await authRepo.setAuthHeaderToken(response.body['_token']);
        responseModel = ResponseModel(false, 'Verify');
        // @demo:byPass
        // await authRepo.saveUserToken(token: response.body['_token']);
        // responseModel = ResponseModel(true, 'Login Successfull');
      } else {
        await authRepo.saveUserToken(token: response.body['_token']);
        responseModel = ResponseModel(true, 'Login Successfull');
      }
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> verifyLogin(String verificationCode) async {
    _isLoading = true;
    update();
    Response response = await authRepo.verifyCode(verificationCode);

    late ResponseModel responseModel;
    if (response.statusCode == 200) {
      if (response.body['verified']) await authRepo.saveUserToken();
      responseModel = ResponseModel(true, 'Login Successfull');
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> registerUser(dynamic data) async {
    _isLoading = true;
    update();
    Response response = await authRepo.registerUser(data);
    late ResponseModel responseModel;
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, 'Register Successfull');
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> getCurrentUser() async {
    _isLoading = true;
    update();
    Response response = await authRepo.getCurrentUser();
    late ResponseModel responseModel;

    if (response.statusCode == 200) {
      _user = User.fromJson(response.body['currentUser']);
      responseModel = ResponseModel(true, 'Profile Fetched');
    } else {
      responseModel = ResponseModel(false, response.statusText);
      logoutUser();
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> logoutUser() async {
    await authRepo.remoUserToken();
    _authorized = false;
    _user = null;
    update();
  }
}
