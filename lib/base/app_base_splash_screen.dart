part of base;

mixin BaseSplashScreen on Base, BaseSharedPreference {
  @override
  @protected
  @mustCallSuper
  Future<void> initialize() async {
    _logger.finest('--> initialize (SplashScreen)');
    await super.initialize();
    if (_configureView == null) {
      WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
      _logger.finest('    preserve SplashScreen (SplashScreen)');
    }
    _logger.finest('<-- initialize (SplashScreen)');
  }

  @override
  @protected
  @mustCallSuper
  Future<void> configure(void Function([String message]) forward) async {
    _logger.finest('--> configure (SplashScreen)');
    if (_configureView != null) {
      _logger.finest('    remove SplashScreen (SplashScreen)');
      FlutterNativeSplash.remove();
    }
    _logger.finest('<-- configure (SplashScreen)');
  }

  @override
  @protected
  @mustCallSuper
  void onConfigureDone() {
    if (_configureView == null) {
      _logger.finest('    remove SplashScreen (SplashScreen)');
      FlutterNativeSplash.remove();
    }
  }
}
