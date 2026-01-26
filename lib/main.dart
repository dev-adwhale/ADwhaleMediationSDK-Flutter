import 'package:flutter/material.dart';
import 'package:adwhale_sdk_flutter/adwhale_sdk_flutter.dart';

import 'guide_sample.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final result = await AdWhaleMediationAds.instance.initialize();
  debugPrint('AdWhale SDK 초기화 결과: $result');

  if (result.isSuccess) {
    runApp(const MyApp());
  } else {
    // 초기화 실패 시 에러 화면 표시
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'SDK 초기화 실패\nstatusCode: ${result.statusCode}\nmessage: ${result.message}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainMenuPage(),
    );
  }
}

/// QA 샘플앱(`activity_main.xml`)의 메인 화면과 동일한 구성을 가진 Flutter 메인 메뉴.
class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCenterButton(
                context,
                text: '기본 배너, 전면, 보상형, 네이티브, 앱오프닝 테스트',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GuideSamplePage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterButton(
      BuildContext context, {
        required String text,
        required VoidCallback onPressed,
      }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6739F5), // 스크린샷과 비슷한 보라색
        foregroundColor: Colors.white, // 텍스트/아이콘 색상
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }
}
