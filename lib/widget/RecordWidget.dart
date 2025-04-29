
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:spam2/component/FontTheme.dart';
import 'package:spam2/component/HiveBox.dart';
import 'package:spam2/component/formatter/FormatType.dart';
import 'package:spam2/component/svg_icon.dart';
import 'package:spam2/domain/Phone.dart';
import 'package:spam2/entity/PhoneRecord.dart';
import 'package:spam2/entity/RecordType.dart';

class RecordWidget extends StatefulWidget {
  const RecordWidget({super.key});

  @override
  State<RecordWidget> createState() => _RecordWidgetState();
}

class _RecordWidgetState extends State<RecordWidget> {

  bool _isLoading = true;
  late final List<PhoneRecord> _records;

  _init() {
    // _records = HiveBox().getRecords();
    final a = PhoneRecord.toRecord(example(PhoneType.SPAM), RecordType.MISSED_CALL, false, 215);
    a.addCount(12);
    a.addCount(45);
    a.addCount(1510);
    final b = PhoneRecord.toRecord(example(PhoneType.SPAM), RecordType.MISSED_CALL, false, 215);
    b.addCount(0);
    b.addCount(0);
    b.addCount(0);
    b.addCount(0);
    b.addCount(0);
    b.addCount(0);
    b.addCount(0);
    b.addCount(0);
    final c = PhoneRecord(1, example(PhoneType.SPAM), RecordType.CALL, false);
    c.detail.add(PhoneRecordDetail(seconds: 123, time: DateTime(2025, 4, 20)));
    final d = PhoneRecord(2, example(PhoneType.SPAM), RecordType.CALL, false);
    d.detail.add(PhoneRecordDetail(seconds: 123, time: DateTime.now().subtract(const Duration(days: 2))));
    final e = PhoneRecord(3, example(PhoneType.SPAM), RecordType.MISSED_CALL, true);
    e.detail.add(PhoneRecordDetail(seconds: 123, time: DateTime.now().subtract(const Duration(days: 1))));
    final list = [
      PhoneRecord.toRecord(example(PhoneType.SPAM), RecordType.CALL, false, 215),
      PhoneRecord.toRecord(example(PhoneType.SPAM), RecordType.MISSED_CALL, false, 215),
      PhoneRecord.toRecord(example(PhoneType.SPAM), RecordType.MISSED_CALL, false, 215),
      PhoneRecord.toRecord(example(PhoneType.SPAM), RecordType.MISSED_CALL, false, 215),
      PhoneRecord.toRecord(example(PhoneType.SPAM), RecordType.MISSED_CALL, false, 215),

    ];
    list.add(a);
    list.add(b);
    list.add(a);
    list.add(e);
    list.add(d);
    list.add(c);

    _records = list;
    setState(() => _isLoading = false);
  }

  Phone example(PhoneType type) {
    return Phone(phoneId: 1, phoneNumber: '01012345678', type: type, description: '테스트');
  }

  _onDelete(PhoneRecord record) {
    setState(() {
      _records.remove(record);
    });
    print('length : ${_records.length}');
  }

  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    // 같은 날짜인지 확인 (오늘)
    if (dateTime.year == today.year && dateTime.month == today.month && dateTime.day == today.day) {
      // 시간만 반환 (21:46 형식)
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }

    // 어제인지 확인
    if (dateTime.year == yesterday.year && dateTime.month == yesterday.month && dateTime.day == yesterday.day) {
      return '어제';
    }

    // 이번 주인지 확인
    if (dateTime.isAfter(weekStart) || dateTime.isAtSameMomentAs(weekStart)) {
      // 요일 반환
      final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
      return weekdays[dateTime.weekday - 1]; // weekday는 1(월요일)부터 시작
    }

    // 그 외의 경우 YYYY. MM. DD 형식으로 반환
    return '${dateTime.year}. ${dateTime.month}. ${dateTime.day}';
  }

  @override
  void initState() {
    _init();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('통화 기록'),
      ),
      body: _isLoading ? const CupertinoActivityIndicator() :
        ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 3,),
          itemCount: _records.length,
          itemBuilder: (context, index) {
            final record = _records[index];
            return Slidable(
              key: UniqueKey(),
              closeOnScroll: true,
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.2,
                dismissible: DismissiblePane(
                  dismissThreshold: 0.5,
                  onDismissed: () {
                    _onDelete(record);
                  },
                ),
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      _onDelete(record);
                    },
                    backgroundColor: Color(0xFFED6666),
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                  ),
                ],
              ),
              child: ElevatedButton(
                style: const ButtonStyle(
                  // 배경색 제거
                  backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                  // 그림자 제거
                  elevation: WidgetStatePropertyAll(0),
                  // 패딩 제거
                  padding: WidgetStatePropertyAll(EdgeInsets.zero),
                  // 테두리 제거
                  side: WidgetStatePropertyAll(BorderSide.none),
                  // 모서리 둥글기 제거
                  shape: WidgetStatePropertyAll(BeveledRectangleBorder()),
                  // 최소 크기 제거
                  minimumSize: WidgetStatePropertyAll(Size.zero),
                  // 그림자 색상 제거
                  shadowColor: WidgetStatePropertyAll(Colors.transparent),
                  // 내부 패딩(tapTargetSize) 최소화
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {

                },
                child: Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SvgIcon.asset(sIcon: record.phone.type.icon,
                            style: SvgIconStyle(width: 40, height: 40)
                          ),
                          const SizedBox(width: 12,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(FormatType.KR.format(record.phone.phoneNumber),
                                style: FontTheme.of(context,
                                  fontColor: record.isBlocked || record.type == RecordType.MISSED_CALL ? null : FontColor.f1,
                                  color: record.isBlocked || record.type == RecordType.MISSED_CALL ? const Color(0xFFE42323) : null,
                                  weight: FontWeight.w500,
                                  size: FontSize.bodyLarge,
                                ),
                              ),
                              const SizedBox(height: 2,),
                              Row(
                                children: [
                                  if (record.isBlocked)
                                    Text('차단됨',
                                      style: FontTheme.of(context,
                                        color: const Color(0xFFE42323),
                                        weight: FontWeight.w500,
                                        size: FontSize.bodyMedium,
                                      ),
                                    ),
                                  if (record.isBlocked)
                                    Container(
                                      width: 2, height: 2,
                                      margin: const EdgeInsets.symmetric(horizontal: 6),
                                      decoration: BoxDecoration(
                                        color: FontColor.f3.get(context)
                                      ),
                                    ),
                                  Text(record.phone.description,
                                    style: FontTheme.of(context,
                                      fontColor: FontColor.f3,
                                      weight: FontWeight.w500,
                                      size: FontSize.bodyMedium,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),

                      Row(
                        children: [
                          Text(formatDateTime(record.detail.last.time,),
                            style: FontTheme.of(context,
                              fontColor: FontColor.f3,
                              weight: FontWeight.w400,
                              size: FontSize.bodyMedium,
                            ),
                          ),
                          const SizedBox(width: 4,),
                          SvgIcon.asset(sIcon: SIcon.info)
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
    );
  }
}
