import 'dart:async';

import 'package:bling/color.dart';
import 'package:bling/context.dart';
import 'package:bling/home/view.dart';
import 'package:bling/models/budget.dart';
import 'package:bling/models/budgetcategory.dart';
import 'package:bling/models/depense.dart';
import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';

import 'base/app_base.dart';
import 'models/budgetinstance.dart';
import 'views/depenses/view.dart';

void main() => Bling(level: Level.FINEST, themes: {
   'default' : {
     'light' : ThemeData(fontFamily: 'Poppins', primaryColor: BlingColor.appBarColor),
     'dark' : ThemeData(fontFamily: 'Poppins', primaryColor: BlingColor.appBarColor)
   }
   });

class Bling extends AppBase with BlingGlobalContext {
  Bling({super.key, super.level, super.themes});

  static Bling of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<Bling>()!;
  }

  @override
  Future<void> initialize() async {
    await super.initialize();
    await Wakelock.disable();
    changeTheme('default');
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  int get dbVersion => 2;

  @override
  FutureOr<void> onCreatingDatabase(Database db, int version) async {
    await db.execute(
        'CREATE TABLE ${Budget.tableName} (id INTEGER PRIMARY KEY, number REAL)');
    await db.execute(
        'CREATE TABLE ${BudgetCategory.tableName} (id INTEGER PRIMARY KEY, name TEXT, number REAL, icon TEXT, enable INTEGER, color INTEGER)');
    await db.execute(
        'CREATE TABLE ${BudgetInstance.tableName} (id INTEGER PRIMARY KEY, number REAL, month INTEGER, year INTEGER, budget_category_id INTEGER)');
    await db.execute(
        'CREATE TABLE ${Depense.tableName} (id INTEGER PRIMARY KEY, number REAL, budget_instance_id INTEGER, labelle TEXT, date TEXT)');
    return super.onCreatingDatabase(db, version);
  }

  @override
  FutureOr<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    while (oldVersion < newVersion) {
      oldVersion++;
      if (oldVersion == 2) {
        db.execute("ALTER TABLE ${Depense.tableName} ADD COLUMN date TEXT");
      }
    }
  }

  @override
  MaterialApp materialAppBuilder(
      {Iterable<LocalizationsDelegate<dynamic>>? localDelegate,
      required Iterable<Locale> locales,
      Widget Function(BuildContext, Widget?)? builder,
      required ThemeMode themeMode,
      Locale? locale,
      required ThemeData light,
      required ThemeData dark}) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: localDelegate,
      supportedLocales: locales,
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
        '/second': (context) => const SpendView(),
      },
      builder: builder,
      themeMode: themeMode,
      locale: locale,
      theme: light,
      darkTheme: dark,
    );
  }

  @override
  State<StatefulWidget> createState() => BlingState();
}

class BlingState extends AppBaseState<Bling>with WidgetsBindingObserver {
  final cron = Cron();

  AppLifecycleState state = AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    cron.schedule(Schedule.parse('0 0 1 * *'), regenerateBudgetInstance);
  }

  @override
  void dispose() {
    cron.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void onStateChange() {
    BudgetCategoryController controller = widget.budgetCategoryController;
    if (controller.budgetCategories.isEmpty) return ;
    BudgetInstance? instance = controller.budgetCategories.first.activeInstance;
    if (instance == null) return ;
    int year = instance.year;
    int month = instance.month;
    if (state == AppLifecycleState.inactive) {
      DateTime time = DateTime.now();
      if (time.year != year || time.month != month) {
        regenerateBudgetInstance();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (this.state != state) {
      this.state = state;
      onStateChange();
    }
  }

  Future <void> regenerateBudgetInstance() async {
    await widget.getCurrentBudgetInstance();
    reloadEntireApp();
  }

  void reloadEntireApp() {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }
    (context as Element).visitChildren(rebuild);
  }
}
