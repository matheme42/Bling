import 'package:bling/base/app_base.dart';

import 'depense.dart';

class BudgetInstance extends Model {
  static const String tableName = "BudgetInstance";

  late int year;

  late int month;

  late double number;

  late int categoryId;

  double depense = 0.0;

  List<Depense> spends = [];

  @override
  void fromMap(Map<String, dynamic> data) {
    categoryId = data['budget_category_id'];
    number = data['number'] ?? number;
    month = data['month'];
    year = data['year'];

    super.fromMap(data);
  }

  @override
  Map<String, dynamic> asMap() {
    Map<String, dynamic> message = {};

    message['number'] = number;
    message['budget_category_id'] = categoryId;
    message['month'] = month;
    message['year'] = year;

    return message..addAll(super.asMap());
  }
}

class BudgetInstanceController extends Controller<BudgetInstance> {
  BudgetInstanceController(Database db) : super(BudgetInstance.tableName, db);

  Future<List<BudgetInstance>> getsCurrent() async {
    List<Map<String, dynamic>> budgetInstanceListQuery = [];
    List<BudgetInstance> budgets = [];

    budgetInstanceListQuery = await db.query(table,
        where: "year = ? and month = ?",
        whereArgs: [DateTime.now().year, DateTime.now().month]);
    for (var budgetInstance in budgetInstanceListQuery) {
      budgets.add(BudgetInstance()..fromMap(budgetInstance));
    }
    return (budgets);
  }

  Future<List<BudgetInstance>> gets() async {
    List<Map<String, dynamic>> budgetInstanceListQuery = [];
    List<BudgetInstance> budgets = [];

    budgetInstanceListQuery = await db.query(table);
    for (var budgetInstance in budgetInstanceListQuery) {
      budgets.add(BudgetInstance()..fromMap(budgetInstance));
    }
    return (budgets);
  }
}
