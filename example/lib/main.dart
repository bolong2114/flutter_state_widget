import 'package:flutter/material.dart';
import 'package:flutter_state_widget/flutter_state_widget.dart';

void main() {
  runApp(const StateWidgetExampleApp());
}

class StateWidgetExampleApp extends StatefulWidget {
  const StateWidgetExampleApp({super.key});

  @override
  State<StateWidgetExampleApp> createState() => _StateWidgetExampleAppState();
}

class _StateWidgetExampleAppState extends State<StateWidgetExampleApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_state_widget example',
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
        ),
        extensions: const [
          StateWidgetThemeData(
            iconColor: Color(0xFF1565C0),
            loadingIndicatorColor: Color(0xFF1565C0),
          ),
        ],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF80CBC4),
          brightness: Brightness.dark,
        ),
        extensions: const [
          StateWidgetThemeData(
            iconColor: Color(0xFF80CBC4),
            messageColor: Color(0xFFD7CCC8),
            loadingIndicatorColor: Color(0xFF80CBC4),
          ),
        ],
      ),
      home: StateWidgetExamplePage(
        themeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
      ),
    );
  }
}

class StateWidgetExamplePage extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const StateWidgetExamplePage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<StateWidgetExamplePage> createState() => _StateWidgetExamplePageState();
}

class _StateWidgetExamplePageState extends State<StateWidgetExamplePage> {
  final ValueNotifier<StateSnapshot<List<String>>> _state =
      ValueNotifier<StateSnapshot<List<String>>>(
    const StateSnapshot.loading(),
  );

  @override
  void initState() {
    super.initState();
    _loadSuccess();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  Future<void> _loadSuccess() async {
    _state.value = const StateSnapshot.loading();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _state.value = const StateSnapshot.success([
      'First item',
      'Second item',
      'Third item',
    ]);
  }

  Future<void> _loadEmpty() async {
    _state.value = const StateSnapshot.loading();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _state.value = const StateSnapshot.empty();
  }

  Future<void> _loadError() async {
    _state.value = const StateSnapshot.loading();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _state.value = const StateSnapshot.error('Request failed, tap retry.');
  }

  void _showIdle() {
    _state.value = const StateSnapshot.idle();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('flutter_state_widget example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ChoiceChip(
                  label: const Text('Light'),
                  selected: widget.themeMode == ThemeMode.light,
                  onSelected: (_) {
                    widget.onThemeModeChanged(ThemeMode.light);
                  },
                ),
                ChoiceChip(
                  label: const Text('Dark'),
                  selected: widget.themeMode == ThemeMode.dark,
                  onSelected: (_) {
                    widget.onThemeModeChanged(ThemeMode.dark);
                  },
                ),
                FilledButton(
                  onPressed: _loadSuccess,
                  child: const Text('Success'),
                ),
                FilledButton.tonal(
                  onPressed: _loadEmpty,
                  child: const Text('Empty'),
                ),
                FilledButton.tonal(
                  onPressed: _loadError,
                  child: const Text('Error'),
                ),
                OutlinedButton(
                  onPressed: _showIdle,
                  child: const Text('Idle'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: StateWidgetTheme(
                  data: StateWidgetThemeData(
                    iconColor: isDark
                        ? const Color(0xFFFFCC80)
                        : const Color(0xFFE65100),
                    messageColor: isDark
                        ? const Color(0xFFFFE0B2)
                        : const Color(0xFF5D4037),
                    loadingIndicatorColor: isDark
                        ? const Color(0xFFFFCC80)
                        : const Color(0xFFE65100),
                    iconSize: 44,
                    maxContentWidth: 360,
                    actionButtonStyle: OutlinedButton.styleFrom(
                      foregroundColor: isDark
                          ? const Color(0xFFFFCC80)
                          : const Color(0xFFE65100),
                      side: BorderSide(
                        color: isDark
                            ? const Color(0xFFFFCC80)
                            : const Color(0xFFE65100),
                      ),
                    ),
                  ),
                  child: StateWidget<List<String>>(
                    listenable: _state,
                    onRetry: _loadSuccess,
                    panels: StatePanels(
                      idle: (context) => const Center(
                        child: Text('Choose a state to preview'),
                      ),
                    ),
                    builder: (context, data) {
                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: data.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                data[index],
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
