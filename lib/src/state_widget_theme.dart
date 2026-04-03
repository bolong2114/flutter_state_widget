import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Theme data used by [StateWidget]'s built-in loading and message panels.
@immutable
class StateWidgetThemeData extends ThemeExtension<StateWidgetThemeData> {
  final Color? iconColor;
  final Color? messageColor;
  final Color? loadingIndicatorColor;
  final TextStyle? messageStyle;
  final ButtonStyle? actionButtonStyle;
  final EdgeInsetsGeometry? padding;
  final double? iconSize;
  final double? iconTitleSpacing;
  final double? actionSpacing;
  final double? maxContentWidth;

  const StateWidgetThemeData({
    this.iconColor,
    this.messageColor,
    this.loadingIndicatorColor,
    this.messageStyle,
    this.actionButtonStyle,
    this.padding,
    this.iconSize,
    this.iconTitleSpacing,
    this.actionSpacing,
    this.maxContentWidth,
  });

  /// Package fallback values derived from the ambient Material theme.
  factory StateWidgetThemeData.fallback(ThemeData theme) {
    return StateWidgetThemeData(
      iconColor: theme.colorScheme.outline,
      messageColor: theme.colorScheme.onSurfaceVariant,
      loadingIndicatorColor: theme.progressIndicatorTheme.color,
      messageStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      actionButtonStyle: theme.outlinedButtonTheme.style,
      padding: const EdgeInsets.all(24),
      iconSize: 40,
      iconTitleSpacing: 12,
      actionSpacing: 16,
      maxContentWidth: 320,
    );
  }

  @override
  StateWidgetThemeData copyWith({
    Color? iconColor,
    Color? messageColor,
    Color? loadingIndicatorColor,
    TextStyle? messageStyle,
    ButtonStyle? actionButtonStyle,
    EdgeInsetsGeometry? padding,
    double? iconSize,
    double? iconTitleSpacing,
    double? actionSpacing,
    double? maxContentWidth,
  }) {
    return StateWidgetThemeData(
      iconColor: iconColor ?? this.iconColor,
      messageColor: messageColor ?? this.messageColor,
      loadingIndicatorColor:
          loadingIndicatorColor ?? this.loadingIndicatorColor,
      messageStyle: messageStyle ?? this.messageStyle,
      actionButtonStyle: actionButtonStyle ?? this.actionButtonStyle,
      padding: padding ?? this.padding,
      iconSize: iconSize ?? this.iconSize,
      iconTitleSpacing: iconTitleSpacing ?? this.iconTitleSpacing,
      actionSpacing: actionSpacing ?? this.actionSpacing,
      maxContentWidth: maxContentWidth ?? this.maxContentWidth,
    );
  }

  /// Overlays [other] on top of the current theme data.
  StateWidgetThemeData merge(StateWidgetThemeData? other) {
    if (other == null) {
      return this;
    }

    return copyWith(
      iconColor: other.iconColor,
      messageColor: other.messageColor,
      loadingIndicatorColor: other.loadingIndicatorColor,
      messageStyle: other.messageStyle,
      actionButtonStyle: other.actionButtonStyle,
      padding: other.padding,
      iconSize: other.iconSize,
      iconTitleSpacing: other.iconTitleSpacing,
      actionSpacing: other.actionSpacing,
      maxContentWidth: other.maxContentWidth,
    );
  }

  @override
  StateWidgetThemeData lerp(
    covariant ThemeExtension<StateWidgetThemeData>? other,
    double t,
  ) {
    if (other is! StateWidgetThemeData) {
      return this;
    }

    return StateWidgetThemeData(
      iconColor: Color.lerp(iconColor, other.iconColor, t),
      messageColor: Color.lerp(messageColor, other.messageColor, t),
      loadingIndicatorColor:
          Color.lerp(loadingIndicatorColor, other.loadingIndicatorColor, t),
      messageStyle: TextStyle.lerp(messageStyle, other.messageStyle, t),
      actionButtonStyle: ButtonStyle.lerp(
        actionButtonStyle,
        other.actionButtonStyle,
        t,
      ),
      padding: EdgeInsetsGeometry.lerp(padding, other.padding, t),
      iconSize: lerpDouble(iconSize, other.iconSize, t),
      iconTitleSpacing: lerpDouble(iconTitleSpacing, other.iconTitleSpacing, t),
      actionSpacing: lerpDouble(actionSpacing, other.actionSpacing, t),
      maxContentWidth: lerpDouble(maxContentWidth, other.maxContentWidth, t),
    );
  }
}

/// A local theme override for [StateWidget]'s built-in panels.
class StateWidgetTheme extends InheritedTheme {
  final StateWidgetThemeData data;

  const StateWidgetTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// Resolves fallback values, ThemeData extensions, and local overrides.
  static StateWidgetThemeData of(BuildContext context) {
    final theme = Theme.of(context);
    final inherited =
        context.dependOnInheritedWidgetOfExactType<StateWidgetTheme>();

    return StateWidgetThemeData.fallback(theme)
        .merge(theme.extension<StateWidgetThemeData>())
        .merge(inherited?.data);
  }

  @override
  bool updateShouldNotify(StateWidgetTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StateWidgetTheme(data: data, child: child);
  }
}
