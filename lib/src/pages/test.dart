import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class BioAuthTestPage extends StatefulWidget {
  const BioAuthTestPage({super.key});

  @override
  State<BioAuthTestPage> createState() => _BioTestPageState();
}

class _BioTestPageState extends State<BioAuthTestPage> {
  late bool bioSupported;

  final LocalAuthentication auth = LocalAuthentication();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkBioSupport();
  }

  void checkBioSupport() async {
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    setState(() => bioSupported = canAuthenticate);
  }

  void fingerAuth() async {
    if (!bioSupported) return;
    print("usgin fingerprint authentication");

    try {
      final bool didAuthenticate = await auth.authenticate(
          // localizedReason: "Authenticate Boltz login on ..xxx.. app ",
          localizedReason: 'Please authenticate to login on ..',
          options: const AuthenticationOptions(biometricOnly: true),
          authMessages: const <AuthMessages>[
            AndroidAuthMessages(
              signInTitle: 'Biometric authentication required!',
              cancelButton: 'No thanks',
            )
          ]);
      print('didAuthenticate: ${didAuthenticate}');
    } on PlatformException catch (e) {
      print(e.code);
      print("error here");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Boltzz Test '),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            OutlinedButton(onPressed: fingerAuth, child: Text("Authorize "))
          ],
        ),
      ),
    );
  }
}
