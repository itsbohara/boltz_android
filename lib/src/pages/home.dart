import 'package:boltz_auth/src/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/simple_icons.dart';

class BoltzHome extends StatefulWidget {
  const BoltzHome({super.key});

  static const routeName = '/home';

  @override
  State<BoltzHome> createState() => _BoltzHomeState();
}

class _BoltzHomeState extends State<BoltzHome> {
  final authController = Get.find<AuthController>();

  void logout() async {
    await authController.logoutUser();
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Boltz Authentication"),
          centerTitle: true,
          actions: [
            IconButton(onPressed: logout, icon: Icon(Icons.logout_outlined))
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                Text(
                  "👋🏻 Hello ${authController.user!.name},",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w600),
                ),
                Text(
                  "Welcome to Boltz",
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 60),
                Text(
                  textAlign: TextAlign.center,
                  "Tap on floating button to start authentication using boltz",
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () => Get.toNamed('/scanQR'),
            tooltip: 'Increment',
            child: Iconify(SimpleIcons.authy) // widget,
            ));
  }
}
