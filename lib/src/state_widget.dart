import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'load_state.dart';
import 'state_snapshot.dart';
import 'state_widget_texts.dart';

/// Builds the success content for [StateWidget].
typedef StateContentBuilder<T> = Widget Function(BuildContext context, T data);

/// Builds a placeholder for a non-success state with an optional retry action.
typedef StatePlaceholderBuilder = Widget Function(
  BuildContext context,
  VoidCallback? onRetry,
);

/// Builds an error placeholder with an optional message and retry action.
typedef StateErrorBuilder = Widget Function(
  BuildContext context,
  String? message,
  VoidCallback? onRetry,
);

@immutable

/// Collection of optional builders used to replace the default state panels.
///
/// This object is immutable because it is intended to be passed around as
/// widget configuration, not mutated as runtime state.
class StatePanels {
  final WidgetBuilder? idle;
  final WidgetBuilder? loading;
  final StatePlaceholderBuilder? empty;
  final StateErrorBuilder? error;

  const StatePanels({
    this.idle,
    this.loading,
    this.empty,
    this.error,
  });
}

/// Renders one of several state panels, or success content when data is ready.
class StateWidget<T> extends StatelessWidget {
  /// Listenable source of truth for the current UI state.
  final ValueListenable<StateSnapshot<T>> listenable;

  /// Builds the success content when [LoadState.success] is active.
  final StateContentBuilder<T> builder;

  /// Called by the default or custom retry-capable panels.
  final VoidCallback? onRetry;

  /// Optional custom builders for replacing the default state panels.
  final StatePanels panels;

  /// Optional localized copy used by the built-in empty and error panels.
  ///
  /// When omitted, the widget resolves package defaults from the current
  /// locale and falls back to English when no match is available.
  final StateWidgetTexts? texts;

  const StateWidget({
    super.key,
    required this.listenable,
    required this.builder,
    this.onRetry,
    this.panels = const StatePanels(),
    this.texts,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<StateSnapshot<T>>(
      valueListenable: listenable,
      builder: (context, snapshot, _) {
        switch (snapshot.status) {
          case LoadState.idle:
            return _buildIdle(context);
          case LoadState.loading:
            return _buildLoading(context);
          case LoadState.empty:
            return _buildEmpty(context);
          case LoadState.error:
            return _buildError(context, snapshot.message);
          case LoadState.success:
            return builder(context, snapshot.data as T);
        }
      },
    );
  }

  Widget _buildIdle(BuildContext context) {
    return panels.idle?.call(context) ?? const SizedBox.shrink();
  }

  Widget _buildLoading(BuildContext context) {
    return panels.loading?.call(context) ?? const _StateLoadingView();
  }

  Widget _buildEmpty(BuildContext context) {
    final texts = _resolveTexts(context);

    return panels.empty?.call(context, onRetry) ??
        _StateMessageView(
          icon: Icons.inbox_outlined,
          title: texts.emptyTitle,
          actionText: texts.retryLabel,
          onAction: onRetry,
        );
  }

  Widget _buildError(BuildContext context, String? message) {
    final texts = _resolveTexts(context);

    return panels.error?.call(context, message, onRetry) ??
        _StateMessageView(
          icon: Icons.error_outline,
          title: message?.isNotEmpty == true ? message! : texts.errorTitle,
          actionText: texts.retryLabel,
          onAction: onRetry,
        );
  }

  StateWidgetTexts _resolveTexts(BuildContext context) {
    return texts ??
        StateWidgetTexts.defaultsFor(Localizations.maybeLocaleOf(context));
  }
}

class _StateLoadingView extends StatelessWidget {
  const _StateLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _StateMessageView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const _StateMessageView({
    required this.icon,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: theme.colorScheme.outline),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (onAction != null && actionText != null) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: onAction,
                  child: Text(actionText!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
