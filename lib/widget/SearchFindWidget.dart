
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spam2/api/SearchService.dart';
import 'package:spam2/component/FontTheme.dart';
import 'package:spam2/component/HiveBox.dart';
import 'package:spam2/component/formatter/FormatType.dart';
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
  final FormatType _formatType = FormatType.KR;
  bool _isLoading = true;

  late bool _isBlocked;
  bool _blockedLoading = false;

  _blockToggle() async {
    setState(() => _blockedLoading = true);
    if (_isBlocked) {
      await HiveBox().deleteBlockedNumber(_result.phone.phoneId);
    } else {
      await HiveBox().addBlockedNumber(_result.phone);
    }
    _isBlocked = !_isBlocked;
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _blockedLoading = false);

  }
  init() async {
    _result = await SearchService().search(phoneNumber: widget.phoneNumber);
    _isBlocked = HiveBox().isBlockedNumber(_result.phone.phoneNumber);
    print(_result.phone.phoneNumber);
    print('isBlocked : $_isBlocked');
    setState(() {
      _isLoading = false;
    });
  }
  @override
  void initState() {
    init();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CupertinoActivityIndicator();
    }
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SvgIcon.asset(sIcon: _result.phone.type.icon),
              const SizedBox(height: 7,),
              Text(_formatType.format(_result.phone.phoneNumber),
                style: FontTheme.of(context,
                  size: FontSize.bodyLarge,
                  weight: FontWeight.w500,
                  fontColor: FontColor.f1
                ),
              ),
              const SizedBox(height: 7,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgIcon.asset(sIcon: SIcon.notify, style: SvgIconStyle(color: _result.phone.type.color)),
                  const SizedBox(width: 4,),
                  Text(_result.phone.description,
                    style: FontTheme.of(context,
                      color: _result.phone.type.color,
                      size: FontSize.bodyMedium,
                    ),
                  )
                ],
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_blockedLoading) return;
                    _blockToggle();
                  },
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _blockedLoading ? const CupertinoActivityIndicator(radius: 8,) :
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgIcon.asset(sIcon: _isBlocked ? SIcon.unblock : SIcon.block),
                          const SizedBox(height: 4,),
                          Text(_isBlocked ? '차단해제' : '차단',
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
                    if (_blockedLoading) return;
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
