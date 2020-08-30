---
title: Using SharedPreferences in Flutter effortlessly
date: 2020-07-15 20:18:47
tags: SharedPreferences, flutter, shared_preferences
---
> We all know that SharedPreferences is a key/value store where you can read and store data very easily. It’s being used in most apps nowadays.
> In Flutter, there’s a package named shared_preferences that helps us deal with key/value data…


Hi. My name is Simon Pham (Cường - in Vietnamese). I have been working with Flutter since January 2019. I decided to write this blog post to share my experience in handling SharedPreferences in Flutter.

![](https://cdn-images-1.medium.com/max/1600/1*xBgJiDzRHBETnWxE6x-5qw.png)

*****

We all know that SharedPreferences is a key/value store where you can read and store data very easily. It’s being used in most apps nowadays.

In Flutter, there’s a package named [shared_preferences](https://pub.dev/packages/shared_preferences) that helps us
deal with key/value data. Its documentation gives us something like this:

```dart
_incrementCounter() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int counter = (prefs.getInt('counter') ?? 0) + 1;
  print('Pressed $counter times.');
  await prefs.setInt('counter', counter);
}
```

It is really inconvenient to get the SharedPreferences instance asynchronously every time we need it. To increase reusability and reduce boilerplate code, I have an approach to save the instance of SharedPreferences and create getters/setters for the preference keys to use them anywhere in the app.

> “Talk is cheap**. **Show me the code.” ~ Linus Torvalds

I will assume that you have already [added the shared_preferences](https://pub.dev/packages/shared_preferences#-installing-tab-) package.

First, we need to define a class to store the SharedPreferences instance. Let’s name it **SharedPrefs**.

```dart
// utils/shared_prefs.dart

class SharedPrefs {
  static SharedPreferences _sharedPrefs;
}

final sharedPrefs = SharedPrefs();
```

Easy, right?

Then, we will define an init() method to get the SharedPreference instance and store it to the _sharedPrefs variable in the SharedPrefs class.

```dart
// utils/shared_prefs.dart

class SharedPrefs {
  static SharedPreferences _sharedPrefs;
  init() async {
    if (_sharedPrefs == null) {
      _sharedPrefs = await SharedPreferences.getInstance();
    }
  }
}

final sharedPrefs = SharedPrefs();
```

And call it in main() function.

```dart
// main.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await sharedPrefs.init();
  runApp(
    MyApp(),
  );
}
```

Why called **SharedPrefs.init()** in the main() function? Because before runApp() is called, the app will show the splash screen. It’s a perfect moment for us to do some essential initialization for the app.

The next step is to define getters & setters for your preference keys. For example, I defined a getter and setter for getting & updating **username** in SharedPreferences.

```dart
// utils/shared_prefs.dart

class SharedPrefs {
  static SharedPreferences _sharedPrefs;

  init() async {
    if (_sharedPrefs == null) {
      _sharedPrefs = await SharedPreferences.getInstance();
    }
  }

  String get username => _sharedPrefs.getString(keyUsername) ?? "";

  set username(String value) {
    _sharedPrefs.setString(keyUsername, value);
  }
}

final sharedPrefs = SharedPrefs();

// constants/strings.dart

const String keyUsername = "key_username";
```


I also create a **keyUsername **constant for consistency. You will not want to use a String directly like *_sharedPrefs*.getString(**“key_username”**) and in another place use *_sharedPrefs*.setString(**“key_user_name”**, value) by mistake.

That’s it. Now you can access **username** ANYWHERE in the app.

```dart
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Text("Hi ${sharedPrefs.username}"),
      ),
    );
  }
}
```

Thank you for reading my blog. You can check out [this gist](https://gist.github.com/simonpham/4aaab5a8ddfcae06fdb0057aeb6230b8) for the full code.

Have questions? Find me at [https://blog.simonit.dev](https://blog.simonit.dev/)
