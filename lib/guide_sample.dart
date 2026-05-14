import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:adwhale_sdk_flutter/adwhale_sdk_flutter.dart';
import '../config.dart';

class GuideSamplePage extends StatefulWidget {
  const GuideSamplePage({super.key});

  @override
  State<GuideSamplePage> createState() => _GuideSamplePageState();
}

class _GuideSamplePageState extends State<GuideSamplePage> {
  static const List<String> _tfuaLabels = <String>[
    'TAG_FOR_UNDER_AGE_OF_CONSENT_TRUE',
    'TAG_FOR_UNDER_AGE_OF_CONSENT_FALSE',
    'TAG_FOR_UNDER_AGE_OF_CONSENT_UNSPECIFIED',
  ];

  static const List<String> _maxRatingLabels = <String>[
    'MAX_AD_CONTENT_RATING_G',
    'MAX_AD_CONTENT_RATING_PG',
    'MAX_AD_CONTENT_RATING_T',
    'MAX_AD_CONTENT_RATING_MA',
  ];

  /// `setMaxAdContentRating`용 (mediation_ads_test_page와 동일 매핑).
  static const List<String?> _maxRatingApiValues = <String?>[
    '.general',
    '.parentalGuidance',
    '.teen',
    '.matureAudience',
  ];

  /// Android GuideActivity 스피너와 동일: 0 TRUE, 1 FALSE, 2 UNSPECIFIED. 기본 UNSPECIFIED.
  int _tfuaModeIndex = 2;

  /// 기본 MA (가장 덜 제한적).
  int _maxRatingIndex = 3;

  bool _isCoppa = false;
  bool _isLoggerOn = false;
  bool _isAppMuted = false;
  final TextEditingController _appVolumeController = TextEditingController(
    text: '0.1',
  );
  final TextEditingController _debugInfoController = TextEditingController();

  int _selectedAdType =
  0; // 0: 배너, 1: 전면, 2: 보상형전면, 3: 네이티브(템플릿), 4: 네이티브(커스텀), 5: 앱 오프닝
  int _selectedBannerSize = 0;

  AdWhaleAdView? _adWhaleAdView;
  final TextEditingController _adaptiveWidthController = TextEditingController(
    text: '0',
  );

  final TextEditingController _placementUidController = TextEditingController();
  final Map<int, String> _placementUidByType = <int, String>{};

  AdWhaleInterstitialAd? _interstitialAd;
  bool _isInterstitialLoaded = false;

  AdWhaleRewardAd? _rewardAd;
  bool _isRewardLoaded = false;

  AdWhaleAppOpenAd? _appOpenAd;
  bool _isAppOpenLoaded = false;

  AdWhaleNativeTemplateView? _adWhaleTemplateNativeAd;
  bool _isTemplateNativeLoaded = false;

  AdWhaleNativeCustomView? _adWhaleCustomNativeAd;
  bool _isCustomNativeLoaded = false;

  AdWhaleNativeTemplate _selectedTemplateSize = AdWhaleNativeTemplate.small;

  AdWhaleNativeAd? _adWhaleNativeAd;
  bool _nativeLoaded = false;
  bool _nativeShown = false;
  double? _nativeHeight;
  StreamSubscription<int>? _nativeHeightSub;

