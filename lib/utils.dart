import 'dart:convert';
import 'dart:io' show Platform;

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';

Future<String> getUniqueUserId() async {
  String? deviceID;
  final deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    final iosDeviceInfo = await deviceInfo.iosInfo;
    deviceID = iosDeviceInfo.identifierForVendor;
  } else if (Platform.isAndroid) {
    final androidDeviceInfo = await deviceInfo.androidInfo;
    deviceID = androidDeviceInfo.id;
  }

  if (deviceID != null && deviceID.length < 4) {
    if (Platform.isAndroid) {
      deviceID += '_android';
    } else if (Platform.isIOS) {
      deviceID += '_ios___';
    }
  }
  if (Platform.isAndroid) {
    deviceID ??= 'flutter_user_id_android';
  } else if (Platform.isIOS) {
    deviceID ??= 'flutter_user_id_ios';
  }

  final userID = sha256
      .convert(utf8.encode(deviceID!))
      .toString()
      .replaceAll(RegExp(r'[^0-9]'), '');
  return userID.substring(0, 10);
}
