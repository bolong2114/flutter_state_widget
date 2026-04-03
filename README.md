# flutter_state_widget

`flutter_state_widget` is a pure Flutter package for rendering a content region through five common UI states:

- idle
- loading
- empty
- error
- success

It is designed for package-safe reuse:

- no project assets
- no third-party UI dependencies
- no external state management dependency
- fully replaceable placeholders for non-success states
- driven by Flutter's built-in `ValueListenable`

## Features

- `StateWidget<T>` renders either success content or a state panel
- `LoadState` keeps the state model explicit and readable
- `StateSnapshot<T>` carries the current state plus optional data/message
- `StatePanels` lets you replace `idle`, `loading`, `empty`, and `error` views
- `StateWidgetTexts` provides built-in Chinese and English placeholder copy
- default placeholders are included, so the package works out of the box

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_state_widget: ^0.1.1
```

Then import it:

```dart
import 'package:flutter_state_widget/flutter_state_widget.dart';
```

## Core Types

### `LoadState`

Represents the current UI phase:

- `idle`
- `loading`
- `empty`
- `error`
- `success`

### `StateSnapshot<T>`

Immutable snapshot object consumed by `StateWidget`.

Constructors:

- `StateSnapshot.idle()`
- `StateSnapshot.loading()`
- `StateSnapshot.empty()`
- `StateSnapshot.error([message])`
- `StateSnapshot.success(data)`

### `StatePanels`

Optional configuration object for replacing built-in panels:

- `idle`
- `loading`
- `empty`
- `error`

### `StateWidgetTexts`

Localized copy for the built-in `empty` and `error` placeholders.

Built-in defaults:

- `StateWidgetTexts.english`
- `StateWidgetTexts.chinese`

## Basic Example

```dart
class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final ValueNotifier<StateSnapshot<String>> state =
      ValueNotifier(const StateSnapshot.loading());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    state.value = const StateSnapshot.loading();

    await Future<void>.delayed(const Duration(seconds: 1));

    state.value = const StateSnapshot.success('Loaded content');
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return StateWidget<String>(
      listenable: state,
      onRetry: _load,
      builder: (context, data) => Center(
        child: Text(data),
      ),
    );
  }
}
```

## Built-In Locale Defaults

When you do not pass `texts`, the package resolves default copy from the
current `Locale`:

- `zh` -> Chinese defaults
- other locales -> English defaults

```dart
MaterialApp(
  locale: const Locale('zh'),
  home: StateWidget<List<String>>(
    listenable: state,
    onRetry: _load,
    builder: (context, data) => ListView(
      children: data.map(Text.new).toList(),
    ),
  ),
);
```

## Override Default Copy

Use `texts` when the host app wants to fully control built-in placeholder
copy without replacing the entire panel UI:

```dart
StateWidget<List<String>>(
  listenable: state,
  onRetry: _load,
  texts: const StateWidgetTexts(
    emptyTitle: 'Nothing here yet',
    errorTitle: 'Request failed',
    retryLabel: 'Try again',
  ),
  builder: (context, data) => ListView(
    children: data.map(Text.new).toList(),
  ),
);
```

## Custom Panels

Use `StatePanels` when you want to replace the default placeholders:

```dart
final state = ValueNotifier<StateSnapshot<List<String>>>(
  const StateSnapshot.empty(),
);

StateWidget<List<String>>(
  listenable: state,
  onRetry: () {},
  builder: (context, data) => ListView(
    children: data.map(Text.new).toList(),
  ),
  panels: StatePanels(
    idle: (context) => const SizedBox.shrink(),
    loading: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
    empty: (context, retry) => Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Nothing here yet'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: retry,
            child: const Text('Refresh'),
          ),
        ],
      ),
    ),
    error: (context, message, retry) => Center(
      child: Text(message ?? 'Load failed'),
    ),
  ),
);
```

## Typical State Updates

```dart
state.value = const StateSnapshot.loading();
state.value = const StateSnapshot.empty();
state.value = const StateSnapshot.error('Network request failed');
state.value = const StateSnapshot.success(myData);
```

## Notes

- `StateWidget` does not perform requests for you
- `StateWidget` does not own the `ValueNotifier`
- `StateWidget` only renders based on the current snapshot
- `success` expects non-null data and forwards it to `builder`

## When To Use

Use this package when:

- you already manage async work elsewhere
- you want a consistent loading/empty/error wrapper
- you need package-friendly defaults with optional full customization

Do not use it as a replacement for application state management. It is a UI rendering helper, not a data flow framework.

---

# 中文说明

`flutter_state_widget` 是一个纯 Flutter 的状态展示组件库，用来在一个内容区域内统一处理五种常见状态：

- idle
- loading
- empty
- error
- success

它适合抽成独立插件复用，原因很直接：

- 不依赖项目资源
- 不依赖第三方 UI 组件
- 不依赖外部状态管理方案
- 非成功态占位都支持外部替换
- 基于 Flutter 原生 `ValueListenable` 驱动

## 功能特点

- `StateWidget<T>` 负责根据当前状态渲染成功内容或占位面板
- `LoadState` 用来描述当前加载状态
- `StateSnapshot<T>` 用来承载当前状态、数据和错误文案
- `StatePanels` 用来覆盖默认的 `idle / loading / empty / error` 视图
- `StateWidgetTexts` 提供内置中英文默认文案
- 不传自定义面板时，组件自带默认实现

## 安装

在 `pubspec.yaml` 中加入依赖：

```yaml
dependencies:
  flutter_state_widget: ^0.1.1
