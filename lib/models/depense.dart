import 'package:bling/base/app_base.dart';
import 'package:bling/models/budgetinstance.dart';

class Depense extends Model {
  static const String tableName = "Depense";

  late String labelle;

  late double number;

  late int budgetInstanceId;

  BudgetInstance? associatedInstance;

  @override
  void fromMap(Map<String, dynamic> data) {
    number = data['number'] ?? number;
    labelle = data['labelle'] ?? labelle;
    budgetInstanceId = data['budget_instance_id'];

    super.fromMap(data);
  }

  @override
  Map<String, dynamic> asMap() {
    Map<String, dynamic> message = {};

    message['number'] = number;
    message['labelle'] = labelle;
    message['budget_instance_id'] = budgetInstanceId;
    return message..addAll(super.asMap());
  }
}

class DepenseController extends Controller<Depense> {
  DepenseController(Database db) : super(Depense.tableName, db);

  Future<List<Depense>> getsDepenseOfCategoriesInstance(
      BudgetInstance instance) async {
    List<Map<String, dynamic>> budgetDepenseListQuery = [];
    List<Depense> depenses = [];

    budgetDepenseListQuery = await db.query(table,
        where: "budget_instance_id = ?", whereArgs: [instance.id]);
    for (var rawDepense in budgetDepenseListQuery) {
      Depense depense = Depense()..fromMap(rawDepense);
      depenses.add(depense);
      instance.depense += depense.number;
      depense.associatedInstance = instance;
    }
    instance.spends = depenses;
    return (depenses);
  }
}
