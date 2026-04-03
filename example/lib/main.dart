import 'package:flutter/material.dart';
import 'package:flutter_state_widget/flutter_state_widget.dart';

void main() {
  runApp(const StateWidgetExampleApp());
}

class StateWidgetExampleApp extends StatelessWidget {
  const StateWidgetExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_state_widget example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
      ),
      home: const StateWidgetExamplePage(),
    );
  }
}

class StateWidgetExamplePage extends StatefulWidget {
  const StateWidgetExamplePage({super.key});

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
          ],
        ),
      ),
    );
  }
}
