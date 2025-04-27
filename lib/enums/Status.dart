
import 'dart:ui';

import 'package:spam2/component/svg_icon.dart';

enum Status {

  NONE(backgroundColor: Color(0xFFB7B7B7), icon: SIcon.statusExit, title: '권한을 설정해주세요.'),
  STOP(backgroundColor: Color(0xFFF04646), icon: SIcon.statusStop, title: '중지됨'),
  PROTECT(backgroundColor: Color(0xFF58CD6D), icon: SIcon.statusProtect, title: '보호중'),

  ;
  final Color backgroundColor;
  final SIcon icon;
  final String title;

  const Status({required this.backgroundColor, required this.icon, required this.title});



}