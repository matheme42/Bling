part of base;

mixin BaseAppBadgerUpdater on Base, BaseSharedPreference, BaseSplashScreen {
  static bool _isBadgeSupported = false;

  @override
  @mustCallSuper
  @protected
  Future<void> initialize() async {
    _logger.finest('--> initialize (BaseAppBadgerUpdater)');
    await super.initialize();
    _isBadgeSupported = await FlutterAppBadger.isAppBadgeSupported();

    _logger.finest('<-- initialize (BaseAppBadgerUpdater)');
  }

  Future<void> updateAppBadgeCount([int count = 0]) async {
    if (!_isBadgeSupported) return;
    if (count == 0) {
      await FlutterAppBadger.removeBadge();
      return;
    }
    await FlutterAppBadger.updateBadgeCount(count);
  }
}
