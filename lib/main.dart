import 'dart:async';

import 'package:bling/home/view.dart';
import 'package:bling/models/budget.dart';
import 'package:bling/models/budgetcategory.dart';
import 'package:bling/models/depense.dart';
import 'package:cron/cron.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';

import 'base/app_base.dart';
import 'models/budgetinstance.dart';

GlobalKey<AppBaseState> key = GlobalKey<AppBaseState>();

void main() => MyApp(level: Level.FINEST, key: key);

class MyApp extends AppBase {
  MyApp({super.key, super.level, super.themes});

  static MyApp of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<MyApp>()!;
  }

  static late BudgetController _budgetController;
  static late BudgetCategoryController _budgetCategoryController;
  static late BudgetInstanceController _budgetInstanceController;
  static late DepenseController _depenseController;

  BudgetController get budgetController => _budgetController;

  BudgetCategoryController get budgetCategoryController =>
      _budgetCategoryController;

  BudgetInstanceController get budgetInstanceController =>
      _budgetInstanceController;

  DepenseController get depenseController => _depenseController;

  void reloadEntireApp(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  Future<void> configure(void Function([String message]) forward) async {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.configure(forward);
    await Wakelock.disable();

    final cron = Cron();
    cron.schedule(Schedule.parse('0 0 1 * *'), () async {
      for (var elm in _budgetCategoryController.budgetCategories) {
        elm.activeInstance = null;
        BudgetInstance instance = BudgetInstance();
        instance.year = DateTime.now().year;
        instance.number = elm.number;
        instance.categoryId = elm.id!;
        instance.month = DateTime.now().month;
        instance.depense = 0.0;
        elm.activeInstance = instance;
        await budgetInstanceController.insert(instance);
      }
      // ignore: use_build_context_synchronously
      reloadEntireApp(key.currentState!.context);
    });

    Database db = await database;
    _budgetController = BudgetController(db);
    await _budgetController.gets();
    if (_budgetController.budget == null) {
      await _budgetController.insert(Budget()..number = 0.0);
    }
    _budgetCategoryController = BudgetCategoryController(db);
    await _budgetCategoryController.gets();

    _budgetInstanceController = BudgetInstanceController(db);
    _depenseController = DepenseController(db);
    List<BudgetInstance> instances =
        await _budgetInstanceController.getsCurrent();
    for (var instance in instances) {
      try {
        _budgetCategoryController.budgetCategories
            .where((e) => e.id == instance.categoryId)
            .first
            .activeInstance = instance;
        await _depenseController.getsDepenseOfCategoriesInstance(instance);
      } catch (e) {
        if (kDebugMode) {
          print(
              'Une instance active sur une category supprimer ne doit jamais arriver');
        }
      }
    }

    /// create a new instance if the current instance doesnt exist
    for (var category in _budgetCategoryController.budgetCategories) {
      if (category.activeInstance == null) {
        BudgetInstance instance = BudgetInstance();
        instance.year = DateTime.now().year;
        instance.number = category.number;
        instance.categoryId = category.id!;
        instance.month = DateTime.now().month;
        instance.depense = 0.0;
        category.activeInstance = instance;
        await budgetInstanceController.insert(instance);
      }
    }
  }

  @override
  FutureOr<void> onCreatingDatabase(Database db, int version) async {
    await db.execute(
        'CREATE TABLE ${Budget.tableName} (id INTEGER PRIMARY KEY, number REAL)');
    await db.execute(
        'CREATE TABLE ${BudgetCategory.tableName} (id INTEGER PRIMARY KEY, name TEXT, number REAL, icon TEXT, enable INTEGER, color INTEGER)');
    await db.execute(
        'CREATE TABLE ${BudgetInstance.tableName} (id INTEGER PRIMARY KEY, number REAL, month INTEGER, year INTEGER, budget_category_id INTEGER)');
    await db.execute(
        'CREATE TABLE ${Depense.tableName} (id INTEGER PRIMARY KEY, number REAL, budget_instance_id INTEGER, labelle TEXT)');
    return super.onCreatingDatabase(db, version);
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
      builder: builder,
      themeMode: themeMode,
      locale: locale,
      theme: light,
      darkTheme: dark,
      home: const Home(),
    );
  }
}
