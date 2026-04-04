# flutter_state_widget

`flutter_state_widget` 是一个面向 Flutter 的状态展示组件库，用于在同一块内容区域内统一管理 `idle`、`loading`、`empty`、`error`、`success` 五种常见界面状态。

它关注的是“状态渲染”，而不是“状态管理”。组件本身不发起请求、不持有业务数据源，也不绑定任何第三方状态管理方案，适合在项目、组件库或独立插件中稳定复用。

## 组件定位

当页面存在以下需求时，这个组件会比手写分支判断更合适：

- 列表页、详情页、卡片区块都需要统一的加载态、空态和错误态
- 异步逻辑已经在 `ViewModel`、`Controller`、`Bloc`、`Riverpod`、`Provider` 或其他层完成
- 希望页面只关心“当前该渲染什么”，不关心占位视图如何重复搭建
- 需要保留默认实现，同时允许针对局部业务做深度定制

## 设计目标

- 纯 Flutter 实现，不依赖第三方 UI 组件
- 不依赖项目资源文件，适合作为独立包发布
- 使用 `ValueListenable` 驱动，接入成本低
- 非成功态视图可整体替换
- 默认文案与默认主题可单独覆写
- 支持全局主题注入，也支持局部样式隔离

## 状态模型

`flutter_state_widget` 采用非常直接的状态流转方式：

```text
异步逻辑 / 业务层
        ↓
StateSnapshot<T>
        ↓
ValueNotifier<StateSnapshot<T>>
        ↓
StateWidget<T>
        ↓
成功内容 或 状态占位
```

其中：

- `LoadState` 描述当前状态阶段
- `StateSnapshot<T>` 承载状态、数据和错误文案
- `StateWidget<T>` 根据快照渲染最终界面

## 功能特性

- `StateWidget<T>` 统一承接成功态与非成功态渲染
- `StateSnapshot<T>` 让状态切换更显式，便于阅读与维护
- `StatePanels` 支持替换 `idle / loading / empty / error` 面板
- `StateWidgetTexts` 支持覆写默认文案
- `StateWidgetThemeData` 支持主题扩展与局部样式覆写
- 内置默认占位视图，接入后即可直接使用

## 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  flutter_state_widget: ^0.1.2
```

导入组件：

```dart
import 'package:flutter_state_widget/flutter_state_widget.dart';
```

## 快速开始

下面是最小可用接入方式，也是最推荐的接入模式：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_state_widget/flutter_state_widget.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final ValueNotifier<StateSnapshot<List<String>>> _state =
      ValueNotifier(const StateSnapshot.loading());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _state.value = const StateSnapshot.loading();

    await Future<void>.delayed(const Duration(seconds: 1));

    _state.value = const StateSnapshot.success([
      '状态组件接入完成',
      '这里是业务内容',
      '可以继续替换成你的列表或详情页',
    ]);
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('快速开始')),
      body: StateWidget<List<String>>(
        listenable: _state,
        onRetry: _load,
        builder: (context, data) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(data[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

## 接入步骤

### 1. 定义状态源

组件不创建状态源，通常由页面自己持有：

```dart
final ValueNotifier<StateSnapshot<List<String>>> state =
    ValueNotifier(const StateSnapshot.loading());