```

然后导入：

```dart
import 'package:flutter_state_widget/flutter_state_widget.dart';
```

## 核心类型

### `LoadState`

表示当前 UI 所处阶段：

- `idle`
- `loading`
- `empty`
- `error`
- `success`

### `StateSnapshot<T>`

一个不可变状态快照对象，供 `StateWidget` 消费。

可用构造函数：

- `StateSnapshot.idle()`
- `StateSnapshot.loading()`
- `StateSnapshot.empty()`
- `StateSnapshot.error([message])`
- `StateSnapshot.success(data)`

### `StatePanels`

用于替换默认占位面板的配置对象，支持：

- `idle`
- `loading`
- `empty`
- `error`

### `StateWidgetTexts`

用于配置内置 `empty` 和 `error` 占位的默认文案。

内置默认值：

- `StateWidgetTexts.english`
- `StateWidgetTexts.chinese`

## 基础示例

```dart
class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final ValueNotifier<StateSnapshot<String>> state =
      ValueNotifier(const StateSnapshot.loading());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    state.value = const StateSnapshot.loading();

    await Future<void>.delayed(const Duration(seconds: 1));

    state.value = const StateSnapshot.success('加载完成');
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StateWidget<String>(
      listenable: state,
      onRetry: _load,
      builder: (context, data) => Center(
        child: Text(data),
      ),
    );
  }
}
```

## 内置语言回退

当你没有传入 `texts` 时，组件会根据当前 `Locale` 自动选择默认文案：

- `zh` -> 中文默认文案
- 其他语言 -> 英文默认文案

```dart
MaterialApp(
  locale: const Locale('zh'),
  home: StateWidget<List<String>>(
    listenable: state,
    onRetry: _load,
    builder: (context, data) => ListView(
      children: data.map(Text.new).toList(),
    ),
  ),
);
```

## 覆盖默认文案

如果你只想改默认文案，不想整套替换 `empty / error` UI，可以传入 `texts`：

```dart
StateWidget<List<String>>(
  listenable: state,
  onRetry: _load,
  texts: const StateWidgetTexts(
    emptyTitle: '这里还没有内容',
    errorTitle: '请求失败',
    retryLabel: '再试一次',
  ),
  builder: (context, data) => ListView(
    children: data.map(Text.new).toList(),
  ),
);
```

## 自定义状态面板

如果你想完全接管默认占位 UI，可以传入 `StatePanels`：

```dart
final state = ValueNotifier<StateSnapshot<List<String>>>(
  const StateSnapshot.empty(),
);

StateWidget<List<String>>(
  listenable: state,
  onRetry: () {},
  builder: (context, data) => ListView(
    children: data.map(Text.new).toList(),
  ),
  panels: StatePanels(
    idle: (context) => const SizedBox.shrink(),
    loading: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
    empty: (context, retry) => Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('当前暂无数据'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: retry,
            child: const Text('重新加载'),
          ),
        ],
      ),
    ),
    error: (context, message, retry) => Center(
      child: Text(message ?? '加载失败'),
    ),
  ),
);
```

## 常见状态切换写法

```dart
state.value = const StateSnapshot.loading();
state.value = const StateSnapshot.empty();
state.value = const StateSnapshot.error('网络请求失败');
state.value = const StateSnapshot.success(myData);
```

## 使用说明

- `StateWidget` 不负责发请求
- `StateWidget` 不管理你的业务状态生命周期
- `StateWidget` 不持有 `ValueNotifier` 的释放职责
- `StateWidget` 只根据当前 `StateSnapshot` 做渲染
- `success` 状态要求有可用数据，并会传给 `builder`

## 适用场景

适合在这些场景下使用：

- 你的异步逻辑已经在别处处理好了
- 你只是想统一 loading / empty / error / success 的展示层
- 你希望组件默认可用，同时又支持业务方完全自定义占位

不建议把它当成状态管理框架使用。它是一个 UI 状态展示组件，不是数据流方案。
