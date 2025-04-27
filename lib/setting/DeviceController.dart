
import 'dart:io';

import 'package:spam2/setting/AndroidDevice.dart';
import 'package:spam2/setting/Device.dart';
import 'package:spam2/setting/IOSDevice.dart';

class DeviceHelper {

  static final DeviceHelper _instance = DeviceHelper._internal();
  factory DeviceHelper() => _instance;

  late final Device device;

  DeviceHelper._internal();

  init() {
    device =  Platform.isAndroid ? AndroidDevice() :
              Platform.isIOS ? IOSDevice() :
              throw UnimplementedError();
  }

}