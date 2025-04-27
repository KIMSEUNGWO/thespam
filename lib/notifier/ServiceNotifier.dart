
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spam2/enums/Status.dart';
import 'package:spam2/setting/DeviceController.dart';

class ServiceNotifier extends StateNotifier<Status> {
  ServiceNotifier() : super(Status.NONE);


  init() async {
    await DeviceHelper().device.init();
    final hasPermission = await DeviceHelper().device.checkPermission();
    await _setState(hasPermission);
  }

  requestPermissions() async {
    bool hasPermission = await DeviceHelper().device.requestPermissions();
    await _setState(hasPermission);
  }

  _setState(bool permission) async {
    if (!permission) {
      state = Status.NONE;
      return;
    }
    bool isRunning = await isServiceRunning();
    if (isRunning) {
      state = Status.PROTECT;
    } else {
      state = Status.STOP;
    }
  }

  Status getStatus() {
    return state;
  }

  Future<bool> isServiceRunning() async {
    return await DeviceHelper().device.isServiceRunning();
  }

  Future<bool> startService() async {
    final result = await DeviceHelper().device.startService();
    state = result ? Status.PROTECT : Status.STOP;
    return result;
  }

  Future<bool> stopService() async {
    final result = await DeviceHelper().device.stopService();
    state = result ? Status.STOP : Status.PROTECT;
    return result;
  }


}

final serviceNotifier = StateNotifierProvider<ServiceNotifier, Status>((ref) => ServiceNotifier());
