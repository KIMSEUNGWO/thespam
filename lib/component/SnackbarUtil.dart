

import 'package:flutter/material.dart';

class SnackbarUtil {

  static show(BuildContext context, Widget widget) {
    final snackbar = SnackBar(
      content: widget,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      backgroundColor: Colors.black.withAlpha(170),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)
      ),
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      snackbar,
    );
  }
}