

import 'package:flutter/material.dart';

class Dropdown {

  static void show<T>(BuildContext context, {required Widget widget}) {
    final safeArea = MediaQuery.of(context).padding.bottom;
    print('safeArea : $safeArea');
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            width: double.infinity,
            height: 250,
            child: Column(
              children: [
                Container(
                  width: 50, height: 4,
                  color: const Color(0xFFE5E6EB),
                ),
                const SizedBox(height: 20,),

                widget
              ],
            ),
          ),
        );
      },
    );
  }
}