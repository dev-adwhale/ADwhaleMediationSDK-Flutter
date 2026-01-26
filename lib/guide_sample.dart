import 'package:flutter/material.dart';
import 'package:adwhale_sdk_flutter/adwhale_sdk_flutter.dart';

class GuideSamplePage extends StatefulWidget {
  const GuideSamplePage({super.key});

  @override
  State<GuideSamplePage> createState() => _GuideSamplePageState();
}

class _GuideSamplePageState extends State<GuideSamplePage> {
  bool _isCoppa = false;
  bool _isLoggerOn = false;

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

  @override
  void initState() {
    super.initState();
    _placementUidByType.addAll(<int, String>{
      0: "placement Uid 를 발급받으세요", // 배너
      1: "placement Uid 를 발급받으세요", // 전면
      2: "placement Uid 를 발급받으세요", // 보상형전면
      3: "placement Uid 를 발급받으세요", // 네이티브(템플릿)
      4: "placement Uid 를 발급받으세요", // 네이티브(커스텀)
      5: "placement Uid 를 발급받으세요", // 앱 오프닝
    });
    _placementUidController.text = _placementUidByType[_selectedAdType] ?? '';
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
    if (_selectedAdType == 4) {
      // 네이티브 커스텀 광고 기본 높이
      return 720;
    }

    switch (_selectedTemplateSize) {
      case AdWhaleNativeTemplate.small:
        return 320;
      case AdWhaleNativeTemplate.medium:
        return 520;
      case AdWhaleNativeTemplate.fullscreen:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  // COPPA + GDPR / CHECK / RESET
                  Row(
                    children: [
                      const Text('COPPA'),
                      const SizedBox(width: 8),
                      Switch(
                        value: _isCoppa,
                        onChanged: (v) async {
                          setState(() => _isCoppa = v);
                          // COPPA 토글: false -> setCoppa(false), true -> setCoppa(true)
                          await AdWhaleMediationAds.instance.setCoppa(v);
                        },
                      ),
                      const SizedBox(width: 8),
                      _purpleSmallButton(
                        'GDPR',
                        onPressed: () async {
                          // GDPR 버튼: requestGdprConsent()
                          await AdWhaleMediationAds.instance
                              .requestGdprConsent();
                        },
                      ),
                      const SizedBox(width: 8),
                      // CHECK 버튼: getAdwhaleGDPR() 호출 후 결과 확인용
                      _purpleSmallButton(
                        'CHECK',
                        onPressed: () async {
                          final consent = await AdWhaleMediationAds.instance
                              .getAdwhaleGDPR();
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'GDPR 동의 상태: ${consent ? 'TRUE' : 'FALSE'}',
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _purpleSmallButton(
                        'RESET',
                        onPressed: () async {
                          // reset 버튼: resetGdprConsentStatus()
                          await AdWhaleMediationAds.instance
                              .resetGdprConsentStatus();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // SINGLE GDPR TRUE / FALSE
                  Row(
                    children: [
                      _purpleSmallButton(
                        'SINGLE GDPR TRUE',
                        onPressed: () async {
                          // single gdpr true: setGdpr(true)
                          await AdWhaleMediationAds.instance.setGdpr(true);
                        },
                      ),
                      const SizedBox(width: 16),
                      _purpleSmallButton(
                        'SINGLE GDPR FALSE',
                        onPressed: () async {
                          // single gdpr false: setGdpr(false)
                          await AdWhaleMediationAds.instance.setGdpr(false);
                        },
                      ),
                      // const Spacer(),
                      // _purpleSmallButton(
                      //   'ADMOB AD INSPECTOR',
                      //   onPressed: () {
                      //   },
                      // ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('1. 로거출력여부:', style: TextStyle(fontSize: 15)),
                  Switch(
                    value: _isLoggerOn,
                    onChanged: (v) async {
                      // 로거 출력 여부 토글:
                      //  - true  -> AdWhaleLog.setLogLevel(Verbose)
                      //  - false -> AdWhaleLog.setLogLevel(None)
                      setState(() => _isLoggerOn = v);
                      await AdWhaleMediationAds.instance.setLoggerEnabled(v);
                      final logLevel = await AdWhaleMediationAds.instance.getLogLevel();
                      debugPrint('현재 로그 레벨: $logLevel');
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
                      _adTypeRadio(3, '네이티브광고(고정형템플릿)'),
                      _adTypeRadio(4, '네이티브광고(커스텀바인딩)'),
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
                  const Text(
                    '4. placement uid입력:',
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _placementUidController,
                    onChanged: (v) {
                      _placementUidByType[_selectedAdType] = v.trim();
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'placement uid를 입력해주세요.',
                      contentPadding: EdgeInsets.symmetric(
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
                            _purpleButton('복사', onPressed: () {}),
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
                            _purpleButton('복사', onPressed: () {}),
                          ],
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    readOnly: true,
                    minLines: 6,
                    maxLines: null,
                    decoration: InputDecoration(
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
        Text(label),
      ],
    );
  }

  Widget _bannerSizeRadio(int value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<int>(
          value: value,
          groupValue: _selectedBannerSize,
          onChanged: (v) => setState(() => _selectedBannerSize = v ?? 0),
        ),
        Text(label),
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
      'GuideSamplePage _createBanner size=$bannerSize, adaptiveWidth=$adaptiveAnchorWidth',
    );
    _adWhaleAdView =
        AdWhaleAdView(
            listener: AdWhaleAdViewListener(
              onLoaded: (ad) {
                debugPrint(
                  'GuideSamplePage BannerAd onLoaded for size $bannerSize',
                );
                setState(() {});
              },
              onLoadFailed: (ad, errorCode, errorMessage) {
                debugPrint(
                  'GuideSamplePage BannerAd onLoadFailed for $bannerSize: errorCode: $errorCode, errorMessage: $errorMessage',
                );
                ad.destroy();
                setState(() {
                  _adWhaleAdView = null;
                });
              },
              onClicked: (ad) {
                debugPrint(
                  'GuideSamplePage BannerAd onClicked for size $bannerSize',
                );
              },
            ),
            adInfo: AdInfo(_currentPlacementUid(), bannerSize),
          )
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
    _placementUidController.dispose();
    _adaptiveWidthController.dispose();
    super.dispose();
  }

  void _onLoadNonBannerPressed() {
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

    setState(() {});
  }

  void _loadInterstitial() {
    _interstitialAd?.destroy();
    _interstitialAd = null;
    _isInterstitialLoaded = false;

    _interstitialAd =
        AdWhaleInterstitialAd(
            appCode: _currentPlacementUid(),
            adLoadCallback: AdWhaleInterstitialAdLoadCallback(
              onLoaded: () {
                debugPrint('GuideSamplePage Interstitial onLoaded');
                _isInterstitialLoaded = true;
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('전면 광고 로드 완료')));
                }
              },
              onLoadFailed: (errorCode, errorMessage) {
                debugPrint(
                  'GuideSamplePage Interstitial onLoadFailed: $errorMessage',
                );
                _interstitialAd = null;
                _isInterstitialLoaded = false;
              },
              onShowed: () {
                debugPrint('GuideSamplePage Interstitial onAdShowed');
              },
              onShowFailed: (errorCode, errorMessage) {
                debugPrint(
                  'GuideSamplePage Interstitial onAdShowFailed: $errorMessage',
                );
                _interstitialAd = null;
                _isInterstitialLoaded = false;
              },
              onClosed: () {
                debugPrint('GuideSamplePage Interstitial onAdClosed');
              },
              onClicked: () {
                debugPrint('GuideSamplePage Interstitial onClicked');
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
            appCode: _currentPlacementUid(),
            adRewardLoadCallback: AdWhaleRewardAdLoadCallback(
              onLoaded: () {
                debugPrint('GuideSamplePage Reward onLoaded');
                _isRewardLoaded = true;
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('보상형 광고 로드 완료')));
                }
              },
              onLoadFailed: (errorCode, errorMessage) {
                debugPrint(
                  'GuideSamplePage Reward onAdFailedToLoad: errorCode: $errorCode, errorMessage: $errorMessage',
                );
                _rewardAd = null;
                _isRewardLoaded = false;
              },
              onUserRewarded: (amount, type) {
                debugPrint(
                  'GuideSamplePage Reward onUserRewarded: $amount, $type',
                );
              },
              onClicked: () {
                debugPrint('GuideSamplePage Reward onClicked');
              },
              onShowed: () {
                debugPrint('GuideSamplePage Reward onAdShowed');
              },
              onShowFailed: (String errorCode, String errorMessage) {
                debugPrint(
                  'GuideSamplePage Reward onFailedToShow: errorCode: $errorCode, errorMessage: $errorMessage',
                );
              },
              onDismissed: () {
                debugPrint('GuideSamplePage Reward onDismissed');
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
            placementUid: _currentPlacementUid(),
            adLoadCallback: AdWhaleAppOpenAdLoadCallback(
              onLoaded: () {
                debugPrint('GuideSamplePage AppOpen onLoaded');
                _isAppOpenLoaded = true;
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('앱오프닝 광고 로드 완료')),
                  );
                }
              },
              onLoadFailed: (code, message) {
                debugPrint(
                  'GuideSamplePage AppOpen onLoadFailed: $code, $message',
                );
                _appOpenAd = null;
                _isAppOpenLoaded = false;
              },
              onShowed: () {
                debugPrint('GuideSamplePage AppOpen onAdShowed');
              },
              onShowFailed: (code, message) {
                debugPrint(
                  'GuideSamplePage AppOpen onAdShowFailed: $code, $message',
                );
                _appOpenAd = null;
                _isAppOpenLoaded = false;
              },
              onDismissed: () {
                debugPrint('GuideSamplePage AppOpen onAdDismissed');
              },
              onClicked: () {
                debugPrint('GuideSamplePage AppOpen onClicked');
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
    _appOpenAd = null;
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

    setState(() {
      _nativeShown = false;
      _nativeLoaded = false;
    });

    _adWhaleTemplateNativeAd =
        AdWhaleNativeTemplateView(
            placementUid: _currentPlacementUid(),
            nativeAdLoadCallback: AdWhaleNativeAdLoadCallback(
              onLoaded: (ad) {
                debugPrint('GuideSamplePage TemplateNative onLoaded');
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
                  'GuideSamplePage TemplateNative onFailedToLoad: $code, $message',
                );
                ad.destroy();
                setState(() {
                  _adWhaleTemplateNativeAd = null;
                  _isTemplateNativeLoaded = false;
                  _nativeLoaded = false;
                  _nativeShown = false;
                });
              },
              onShowFailed: (ad, code, message) {
                debugPrint(
                  'GuideSamplePage TemplateNative onShowFailed: $code, $message',
                );
                ad.destroy();
                setState(() {
                  _adWhaleTemplateNativeAd = null;
                  _isTemplateNativeLoaded = false;
                  _nativeLoaded = false;
                  _nativeShown = false;
                });
              },
              onClicked: (ad) {
                debugPrint('GuideSamplePage TemplateNative onClicked');
              },
              onClosed: (ad) {
                debugPrint('GuideSamplePage TemplateNative onClosed');
              },
            ),
            template: _selectedTemplateSize,
          )
          ..setRegion('서울시 구로구')
          ..setGcoder(37.48, 126.89)
          ..setPlacementName('test_template_native');

    _adWhaleNativeAd = _adWhaleTemplateNativeAd;
    _nativeLoaded = false;

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

    setState(() {
      _nativeShown = false;
      _nativeLoaded = false;
    });

    _adWhaleCustomNativeAd =
        AdWhaleNativeCustomView(
            placementUid: _currentPlacementUid(),
            nativeAdLoadCallback: AdWhaleNativeAdLoadCallback(
              onLoaded: (ad) {
                debugPrint('GuideSamplePage CustomNative onLoaded');
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
                  'GuideSamplePage CustomNative onFailedToLoad: $code, $message',
                );
                ad.destroy();
                setState(() {
                  _adWhaleCustomNativeAd = null;
                  _isCustomNativeLoaded = false;
                  _nativeLoaded = false;
                  _nativeShown = false;
                });
              },
              onShowFailed: (ad, code, message) {
                debugPrint(
                  'GuideSamplePage CustomNative onShowFailed: $code, $message',
                );
                ad.destroy();
                setState(() {
                  _adWhaleCustomNativeAd = null;
                  _isCustomNativeLoaded = false;
                  _nativeLoaded = false;
                  _nativeShown = false;
                });
              },
              onClicked: (ad) {
                debugPrint('GuideSamplePage CustomNative onClicked');
              },
              onClosed: (ad) {
                debugPrint('GuideSamplePage CustomNative onClosed');
              },
            ),
            factoryId: 'app_custom',
          )
          ..setRegion('서울시 구로구')
          ..setGcoder(37.48, 126.89)
          ..setPlacementName('test_custom_native');

    _adWhaleNativeAd = _adWhaleCustomNativeAd;
    _nativeLoaded = false;

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

  Widget _purpleSmallButton(String text, {required VoidCallback onPressed}) {
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
