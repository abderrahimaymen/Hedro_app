import 'package:flutter/foundation.dart';
import '../models/flow_calculator.dart';
import '../l10n/app_translations.dart';

/// App-wide state provider using ChangeNotifier + Provider.
class AppProvider extends ChangeNotifier {
  // ── Theme ──────────────────────────────────────────────────────────
  bool _isDark = false;
  bool get isDark => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  // ── Locale / Language ──────────────────────────────────────────────
  String _locale = 'en'; // 'en', 'fr', 'ar'
  String get locale => _locale;

  /// Whether current language is RTL (Arabic).
  bool get isRtl => _locale == 'ar';

  void setLocale(String locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  /// Convenience: get a translated string for the current locale.
  String t(String key) => AppTranslations.get(_locale, key);

  // ── Inputs ─────────────────────────────────────────────────────────
  PipeInputs _inputs = const PipeInputs(
    pipeLength: '',
    pipeDiameter: '',
    flowRate: '',
    roughness: '',
  );

  PipeInputs get inputs => _inputs;

  void updateInput(String field, String value) {
    switch (field) {
      case 'pipeLength':
        _inputs = _inputs.copyWith(pipeLength: value);
        break;
      case 'pipeDiameter':
        _inputs = _inputs.copyWith(pipeDiameter: value);
        break;
      case 'flowRate':
        _inputs = _inputs.copyWith(flowRate: value);
        break;
      case 'roughness':
        _inputs = _inputs.copyWith(roughness: value);
        break;
    }
    notifyListeners();
  }

  // ── Validation errors ──────────────────────────────────────────────
  Set<String> _validationErrors = {};
  Set<String> get validationErrors => _validationErrors;

  // ── Results ────────────────────────────────────────────────────────
  FlowResults? _results;
  FlowResults? get results => _results;

  // ── Calculate ──────────────────────────────────────────────────────
  bool calculate() {
    final errors = <String>{};

    final L = double.tryParse(_inputs.pipeLength);
    final D = double.tryParse(_inputs.pipeDiameter);
    final Q = double.tryParse(_inputs.flowRate);

    if (L == null || L <= 0) errors.add('pipeLength');
    if (D == null || D <= 0) errors.add('pipeDiameter');
    if (Q == null || Q <= 0) errors.add('flowRate');

    _validationErrors = errors;

    if (errors.isNotEmpty) {
      notifyListeners();
      return false;
    }

    try {
      final roughnessMm = _inputs.roughness.isNotEmpty
          ? double.tryParse(_inputs.roughness)
          : null;

      _results = FlowCalculator.calculate(
        L: L!,
        D: D!,
        Q: Q!,
        roughnessMm: roughnessMm,
      );
      notifyListeners();
      return true;
    } catch (_) {
      _validationErrors = {'general'};
      notifyListeners();
      return false;
    }
  }

  // ── Reset ──────────────────────────────────────────────────────────
  void resetAll() {
    _inputs = const PipeInputs(
      pipeLength: '',
      pipeDiameter: '',
      flowRate: '',
      roughness: '',
    );
    _results = null;
    _validationErrors = {};
    notifyListeners();
  }
}
