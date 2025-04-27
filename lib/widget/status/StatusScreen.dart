

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spam2/component/FontTheme.dart';
import 'package:spam2/component/svg_icon.dart';
import 'package:spam2/component/toogle_button.dart';
import 'package:spam2/enums/Status.dart';
import 'package:spam2/notifier/ServiceNotifier.dart';

class StatusScreen extends ConsumerStatefulWidget {
  final Function(bool loading) loading;
  const StatusScreen({super.key, required this.loading});

  @override
  createState() => _StatusScreenState();
}

class _StatusScreenState extends ConsumerState<StatusScreen> {

  _toggle(bool isOn) async {
    if (isOn) {
      await ref.read(serviceNotifier.notifier).startService();
    } else {
      await ref.read(serviceNotifier.notifier).stopService();
    }
  }

  _requestPermissions() async {
    widget.loading(true);
    await ref.read(serviceNotifier.notifier).requestPermissions();
    widget.loading(false);
  }

  @override
  Widget build(BuildContext context) {
    Status status = ref.watch(serviceNotifier);
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            width: double.infinity, height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              color: status.backgroundColor,
            ),
          ),

          Container(
            width: double.infinity, height: MediaQuery.of(context).size.height * 0.5,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(0),
                  Colors.black.withAlpha(130),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgIcon.asset(sIcon: status.icon),
                  const SizedBox(height: 16,),
                  Text(status.title,
                    style: FontTheme.of(context,
                      size: FontSize.displayLarge,
                      color: Colors.white,
                      weight: FontWeight.w500
                    ),
                  ),
                  const SizedBox(height: 8,),
                  if (status != Status.NONE)
                    ToggleButton(
                      callback: () => status == Status.PROTECT,
                      onChanged: _toggle,
                      decoration: ToggleDecoration(
                        width: 50,
                        height: 30,
                        color: const Color(0xFF41BA45)
                      ),
                    ),
                  if (status == Status.NONE)
                    GestureDetector(
                      onTap: () {
                        _requestPermissions();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100)
                        ),
                        child: Text('권한 설정하기',
                          style: FontTheme.of(context,
                            size: FontSize.bodyMedium,
                            fontColor: FontColor.f1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ]
      ),
    );
  }
}
