import 'package:bling/base/app_base.dart';

class Budget extends Model {
  static const String tableName = "Budget";

  double number = 0.0;

  @override
  void fromMap(Map<String, dynamic> data) {
    number = data['number'] ?? number;

    super.fromMap(data);
  }

  @override
  Map<String, dynamic> asMap() {
    Map<String, dynamic> message = {};

    message['number'] = number;
    return message..addAll(super.asMap());
  }
}

class BudgetController extends Controller<Budget> {
  BudgetController(Database db) : super(Budget.tableName, db);

  Budget? budget;

  Future<Budget?> gets() async {
    List<Map<String, dynamic>> budgetListQuery = [];

    budgetListQuery = await db.query(table);
    for (var localBudget in budgetListQuery) {
      budget = (Budget()..fromMap(localBudget));
      break;
    }
    return budget;
  }

  @override
  Future<Budget> insert(Budget model) async {
    Budget localBudget = await super.insert(model);
    budget = localBudget;
    return localBudget;
  }
}
