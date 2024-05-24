import 'package:axxend_video/constants.dart';
import 'package:axxend_video/login_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final TextEditingController singleInviteeUserIDTextCtrl =
      TextEditingController();
  final TextEditingController groupInviteeUserIDsTextCtrl =
      TextEditingController();

  String _number = '';
  String _error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              child: Icon(Icons.person),
            ),
            const SizedBox(width: 15),
            Text(currentUser.id),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_sharp),
            iconSize: 20,
            onPressed: () {
              logout().then((value) {
                onUserLogout();
                Navigator.pushReplacementNamed(
                  context,
                  PageRouteNames.login,
                );
              });
            },
          )
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: PopScope(
        onPopInvoked: (pop) {
          ZegoUIKit().onWillPop(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    _number.isEmpty ? "0" : _number,
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  _error,
                  textAlign: TextAlign.center,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.4,
                      children: setKeyboard(),
                    ),
                  ),
                ),
                ZegoSendCallInvitationButton(
                  isVideoCall: true,
                  invitees: getInvitesFromTextCtrl(_number),
                  resourceID: "axxend_video",
                  iconSize: const Size(80, 80),
                  buttonSize: const Size(100, 100),
                  onPressed: onSendCallInvitationFinished,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _numberBtn(String number) {
    return TextButton(
      child: Text(
        number,
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: () {
        setState(() {
          if (_number.length == 10) {
            _number = _number;
            HapticFeedback.heavyImpact();
          } else {
            _number += number;
          }
        });
      },
    );
  }

  Widget _decimalBtn() {
    return TextButton(
      child: Text(
        '.',
        style: TextStyle(
          fontSize: 40,
          color: Theme.of(context).textTheme.bodyMedium!.color,
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: () {
        setState(() {
          if (_number == '0') {
            _number += '.';
          } else if (_number.length == 7) {
            _number = _number;
            HapticFeedback.heavyImpact();
          } else {
            _number += '.';
          }
        });
      },
    );
  }

  Widget _deleteBtn() {
    return TextButton(
      child: Icon(
        Icons.backspace_rounded,
        color: Theme.of(context).textTheme.bodyMedium!.color,
      ),
      onPressed: () {
        setState(() {
          if (_number.length <= 1) {
            _number = '';
          } else {
            _number = _number.substring(0, _number.length - 1);
          }
        });
      },
      onLongPress: () {
        HapticFeedback.heavyImpact();
        setState(() {
          _number = '0';
          _error = '';
        });
      },
    );
  }

  List<Widget> setKeyboard() {
    List<Widget> keyboard = [];

    // 1 - 9
    List.generate(9, (index) {
      keyboard.add(_numberBtn('${index + 1}'));
    });

    keyboard.add(_decimalBtn());
    keyboard.add(_numberBtn('0'));
    keyboard.add(_deleteBtn());

    return keyboard;
  }

  void onSendCallInvitationFinished(
    String code,
    String finishedMessage,
    List<String> errorInvitees,
  ) {
    if (errorInvitees.isNotEmpty) {
      setState(() {
        _error = "";
      });
      String userIDs = "";
      for (int index = 0; index < errorInvitees.length; index++) {
        if (index >= 5) {
          userIDs += '... ';
          break;
        }

        var userID = errorInvitees.elementAt(index);
        userIDs += '$userID ';
      }
      if (userIDs.isNotEmpty) {
        userIDs = userIDs.substring(0, userIDs.length - 1);
      }

      var message = 'User doesn\'t exist or is offline: $userIDs';
      if (code.isNotEmpty) {
        message = ', code: $code, message:$message';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } else if (code.isNotEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(finishedMessage)));
    } else {
      setState(() {
        _error = "Input the number to call";
      });
    }
  }
}

List<ZegoUIKitUser> getInvitesFromTextCtrl(String textCtrlText) {
  List<ZegoUIKitUser> invitees = [];

  var inviteeIDs = textCtrlText.trim().replaceAll('，', '');
  inviteeIDs.split(",").forEach((inviteeUserID) {
    if (inviteeUserID.isEmpty) {
      return;
    }

    invitees.add(ZegoUIKitUser(
      id: inviteeUserID,
      name: inviteeUserID,
    ));
  });

  return invitees;
}
