import 'dart:io';

import 'package:flutter/material.dart';
import 'package:adwhale_sdk_flutter/adwhale_sdk_flutter.dart';

/// Android / iOS 통합 배너 샘플.
/// Android: AdWhale placement UID 사용, iOS: AdMob ad unit ID 사용.
/// 같은 화면에서 플랫폼에 따라 해당 ID만 사용합니다.
class GuideSampleIntegrationPage extends StatefulWidget {
  const GuideSampleIntegrationPage({super.key});

  @override
  State<GuideSampleIntegrationPage> createState() =>
      _GuideSampleIntegrationPageState();
}

class _GuideSampleIntegrationPageState extends State<GuideSampleIntegrationPage> {
  int _selectedBannerSize = 0; // 0: 320x50, 1: 320x100, 2: 300x250, 3: 250x250, 4: Adaptive
  AdWhaleAdView? _bannerAd;

  AdWhaleAdSize _selectedAdSize() {
    switch (_selectedBannerSize) {
      case 0:
        return AdWhaleAdSize.BANNER_320x50;
      case 1:
        return AdWhaleAdSize.BANNER_320x100;
      case 2:
        return AdWhaleAdSize.BANNER_300x250;
      case 3:
        return AdWhaleAdSize.BANNER_250x250; // iOS에서는 미지원 → onLoadFailed
      case 4:
        return AdWhaleAdSize.ADAPTIVE_ANCHOR;
      default:
        return AdWhaleAdSize.BANNER_320x50;
    }
  }

  /// 고정 배너일 때 컨테이너 너비. iOS에서 요청 크기(320x50 등)와 뷰 프레임이 맞아야 미디에이션에 올바른 크기로 전달됨.
  double _bannerWidthFor(AdWhaleAdSize? size) {
    if (size == null) return 320;
    switch (size) {
      case AdWhaleAdSize.BANNER_320x50:
      case AdWhaleAdSize.BANNER_320x100:
        return 320.0;
      case AdWhaleAdSize.BANNER_300x250:
        return 300.0;
      case AdWhaleAdSize.BANNER_250x250:
        return 250.0; // iOS 미지원
      case AdWhaleAdSize.ADAPTIVE_ANCHOR:
        return double.infinity;
    }
  }

  double _bannerHeightFor(AdWhaleAdSize? size) {
    if (size == null) return 50;
    switch (size) {
      case AdWhaleAdSize.BANNER_320x50:
        return 50.0;
      case AdWhaleAdSize.BANNER_320x100:
        return 100.0;
      case AdWhaleAdSize.BANNER_300x250:
      case AdWhaleAdSize.BANNER_250x250:
        return 250.0;
      case AdWhaleAdSize.ADAPTIVE_ANCHOR:
        return 50.0;
    }
  }

  Future<void> _loadBanner() async {
    final oldAd = _bannerAd;
    _bannerAd = null;
    setState(() {});

    await oldAd?.destroy();

    if (!mounted) return;
    final size = _selectedAdSize();
    final newAd = AdWhaleAdView(
      listener: AdWhaleAdViewListener(
        onLoaded: (ad) {
          debugPrint('GuideSampleIntegrationPage Banner onLoaded');
          if (mounted) setState(() {});
        },
        onLoadFailed: (ad, errorCode, errorMessage) {
          debugPrint(
            'GuideSampleIntegrationPage Banner onLoadFailed: $errorCode, $errorMessage',
          );
          ad.destroy();
          if (mounted) {
            setState(() {
              _bannerAd = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('로드 실패: $errorMessage')),
            );
          }
        },
        onClicked: (ad) {
          debugPrint('GuideSampleIntegrationPage Banner onClicked');
        },
      ),
      adInfo: AdInfo(
        androidPlacementUid: 'placement Uid 를 발급받으세요',
        iosBannerAdUnitId: 'Google AdMob 배너 단위 ID',
        bannerHeight: size,
      ),
    );
    if (size == AdWhaleAdSize.ADAPTIVE_ANCHOR) {
      newAd.setAdaptiveAnchorWidth(0);
    }
    await newAd.loadAd();
    if (!mounted) return;
    _bannerAd = newAd;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Android / iOS 통합 배너 샘플'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Platform.isAndroid
                        ? 'Android: AdWhale placement UID 사용'
                        : 'iOS: AdMob ad unit ID 사용\n(250x250은 iOS 미지원)',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  const Text('배너 사이즈', style: TextStyle(fontSize: 15)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _sizeChip(0, '320x50'),
                      _sizeChip(1, '320x100'),
                      _sizeChip(2, '300x250'),
                      _sizeChip(3, '250x250'),
                      _sizeChip(4, 'Adaptive'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _loadBanner(),
                    child: const Text('배너 로드'),
                  ),
                ],
              ),
            ),
          ),
          if (_bannerAd != null)
            Center(
              child: Container(
                width: _bannerWidthFor(_bannerAd!.adInfo.bannerHeight),
                height: _bannerHeightFor(_bannerAd!.adInfo.bannerHeight),
                color: Colors.grey[200],
                child: AdWhaleAdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sizeChip(int index, String label) {
    final selected = _selectedBannerSize == index;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _selectedBannerSize = index;
        });
      },
    );
  }

  @override
  void dispose() {
    _bannerAd?.destroy();
    super.dispose();
  }
}
