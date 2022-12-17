import 'package:boltz_auth/src/controllers/remote_auth_controller.dart';
import 'package:boltz_auth/src/controllers/settings_controller.dart';
import 'package:boltz_auth/src/repository/user_repo.dart';
import 'package:get/get.dart';
import 'package:boltz_auth/src/controllers/auth_controller.dart';
// import 'package:boltz_auth/src/controllers/settings_controller.dart';
import 'package:boltz_auth/src/core/api_client.dart';
import 'package:boltz_auth/src/repository/auth_repo.dart';

import 'package:boltz_auth/src/services/settings_service.dart';
import 'package:boltz_auth/src/utils/constants.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  final storage = const FlutterSecureStorage();
  final _authToken = await storage.read(key: "userSession");

  Get.lazyPut(() => sharedPreferences);
  Get.lazyPut(() => storage);
  //api client
  Get.lazyPut(
      () => ApiClient(appBaseUrl: AppConstants.apiBASEURL, token: _authToken));

  Get.lazyPut(() => AuthRepo(apiClient: Get.find(), storage: Get.find()));

  //repos
  Get.lazyPut(() => UserRepo(apiClient: Get.find()));

  //service
  Get.lazyPut(() =>
      SettingsService(sharedPreferences: Get.find(), storage: Get.find()));

  // controllers
  Get.lazyPut(() => SettingsController(Get.find()));
  Get.lazyPut(() => AuthController(authRepo: Get.find(), storage: Get.find()));

  Get.lazyPut(() =>
      BoltzRemoteAuthController(authRepo: Get.find(), storage: Get.find()));
}
