// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 2-A. First-run setup, also reachable from Home while setup is incomplete. Six
// steps; every step can be skipped. Status comes from the Android side and is re-read on resume
// and, on the switch step, every 500 ms (the input-method picker returns focus without a resume).
import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../bridge/messages.g.dart';
import '../../core/log.dart';
import '../../settings/kosha_settings.dart';
import '../app_services.dart';
import '../routes.dart';
import '../shell/settings_actions.dart';
import 'onboarding_steps.dart';

const int _stepCount = 6;
const Duration _switchPoll = Duration(milliseconds: 500);

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  AppServices? _services;
  late final AppLifecycleListener _lifecycle;
  Timer? _poll;
  int _step = 0;
  bool _enabled = false;
  bool _selected = false;
  bool? _internet;
  bool _debugBuild = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: () => unawaited(_refresh()));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_services != null) return;
    final services = AppScope.of(context);
    _services = services;
    unawaited(_refresh());
    unawaited(_readBuildInfo(services));
  }

  @override
  void dispose() {
    _poll?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _readBuildInfo(AppServices services) async {
    try {
      final info = await services.platform.getAppInfo();
      if (mounted) setState(() => _debugBuild = info.isDebugBuild);
    } on Object catch (e) {
      KoshaLog.w('Onboarding', 'app info unavailable', e.runtimeType);
    }
  }

  Future<void> _refresh() async {
    final services = _services;
    if (services == null) return;
    try {
      final enabled = await services.app.isKoshaEnabled();
      final selected = await services.app.isKoshaSelected();
      final internet = await services.platform.hasInternetPermission();
      if (!mounted) return;
      setState(() {
        _enabled = enabled;
        _selected = selected;
        _internet = internet;
      });
    } on Object catch (e) {
      KoshaLog.w('Onboarding', 'status check failed', e.runtimeType);
    }
  }

  void _goTo(int step) {
    final next = step.clamp(0, _stepCount - 1);
    _poll?.cancel();
    _poll = null;
    if (next == 1) {
      _poll = Timer.periodic(_switchPoll, (_) => unawaited(_refresh()));
    }
    setState(() => _step = next);
    if (next == 1) unawaited(_refresh());
  }

  bool get _stepDone => switch (_step) {
    0 => _enabled,
    1 => _selected,
    2 => _internet != null,
    _ => true,
  };

  void _finish() {
    writeSettings(
      context,
      SettingsSection.languages,
      (s) => s.copyWith(languages: s.languages.copyWith(onboardingDone: true)),
    );
    _leave();
  }

  /// Closes setup. On first run this screen is the root, so it is replaced by home.
  void _leave() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      unawaited(navigator.pushReplacementNamed(KoshaRoutes.home));
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = _services;
    final app = services?.app;
    final last = _step == _stepCount - 1;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set up Kosha'),
        actions: [IconButton(tooltip: 'Close setup', icon: const Icon(Icons.close), onPressed: _leave)],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: 'Step ${_step + 1} of $_stepCount',
                      child: LinearProgressIndicator(value: (_step + 1) / _stepCount, color: scheme.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${_step + 1}/$_stepCount', style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 320),
                child: KeyedSubtree(key: ValueKey<int>(_step), child: _stepBody(app)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  if (_step > 0) TextButton(onPressed: () => _goTo(_step - 1), child: const Text('Back')),
                  const Spacer(),
                  if (!_stepDone && !last) TextButton(onPressed: () => _goTo(_step + 1), child: const Text('Skip')),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: last ? _finish : () => _goTo(_step + 1), child: Text(last ? 'Done' : 'Next')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepBody(AppHostApi? app) => switch (_step) {
    0 => EnableStep(enabled: _enabled, onOpenSettings: () => unawaited(app?.openInputMethodSettings())),
    1 => SwitchStep(enabled: _enabled, selected: _selected, onChoose: () => unawaited(app?.showInputMethodPicker())),
    2 => PrivacyStep(internet: _internet, debugBuild: _debugBuild),
    3 => const PersonaliseStep(),
    4 => const TryStep(),
    _ => const FinishStep(),
  };
}
