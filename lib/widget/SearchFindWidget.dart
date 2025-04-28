
import 'package:flutter/material.dart';
import 'package:spam2/api/SearchService.dart';
import 'package:spam2/component/FontTheme.dart';
import 'package:spam2/component/svg_icon.dart';
import 'package:spam2/domain/SearchResult.dart';

class SearchFindWidget extends StatefulWidget {
  final String phoneNumber;
  const SearchFindWidget({super.key, required this.phoneNumber});

  @override
  State<SearchFindWidget> createState() => _SearchFindWidgetState();
}

class _SearchFindWidgetState extends State<SearchFindWidget> {

  late final SearchResult _result;

  init() async {
    // final stopwatch = Stopwatch()..start();
    // await SearchService().get('010-1234-5678');
    // _result = await SearchService().search(phoneNumber: widget.phoneNumber);
    // stopwatch.stop();
    // print('요청-응답 소요 시간: ${stopwatch.elapsedMilliseconds} ms');
  }
  @override
  void initState() {
    init();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {

                  },
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgIcon.asset(sIcon: SIcon.block),
                        const SizedBox(height: 4,),
                        Text('차단',
                          style: FontTheme.of(context,
                            fontColor: FontColor.f2,
                            size: FontSize.bodySmall,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10,),
              Expanded(
                child: GestureDetector(
                  onTap: () {

                  },
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgIcon.asset(sIcon: SIcon.report),
                        const SizedBox(height: 4,),
                        Text('평가',
                          style: FontTheme.of(context,
                            fontColor: FontColor.f2,
                            size: FontSize.bodySmall,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
