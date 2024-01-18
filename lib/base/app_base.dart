library base;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' show join;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

export 'package:flutter_local_notifications/flutter_local_notifications.dart';
export 'package:intl/intl.dart';
export 'package:logging/logging.dart';
export 'package:shared_preferences/shared_preferences.dart';
export 'package:sqflite/sqflite.dart';

part 'app_base_badger.dart';
part 'app_base_database.dart';
part 'app_base_local_notification.dart';
part 'app_base_shared_preference.dart';
part 'app_base_splash_screen.dart';

abstract class Base extends StatefulWidget {
  Base(
      {super.key,
      Map<String, Map<String, ThemeData>> themes = const {},
      Widget? configureView})
      : _themes = themes,
        _configureView = configureView;

  final Logger _logger = Logger('App');

  final Widget? _configureView;

  /// themes format:
  /// themes = {
  /// blue : {'light' : Theme(), 'dark' : Theme()}
  /// red : {'light' : Theme(), 'dark' : Theme()}
  /// }
  final Map<String, Map<String, ThemeData>> _themes;

  MaterialApp materialAppBuilder(
      {Iterable<LocalizationsDelegate<dynamic>>? localDelegate,
      required Iterable<Locale> locales,
      Widget Function(BuildContext, Widget?)? builder,
      required ThemeMode themeMode,
      Locale? locale,
      required ThemeData light,
      required ThemeData dark}) {
    return MaterialApp(
      localizationsDelegates: localDelegate,
      supportedLocales: locales,
      themeMode: themeMode,
      darkTheme: dark,
      theme: light,
      builder: builder,
      locale: locale,
    );
  }

  @protected
  @mustCallSuper
  Future<void> initialize();

  @protected
  @mustCallSuper
  Future<void> configure(void Function([String message]) forward);

  @protected
  @mustCallSuper
  void onConfigureDone();
}

abstract class AppBase extends Base
    with
        BaseDatabaseController,
        BaseSharedPreference,
        BaseSplashScreen,
        BaseAppBadgerUpdater,
        BaseLocalNotification {
  static const String _sharedPreferenceLocaleKey = "base_app_locale";
  static const String _sharedPreferenceThemeDataKey = "base_app_themeMode";
  static const String _sharedPreferenceThemeKey = "base_app_theme";

  final ValueNotifier<ThemeMode> _themeModeNotifier =
      ValueNotifier(ThemeMode.system);
  final ValueNotifier<ThemeData> _themeLightNotifier =
      ValueNotifier(ThemeData.light());
  final ValueNotifier<ThemeData> _themeDarkNotifier =
      ValueNotifier(ThemeData.dark());

  final ValueNotifier<String?> _localeNotifier = ValueNotifier(null);

  final DateTime _startTime = DateTime.now();

  AppBase(
      {super.key, Level level = Level.ALL, super.themes, super.configureView}) {
    if (kDebugMode) {
      Logger.root.level = level;
      Logger.root.onRecord.listen(onReceiveLog);
      _logger.config('Logger listen from AppBase');
      _logger.config('Logger Level ${level.toString()}');
    }
    initialize().then((_) {
      _logger.finer('    runApp($this)');
      runApp(this);
    });
  }

  @protected
  void onReceiveLog(LogRecord record) {
    Duration duration = record.time.difference(_startTime);
    String second = (duration.inSeconds).toString().padLeft(2, '0');
    String millisecond =
        (duration.inMilliseconds % 1000).toString().padLeft(3, '0');

    String name = record.level.name.padRight(7);
    if (kDebugMode) {
      print('$second:$millisecond ms $name: ${record.message}');
    }
  }

  @override
  @protected
  @mustCallSuper
  Future<void> initialize() async {
    _logger.finest('--> initialize (AppBase)');
    await super.initialize();

    String? sharedPreferenceLocale =
        sharedPreferences.getString(_sharedPreferenceLocaleKey);
    if (sharedPreferenceLocale != null) {
      _logger.finer('    setLocale from sharedPreference(AppBase)');
      _logger.config('Locale: $sharedPreferenceLocale');
      _localeNotifier.value = sharedPreferenceLocale;
    } else {
      _logger.config('Locale: ${Platform.localeName}');
    }

    String? sharedPreferenceThemeMode =
        sharedPreferences.getString(_sharedPreferenceThemeDataKey);
    if (sharedPreferenceThemeMode != null) {
      _logger.finer('    set Theme Mode from sharedPreference(AppBase)');
      _logger.config('Theme Mode: $sharedPreferenceThemeMode');
      _themeModeNotifier.value = ThemeMode.values
          .firstWhere((e) => e.name == sharedPreferenceThemeMode);
    } else {
      _logger.config('Theme Mode : ${ThemeMode.system.name}');
    }

    String? sharedPreferenceTheme =
        sharedPreferences.getString(_sharedPreferenceThemeKey);
    if (sharedPreferenceTheme != null) {
      _logger.finer('    set Theme from sharedPreference(AppBase)');
      _logger.config('Theme: $sharedPreferenceTheme');
      changeTheme(sharedPreferenceTheme);
    } else {
      _logger.config('Theme : default');
    }
    _logger.finest('<-- initialize (AppBase)');
  }

  @override
  @protected
  @mustCallSuper
  Future<void> configure(void Function([String message]) forward) async {
    _logger.finest('--> configure (AppBase)');
    Intl.defaultLocale = _localeNotifier.value ?? Platform.localeName;
    await super.configure(forward);
    _logger.finest('<-- configure (AppBase)');
  }

  @mustCallSuper
  void changeTheme(String? theme) {
    if (!_themes.containsKey(theme)) {
      _themeLightNotifier.value = ThemeData.light();
      _themeDarkNotifier.value = ThemeData.dark();
      sharedPreferences.remove(_sharedPreferenceThemeKey);
      return;
    }
    sharedPreferences.setString(_sharedPreferenceThemeKey, theme!);
    Map<String, ThemeData> themeMap = _themes[theme]!;
    if (themeMap.containsKey('light')) {
      _themeLightNotifier.value = themeMap['light']!;
    }
    if (themeMap.containsKey('dark')) {
      _themeDarkNotifier.value = themeMap['dark']!;
    } else if (themeMap.containsKey('light')) {
      _themeDarkNotifier.value = themeMap['light']!;
    }
  }

  @mustCallSuper
  void changeThemeMode(ThemeMode theme) {
    _themeModeNotifier.value = theme;

    if (theme == ThemeMode.system) {
      sharedPreferences.remove(_sharedPreferenceThemeDataKey);
      return;
    }
    sharedPreferences.setString(_sharedPreferenceThemeDataKey, theme.name);
  }

  @mustCallSuper
  void changeLocale(String? locale) {
    _localeNotifier.value = locale;
    if (locale == null) {
      sharedPreferences.remove(_sharedPreferenceLocaleKey);
      return;
    }
    sharedPreferences.setString(_sharedPreferenceLocaleKey, locale);
  }

  @override
  State<StatefulWidget> createState() => AppBaseState();
}

