import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:adwhale_sdk_flutter/adwhale_sdk_flutter.dart';

/// AdWhaleMediationAds API 단위 테스트 샘플 (Android / iOS 통합).
///
/// 지원 매트릭스:
/// - 1~4: Android O iOS O
/// - 5~8: Android X iOS O
/// - 9~10: Android O iOS X
///
/// 각 기능 실행 후 테스트 결과를 화면에서 확인할 수 있습니다.
class MediationAdsTestPage extends StatefulWidget {
  const MediationAdsTestPage({super.key});

  @override
  State<MediationAdsTestPage> createState() => _MediationAdsTestPageState();
}

class _MediationAdsTestPageState extends State<MediationAdsTestPage> {
  final Map<String, String> _results = {};
  bool _loading = false;
  final TextEditingController _testDeviceIdsController =
  TextEditingController();

  @override
  void dispose() {
    _testDeviceIdsController.dispose();
    super.dispose();
  }

  bool get _isAndroid => Platform.isAndroid;
  bool get _isIOS => Platform.isIOS;

  void _setResult(String key, String value) {
    setState(() {
      _results[key] = value;
    });
  }

  void _run(String key, Future<void> Function() action) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _results[key] = '실행 중...';
    });
    try {
      await action();
    } catch (e, st) {
      _setResult(key, '에러: $e\n$st');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  static const _unsupportedMessage = '현재 플랫폼 미지원';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AdWhaleMediationAds 단위 테스트'),
        backgroundColor: const Color(0xFF6739F5),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('1~4 공통 (Android ✓ iOS ✓)'),
          _testRow(
            key: '1_initialize',
            label: '1. initialize',
            support: 'Android ✓ iOS ✓',
            platformSupported: true,
            run: () async {
              final r = await AdWhaleMediationAds.instance.initialize();
              _setResult(
                '1_initialize',
                'statusCode: ${r.statusCode}\nmessage: ${r.message}\nisSuccess: ${r.isSuccess}',
              );
            },
          ),
          _testRow(
            key: '2_requestGdprConsent',
            label: '2. requestGdprConsent',
            support: 'Android ✓ iOS ✓',
            platformSupported: true,
            run: () async {
              final r = await AdWhaleMediationAds.instance.requestGdprConsent();
              _setResult(
                '2_requestGdprConsent',
                'success: ${r['success']}\nmessage: ${r['message']}',
              );
            },
          ),
          _testRow(
            key: '3_resetGdprConsentStatus',
            label: '3. resetGdprConsentStatus',
            support: 'Android ✓ iOS ✓',
            platformSupported: true,
            run: () async {
              await AdWhaleMediationAds.instance.resetGdprConsentStatus();
              _setResult('3_resetGdprConsentStatus', '완료 (void)');
            },
          ),
          _testRowWithBool(
            key: '4_setCoppa',
            label: '4. setCoppa(isChildDirected)',
            support: 'Android ✓ iOS ✓',
            platformSupported: true,
            run: (value) async {
              await AdWhaleMediationAds.instance.setCoppa(value);
              _setResult('4_setCoppa', 'setCoppa($value) 완료');
            },
          ),
          const SizedBox(height: 24),
          _sectionTitle('5~8 iOS 전용 (Android ✗ iOS ✓)'),
          _testRowWithBool(
            key: '5_setTagForUnderAgeOfConsent',
            label: '5. setTagForUnderAgeOfConsent(value)',
            support: 'Android ✗ iOS ✓',
            platformSupported: true,
            run: (value) async {
              try {
                await AdWhaleMediationAds.instance.setTagForUnderAgeOfConsent(value);
                _setResult('5_setTagForUnderAgeOfConsent', 'setTagForUnderAgeOfConsent($value) 완료');
              } catch (e) {
                _setResult('5_setTagForUnderAgeOfConsent', '에러(미지원 등): $e');
              }
            },
          ),
          _testRowMaxAdContentRating(),
          _testRowTestDeviceIds(),
          _testRow(
            key: '8_showAdInspector',
            label: '8. showAdInspector',
            support: 'Android ✗ iOS ✓',
            platformSupported: true,
            run: () async {
              try {
                final ok = await AdWhaleMediationAds.instance.showAdInspector();
                _setResult('8_showAdInspector', 'result: $ok');
              } catch (e) {
                _setResult('8_showAdInspector', '에러(미지원 등): $e');
              }
            },
          ),
          const SizedBox(height: 24),
          _sectionTitle('9~10 Android 전용 (Android ✓ iOS ✗)'),
          _testRowWithBool(
            key: '9_setLoggerEnabled',
            label: '9. setLoggerEnabled(enabled)',
            support: 'Android ✓ iOS ✗',
            platformSupported: true,
            run: (value) async {
              try {
                await AdWhaleMediationAds.instance.setLoggerEnabled(value);
                _setResult('9_setLoggerEnabled', 'setLoggerEnabled($value) 완료');
              } catch (e) {
                _setResult('9_setLoggerEnabled', '에러(미지원 등): $e');
              }
            },
          ),
          _testRow(
            key: '10_getLogLevel',
            label: '10. getLogLevel',
            support: 'Android ✓ iOS ✗',
            platformSupported: true,
            run: () async {
              try {
                final level =
                await AdWhaleMediationAds.instance.getLogLevel();
                _setResult('10_getLogLevel', 'logLevel: "$level"');
              } catch (e) {
                _setResult('10_getLogLevel', '에러(미지원 등): $e');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6739F5),
        ),
      ),
    );
  }

  Widget _testRow({
    required String key,
    required String label,
    required String support,
    required bool platformSupported,
    required Future<void> Function() run,
  }) {
    return _ResultCard(
      label: label,
      support: support,
      result: _results[key],
      loading: _loading,
      platformSupported: platformSupported,
      onRun: () => _run(key, run),
    );
  }

  Widget _testRowWithBool({
    required String key,
    required String label,
    required String support,
    required bool platformSupported,
    required Future<void> Function(bool value) run,
  }) {
    return _ResultCardWithBool(
      label: label,
      support: support,
      result: _results[key],
      loading: _loading,
      platformSupported: platformSupported,
      onRun: (value) => _run(key, () => run(value)),
    );
  }

  Widget _testRowMaxAdContentRating() {
    const options = [
      ('.general', '.general'),
      ('.parentalGuidance', '.parentalGuidance'),
      ('.teen', '.teen'),
      ('.matureAudience', '.matureAudience'),
      ('해제(null)', null),
    ];
    return _ResultCardWithOptions<String?>(
      label: '6. setMaxAdContentRating(rating)',
      support: 'Android ✗ iOS ✓',
      result: _results['6_setMaxAdContentRating'],
      loading: _loading,
      platformSupported: true,
      options: options,
      onRun: (rating) => _run('6_setMaxAdContentRating', () async {
        try {
          await AdWhaleMediationAds.instance.setMaxAdContentRating(rating);
          _setResult(
            '6_setMaxAdContentRating',
            rating == null ? '설정 해제 완료' : 'setMaxAdContentRating($rating) 완료',
          );
        } catch (e) {
          _setResult('6_setMaxAdContentRating', '에러(미지원 등): $e');
        }
      }),
    );
  }

  Widget _testRowTestDeviceIds() {
    return _ResultCardWithTextField(
      label: '7. setTestDeviceIdentifiers(ids)',
      support: 'Android ✗ iOS ✓',
      hint: '쉼표로 구분 (예: id1, id2)',
      result: _results['7_setTestDeviceIdentifiers'],
      loading: _loading,
      platformSupported: true,
      onRun: () {
        final text = _testDeviceIdsController.text.trim();
        final ids = text.isEmpty
            ? <String>[]
            : text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        _run('7_setTestDeviceIdentifiers', () async {
          try {
            await AdWhaleMediationAds.instance.setTestDeviceIdentifiers(ids);
            _setResult(
              '7_setTestDeviceIdentifiers',
              ids.isEmpty ? '빈 목록 적용' : 'ids: $ids',
            );
          } catch (e) {
            _setResult('7_setTestDeviceIdentifiers', '에러(미지원 등): $e');
          }
        });
      },
      controller: _testDeviceIdsController,
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.label,
    required this.support,
    required this.result,
    required this.loading,
    required this.platformSupported,
    required this.onRun,
  });

  final String label;
  final String support;
  final String? result;
  final bool loading;
  final bool platformSupported;
  final VoidCallback onRun;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  support,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            if (!platformSupported)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '현재 플랫폼 미지원',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                ),
              ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: (loading || !platformSupported) ? null : onRun,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6739F5),
                foregroundColor: Colors.white,
              ),
              child: const Text('실행'),
            ),
            if (result != null && result!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  result!,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultCardWithBool extends StatelessWidget {
  const _ResultCardWithBool({
    required this.label,
    required this.support,
    required this.result,
    required this.loading,
    required this.platformSupported,
    required this.onRun,
  });

  final String label;
  final String support;
  final String? result;
  final bool loading;
  final bool platformSupported;
  final void Function(bool value) onRun;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  support,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            if (!platformSupported)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '현재 플랫폼 미지원',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: (loading || !platformSupported) ? null : () => onRun(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6739F5),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('true'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: (loading || !platformSupported) ? null : () => onRun(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6739F5),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('false'),
                ),
              ],
            ),
            if (result != null && result!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  result!,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultCardWithOptions<T> extends StatelessWidget {
  const _ResultCardWithOptions({
    required this.label,
    required this.support,
    required this.result,
    required this.loading,
    required this.platformSupported,
    required this.options,
    required this.onRun,
  });

  final String label;
  final String support;
  final String? result;
  final bool loading;
  final bool platformSupported;
  final List<(String display, T value)> options;
  final void Function(T value) onRun;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  support,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            if (!platformSupported)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '현재 플랫폼 미지원',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: options
                  .map((e) => ElevatedButton(
                onPressed: (loading || !platformSupported) ? null : () => onRun(e.$2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6739F5),
                  foregroundColor: Colors.white,
                ),
                child: Text(e.$1),
              ))
                  .toList(),
            ),
            if (result != null && result!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  result!,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultCardWithTextField extends StatelessWidget {
  const _ResultCardWithTextField({
    required this.label,
    required this.support,
    required this.hint,
    required this.result,
    required this.loading,
    required this.platformSupported,
    required this.onRun,
    required this.controller,
  });

  final String label;
  final String support;
  final String hint;
  final String? result;
  final bool loading;
  final bool platformSupported;
  final VoidCallback onRun;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  support,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            if (!platformSupported)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '현재 플랫폼 미지원',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                ),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: (loading || !platformSupported) ? null : onRun,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6739F5),
                foregroundColor: Colors.white,
              ),
              child: const Text('실행'),
            ),
            if (result != null && result!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  result!,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
