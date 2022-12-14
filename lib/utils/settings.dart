import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rsvp/themes/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends ChangeNotifier {
  static final Settings _instance = Settings._internal();

  static Settings get instance => _instance;

  factory Settings() {
    return _instance;
  }

  Settings._internal();

  static SharedPreferences? _sharedPreferences;
  static const signedInKey = 'isSignedIn';
  static const emailKey = 'emailKey';
  static const skipCountKey = 'skipCount';
  static const darkKey = 'isDark';
  static const recentKey = 'recent';

  static const maxSkipCount = 3;

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    loadTheme();
  }

  static ThemeMode _theme = ThemeMode.light;

  static ThemeMode get getTheme => _theme;

  static void setTheme(ThemeMode theme) {
    _theme = theme;
    bool isDark = theme == ThemeMode.dark;
    _sharedPreferences!.setBool(darkKey, isDark);
    CorsairsTheme.isDark = isDark;
    _instance.notify();
  }

  static Future<void> loadTheme() async {
    final bool isDark = _sharedPreferences!.getBool(darkKey) ?? false;
    _theme = isDark == true ? ThemeMode.dark : ThemeMode.light;
    CorsairsTheme.isDark = isDark;
    setTheme(_theme);
  }

  static Future<void> initSharedPreference() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  set dark(bool value) {
    _sharedPreferences!.setBool(darkKey, value);
  }

  // static Future<bool> get isDark async {
  //   bool _dark = _sharedPreferences!.getBool(darkKey) ?? false;
  //   if (_dark) {
  //     darkNotifier.value = true;
  //   }
  //   return _dark;
  // }

  static set setSignedIn(bool value) {
    _sharedPreferences!.setBool('$signedInKey', value);
  }

  // static FutureOr<bool> get isSignedIn async {
  //   if (_sharedPreferences == null) {
  //     _sharedPreferences = await SharedPreferences.getInstance();
  //   }
  //   final _isSignedIn = _sharedPreferences!.getBool('$signedInKey') ?? false;
  //   return _isSignedIn;
  // }

  static FutureOr<String> get email async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    final _email = _sharedPreferences!.getString('$emailKey') ?? '';
    return _email;
  }

  static Future<void> setIsSignedIn(bool status, {String email = ''}) async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    await _sharedPreferences!.setBool('$signedInKey', status);
    await _sharedPreferences!.setString('$emailKey', email);
    _instance.notify();
  }

  static set setSkipCount(int value) {
    _sharedPreferences!.setInt('$skipCountKey', value);
  }


  static FutureOr<int> get skipCount async {
    _sharedPreferences ??= await SharedPreferences.getInstance();

    final int count = _sharedPreferences!.getInt('$skipCountKey') ?? 0;
    return count;
  }

  static Future<void> clear() async {
    await _sharedPreferences!.clear();
  }

  void notify() {
    notifyListeners();
  }
}
