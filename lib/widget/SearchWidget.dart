
import 'package:flutter/material.dart';
import 'package:spam2/component/FontTheme.dart';
import 'package:spam2/component/svg_icon.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {

  final TextEditingController _controller = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('번호 조회'),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 26, left: 20, right: 20),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8FA),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [

            Row(
              children: [
                Row(
                  children: [
                    SvgIcon.asset(sIcon: SIcon.flagKr),
                    const SizedBox(width: 4,),
                    Text('+82',
                      style: FontTheme.of(context,
                        fontColor: FontColor.f1,
                        size: FontSize.bodyLarge
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 6,),
                Icon(Icons.keyboard_arrow_down_rounded, size: 18,
                  color: FontColor.f3.get(context),
                ),
              ],
            ),
            const SizedBox(width: 10,),
            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                style: FontTheme.of(context,
                  fontColor: FontColor.f1,
                  size: FontSize.bodyLarge,
                ),
                decoration: InputDecoration(
                  isDense: true, // 이 속성이 중요! 더 작은 높이를 제공합니다
                  contentPadding: EdgeInsets.zero, // 내부 패딩 제거
                  hintText: '번호를 입력해주세요..',
                  hintStyle: FontTheme.of(context,
                    fontColor: FontColor.f3,
                    size: FontSize.bodyLarge,
                  ),
                  hintMaxLines: 1,
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                  errorBorder: const OutlineInputBorder(borderSide: BorderSide.none),

                ),
              ),
            ),

          ],
        )
      ),
    );
  }
}
