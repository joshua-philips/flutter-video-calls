import 'package:axxend_video/simple_text_field.dart';
import 'package:axxend_video/utils.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import 'constants.dart';
import 'login_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _numberTextController = TextEditingController(text: 'user_id');

  @override
  void initState() {
    super.initState();

    getUniqueUserId().then((userID) async {
      setState(() {
        _numberTextController.text = userID;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        onPopInvoked: (pop) {
          ZegoUIKit().onWillPop(context);
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome to",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 24,
                  ),
                ),
                const Text(
                  "Video Calls",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 40,
                  ),
                ),
                const Text(
                  "Enter a number to start. Preferably your phone number but any number is also accepted. It will be used to identify you on the network",
                  style: TextStyle(
                    fontWeight: FontWeight.w200,
                  ),
                ),
                const SizedBox(height: 50),
                SimpleTextField(
                  textEditingController: _numberTextController,
                  labelText: "Phone Number (Identification)",
                  textInputType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (_numberTextController.text.isEmpty) {
                    } else if (_numberTextController.text.length != 10) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Your number must have 10 digits")));
                    } else {
                      login(
                        userID: _numberTextController.text,
                        userName: _numberTextController.text,
                      ).then((value) {
                        onUserLogin();
                        Navigator.pushReplacementNamed(
                          context,
                          PageRouteNames.home,
                        );
                      });
                    }
                  },
                  child: const Text('Get Started', style: textStyle),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
