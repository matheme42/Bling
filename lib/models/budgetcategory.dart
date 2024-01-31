import 'dart:async';

import 'package:bling/base/app_base.dart';
import 'package:bling/color.dart';
import 'package:bling/models/budgetinstance.dart';
import 'package:flutter/material.dart';

class BudgetCategory extends Model {
  static const String tableName = "BudgetCategory";

  String name = "";

  double number = 0;

  String icon = "";

  bool enable = true;

  Color color = BlingColor.scaffoldColor;

  int? position;

  /// Link of the active instance of the category
  BudgetInstance? activeInstance;

  @override
  void fromMap(Map<String, dynamic> data) {
    name = data['name'] ?? name;
    icon = data['icon'] ?? icon;
    number = data['number'] ?? number;
    enable = data['enable'] > 0 ? true : false;
    color = Color(data['color']);
    position = data['position'] ?? position;
    super.fromMap(data);
  }

  @override
  Map<String, dynamic> asMap() {
    Map<String, dynamic> message = {};
    message['name'] = name;
    message['icon'] = icon;
    message['number'] = number;
    message['enable'] = enable ? 1 : 0;
    message['color'] = color.value;
    message['position'] = position;
    return message..addAll(super.asMap());
  }
}

class BudgetCategoryController extends Controller<BudgetCategory> {
  BudgetCategoryController(Database db) : super(BudgetCategory.tableName, db);
  List<BudgetCategory> budgetCategories = [];

  static final StreamController<void> _onChange = StreamController.broadcast();

  Stream<void> onChange = _onChange.stream;

  Future<BudgetCategory?> getByName(String name) async {
    List<Map<String, dynamic>> budgetCategoryListQuery = [];

    budgetCategoryListQuery =
    await db.query(table, where: "name = ?", whereArgs: [name]);

    if (budgetCategoryListQuery.isNotEmpty) {
      var category = BudgetCategory()..fromMap(budgetCategoryListQuery.first);
      budgetCategories.add(category);
      return category;
    }
    return null;
  }

  Future<List<BudgetCategory>> gets() async {
    List<Map<String, dynamic>> budgetCategoryListQuery = [];
    budgetCategories.clear();
    budgetCategoryListQuery =
        await db.query(table, where: "enable = ?", whereArgs: [1]);
    for (var budget in budgetCategoryListQuery) {
      budgetCategories.add(BudgetCategory()..fromMap(budget));
    }

    int index = 0;
    for (var element in budgetCategories) {
      element.position ??= index;
      await update(budgetCategories[index]);
      index++;
    }
    budgetCategories.sort((a, b) => (a.position! > b.position!) ? 1 : 0);
    return (budgetCategories);
  }

  @override
  Future<BudgetCategory> insert(BudgetCategory model) async {
    BudgetCategory budgetCategory = await super.insert(model);
    model.position = budgetCategories.length;
    budgetCategories.add(budgetCategory);
    _onChange.sink.add(null);
    return budgetCategory;
  }

  @override
  Future<int> delete(BudgetCategory model) async {
    int id = await super.delete(model);
    budgetCategories.remove(model);
    _onChange.sink.add(null);
    return id;
  }

  @override
  Future<int> update(BudgetCategory model) async {
    int id = await super.update(model);
    _onChange.sink.add(null);
    return id;
  }

  Future<List<int>> updates(List<BudgetCategory> models) async {
    Batch batch = db.batch();

    int index = 0;
    for (var p in models) {
      p.position = index;
      batch.update(table, p.asMap(), where: 'id = ?', whereArgs: [p.id]);
      index++;
    }
    await batch.commit();
    return List.generate(models.length, (index) => models[index].id!);
  }
}