class AppBaseState <T extends AppBase> extends State<AppBase> with WidgetsBindingObserver {
  bool loaded = false;

  @override
  T get widget => _widget!;
  T? _widget;

  @override
  void initState() {
    super.initState();
    _widget = super.widget as T;
    widget._logger.finest("--> initState (AppBaseState)");
    widget._logger.finer("    configure app (AppBaseState)");
    widget.configure(onLoadingForward).then(onLoadingDone);
    widget._logger
        .finest("    add WidgetsBindingObserver($this) (AppBaseState)");
    WidgetsBinding.instance.addObserver(this);
    widget._logger.finest("<-- initState (AppBaseState)");
  }

  @protected
  void onLoadingForward([String? message]) {
    widget._logger.finest("--> onLoadingForward (AppBaseState)");

    widget._logger
        .info("    configuration in progress: $message (AppBaseState)");
    if (mounted) {
      widget._logger.finest("    setState (AppBaseState)");
      setState(() {});
    }
    widget._logger.finest("<-- onLoadingForward (AppBaseState)");
  }

  @protected
  @mustCallSuper
  void onLoadingDone(_) {
    widget._logger.finest("--> onLoadingDone (AppBaseState)");
    if (widget._configureView != null) {
      widget._logger
          .finer("    remove ${widget._configureView} (AppBaseState)");
    }
    loaded = true;

    widget.onConfigureDone();
    if (mounted) {
      widget._logger.finest("    call setState (AppBaseState)");
      setState(() {});
    }
    widget._logger.finer("    app configured (AppBaseState)");
    widget._logger.finest("<-- onLoadingDone (AppBaseState)");
  }

  @override
  void dispose() {
    widget._logger.finest("--> dispose (AppBaseState)");
    WidgetsBinding.instance.removeObserver(this);
    widget._logger
        .finest("    remove WidgetsBindingObserver($this) (AppBaseState)");
    super.dispose();
    widget._logger.finest("<-- dispose (AppBaseState)");
  }

  @override
  void didChangePlatformBrightness() {
    if (mounted && widget._themeModeNotifier.value == ThemeMode.system) {
      setState(() {});
    }
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    widget._logger.finest("--> didChangeLocales (AppBaseState)");
    String? locale =
        widget._localeNotifier.value ?? locales?.first.toLanguageTag();

    widget._logger.info("system change local: $locale");
    if (locale != null) {
      Intl.defaultLocale = locale;
      widget._logger.finer(" Intl.defaultLocale local set to: $locale");
    }
    if (mounted) {
      widget._logger.finest("    call setState (AppBaseState)");
      setState(() {});
    }
    widget._logger.finest("<-- didChangeLocales (AppBaseState)");
  }

  Widget cascadedListenableBuilder(
      {required Widget Function(
              ThemeData light, ThemeData dark, ThemeMode mode, String? locale)
          builder}) {
    return ValueListenableBuilder<ThemeData>(
        valueListenable: widget._themeLightNotifier,
        builder: (context, light, _) {
          return ValueListenableBuilder<ThemeData>(
              valueListenable: widget._themeDarkNotifier,
              builder: (context, dark, _) {
                return ValueListenableBuilder<String?>(
                    valueListenable: widget._localeNotifier,
                    builder: (context, locale, _) {
                      return ValueListenableBuilder<ThemeMode>(
                          valueListenable: widget._themeModeNotifier,
                          builder: (context, themeMode, _) {
                            return builder(light, dark, themeMode, locale);
                          });
                    });
              });
        });
  }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    return cascadedListenableBuilder(builder: (light, dark, themeMode, locale) {
      Locale? deFaultLocale;
      if (locale != null) {
        var localeSplit = locale.split('-');
        deFaultLocale = Locale(localeSplit.first, localeSplit.last);
      }
      return widget.materialAppBuilder(
        localDelegate: AppLocalizations.localizationsDelegates,
        locales: AppLocalizations.supportedLocales,
        locale: deFaultLocale,
        themeMode: themeMode,
        builder: (_, navigator) {
          return Builder(builder: (context) {
            if (!loaded) {
              return widget._configureView ?? const SizedBox.shrink();
            }
            return navigator ?? const SizedBox.shrink();
          });
        },
        light: light,
        dark: dark,
      );
    });
  }
}
