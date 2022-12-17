import 'dart:convert';

import 'package:boltz_auth/src/controllers/auth_controller.dart';
import 'package:boltz_auth/src/controllers/remote_auth_controller.dart';
import 'package:boltz_auth/src/core/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

import 'package:socket_io_client/socket_io_client.dart' as IO;

class BoltzAuthPage extends StatefulWidget {
  BoltzAuthPage({super.key, required this.auth});

  static const routeName = '/boltz-auth';

  String auth;

  @override
  State<BoltzAuthPage> createState() => _BoltzAuthPageState();
}

class _BoltzAuthPageState extends State<BoltzAuthPage> {
  String app = "Boltz Auth";
  late String connectionHash;
  bool authenticating = false;

  final _auth = Get.find<BoltzRemoteAuthController>();

  // bio auth
  final LocalAuthentication auth = LocalAuthentication();
  late bool bioSupported;

  bool authorized = false;
  bool usedAuth = false;
  bool authError = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() => bioAuthentication());
  }

  void bioAuthentication() async {
    try {
      decodeQR();
      await _auth.initializeAuth();
      listenSocketConn();
      initAuthentication();
      initBiometricAuthentication();
    } catch (e) {
      setState(() => authError = true);
      showCustomErrorSnackbar("Unable to process boltz authentication!");
    }
  }

  void decodeQR() {
    var data = jsonDecode(widget.auth);
    setState(() {
      app = data['app'];
      connectionHash = data['hash'];
    });
  }

  void listenSocketConn() {
    _auth.socket!.on("boltz@auth:failed", (message) {
      setState(() {
        authenticating = false;
        usedAuth = true;
      });
      Get.defaultDialog(
        title: "Invalid request!",
        middleText: message,
        barrierDismissible: false,
        cancel: OutlinedButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: const Text("Ok")),
      );
    });

    _auth.socket!.on("connect_error", (data) {
      print("Unable to connect auth server");
      setState(() => usedAuth = true);
    });
    _auth.socket!.on("boltz@auth:authorized", (data) {
      setState(() {
        authorized = true;
        authenticating = false;
        usedAuth = true;
      });
      returnOnAuthorized();
    });
  }

  // close this page on timeout when authorized
  void returnOnAuthorized() async {
    await Future.delayed(const Duration(seconds: 3));
    Get.back();
  }

  void initAuthentication() {
    _auth.socket!.emit("boltz@auth:app_init", connectionHash);
  }

  Future verifyAuthentication() async {
    bool isSocketConnected = _auth.socketConnected;
    if (!isSocketConnected) {
      isSocketConnected = _auth.connectSocket().connected;
    }
    if (isSocketConnected) {
      _auth.socket!.emit("boltz@auth:authenticate", connectionHash);
    }
  }

  void initBiometricAuthentication() async {
    await checkBioSupport();
    if (!bioSupported || authError) {
      print("Biometric authentication not supported/failed!");
      return;
    }
    try {
      final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Please authenticate to login on ${app}',
          options: const AuthenticationOptions(biometricOnly: true),
          authMessages: const <AuthMessages>[
            AndroidAuthMessages(
              signInTitle: 'Biometric authentication required!',
              cancelButton: 'No thanks',
            )
          ]);

      if (didAuthenticate) {
        verifyAuthentication();
        setState(() => authenticating = didAuthenticate);
      }
    } on PlatformException catch (e) {
      print(e.code);
      print("local bio auth error here");
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _auth.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(app),
        centerTitle: true,
      ),
      body: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          (usedAuth && !authorized)
              ? const Text("Couldn't process authentication! ")
              : Container(),
          usedAuth
              ? Text("Authentication ${authorized ? "Success" : "Failed"}!",
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(fontWeight: FontWeight.w500))
              : Container(),
          const SizedBox(height: 20),
          !authorized
              ? ElevatedButton(
                  onPressed: initBiometricAuthentication,
                  child: const Text("Authorize"))
              : Container()
        ],
      )),
    );
  }

  Future checkBioSupport() async {
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    setState(() => bioSupported = canAuthenticate);
  }
}
