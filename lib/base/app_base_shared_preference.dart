part of base;

mixin BaseSharedPreference on Base {
  static late SharedPreferences _sharedPreferences;

  SharedPreferences get sharedPreferences => _sharedPreferences;

  @override
  @protected
  @mustCallSuper
  Future<void> initialize() async {
    _logger.finest('--> initialize (BaseSharedPreference)');
    WidgetsFlutterBinding.ensureInitialized();
    _sharedPreferences = await SharedPreferences.getInstance();
    _logger.finest('<-- initialize (BaseSharedPreference)');
  }
}
