import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:boltz_auth/src/controllers/auth_controller.dart';

class Boot extends StatefulWidget {
  const Boot({super.key});

  static const routeName = '/';

  @override
  State<Boot> createState() => _BootState();
}

class _BootState extends State<Boot> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAuthUser();
  }

  Future<void> initAuthUser() async {
    final authController = Get.find<AuthController>();
    await authController.initAuthUser();
    if (!authController.isAuthorized) {
      Get.offAndToNamed('/login');
      return;
    }
    Get.offAndToNamed('/home');
  }

  Widget BoltzLogo() {
    return Container(
      child: Image.asset('assets/logo/boltz-logo.png',
          width: MediaQuery.of(context).size.width * 0.22),
    );
  }

  Widget _boltz() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BoltzLogo(),
        SizedBox(height: 30),
        Text("Boltz Authentication",
            style: Theme.of(context)
                .textTheme
                .headline5!
                .copyWith(fontWeight: FontWeight.w500))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _boltz()),
    );

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SizedBox(height: 50),
            // CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
