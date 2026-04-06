# Changelog

All notable changes to this project will be documented in this file.

## 0.2.0

- Breaking: replaced `StateWidget.listenable` with `StateWidget.controller`.
- Added `StateWidgetController<T>` to drive `idle/loading/empty/error/success` transitions directly.
- Updated package tests and `example` app to use `StateWidgetController`.
- Updated README API documentation and usage snippets to the controller-based model.

## 0.1.2

- Added `StateWidgetThemeData` for configuring built-in loading and message panel styling.
- Added `StateWidgetTheme` for local theme overrides without replacing the entire panel UI.
- Updated default loading, empty, and error panels to resolve theme values from `ThemeData.extensions` with package-safe fallbacks.
- Updated the example app to demonstrate light, dark, and local override theme usage.
- Added widget tests and README documentation for multi-theme support in both English and Chinese.

## 0.1.1

- Added `StateWidgetTexts` for built-in placeholder copy customization.
- Added Chinese and English default placeholder copy with locale fallback.
- Updated tests and documentation for localized placeholder behavior.

## 0.1.0

- Initial public release of `state_widget`.
- Added `StateWidget`, `StateSnapshot`, `LoadState`, and `StatePanels`.
- Added customizable built-in panels for `idle`, `loading`, `empty`, and `error`.
- Added package documentation in English and Chinese.
- Added runnable `example` app with Android, iOS, and Web support.
- Added widget tests for both the package and the example app.
