import 'package:boltz_auth/src/controllers/auth_controller.dart';
import 'package:boltz_auth/src/core/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';

class LoginVerifyPage extends StatefulWidget {
  const LoginVerifyPage({super.key});
  static const routeName = '/verify';

  @override
  State<LoginVerifyPage> createState() => _LoginVerifyPageState();
}

class _LoginVerifyPageState extends State<LoginVerifyPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String verificationCode = "";
  final authController = Get.find<AuthController>();

  bool _onEditing = false;

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate()) return;

    var result = await authController.verifyLogin(verificationCode);

    if (result.isSuccess) {
      Get.offAllNamed('/');
    } else
      showCustomErrorSnackbar(result.message);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(title: Text("Verification"), centerTitle: true),
        body: Center(
          child: Container(
            width: size.width * 0.9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                const Center(
                  child: Text(
                    "Enter verification code send to your email",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Center(
                      child: VerificationCode(
                    textStyle:
                        TextStyle(fontSize: 20.0, color: Colors.red[900]),
                    keyboardType: TextInputType.number,
                    underlineColor: Colors
                        .amber, // If this is null it will use primaryColor: Colors.red from Theme
                    length: 6,
                    cursorColor: Colors
                        .blue, // If this is null it will default to the ambient
                    // clearAll is NOT required, you can delete it
                    // takes any widget, so you can implement your design
                    clearAll: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'clear all',
                        style: TextStyle(
                            fontSize: 14.0,
                            decoration: TextDecoration.underline,
                            color: Colors.blue[700]),
                      ),
                    ),
                    onCompleted: (String value) {
                      setState(() {
                        verificationCode = value;
                        // _onEditing = false;
                      });
                    },
                    onEditing: (bool value) {
                      setState(() {
                        _onEditing = value;
                      });
                      if (!_onEditing) FocusScope.of(context).unfocus();
                    },
                  )),
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: (_onEditing || authController.isLoading)
                      ? null
                      : _handleVerify,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // _authController.isLoading
                      //     ? SizedBox(
                      //         height: 20,
                      //         width: 20,
                      //         child: CircularProgressIndicator(
                      //           strokeWidth: 2,
                      //         ),
                      //       )
                      //     : Container(),
                      SizedBox(width: 10),
                      Text(
                        "Verify",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
