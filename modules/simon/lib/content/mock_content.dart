part of 'mock.dart';

const String _mockTitle =
    'Store key-value data in Flutter using hive - but easier';
const String _mockSlug =
    'store-key-value-data-in-flutter-using-hive-but-easier';
const String _mockCoverImage =
    'https://dev-to-uploads.s3.amazonaws.com/uploads/articles/3qjil3gtjamezgaaoqwf.png';
const String _mockSummary =
    'The <strong>easy_hive</strong> package is a Flutter package that wraps the <strong>hive</strong> database to reduce boilerplate code and replace shared_preferences. It allows developers to use <strong>Enum keys</strong> for type safety and simplifies features like <strong>encryption</strong> and <strong>lazy loading</strong> through easy-to-use mixins. The package also includes built-in support for <strong>listens</strong> to facilitate reactive state management.';
const List<String> _mockTags = ['flutter', 'hive', 'dart'];
final DateTime _mockPublishedAt = DateTime(2023, 3, 28, 13, 41);
const String _mockContent = '''
## Introduction

A while ago, I posted a [post](https://dev.to/simonpham/using-sharedpreferences-in-flutter-effortlessly-3e29) about how to store key-value data using shared_preferences package.

However, [shared_preferences](https://pub.dev/packages/shared_preferences) is not pure Dart and depends on the platform, which might not be a good performance choice. So, I decided to look for another approach, and I found [hive](https://pub.dev/packages/hive).

After using the package for several projects, I grew tired of writing/copying boilerplate code just to store my key-value data. I came up with an idea of writing a wrapper package for hive. This package should meet these criteria:

- Support data encryption
- Support Lazy loading of data
- Support store data using Enum key
- Support Listenable
- And be EASY to use.

## Links

- pub.dev: [https://pub.dev/packages/easy_hive](https://pub.dev/packages/easy_hive)
- GitHub: [https://github.com/simonpham/easy_hive](https://github.com/simonpham/easy_hive)

## Guide to use:

You can either define your boxes as _Singleton_ classes **or** use a service locator like [
_get_it_](https://pub.dev/packages/get_it).

Let's take a look at the guide to define a simple SettingsBox to store your settings using singleton class approach.

### 1. Define box keys 🔑

```dart
enum Settings {
  key, // Use as box key. You can use a String constant instead.

  /// Other keys below...
  themeMode,
  counter,
}
```

### 2. Define a box 📦

```dart

import 'package:easy_hive/easy_hive.dart';

class SettingsBox extends EasyBox {
  @override
  String get boxKey => Settings.key.toString();

  /// Singleton.
  static final SettingsBox _instance = SettingsBox._();

  factory SettingsBox() => _instance;

  SettingsBox._();
}

```

### 3. Initialize box 🚀

```dart

import 'package:easy_hive/easy_hive.dart';

Future<void> main() async {
  await EasyBox.initialize();

  await SettingsBox().init();

  // runApp...
}

```


### 4. Define getter & setter for your data 💄

```dart
extension GeneralSettingsExtension on SettingsBox {
  ThemeMode get themeMode {
    final index = get(
      Settings.themeMode,
      defaultValue: 0,
    );
    return ThemeMode.values[index];
  }

  set themeMode(ThemeMode value) => put(Settings.themeMode, value.index);

  int get counter => get(Settings.counter, defaultValue: 0);

  set counter(int value) => put(Settings.counter, value);
}
```

### 5. Use it anywhere 🔥

```dart
  Text(
    'You have pushed: \${SettingsBox().counter} times.',
    style: Theme.of(context).textTheme.headlineMedium,
  ),
  FilledButton(
    onPressed: () {
      SettingsBox().counter++;
    },
    child: Text('Increment'),
  ),
  FilledButton(
    onPressed: () {
      SettingsBox().themeMode = ThemeMode.dark;
    },
    child: Text('Dark Theme'),
  ),
```

## Advanced Usage 😈

### Enable encryption 🔐

#### 1. Install [easy_hive_encryption](https://pub.dev/packages/easy_hive_encryption):

#### 2. Add `EncryptionMixin` to your box class:

```dart
class SettingsBox extends EasyBox with EncryptionMixin {
  @override
  String get boxKey => Settings.key.toString();

  /// Override encryption key name (optional).
  @override
  String get encryptionKeyName => "your-own-key-name";
}
```

#### 3. Follow [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)'s guide for specific platform setup.

### Enable lazy loading 🐢

#### 1. Add `LazyMixin` to your box class:

```dart
class SettingsBox extends EasyBox with LazyMixin {
  @override
  String get boxKey => Settings.key.toString();
}
```

#### 2. Use `await` to `get` your value:

```dart
extension GeneralSettingsExtension on SettingsBox {
  Future<ThemeMode> getThemeMode() async {
    final index = await get(
      Settings.themeMode,
      defaultValue: 0,
    );
    return ThemeMode.values[index];
  }
}
```

### Listen to value changes 🎧

#### Recommended: Use `RefreshableBox` + [provider](https://pub.dev/packages/provider):

#### 1. Extends `RefreshableBox` instead of `EasyBox`:

```dart
class SettingsBox extends RefreshableBox {
  @override
  String get boxKey => Settings.key.toString();
}
```

#### 2. Use it as a provider:

```dart
  ChangeNotifierProvider(
    create: (_) => SettingsBox(),
    child: SomeWidget(),
  ),
```

```dart
// Inside SomeWidget.
Text(
  'You have pushed: '
  '\${context.select((SettingsBox _) => _.counter)} times.',
),
```

For more info, see [provider](https://pub.dev/packages/provider) package.

---

#### Or if you don't want `RefreshableBox`:

#### Just use `ValueListenableBuilder` to listen to changes.

```dart
ValueListenableBuilder(
  valueListenable: [
    Settings.counter,
  ].of(SettingsBox()),
  builder: (context, _, __) {
    return Text(
      '\${SettingsBox().counter}',
    );
  },
),
```

This guide is taken from [easy_hive repository](https://github.com/simonpham/easy_hive).

## Happy Coding 🦊

''';
