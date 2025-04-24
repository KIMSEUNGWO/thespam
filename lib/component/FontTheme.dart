

import 'package:flutter/material.dart';

class FontTheme {

  FontTheme._private();

  static TextStyle of(BuildContext context, {FontWeight? weight, FontSize? size, FontColor? fontColor, Color? color, String? fontFamily, TextDecoration? decoration}) {
    return TextStyle(
      color: fontColor?.get(context) ?? color,
      fontWeight: weight,
      fontSize: size?.get(context),
      height: 1.4,
      fontFamily: fontFamily,
      decoration: decoration
    );
  }

}

enum FontColor {

  f1,
  f2,
  f3,
  main,
  main2;

  Color get(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;
    return switch(this) {
      FontColor.f1 => colorTheme.primary,
      FontColor.f2 => colorTheme.secondary,
      FontColor.f3 => colorTheme.tertiary,
      FontColor.main => colorTheme.onPrimary,
      FontColor.main2 => colorTheme.onSecondary,
    };
  }
}

enum FontSize {
  displayLarge,
  displayMedium,
  displaySmall,

  bodyLarge,
  bodyMedium,
  bodySmall,;

  double? get(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return switch(this) {
      FontSize.displayLarge => textTheme.displayLarge!.fontSize,
      FontSize.displayMedium => textTheme.displayMedium!.fontSize,
      FontSize.displaySmall => textTheme.displaySmall!.fontSize,
      FontSize.bodyLarge => textTheme.bodyLarge!.fontSize,
      FontSize.bodyMedium => textTheme.bodyMedium!.fontSize,
      FontSize.bodySmall => textTheme.bodySmall!.fontSize,
    };
  }

}
