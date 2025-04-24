

abstract class Device {

  init();

  Future<bool> setNativePermission() async {
    return true;
  }


}