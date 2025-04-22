import 'package:flutter/material.dart';
import 'package:spam2/component/CallDetectionService.dart';
import 'package:spam2/component/callkit_component.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CallkitComponent().init();
  await CallDetectionService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('통화 앱 예제'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await CallkitComponent().showCallkit('01012341234');
                },
                child: Text('테스트 전화 받기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
