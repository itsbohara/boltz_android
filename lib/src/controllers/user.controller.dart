import 'package:get/get.dart';
import 'package:boltz_auth/src/models/ResponseModel.dart';
import 'package:boltz_auth/src/models/User.dart';
import 'package:boltz_auth/src/repository/user_repo.dart';

class UserController extends GetxController implements GetxService {
  final UserRepo userRepo;
  UserController({required this.userRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _authorized = false;
  bool get isAuthorized => _authorized;
//
  User? _user;
  User? get user => _user;

  // Future<void> updateUserFullName(String name) async {
  //   Response response = await userRepo.updateName(name);
  //   if (response.statusCode == 200) {
  //     _user = User.fromJson(response.body);
  //   }
  // }

  Future<ResponseModel> getUserData() async {
    _isLoading = true;
    update();
    Response response = await userRepo.getUserProfileData();
    late ResponseModel responseModel;

    if (response.statusCode == 200) {
      _authorized = true;
      _user = User.fromJson(response.body['user']);
      responseModel = ResponseModel(true, 'Profile Fetched');
    } else {
      responseModel = ResponseModel(
          false, response.body['message'] ?? response.statusText!);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> clear() async {
    _authorized = false;
    _user = null;
  }
}
