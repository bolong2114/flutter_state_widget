import 'package:flutter/widgets.dart';

/// Localized default copy used by [StateWidget]'s built-in placeholders.
@immutable
class StateWidgetTexts {
  final String emptyTitle;
  final String errorTitle;
  final String retryLabel;

  const StateWidgetTexts({
    required this.emptyTitle,
    required this.errorTitle,
    required this.retryLabel,
  });

  static const StateWidgetTexts english = StateWidgetTexts(
    emptyTitle: 'No data available',
    errorTitle: 'Something went wrong',
    retryLabel: 'Retry',
  );

  static const StateWidgetTexts chinese = StateWidgetTexts(
    emptyTitle: '暂无数据',
    errorTitle: '出了点问题',
    retryLabel: '重试',
  );

  /// Returns package defaults for the given locale, falling back to English.
  static StateWidgetTexts defaultsFor(Locale? locale) {
    switch (locale?.languageCode) {
      case 'zh':
        return chinese;
      default:
        return english;
    }
  }
}
