import 'package:bling/base/app_base.dart';
import 'package:bling/models/budgetinstance.dart';

class Depense extends Model {
  static const String tableName = "Depense";

  late String labelle;

  late double number;

  late int budgetInstanceId;

  DateTime? date;

  BudgetInstance? _associatedInstance;

  BudgetInstance? get associatedInstance => _associatedInstance;
  set associatedInstance(BudgetInstance? instance) {
    if (instance != null && date == null) {
      date = DateTime(instance.year, instance.month, 1);
    }
    _associatedInstance = instance;
  }

  @override
  void fromMap(Map<String, dynamic> data) {
    number = data['number'] ?? number;
    labelle = data['labelle'] ?? labelle;
    date = DateTime.tryParse(data['date']) ?? date;
    budgetInstanceId = data['budget_instance_id'];

    super.fromMap(data);
  }

  @override
  Map<String, dynamic> asMap() {
    Map<String, dynamic> message = {};

    message['number'] = number;
    message['labelle'] = labelle;
    message['date'] = date?.toIso8601String();
    message['budget_instance_id'] = budgetInstanceId;
    return message..addAll(super.asMap());
  }
}

class DepenseController extends Controller<Depense> {
  DepenseController(Database db) : super(Depense.tableName, db);

  final List<Depense> depenses = [];

  @override
  Future<Depense> insert(Depense model) async {
    Depense depense = await super.insert(model);
    depenses.add(depense);
    depenses.sort(sortDepense);
    return depense;
  }

  @override
  Future<int> delete(Depense model) async {
    depenses.remove(model);
    return await super.delete(model);
  }

    Future<List<Depense>> getsDepenseOfCategoriesInstance(
      BudgetInstance instance) async {
    List<Map<String, dynamic>> budgetDepenseListQuery = [];
    List<Depense> depenses = [];

    this.depenses.removeWhere((e) => e.budgetInstanceId == instance.id);
    budgetDepenseListQuery = await db.query(table,
        where: "budget_instance_id = ?", whereArgs: [instance.id]);

    for (var rawDepense in budgetDepenseListQuery) {
      Depense depense = Depense()..fromMap(rawDepense);
      depenses.add(depense);
      instance.depense += depense.number;
      depense.associatedInstance = instance;
    }
    instance.spends = depenses;
    this.depenses.addAll(depenses);
    this.depenses.sort(sortDepense);
    return (depenses..sort(sortDepense));
  }

  int sortDepense(Depense a, Depense b) {
    if (a.date != null && b.date != null) {
      int value = b.date!.compareTo(a.date!);
      if (value != 0) return value;
    }
    return b.labelle.compareTo(a.labelle);
  }
}
