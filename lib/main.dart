import 'dart:io' show Platform;

import 'package:adwhale_sdk_flutter_sample/transition_popup_ad_test_page.dart';
import 'package:flutter/material.dart';
import 'package:adwhale_sdk_flutter/adwhale_sdk_flutter.dart';

import 'guide_sample.dart';

bool _exitPopupAdGuard = false;
bool _isExitPopupAdLoaded = false;

final AdWhaleExitPopupAd _exitPopupAd = AdWhaleExitPopupAd(
  placementUid: 'placement Uid 를 발급받으세요',
  adLoadCallback: AdWhaleExitPopupAdLoadCallback(
    onLoaded: () {
      debugPrint('ExitPopupAd onLoaded');
      _isExitPopupAdLoaded = true;
    },
    onLoadFailed: (errorCode, errorMessage) {
      debugPrint('ExitPopupAd onLoadFailed: $errorMessage');
      _isExitPopupAdLoaded = false;
    },
    onShowed: () {
      debugPrint('ExitPopupAd onShowed');
      _isExitPopupAdLoaded = false;
    },
    onShowFailed: (errorCode, errorMessage) {
      debugPrint('ExitPopupAd onShowFailed: $errorMessage');
      _isExitPopupAdLoaded = false;
    },
    onClosed: (reason) {
      debugPrint('ExitPopupAd onClosed reason=$reason');
      _isExitPopupAdLoaded = false;
    },
    onClicked: () {
      debugPrint('ExitPopupAd onClicked');
    },
  ),
)
  ..setCustomizeButtonText('테스트 취소', '테스트 종료')
  ..setCustomDescription('테스트 문구');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final result = await AdWhaleMediationAds.instance.initialize();
  debugPrint('AdWhale SDK 초기화 결과: $result');

  if (result.isSuccess) {
    // 앱 종료 광고(Exit Popup Ad)는 Android 전용 샘플입니다.
    if (Platform.isAndroid) {
      try {
        await _exitPopupAd.loadAd();
      } catch (e) {
        debugPrint('ExitPopupAd load failed: $e');
      }
    }
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
    final isAndroid = Platform.isAndroid;
    return WillPopScope(
        onWillPop: () async {
          if (!Platform.isAndroid) return true;
          if (_exitPopupAdGuard) return false;
          if (!_isExitPopupAdLoaded) return true;

          _exitPopupAdGuard = true;
          try {
            await _exitPopupAd.showAd();
            return false; // ExitPopupAd를 띄우므로 즉시 종료(pop)하지 않습니다.
          } catch (e) {
            debugPrint('showExitPopupAd failed: $e');
            return true; // 에러 시 기본 동작(종료)을 허용합니다.
          } finally {
            Future<void>.delayed(const Duration(seconds: 2)).then((_) {
              _exitPopupAdGuard = false;
            });
          }
        },

        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  _buildCenterButton(
                    context,
                    text: '기본 배너, 전면, 보상형, 네이티브, 앱오프닝 테스트',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const GuideSamplePage()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildCenterButton(
                    context,
                    text: '앱 전환 광고 테스트',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TransitionPopupAdTestPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        )
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
