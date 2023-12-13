part of base;

mixin BaseLocalNotification
    on Base, BaseSharedPreference, BaseSplashScreen, BaseAppBadgerUpdater {
  static final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  @protected
  @mustCallSuper
  Future<void> initialize() async {
    _logger.finest('--> initialize (BaseLocalNotification)');
    await super.initialize();

    tz.initializeTimeZones();
    final locationName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(locationName));

    var a = const AndroidInitializationSettings('mipmap/ic_launcher');
    var i = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(iOS: i, android: a);

    /// when app is close
    final details =
        await _localNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      onNotificationClicked(details.notificationResponse!);
    }

    await _localNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationClicked);
    _logger.finest('<-- initialize (BaseLocalNotification)');
  }

  @protected
  @mustCallSuper
  void onNotificationClicked(NotificationResponse notificationResponse) {
    _logger.info('click on notification: ${notificationResponse.payload}');
  }

  Future<NotificationDetails> _notificationDetail() async {
    return const NotificationDetails(
        android: AndroidNotificationDetails('notification', 'channel1',
            channelDescription: 'description channel 1',
            playSound: true,
            importance: Importance.max,
            priority: Priority.max),
        iOS: DarwinNotificationDetails());
  }

  Future<void> showNotification(
      {int id = 0,
      String? title,
      String? body,
      String? payload,
      Duration? duration,
      NotificationDetails? details}) async {
    if (duration != null) {
      _localNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.now(tz.local).add(duration),
          details ?? await _notificationDetail(),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidAllowWhileIdle: true,
          matchDateTimeComponents: DateTimeComponents.time);
      return;
    }

    _localNotificationsPlugin.show(
        id, title, body, details ?? await _notificationDetail(),
        payload: payload);
  }

  Future<void> removeNotification([int? id]) async {
    if (id != null) {
      await _localNotificationsPlugin.cancel(id);
      return;
    }
    await _localNotificationsPlugin.cancelAll();
  }
}
