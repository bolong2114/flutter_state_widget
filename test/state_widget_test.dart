import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_state_widget/flutter_state_widget.dart';

void main() {
  group('StateWidget', () {
    testWidgets('renders success content', (tester) async {
      final state = ValueNotifier<StateSnapshot<String>>(
        const StateSnapshot.success('done'),
      );

      await tester.pumpWidget(
        _wrap(
          StateWidget<String>(
            listenable: state,
            builder: (context, data) => Text('value:$data'),
          ),
        ),
      );

      expect(find.text('value:done'), findsOneWidget);
    });

    testWidgets('renders default loading placeholder', (tester) async {
      final state = ValueNotifier<StateSnapshot<String>>(
        const StateSnapshot.loading(),
      );

      await tester.pumpWidget(
        _wrap(
          StateWidget<String>(
            listenable: state,
            builder: (context, data) => Text(data),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders custom panels', (tester) async {
      final state = ValueNotifier<StateSnapshot<String>>(
        const StateSnapshot.empty(),
      );

      await tester.pumpWidget(
        _wrap(
          StateWidget<String>(
            listenable: state,
            builder: (context, data) => Text(data),
            panels: StatePanels(
              idle: (context) => const Text('idle'),
              loading: (context) => const Text('loading'),
              empty: (context, onRetry) => const Text('empty'),
              error: (context, message, onRetry) => const Text('error'),
            ),
          ),
        ),
      );

      expect(find.text('empty'), findsOneWidget);

      state.value = const StateSnapshot.loading();
      await tester.pump();
      expect(find.text('loading'), findsOneWidget);

      state.value = const StateSnapshot.error('boom');
      await tester.pump();
      expect(find.text('error'), findsOneWidget);

      state.value = const StateSnapshot.idle();
      await tester.pump();
      expect(find.text('idle'), findsOneWidget);
    });

    testWidgets('passes retry callback to default empty placeholder',
        (tester) async {
      final state = ValueNotifier<StateSnapshot<String>>(
        const StateSnapshot.empty(),
      );
      var retried = 0;

      await tester.pumpWidget(
        _wrap(
          StateWidget<String>(
            listenable: state,
            onRetry: () => retried++,
            builder: (context, data) => Text(data),
          ),
        ),
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retried, 1);
    });

    testWidgets('uses Chinese defaults for zh locale', (tester) async {
      final state = ValueNotifier<StateSnapshot<String>>(
        const StateSnapshot.empty(),
      );

      await tester.pumpWidget(
        _wrap(
          StateWidget<String>(
            listenable: state,
            onRetry: () {},
            builder: (context, data) => Text(data),
          ),
          locale: const Locale('zh'),
        ),
      );

      expect(find.text('暂无数据'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
    });

    testWidgets('lets host override default texts', (tester) async {
      final state = ValueNotifier<StateSnapshot<String>>(
        const StateSnapshot.error(),
      );

      await tester.pumpWidget(
        _wrap(
          StateWidget<String>(
            listenable: state,
            onRetry: () {},
            texts: const StateWidgetTexts(
              emptyTitle: 'Nothing to show',
              errorTitle: 'Request failed',
              retryLabel: 'Try again',
            ),
            builder: (context, data) => Text(data),
          ),
        ),
      );

      expect(find.text('Request failed'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('uses StateWidgetThemeData from ThemeData extension',
        (tester) async {
      final state = ValueNotifier<StateSnapshot<String>>(
        const StateSnapshot.empty(),
      );

      await tester.pumpWidget(
        _wrap(
          StateWidget<String>(
            listenable: state,
            onRetry: () {},
            builder: (context, data) => Text(data),
          ),
          theme: ThemeData(
            extensions: const [
              StateWidgetThemeData(
                iconColor: Colors.purple,
                messageColor: Colors.orange,
                loadingIndicatorColor: Colors.teal,
                iconSize: 48,
              ),
            ],
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.inbox_outlined));
      final text = tester.widget<Text>(find.text('No data available'));

      expect(icon.color, Colors.purple);
      expect(icon.size, 48);
      expect(text.style?.color, Colors.orange);

      state.value = const StateSnapshot.loading();
      await tester.pump();

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.color, Colors.teal);
    });

    testWidgets('local StateWidgetTheme overrides ThemeData extension',
        (tester) async {
      final state = ValueNotifier<StateSnapshot<String>>(
        const StateSnapshot.error(),
      );

      await tester.pumpWidget(
        _wrap(
          StateWidgetTheme(
            data: const StateWidgetThemeData(
              iconColor: Colors.green,
              messageColor: Colors.blue,
            ),
            child: StateWidget<String>(
              listenable: state,
              onRetry: () {},
              builder: (context, data) => Text(data),
            ),
          ),
          theme: ThemeData(
            extensions: const [
              StateWidgetThemeData(
                iconColor: Colors.red,
                messageColor: Colors.amber,
              ),
            ],
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      final text = tester.widget<Text>(find.text('Something went wrong'));

      expect(icon.color, Colors.green);
      expect(text.style?.color, Colors.blue);
    });

    testWidgets('updates when state changes', (tester) async {
      final state = ValueNotifier<StateSnapshot<String>>(
        const StateSnapshot.loading(),
      );

      await tester.pumpWidget(
        _wrap(
          StateWidget<String>(
            listenable: state,
            builder: (context, data) => Text(data),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      state.value = const StateSnapshot.success('loaded');
      await tester.pump();

      expect(find.text('loaded'), findsOneWidget);
    });
  });
}

Widget _wrap(Widget child, {Locale? locale, ThemeData? theme}) {
  return MaterialApp(
    locale: locale ?? const Locale('en'),
    theme: theme,
    supportedLocales: const [
      Locale('en'),
      Locale('zh'),
    ],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: Scaffold(body: child),
  );
}
