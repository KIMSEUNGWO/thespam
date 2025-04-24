

import 'package:flutter/material.dart';
import 'package:spam2/component/FontTheme.dart';
import 'package:spam2/component/svg_icon.dart';
import 'package:spam2/enums/Status.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {

  late Status _status;


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            width: double.infinity, height: MediaQuery.of(context).size.height * 0.5,
            decoration: const BoxDecoration(
              color: Color(0xFFB7B7B7),
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
                  SvgIcon.asset(sIcon: SIcon.statusExit),
                  const SizedBox(height: 16,),
                  Text('권한을 설정해주세요.',
                    style: FontTheme.of(context,
                      size: FontSize.displayLarge,
                      color: Colors.white,
                      weight: FontWeight.w500
                    ),
                  ),
                  const SizedBox(height: 8,),
                  Container(
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
                ],
              ),
            ),
          ),
        ]
      ),
    );
  }
}
