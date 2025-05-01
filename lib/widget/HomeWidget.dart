

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spam2/component/FontTheme.dart';
import 'package:spam2/component/svg_icon.dart';
import 'package:spam2/notifier/ServiceNotifier.dart';
import 'package:spam2/widget/RecordWidget.dart';
import 'package:spam2/widget/SearchWidget.dart';
import 'package:spam2/widget/status/IOSStatusScreen.dart';
import 'package:spam2/widget/status/StatusScreen.dart';
import 'dart:math' as math;

class HomeWidget extends ConsumerStatefulWidget {
  const HomeWidget({super.key});

  @override
  createState() => _HomeWidgetState();
}

class _HomeWidgetState extends ConsumerState<HomeWidget> {

  bool _isLoading = false;

  _init() async {
    _setLoading(true);
    await ref.read(serviceNotifier.notifier).init();
    _setLoading(false);
  }
  _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double bottomWidgetHeight =  math.max(MediaQuery.of(context).size.height * 0.5 - 94, 0);
    return Stack(
      children: [
        Scaffold(
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            actions: [
              GestureDetector(
                onTap: () {

                },
                child: SvgIcon.asset(sIcon: SIcon.gear),
              ),
              const SizedBox(width: 20,),
            ],
          ),
          body: SizedBox(
            width: double.infinity,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0, right: 0,
                  child: Platform.isAndroid
                    ? StatusScreen(loading: _setLoading,)
                    : IOSStatusScreen(loading: _setLoading),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: bottomWidgetHeight,
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return const SearchWidget();
                          },));
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100)
                          ),
                          child: Row(
                            children: [
                              SvgIcon.asset(sIcon: SIcon.search),
                              const SizedBox(width: 14,),
                              Text('번호를 조회해보세요.',
                                style: FontTheme.of(context,
                                  color: const Color(0xFF767676),
                                  size: FontSize.bodyLarge,
                                  weight: FontWeight.w500
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14,),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(32),
                              topLeft: Radius.circular(32)
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 48, height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E6EB),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              const SizedBox(height: 26,),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return const RecordWidget();
                                  },));
                                },
                                child: Container(
                                  decoration: const BoxDecoration(),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SvgIcon.asset(sIcon: SIcon.clock),
                                          const SizedBox(width: 15,),
                                          Text('기록',
                                            style: FontTheme.of(context,
                                              size: FontSize.bodyLarge,
                                              weight: FontWeight.w500,
                                              fontColor: FontColor.f2
                                            ),
                                          )
                                        ],
                                      ),
                                      Icon(Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color: FontColor.f3.get(context),
                                      )

                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(

                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SvgIcon.asset(sIcon: SIcon.block),
                                          const SizedBox(width: 15,),
                                          Text('차단 목록',
                                            style: FontTheme.of(context,
                                                size: FontSize.bodyLarge,
                                                weight: FontWeight.w500,
                                                fontColor: FontColor.f2
                                            ),
                                          )
                                        ],
                                      ),
                                      Icon(Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color: FontColor.f3.get(context),
                                      )

                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
      ),

        if (_isLoading)
          Positioned(
            top: 0, left: 0, right: 0, bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50)
              ),
              child: const Center(child: CupertinoActivityIndicator()),
            ),
          ),
      ]
    );
  }
}
