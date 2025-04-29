
import 'package:spam2/component/HiveBox.dart';
import 'package:spam2/component/InitConfig.dart';
import 'package:spam2/component/channel/BlockedNumberHandler.dart';

class InitManager {

  final List<InitConfig> _initList = [
    HiveBox()
  ];

  init() async {
    BlockedNumberHandler();
    for (var entity in _initList) {
      await entity.init();
    }
  }


}