  @override
  void initState() {
    super.initState();
    _placementUidByType.addAll(<int, String>{
      0: AdConfig.banner320x50PlacementUid, // 배너
      1: AdConfig.interstitialPlacementUid1, // 전면
      2: AdConfig.rewardPlacementUid1, // 보상형전면
      3: AdConfig.nativePlacementUid, // 네이티브(템플릿)
      4: AdConfig.nativePlacementUid, // 네이티브(커스텀)
      5: AdConfig.appOpenPlacementUid, // 앱 오프닝
    });
    _placementUidController.text = _placementUidByType[_selectedAdType] ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _applyTfuaMode(_tfuaModeIndex);
      await _applyMaxRating(_maxRatingIndex);
    });
  }

  Future<void> _applyTfuaMode(int index) async {
    try {
      await AdWhaleMediationAds.instance.setTagForUnderAgeOfConsentMode(index);
      debugPrint('TFUA applied: ${_tfuaLabels[index]}');
    } catch (e) {
      debugPrint('setTagForUnderAgeOfConsentMode error: $e');
    }
  }

  Future<void> _applyMaxRating(int index) async {
    try {
      final rating = _maxRatingApiValues[index];
      await AdWhaleMediationAds.instance.setMaxAdContentRating(rating);
      debugPrint('MaxAdContentRating applied: ${_maxRatingLabels[index]}');
    } catch (e) {
      debugPrint('setMaxAdContentRating error: $e');
    }
  }

  void _onAdTypeChanged(int newType) {
    // 현재 입력값을 현재 타입에 저장
    _placementUidByType[_selectedAdType] = _placementUidController.text.trim();

    setState(() {
      _selectedAdType = newType;
      _placementUidController.text = _placementUidByType[newType] ?? '';
    });
  }

  String _currentPlacementUid() {
    final text = _placementUidController.text.trim();
    if (text.isNotEmpty) return text;
    return _placementUidByType[_selectedAdType] ?? '';
  }

  double _nativeAdHeightForCurrent() {
    final h = _nativeHeight;
    if (_selectedAdType == 4) {
      if (h != null) {
        return h.clamp(360, 2200).toDouble();
      }
      return 720;
    }

    switch (_selectedTemplateSize) {
      case AdWhaleNativeTemplate.small:
        if (h != null) return h.clamp(220, 900).toDouble();
        return 320;
      case AdWhaleNativeTemplate.medium:
        if (h != null) return h.clamp(340, 1300).toDouble();
        return 520;
      case AdWhaleNativeTemplate.fullscreen:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isIos = Platform.isIOS;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('기본 배너/전면/보상형/네이티브/앱오프닝 테스트')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TFUA / MaxRating (Android GuideActivity 상단 스피너)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('TFUA', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _tfuaModeIndex,
                          items: List<DropdownMenuItem<int>>.generate(
                            _tfuaLabels.length,
                                (int i) => DropdownMenuItem<int>(
                              value: i,
                              child: Text(
                                _tfuaLabels[i],
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          onChanged: (int? v) async {
                            if (v == null) return;
                            setState(() => _tfuaModeIndex = v);
                            await _applyTfuaMode(v);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('TFUA: ${_tfuaLabels[v]}'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('MaxRating', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _maxRatingIndex,
                          items: List<DropdownMenuItem<int>>.generate(
                            _maxRatingLabels.length,
                                (int i) => DropdownMenuItem<int>(
                              value: i,
                              child: Text(
                                _maxRatingLabels[i],
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          onChanged: (int? v) async {
                            if (v == null) return;
                            setState(() => _maxRatingIndex = v);
                            await _applyMaxRating(v);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'MaxRating: ${_maxRatingLabels[v]}',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // COPPA + GDPR + Check(Android만) + Reset
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('COPPA'),
                          Switch(
                            value: _isCoppa,
                            onChanged: (v) async {
                              setState(() => _isCoppa = v);
                              await AdWhaleMediationAds.instance.setCoppa(v);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('COPPA setting applied: $v'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      _purpleSmallButton(
                        'GDPR',
                        onPressed: () async {
                          final r = await AdWhaleMediationAds.instance
                              .requestGdprConsent();
                          if (!mounted) return;
                          final ok = r['success'] == true;
                          final msg = r['message']?.toString() ?? '';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'GDPR Consent: ${ok ? 'Success' : 'Failed'}, $msg',
                              ),
                            ),
                          );
                        },
                      ),
                      _purpleSmallButton(
                        'Check',
                        onPressed: Platform.isAndroid
                            ? () async {
                          try {
                            final m = await AdWhaleMediationAds.instance
                                .getConsentStatus();
                            if (!mounted) return;
                            final coppa = m['coppa'];
                            final gdpr = m['gdpr']?.toString() ?? '';
                            final pc = m['personalizedConsent'];
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'coppa: $coppa, gdpr: $gdpr, personalizedConsent: $pc',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Check: $e')),
                            );
                          }
                        }
                            : null,
                      ),
                      _purpleSmallButton(
                        'Reset',
                        onPressed: () async {
                          await AdWhaleMediationAds.instance
                              .resetGdprConsentStatus();
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'GDPR consent status has been reset.',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _purpleSmallButton(
                        'SINGLE GDPR TRUE',
                        onPressed: Platform.isAndroid
                            ? () async {
                          await AdWhaleMediationAds.instance
                              .setGdpr(true);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('setGdpr(true)'),
                            ),
                          );
                        }
                            : null,
                      ),
                      _purpleSmallButton(
                        'SINGLE GDPR FALSE',
                        onPressed: Platform.isAndroid
                            ? () async {
                          await AdWhaleMediationAds.instance
                              .setGdpr(false);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('setGdpr(false)'),
                            ),
                          );
                        }
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _purpleSmallButton(
                      'AdMob Ad Inspector',
                      onPressed: () async {
                        try {
                          final ok = await AdWhaleMediationAds.instance
                              .showAdInspector(
                            onClosed: (code, message) {
                              debugPrint(
                                'AdInspector closed: code=$code message=$message',
                              );
                              if (!context.mounted) return;
                              if (code != 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              }
                            },
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? 'Ad Inspector 요청됨'
                                    : 'Ad Inspector를 열 수 없습니다(Activity 등).',
                              ),
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ad Inspector: $e')),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('1. 로거출력여부:', style: TextStyle(fontSize: 15)),
                  Switch(
                    value: _isLoggerOn,
                    onChanged: (v) async {
                      if (isIos) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('iOS에서는 로거 설정을 지원하지 않습니다.'),
                          ),
                        );
                        return;
                      }
                      // 로거 출력 여부 토글:
                      //  - true  -> AdWhaleLog.setLogLevel(Verbose)
                      //  - false -> AdWhaleLog.setLogLevel(None)
                      setState(() => _isLoggerOn = v);
                      await AdWhaleMediationAds.instance.setLoggerEnabled(v);
                      final logLevel = await AdWhaleMediationAds.instance
                          .getLogLevel();
                      debugPrint('현재 로그 레벨: $logLevel');
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text('앱 볼륨/Mute 설정:', style: TextStyle(fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('App Muted:', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Switch(
                        value: _isAppMuted,
                        onChanged: (v) {
                          setState(() => _isAppMuted = v);
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _appVolumeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '0.0 ~ 1.0',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _purpleSmallButton(
                    '볼륨/Mute 적용',
                    onPressed: () async {
                      try {
                        final text = _appVolumeController.text.trim();
                        if (text.isEmpty) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('볼륨 값을 입력해주세요.')),
                          );
                          return;
                        }

                        double volume = double.parse(text);
                        if (volume < 0.0) volume = 0.0;
                        if (volume > 1.0) volume = 1.0;

                        await AdWhaleMediationAds.instance.setAppMuted(
                          _isAppMuted,
                        );
                        await AdWhaleMediationAds.instance.setAppVolume(volume);

                        debugPrint(
                          'setAppMuted=$_isAppMuted setAppVolume=$volume',
                        );
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Mute: $_isAppMuted, Volume: ${volume.toStringAsFixed(2)}',
                            ),
                          ),
                        );
                      } catch (e) {
                        debugPrint('setAppMuted/setAppVolume error: $e');
                        if (!mounted) return;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('설정 실패: $e')));
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text('2. 광고 타입 선택:', style: TextStyle(fontSize: 15)),
                  const SizedBox(height: 4),
                  // 광고 타입 라디오
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _adTypeRadio(0, '배너'),
                      _adTypeRadio(1, '전면'),
                      _adTypeRadio(2, '보상형전면'),
                      _adTypeRadio(
                        3,
                        isIos ? '네이티브광고(고정형템플릿) (iOS 미지원)' : '네이티브광고(고정형템플릿)',
                      ),
                      _adTypeRadio(
                        4,
                        isIos
                            ? '네이티브광고(커스텀바인딩) (iOS: SDK 고정 레이아웃)'
                            : '네이티브광고(커스텀바인딩)',
                      ),
                      _adTypeRadio(5, '앱 오프닝'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '3. publisher uid입력:',
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  const TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'publisher uid를 입력해주세요.',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isIos &&
                        (_selectedAdType == 1 ||
                            _selectedAdType == 2 ||
                            _selectedAdType == 4 ||
                            _selectedAdType == 5)
                        ? '4. placement / Ad Unit ID:'
                        : '4. placement uid입력:',
                    style: const TextStyle(fontSize: 15),
                  ),
                  if (isIos &&
                      (_selectedAdType == 1 ||
                          _selectedAdType == 2 ||
                          _selectedAdType == 4 ||
                          _selectedAdType == 5)) ...[
                    const SizedBox(height: 4),
                    Text(
                      _selectedAdType == 1
                          ? 'iOS 전면: AdConfig.iosInterstitialAdUnitId로 로드됩니다. 아래 입력은 사용하지 않습니다.'
                          : _selectedAdType == 2
                          ? 'iOS 보상형: AdConfig.iosRewardAdUnitId로 로드됩니다. 아래 입력은 사용하지 않습니다.'
                          : _selectedAdType == 4
                          ? 'iOS 네이티브: AdConfig.iosNativeAdUnitId로 로드됩니다. 아래 입력은 사용하지 않습니다.'
                          : 'iOS 앱오프닝: AdConfig.iosAppOpenAdUnitId로 로드됩니다. 아래 입력은 사용하지 않습니다.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                  const SizedBox(height: 4),
                  TextField(
                    controller: _placementUidController,
                    onChanged: (v) {
                      _placementUidByType[_selectedAdType] = v.trim();
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText:
                      isIos &&
                          (_selectedAdType == 1 ||
                              _selectedAdType == 2 ||
                              _selectedAdType == 4 ||
                              _selectedAdType == 5)
                          ? '(Android만) placement uid'
                          : 'placement uid를 입력해주세요.',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  // 5. 광고사이즈선택: (배너/네이티브 템플릿에서만 노출)
                  if (_selectedAdType == 0 || _selectedAdType == 3) ...[
                    const Text('5. 광고사이즈선택:', style: TextStyle(fontSize: 15)),
                    const SizedBox(height: 4),
                    // 배너 선택 시: 배너 사이즈 5개
                    if (_selectedAdType == 0) ...[
                      Wrap(
                        spacing: 12,
                        children: [
                          _bannerSizeRadio(0, '320x50'),
                          _bannerSizeRadio(1, '320x100'),
                          _bannerSizeRadio(2, '300x250'),
                          _bannerSizeRadio(3, '250x250'),
                          _bannerSizeRadio(4, 'Adaptive'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // adaptive width 영역 (선택 시 노출)
                      if (_selectedBannerSize == 4)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'adaptive width size(0: 디바이스 전체 길이):',
                              style: TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: _adaptiveWidthController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'adaptive anchor width를 입력해주세요.',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                    ],
                    // 네이티브 템플릿 선택 시: 템플릿 크기 3개
                    if (_selectedAdType == 3) ...[
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('템플릿 크기:', style: TextStyle(fontSize: 14)),
                          Wrap(
                            spacing: 12,
                            children: [
                              ChoiceChip(
                                label: const Text('Small'),
                                selected:
                                _selectedTemplateSize ==
                                    AdWhaleNativeTemplate.small,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedTemplateSize =
                                        AdWhaleNativeTemplate.small;
                                  });
                                },
                              ),
                              ChoiceChip(
                                label: const Text('Medium'),
                                selected:
                                _selectedTemplateSize ==
                                    AdWhaleNativeTemplate.medium,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedTemplateSize =
                                        AdWhaleNativeTemplate.medium;
                                  });
                                },
                              ),
                              ChoiceChip(
                                label: const Text('Fullscreen'),
                                selected:
                                _selectedTemplateSize ==
                                    AdWhaleNativeTemplate.fullscreen,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedTemplateSize =
                                        AdWhaleNativeTemplate.fullscreen;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                  ] else ...[
                    const SizedBox(height: 12),
                  ],
                  // 광고 로드 / 표시 / 뷰 초기화 / 복사 버튼
                  // - 배너:  [광고 로드] [뷰 초기화] [복사] (3개)
                  // - 그 외: [광고 로드] [광고 표시] [뷰 초기화] [복사] (4개)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _selectedAdType == 0
                        ? [
                      _purpleButton(
                        '광고 로드',
                        onPressed: _onBannerLoadPressed,
                      ),
                      _purpleButton(
                        '뷰 초기화',
                        onPressed: _onClearAdsPressed,
                      ),
                      _purpleButton('복사', onPressed: _onCopyDebugPressed),
                    ]
                        : [
                      _purpleButton(
                        '광고 로드',
                        onPressed: _onLoadNonBannerPressed,
                      ),
                      _purpleButton(
                        '광고 표시',
                        onPressed: _onShowNonBannerPressed,
                      ),
                      _purpleButton(
                        '뷰 초기화',
                        onPressed: _onClearAdsPressed,
                      ),
                      _purpleButton('복사', onPressed: _onCopyDebugPressed),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _debugInfoController,
                    readOnly: true,
                    minLines: 6,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Please touch [광고 로드] button.',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 네이티브 광고 영역 (템플릿/커스텀 공통)
                  const Text(
                    '네이티브 광고 영역',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_nativeShown &&
                      _adWhaleNativeAd != null &&
                      _nativeAdHeightForCurrent() > 0)
                    SizedBox(
                      height: _nativeAdHeightForCurrent(),
                      child: AdWhaleAdWidget(
                        key: ValueKey(_adWhaleNativeAd!.hashCode),
                        ad: _adWhaleNativeAd as AdWithView,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // 하단 배너 영역(adViewRoot 역할)
          Container(
            width: double.infinity,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: _adWhaleAdView == null
                ? const SizedBox(
              height: 60,
              child: Center(
                child: Text(
                  '여기에 배너 광고가 노출됩니다.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            )
                : SizedBox(
              height: _bannerHeightFor(_adWhaleAdView!),
              child: AdWhaleAdWidget(
                key: ValueKey(_adWhaleAdView!.hashCode),
                ad: _adWhaleAdView!,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _adTypeRadio(int value, String label) {
    return Row(
      children: [
        Radio<int>(
          value: value,
          groupValue: _selectedAdType,
          onChanged: (v) => _onAdTypeChanged(v ?? 0),
        ),
        Expanded(child: Text(label, softWrap: true)),
      ],
    );
  }

  Widget _bannerSizeRadio(int value, String label) {
    return Row(
      children: [
        Radio<int>(
          value: value,
          groupValue: _selectedBannerSize,
          onChanged: (v) => setState(() => _selectedBannerSize = v ?? 0),
        ),
        Expanded(child: Text(label, softWrap: true)),
      ],
    );
  }

  AdWhaleAdSize _bannerEnumForSelectedSize() {
    switch (_selectedBannerSize) {
      case 0:
        return AdWhaleAdSize.BANNER_320x50;
      case 1:
        return AdWhaleAdSize.BANNER_320x100;
      case 2:
        return AdWhaleAdSize.BANNER_300x250;
      case 3:
        return AdWhaleAdSize.BANNER_250x250;
      case 4:
      default:
        return AdWhaleAdSize.ADAPTIVE_ANCHOR;
    }
  }

  void _onBannerLoadPressed() {
    if (_selectedAdType != 0) return;

    final sizeEnum = _bannerEnumForSelectedSize();

    int adaptiveWidth = 0;
    if (sizeEnum == AdWhaleAdSize.ADAPTIVE_ANCHOR) {
      final text = _adaptiveWidthController.text.trim();
      final parsed = int.tryParse(text);
      if (parsed != null && parsed >= 0) {
        adaptiveWidth = parsed;
      }
    }

    _adWhaleAdView?.destroy();
    _adWhaleAdView = null;
    setState(() {});

    _createBanner(
      sizeEnum,
      adaptiveAnchorWidth: sizeEnum == AdWhaleAdSize.ADAPTIVE_ANCHOR
          ? adaptiveWidth
          : null,
    );
  }

  void _createBanner(AdWhaleAdSize bannerSize, {int? adaptiveAnchorWidth}) {
    debugPrint(
      'GuideSampleAndroidPage _createBanner size=$bannerSize, adaptiveWidth=$adaptiveAnchorWidth',
    );
    final listener = AdWhaleAdViewListener(
      onLoaded: (ad) {
        debugPrint(
          'GuideSampleAndroidPage BannerAd onLoaded for size $bannerSize',
        );
        setState(() {});
      },
      onLoadFailed: (ad, errorCode, errorMessage) {
        debugPrint(
          'GuideSampleAndroidPage BannerAd onLoadFailed for $bannerSize: errorCode: $errorCode, errorMessage: $errorMessage',
        );
        ad.destroy();
        setState(() {
          _adWhaleAdView = null;
        });
      },
      onClicked: (ad) {
        debugPrint(
          'GuideSampleAndroidPage BannerAd onClicked for size $bannerSize',
        );
      },
    );
    final adInfo = Platform.isIOS
        ? AdInfo(
      androidPlacementUid: _currentPlacementUid(),
      iosBannerAdUnitId: AdConfig.iosBannerAdUnitId,
      bannerHeight: bannerSize,
    )
        : AdInfo.legacy(_currentPlacementUid(), bannerSize);

    _adWhaleAdView = AdWhaleAdView(listener: listener, adInfo: adInfo)
      ..setRegion('서울시 강남구')
      ..setGcoder(37.5665, 126.9780)
      ..setPlacementName('guide_banner');

    if (adaptiveAnchorWidth != null) {
      _adWhaleAdView!.setAdaptiveAnchorWidth(adaptiveAnchorWidth);
    }
    _adWhaleAdView!.loadAd();
  }

  double _bannerHeightFor(AdWhaleAdView ad) {
    switch (ad.adInfo.bannerHeight) {
      case AdWhaleAdSize.BANNER_320x50:
        return 50.0;
      case AdWhaleAdSize.BANNER_320x100:
        return 100.0;
      case AdWhaleAdSize.BANNER_300x250:
        return 250.0;
      case AdWhaleAdSize.BANNER_250x250:
        return 250.0;
      case AdWhaleAdSize.ADAPTIVE_ANCHOR:
        return 50.0;
    }
  }

  @override
  void dispose() {
    _adWhaleAdView?.destroy();
    _interstitialAd?.destroy();
    _rewardAd?.destroy();
    _appOpenAd?.destroy();
    _adWhaleTemplateNativeAd?.destroy();
    _adWhaleCustomNativeAd?.destroy();
    _adWhaleNativeAd?.destroy();
    _nativeHeightSub?.cancel();
    _placementUidController.dispose();
    _adaptiveWidthController.dispose();
    _appVolumeController.dispose();
    _debugInfoController.dispose();
    super.dispose();
  }

  Future<void> _onCopyDebugPressed() async {
    final text = _debugInfoController.text;
    if (text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('복사할 내용이 없습니다.')));
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copy success!')));
  }

  void _onLoadNonBannerPressed() {
    if (Platform.isIOS &&
        _selectedAdType != 1 &&
        _selectedAdType != 2 &&
        _selectedAdType != 4 &&
        _selectedAdType != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('iOS에서는 현재 전면/보상형/네이티브(커스텀)/앱오프닝만 지원합니다.'),
        ),
      );
      return;
    }
    switch (_selectedAdType) {
      case 1: // 전면
        _loadInterstitial();
        break;
      case 2: // 보상형전면
        _loadReward();
        break;
      case 3: // 네이티브 템플릿
        _loadTemplateNative();
        break;
      case 4: // 네이티브 커스텀바인딩
        _loadCustomNative();
        break;
      case 5: // 앱 오프닝
        _loadAppOpen();
        break;
      default:
        break;
    }
  }

  void _onShowNonBannerPressed() {
    if (Platform.isIOS &&
        _selectedAdType != 1 &&
        _selectedAdType != 2 &&
        _selectedAdType != 4 &&
        _selectedAdType != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('iOS에서는 현재 전면/보상형/네이티브(커스텀)/앱오프닝만 지원합니다.'),
        ),
      );
      return;
    }
    switch (_selectedAdType) {
      case 1:
        _showInterstitial();
        break;
      case 2:
        _showReward();
        break;
      case 3:
        _showTemplateNative();
        break;
      case 4:
        _showCustomNative();
        break;
      case 5:
        _showAppOpen();
        break;
      default:
        break;
    }
  }

  void _onClearAdsPressed() {
    _adWhaleAdView?.destroy();
    _adWhaleAdView = null;

    _interstitialAd?.destroy();
    _interstitialAd = null;
    _isInterstitialLoaded = false;

    _rewardAd?.destroy();
    _rewardAd = null;
    _isRewardLoaded = false;

    _appOpenAd?.destroy();
    _appOpenAd = null;
    _isAppOpenLoaded = false;

    _adWhaleTemplateNativeAd?.destroy();
    _adWhaleTemplateNativeAd = null;
    _isTemplateNativeLoaded = false;

    _adWhaleCustomNativeAd?.destroy();
    _adWhaleCustomNativeAd = null;
    _isCustomNativeLoaded = false;

    _adWhaleNativeAd?.destroy();
    _adWhaleNativeAd = null;
    _nativeLoaded = false;
    _nativeShown = false;
    _nativeHeight = null;
    _nativeHeightSub?.cancel();
    _nativeHeightSub = null;

    setState(() {});
  }

  void _loadInterstitial() {
    _interstitialAd?.destroy();
    _interstitialAd = null;
    _isInterstitialLoaded = false;

    final String interstitialUnitId = Platform.isIOS
        ? AdConfig.iosInterstitialAdUnitId
        : _currentPlacementUid();

    _interstitialAd =
    AdWhaleInterstitialAd(
      placementUid: interstitialUnitId,
      adLoadCallback: AdWhaleInterstitialAdLoadCallback(
        onLoaded: () {
          debugPrint('GuideSampleAndroidPage Interstitial onLoaded');
          _isInterstitialLoaded = true;
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('전면 광고 로드 완료')));
          }
        },
        onLoadFailed: (errorCode, errorMessage) {
          debugPrint(
            'GuideSampleAndroidPage Interstitial onLoadFailed: $errorMessage',
          );
          _interstitialAd = null;
          _isInterstitialLoaded = false;
        },
        onShowed: () {
          debugPrint('GuideSampleAndroidPage Interstitial onAdShowed');
        },
        onShowFailed: (errorCode, errorMessage) {
          debugPrint(
            'GuideSampleAndroidPage Interstitial onAdShowFailed: $errorMessage',
          );
          _interstitialAd = null;
          _isInterstitialLoaded = false;
        },
        onClosed: () {
          debugPrint('GuideSampleAndroidPage Interstitial onAdClosed');
        },
        onClicked: () {
          debugPrint('GuideSampleAndroidPage Interstitial onClicked');
        },
      ),
    )
      ..setRegion('서울시 서초구')
      ..setGcoder(37.49, 127.02)
      ..setPlacementName('test_interstitial');
    _interstitialAd!.loadAd();
  }

  void _showInterstitial() {
    if (_interstitialAd == null || !_isInterstitialLoaded) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('전면 광고를 먼저 로드해 주세요.')));
      }
      return;
    }
    _interstitialAd!.showAd();
    _isInterstitialLoaded = false;
    _interstitialAd = null;
  }

  void _loadReward() {
    _rewardAd?.destroy();
    _rewardAd = null;
    _isRewardLoaded = false;

    _rewardAd =
    AdWhaleRewardAd(
      placementUid: Platform.isIOS
          ? AdConfig.iosRewardAdUnitId
          : _currentPlacementUid(),
      adRewardLoadCallback: AdWhaleRewardAdLoadCallback(
        onLoaded: () {
          debugPrint('GuideSampleAndroidPage Reward onLoaded');
          _isRewardLoaded = true;
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('보상형 광고 로드 완료')));
          }
        },
        onLoadFailed: (errorCode, errorMessage) {
          debugPrint(
            'GuideSampleAndroidPage Reward onAdFailedToLoad: errorCode: $errorCode, errorMessage: $errorMessage',
          );
          _rewardAd = null;
          _isRewardLoaded = false;
        },
        onUserRewarded: (amount, type) {
          debugPrint(
            'GuideSampleAndroidPage Reward onUserRewarded: $amount, $type',
          );
        },
        onClicked: () {
          debugPrint('GuideSampleAndroidPage Reward onClicked');
        },
        onShowed: () {
          debugPrint('GuideSampleAndroidPage Reward onAdShowed');
        },
        onShowFailed: (String errorCode, String errorMessage) {
          debugPrint(
            'GuideSampleAndroidPage Reward onFailedToShow: errorCode: $errorCode, errorMessage: $errorMessage',
          );
        },
        onDismissed: () {
          debugPrint('GuideSampleAndroidPage Reward onDismissed');
        },
      ),
    )
      ..setRegion('test_reward_region')
      ..setGcoder(37.5, 126.9)
      ..setPlacementName('test_reward');
    _rewardAd!.loadAd();
  }

  void _showReward() {
    if (_rewardAd == null || !_isRewardLoaded) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('보상형 광고를 먼저 로드해 주세요.')));
      }
      return;
    }
    _rewardAd!.showAd();
    _isRewardLoaded = false;
    _rewardAd = null;
  }

  void _loadAppOpen() {
    _appOpenAd?.destroy();
    _appOpenAd = null;
    _isAppOpenLoaded = false;

    _appOpenAd =
    AdWhaleAppOpenAd(
      placementUid: Platform.isIOS
          ? AdConfig.iosAppOpenAdUnitId
          : _currentPlacementUid(),
      adLoadCallback: AdWhaleAppOpenAdLoadCallback(
        onLoaded: () {
          debugPrint('GuideSampleAndroidPage AppOpen onLoaded');
          _isAppOpenLoaded = true;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('앱오프닝 광고 로드 완료')),
            );
          }
        },
        onLoadFailed: (code, message) {
          debugPrint(
            'GuideSampleAndroidPage AppOpen onLoadFailed: $code, $message',
          );
          _appOpenAd?.destroy();
          _appOpenAd = null;
          _isAppOpenLoaded = false;
        },
        onShowed: () {
          debugPrint('GuideSampleAndroidPage AppOpen onAdShowed');
        },
        onShowFailed: (code, message) {
          debugPrint(
            'GuideSampleAndroidPage AppOpen onAdShowFailed: $code, $message',
          );
          _appOpenAd?.destroy();
          _appOpenAd = null;
          _isAppOpenLoaded = false;
        },
        onDismissed: () {
          debugPrint('GuideSampleAndroidPage AppOpen onAdDismissed');
          _appOpenAd?.destroy();
          _appOpenAd = null;
          _isAppOpenLoaded = false;
        },
        onClicked: () {
          debugPrint('GuideSampleAndroidPage AppOpen onClicked');
        },
      ),
    )
      ..setRegion('서울시 강남구')
      ..setGcoder(37.5665, 126.9780)
      ..setPlacementName('test_app_open');
    _appOpenAd!.loadAd();
  }

  void _showAppOpen() {
    if (_appOpenAd == null || !_isAppOpenLoaded) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('앱오프닝 광고를 먼저 로드해 주세요.')));
      }
      return;
    }
    _appOpenAd!.showAd();
    _isAppOpenLoaded = false;
    // iOS는 AdWhaleAppOpenAd.shared 싱글톤이라, 여기서 참조만 끊으면 네이티브에
    // 미사용 광고가 남아 다음 load가 실패할 수 있다. 정리는 onDismissed / onShowFailed에서 destroy().
  }

  void _loadTemplateNative() {
    _adWhaleTemplateNativeAd?.destroy();
    _adWhaleTemplateNativeAd = null;
    _isTemplateNativeLoaded = false;

    // 공통 네이티브 상태 초기화
    _adWhaleNativeAd?.destroy();
    _adWhaleNativeAd = null;
    _nativeLoaded = false;
    _nativeShown = false;
    _nativeHeight = null;
    _nativeHeightSub?.cancel();
    _nativeHeightSub = null;

    setState(() {
      _nativeShown = false;
      _nativeHeight = null;
      _nativeLoaded = false;
    });

    _adWhaleTemplateNativeAd =
    AdWhaleNativeTemplateView(
      placementUid: _currentPlacementUid(),
      nativeAdLoadCallback: AdWhaleNativeAdLoadCallback(
        onLoaded: (ad) {
          debugPrint('GuideSampleAndroidPage TemplateNative onLoaded');
          setState(() {
            _isTemplateNativeLoaded = true;
            _nativeLoaded = true;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('네이티브 템플릿 광고 로드 완료')),
            );
          }
        },
        onLoadFailed: (ad, code, message) {
          debugPrint(
            'GuideSampleAndroidPage TemplateNative onFailedToLoad: $code, $message',
          );
          ad.destroy();
          setState(() {
            _adWhaleTemplateNativeAd = null;
            _isTemplateNativeLoaded = false;
            _nativeLoaded = false;
            _nativeShown = false;
            _nativeHeight = null;
          });
        },
        onShowFailed: (ad, code, message) {
          debugPrint(
            'GuideSampleAndroidPage TemplateNative onShowFailed: $code, $message',
          );
          ad.destroy();
          setState(() {
            _adWhaleTemplateNativeAd = null;
            _isTemplateNativeLoaded = false;
            _nativeLoaded = false;
            _nativeShown = false;
            _nativeHeight = null;
          });
        },
        onClicked: (ad) {
          debugPrint('GuideSampleAndroidPage TemplateNative onClicked');
        },
        onClosed: (ad) {
          debugPrint('GuideSampleAndroidPage TemplateNative onClosed');
        },
      ),
      template: _selectedTemplateSize,
    )
      ..setRegion('서울시 구로구')
      ..setGcoder(37.48, 126.89)
      ..setPlacementName('test_template_native');

    _adWhaleNativeAd = _adWhaleTemplateNativeAd;
    _nativeLoaded = false;

    _nativeHeightSub = instanceManager.nativeAdHeightStream.listen((int h) {
      if (!mounted) return;
      setState(() {
        _nativeHeight = h.toDouble();
      });
    });

    _adWhaleTemplateNativeAd!.loadAd();
  }

  void _showTemplateNative() {
    if (_adWhaleTemplateNativeAd == null || !_isTemplateNativeLoaded) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('네이티브 템플릿 광고를 먼저 로드해 주세요.')),
        );
      }
      return;
    }
    _adWhaleTemplateNativeAd!.showAd();
    setState(() {
      _isTemplateNativeLoaded = false;
      _nativeLoaded = false;
      _nativeShown = true; // 여기서 setState가 핵심 (native_test_page와 동일)
    });
  }

  void _loadCustomNative() {
    _adWhaleCustomNativeAd?.destroy();
    _adWhaleCustomNativeAd = null;
    _isCustomNativeLoaded = false;

    _adWhaleNativeAd?.destroy();
    _adWhaleNativeAd = null;
    _nativeLoaded = false;
    _nativeShown = false;
    _nativeHeight = null;
    _nativeHeightSub?.cancel();
    _nativeHeightSub = null;

    setState(() {
      _nativeShown = false;
      _nativeHeight = null;
      _nativeLoaded = false;
    });

    _adWhaleCustomNativeAd =
    AdWhaleNativeCustomView(
      placementUid: Platform.isIOS
          ? AdConfig.iosNativeAdUnitId
          : _currentPlacementUid(),
      nativeAdLoadCallback: AdWhaleNativeAdLoadCallback(
        onLoaded: (ad) {
          debugPrint('GuideSampleAndroidPage CustomNative onLoaded');
          setState(() {
            _isCustomNativeLoaded = true;
            _nativeLoaded = true;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('네이티브 커스텀 광고 로드 완료')),
            );
          }
        },
        onLoadFailed: (ad, code, message) {
          debugPrint(
            'GuideSampleAndroidPage CustomNative onFailedToLoad: $code, $message',
          );
          ad.destroy();
          setState(() {
            _adWhaleCustomNativeAd = null;
            _isCustomNativeLoaded = false;
            _nativeLoaded = false;
            _nativeShown = false;
            _nativeHeight = null;
          });
        },
        onShowFailed: (ad, code, message) {
          debugPrint(
            'GuideSampleAndroidPage CustomNative onShowFailed: $code, $message',
          );
          ad.destroy();
          setState(() {
            _adWhaleCustomNativeAd = null;
            _isCustomNativeLoaded = false;
            _nativeLoaded = false;
            _nativeShown = false;
            _nativeHeight = null;
          });
        },
        onClicked: (ad) {
          debugPrint('GuideSampleAndroidPage CustomNative onClicked');
        },
        onClosed: (ad) {
          debugPrint('GuideSampleAndroidPage CustomNative onClosed');
        },
      ),
      factoryId: 'app_custom',
    )
      ..setRegion('서울시 구로구')
      ..setGcoder(37.48, 126.89)
      ..setPlacementName('test_custom_native');

    _adWhaleNativeAd = _adWhaleCustomNativeAd;
    _nativeLoaded = false;

    _nativeHeightSub = instanceManager.nativeAdHeightStream.listen((int h) {
      if (!mounted) return;
      setState(() {
        _nativeHeight = h.toDouble();
      });
    });

    _adWhaleCustomNativeAd!.loadAd();
  }

  void _showCustomNative() {
    if (_adWhaleCustomNativeAd == null || !_isCustomNativeLoaded) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('네이티브 커스텀 광고를 먼저 로드해 주세요.')),
        );
      }
      return;
    }
    _adWhaleCustomNativeAd!.showAd();
    setState(() {
      _isCustomNativeLoaded = false;
      _nativeLoaded = false;
      _nativeShown = true;
    });
  }

  Widget _purpleSmallButton(String text, {VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6739F5),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 11),
        minimumSize: const Size(0, 0),
      ),
      child: Text(text),
    );
  }

  Widget _purpleButton(String text, {required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6739F5),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        textStyle: const TextStyle(fontSize: 13),
      ),
      child: Text(text),
    );
  }
}
