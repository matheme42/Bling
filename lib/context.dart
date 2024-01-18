import 'package:flutter/foundation.dart';

import 'base/app_base.dart';
import 'models/budget.dart';
import 'models/budgetcategory.dart';
import 'models/budgetinstance.dart';
import 'models/depense.dart';

mixin BlingGlobalContext on AppBase {
  static late BudgetController _budgetController;
  static late BudgetCategoryController _budgetCategoryController;
  static late BudgetInstanceController _budgetInstanceController;
  static late DepenseController _depenseController;

  BudgetController get budgetController => _budgetController;
  BudgetCategoryController get budgetCategoryController => _budgetCategoryController;
  BudgetInstanceController get budgetInstanceController => _budgetInstanceController;
  DepenseController get depenseController => _depenseController;

  Future<void> getCurrentBudgetInstance() async {
    for (var elm in budgetCategoryController.budgetCategories) {
      elm.activeInstance = null;
    }
    List<BudgetInstance> instances = await _budgetInstanceController.getsCurrent();
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
  Future<void> initialize() async {
    await super.initialize();

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
    await getCurrentBudgetInstance();
  }
}