```

### 2. 在请求前后更新状态

推荐按以下顺序更新：

```dart
state.value = const StateSnapshot.loading();
state.value = const StateSnapshot.empty();
state.value = const StateSnapshot.error('网络请求失败，请稍后重试');
state.value = const StateSnapshot.success(['条目一', '条目二']);
```

### 3. 用 `StateWidget` 承接渲染

```dart
StateWidget<List<String>>(
  listenable: state,
  onRetry: _load,
  builder: (context, data) {
    return ListView(
      children: data.map((item) => ListTile(title: Text(item))).toList(),
    );
  },
);
```

## 核心类型

### `LoadState`

用于描述当前界面所处的阶段：

- `idle`
- `loading`
- `empty`
- `error`
- `success`

### `StateSnapshot<T>`

不可变状态快照对象，是 `StateWidget` 的直接输入。

可用构造函数：

- `StateSnapshot.idle()`
- `StateSnapshot.loading()`
- `StateSnapshot.empty()`
- `StateSnapshot.error([message])`
- `StateSnapshot.success(data)`

### `StatePanels`

用于替换默认占位面板，支持以下状态：

- `idle`
- `loading`
- `empty`
- `error`

### `StateWidgetTexts`

用于覆盖默认空态和错误态文案。

内置文案常量：

- `StateWidgetTexts.chinese`
- `StateWidgetTexts.english`

### `StateWidgetThemeData`

用于配置默认占位视图的视觉表现，可控制：

- 图标颜色与尺寸
- 文案颜色与文本样式
- 加载指示器颜色
- 按钮样式
- 内边距、间距、最大宽度

## 使用方式

### 基础渲染

最常见的用法是只关心成功态内容，把其他状态交给组件默认实现：

```dart
StateWidget<List<String>>(
  listenable: state,
  onRetry: _load,
  builder: (context, data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return ListTile(title: Text(data[index]));
      },
    );
  },
);
```

### 自定义默认文案

如果只想调整提示语，而不想改默认布局，可以传入 `texts`：

```dart
StateWidget<List<String>>(
  listenable: state,
  onRetry: _load,
  texts: const StateWidgetTexts(
    emptyTitle: '当前还没有内容',
    errorTitle: '加载失败，请稍后再试',
    retryLabel: '重新加载',
  ),
  builder: (context, data) {
    return ListView(
      children: data.map((item) => ListTile(title: Text(item))).toList(),
    );
  },
);
```

### 替换默认状态面板

如果业务对空态、错误态、加载态有自己的设计规范，可以通过 `StatePanels` 整体替换：

```dart
StateWidget<List<String>>(
  listenable: state,
  onRetry: _load,
  panels: StatePanels(
    idle: (context) => const Center(
      child: Text('请先选择查询条件'),
    ),
    loading: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
    empty: (context, retry) => Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('暂无结果'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: retry,
            child: const Text('刷新'),
          ),
        ],
      ),
    ),
    error: (context, message, retry) => Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message ?? '服务暂时不可用'),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: retry,
            child: const Text('重试'),
          ),
        ],
      ),
    ),
  ),
  builder: (context, data) {
    return ListView(
      children: data.map((item) => ListTile(title: Text(item))).toList(),
    );
  },
);
```

### 全局主题注入

当你希望整个应用中的状态组件都遵循统一视觉规范时，推荐通过 `ThemeData.extensions` 注入：

```dart
MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1565C0),
    ),
    extensions: const [
      StateWidgetThemeData(
        iconColor: Color(0xFF1565C0),
        loadingIndicatorColor: Color(0xFF1565C0),
        messageColor: Color(0xFF455A64),
      ),
    ],
  ),
  home: const DemoPage(),
);
```

### 局部主题覆写

如果只有某一块区域需要特殊视觉风格，可以使用 `StateWidgetTheme`：

```dart
StateWidgetTheme(
  data: StateWidgetThemeData(
    iconColor: const Color(0xFFE65100),
    messageColor: const Color(0xFF5D4037),
    loadingIndicatorColor: const Color(0xFFE65100),
    iconSize: 44,
    maxContentWidth: 360,
    actionButtonStyle: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFFE65100),
    ),
  ),
  child: StateWidget<List<String>>(
    listenable: state,
    onRetry: _load,
    builder: (context, data) {
      return ListView(
        children: data.map((item) => ListTile(title: Text(item))).toList(),
      );
    },
  ),
);
```

### 多语言默认文案策略

当未显式传入 `texts` 时，组件会根据当前 `Locale` 自动选择内置文案：

- `languageCode == 'zh'` 时使用中文默认文案
- 其他语言环境下使用英文默认文案

```dart
MaterialApp(
  locale: const Locale('zh'),
  home: StateWidget<List<String>>(
    listenable: state,
    onRetry: _load,
    builder: (context, data) {
      return ListView(
        children: data.map((item) => ListTile(title: Text(item))).toList(),
      );
    },
  ),
);
```

## 推荐接入模式

为了让组件在项目中长期可维护，建议采用以下职责分层：

- 业务层负责请求、缓存、错误处理和状态转换
- 页面层负责持有 `ValueNotifier<StateSnapshot<T>>`
- `StateWidget<T>` 只负责界面呈现，不承载业务逻辑

一个比较稳妥的写法是：

```dart
Future<void> _load() async {
  state.value = const StateSnapshot.loading();

  try {
    final result = await repository.fetchData();

    if (result.isEmpty) {
      state.value = const StateSnapshot.empty();
      return;
    }

    state.value = StateSnapshot.success(result);
  } catch (error) {
    state.value = StateSnapshot.error(error.toString());
  }
}
```

这种方式的优势是：

- 页面状态转换足够清晰
- 单元测试容易覆盖
- 后续替换状态管理方案时，界面层改动很小

## 行为约定

在使用前，建议先明确以下约束：

- `StateWidget` 不负责发起请求
- `StateWidget` 不持有也不释放外部业务资源，只消费 `listenable`
- `success` 状态下会将 `data` 交给 `builder`
- `idle / loading / empty / error` 状态下会优先使用自定义 `panels`，否则使用内置实现
- `onRetry` 只是在默认或自定义面板中作为回调透传，不带任何内置重试逻辑

## 适用与边界

适合使用的场景：

- 页面已有异步数据流，只缺统一渲染容器
- 列表页、详情页、局部模块都要保持一致的占位体验
- 需要一个轻量、可发布、可复用的状态渲染组件

不建议承担的职责：

- 代替完整状态管理框架
- 代替 Repository、UseCase、Controller 等业务层抽象
- 在组件内部直接拼接复杂请求流程

## 示例工程

仓库中的示例工程位于 `example/`，包含以下场景：

- 成功态展示
- 空态切换
- 错误态切换
- `idle` 态演示
- 深色 / 浅色主题切换
- 局部 `StateWidgetTheme` 覆写

可以直接运行查看效果：

```bash
cd example
flutter run
```

## 导出内容

包入口 `package:flutter_state_widget/flutter_state_widget.dart` 默认导出：

- `LoadState`
- `StateSnapshot`
- `StateWidget`
- `StateWidgetTheme`
- `StateWidgetThemeData`
- `StateWidgetTexts`

## 总结

`flutter_state_widget` 适合在 Flutter 项目中承担“统一状态渲染层”的角色。它不侵入现有架构，不绑定状态管理方案，同时保留了足够明确的默认行为和可扩展能力，适合作为项目基础组件长期维护。
