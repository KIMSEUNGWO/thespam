

abstract class Device {

  init();

  Future<bool> setNativePermission() async {
    return true;
  }

  Future<bool> checkPermission();
  Future<bool> requestPermissions();
  Future<bool> startService();
  Future<bool> stopService();
  Future<bool> isServiceRunning();


}