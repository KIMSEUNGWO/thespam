import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {

  final SvgPicture svgPicture;

  const SvgIcon.privateConstructor(this.svgPicture, {super.key});

  static SvgIcon asset({required SIcon sIcon, SvgIconStyle? style,}) {
    return _SvgIconBuilder(sIcon: sIcon).build(style);
  }

  @override
  Widget build(BuildContext context) {
    return svgPicture;
  }

}

class SvgIconStyle {

  double? width;
  double? height;
  Color? color;
  BoxFit? fit;
  BlendMode? blendMode;

  SvgIconStyle({this.width, this.height, this.color, this.fit, this.blendMode});

}

class SIcon {

  final String picture;
  final double width;
  final double height;

  const SIcon({required this.picture, required this.width, required this.height});

  static const SIcon gear = SIcon(picture: 'assets/icons/gear.svg', width: 28, height: 28);
  static const SIcon search = SIcon(picture: 'assets/icons/search.svg', width: 24, height: 24);
  static const SIcon clock = SIcon(picture: 'assets/icons/menu_clock.svg', width: 20, height: 20);
  static const SIcon block = SIcon(picture: 'assets/icons/menu_block.svg', width: 20, height: 20);
  static const SIcon notify = SIcon(picture: 'assets/icons/notify.svg', width: 16, height: 16);
  static const SIcon report = SIcon(picture: 'assets/icons/report.svg', width: 22, height: 22);

  static const SIcon toggleProtect = SIcon(picture: 'assets/icons/toggle_protect.svg', width: 26, height: 26);
  static const SIcon toggleStop = SIcon(picture: 'assets/icons/toggle_stop.svg', width: 26, height: 26);

  static const SIcon statusExit = SIcon(picture: 'assets/icons/status_exit.svg', width: 80, height: 80);
  static const SIcon statusProtect = SIcon(picture: 'assets/icons/status_protect.svg', width: 80, height: 80);
  static const SIcon statusStop = SIcon(picture: 'assets/icons/status_stop.svg', width: 80, height: 80);


  static const SIcon flagKr = SIcon(picture: 'assets/icons/flags/kr.svg', width: 32, height: 24);

  static const SIcon searchNotFound = SIcon(picture: 'assets/icons/search_notfound.svg', width: 50, height: 50);
  static const SIcon searchWarning = SIcon(picture: 'assets/icons/search_warning.svg', width: 50, height: 50);
  static const SIcon searchSafe = SIcon(picture: 'assets/icons/search_safe.svg', width: 50, height: 50);



}


class _SvgIconBuilder {

  final SIcon sIcon;

  _SvgIconBuilder({required this.sIcon});

  SvgIcon build(SvgIconStyle? style) {
    return SvgIcon.privateConstructor(SvgPicture.asset(sIcon.picture,
        width: style?.width ?? sIcon.width,
        height: style?.height ?? sIcon.height,
        fit: style?.fit ?? BoxFit.contain,
        colorFilter: style == null || style.color == null ? null : ColorFilter.mode(style.color!, style.blendMode ?? BlendMode.srcIn),
    ));
  }

}