
import 'package:flutter/material.dart';
import 'package:spam2/component/FontTheme.dart';
import 'package:spam2/component/dropdown.dart';
import 'package:spam2/component/formatter/FormatType.dart';
import 'package:spam2/component/svg_icon.dart';
import 'package:spam2/widget/SearchFindWidget.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {

  final TextEditingController _controller = TextEditingController();
  final FormatType _formatType = FormatType.KR;
  bool _canSearch = false;

  _search() {
    final phoneNumber = _controller.text.replaceAll(RegExp(r'[^\d]'), '');
    _controller.text = '';
    Dropdown.show(context,
      widget: SearchFindWidget(phoneNumber: phoneNumber),
    );
  }
  _phoneNumberChanged(String text) {
    _controller.text = _formatType.format(text, ' ');

    setState(() {
      _canSearch = _controller.text.isNotEmpty;
    });

  }

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
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
                  onChanged: _phoneNumberChanged,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: FontTheme.of(context,
                    fontColor: FontColor.f1,
                    size: FontSize.bodyLarge,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
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
        bottomNavigationBar: SafeArea(
          child: GestureDetector(
            onTap: () {
              if (_canSearch) {
                _search();
              }
            },
            child: Container(
              height: 50,
              margin: EdgeInsets.only(
                left: 20, right: 20,
                bottom: keyboardHeight + 10
              ),
              decoration: BoxDecoration(
                color: _canSearch
                  ? Theme.of(context).colorScheme.onPrimary
                  : Colors.grey,
                borderRadius: BorderRadius.circular(16)
              ),
              child: Center(
                child: Text('조회하기',
                  style: FontTheme.of(context,
                    color: Colors.white,
                    size: FontSize.bodyLarge,
                    weight: FontWeight.w500
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
