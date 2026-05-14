import 'dart:io' show Platform;

import 'package:adwhale_sdk_flutter/adwhale_sdk_flutter.dart';
import 'package:flutter/material.dart';

/// Android: [AdWhaleMediationTransitionPopupAd] 샘플 (앱 전환 팝업).
///
/// iOS에서는 미지원 안내만 표시합니다.
class TransitionPopupAdTestPage extends StatefulWidget {
  const TransitionPopupAdTestPage({super.key});

  @override
  State<TransitionPopupAdTestPage> createState() =>
      _TransitionPopupAdTestPageState();
}

class _TransitionPopupAdTestPageState extends State<TransitionPopupAdTestPage> {
  AdWhaleTransitionPopupAd? _ad;
  bool _loaded = false;
  String _log = '';

  void _appendLog(String line) {
    if (!mounted) return;
    setState(() {
      _log = _log.isEmpty ? line : '$_log\n$line';
    });
  }

  @override
  void initState() {
    super.initState();
    if (!Platform.isAndroid) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createAndLoadAd();
    });
  }

  Future<void> _createAndLoadAd() async {
    if (!Platform.isAndroid) {
      return;
    }
    await _ad?.destroy();
    _ad = AdWhaleTransitionPopupAd(
      placementUid: 'placement Uid 를 발급받으세요',
      adLoadCallback: AdWhaleTransitionPopupAdLoadCallback(
        onLoaded: () {
          _appendLog('onLoaded');
          if (!mounted) return;
          setState(() => _loaded = true);
        },
        onLoadFailed: (code, msg) {
          _appendLog('onLoadFailed: $code $msg');
          if (!mounted) return;
          setState(() => _loaded = false);
        },
        onShowed: () {
          _appendLog('onShowed');
          if (!mounted) return;
          setState(() => _loaded = false);
        },
        onShowFailed: (code, msg) {
          _appendLog('onShowFailed: $code $msg');
          if (!mounted) return;
          setState(() => _loaded = false);
        },
        onClosed: (reason) {
          _appendLog('onClosed: $reason');
        },
        onClicked: () => _appendLog('onClicked'),
      ),
    )
      ..setPlacementName('transition_popup_main')
      ..setRegion('서울시 강남구')
      ..setGcoder(37.5665, 126.9780);

    if (mounted) {
      setState(() => _loaded = false);
    }
    await _ad!.loadAd();
  }

  @override
  void dispose() {
    _ad?.destroy();
    super.dispose();
  }

  Future<void> _showAd() async {
    if (_ad == null || !_loaded) {
      _appendLog('표시 불가: 로드되지 않음');
      return;
    }
    try {
      await _ad!.showAd();
    } catch (e) {
      _appendLog('showAd error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) {
      return Scaffold(
        appBar: AppBar(title: const Text('앱 전환 광고 테스트')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              '앱 전환 광고(Transition Popup Ad)는 Android 전용입니다.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('앱 전환 광고 테스트')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '로드가 끝난 뒤 화면 전환 직전에 showAd()를 호출하는 형태로 사용합니다. '
              'Activity onResume에 대응하는 resume()은 플러그인에서 처리합니다.',
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loaded ? _showAd : null,
              child: const Text('앱 전환 광고 표시'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _createAndLoadAd,
              child: const Text('다시 로드'),
            ),
            const SizedBox(height: 16),
            Text(
              _loaded ? '상태: 로드 완료' : '상태: 로드 대기/실패',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  _log.isEmpty ? '(이벤트 로그)' : _log,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
