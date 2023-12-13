import 'package:auto_size_text/auto_size_text.dart';
import 'package:bling/main.dart';
import 'package:bling/models/budgetcategory.dart';
import 'package:bling/models/depense.dart';
import 'package:flutter/material.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class BudgetDepenseBody extends StatefulWidget {
  const BudgetDepenseBody({super.key});

  @override
  State<StatefulWidget> createState() => BudgetDepenseBodyState();
}

class BudgetDepenseBodyState extends State<BudgetDepenseBody> {
  @override
  Widget build(BuildContext context) {
    List<BudgetCategory> budgetCategories =
        MyApp.of(context).budgetCategoryController.budgetCategories;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Builder(
        builder: (context) {
          if (MyApp.of(context).budgetCategoryController.budgetCategories.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                  child: Text('Categories vides', style: TextStyle(
                      fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ), textAlign: TextAlign.center)
              ),
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: List.generate(budgetCategories.length + 1, (index) {
                if (index == budgetCategories.length) {
                  return const SizedBox(height: 40);
                }
                BudgetCategory budgetCategory = budgetCategories[index];
                AutoSizeGroup group = AutoSizeGroup();
                double value = budgetCategory.activeInstance!.number -
                    budgetCategory.activeInstance!.depense;
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Material(
                    type: MaterialType.transparency,
                    borderRadius: BorderRadius.circular(16.0),
                    clipBehavior: Clip.hardEdge,
                    child: ExpansionTile(
                      leading: Text(budgetCategory.icon,
                          style: const TextStyle(fontSize: 20)),
                      clipBehavior: Clip.hardEdge,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AutoSizeText(
                              budgetCategory.name.toLowerCase().capitalize(),
                              group: group,
                              maxLines: 1),
                          Row(
                            children: [
                              AutoSizeText(value.toStringAsFixed(2),
                                  group: group,
                                  maxLines: 1,
                                  style:
                                      const TextStyle(fontWeight: FontWeight.bold)),
                              AutoSizeText(
                                  "/${budgetCategory.activeInstance!.number.toStringAsFixed(2)}€",
                                  group: group,
                                  maxLines: 1)
                            ],
                          ),
                        ],
                      ),
                      backgroundColor: Colors.brown[400],
                      collapsedBackgroundColor: value >= 0 ? Colors.brown : Colors.red[(400)],
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: budgetCategory.color),
                          borderRadius: BorderRadius.circular(16.0)),
                      collapsedShape: RoundedRectangleBorder(
                          side: BorderSide(color: budgetCategory.color),
                          borderRadius: BorderRadius.circular(16.0)),
                      children: List.generate(
                          budgetCategory.activeInstance!.spends.length, (index) {
                        Depense depense =
                            budgetCategory.activeInstance!.spends[index];
                        return ListTile(
                          leading: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text((index + 1).toString()),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(depense.labelle),
                              Text("${depense.number.toStringAsFixed(2)}€"),
                            ],
                          ),
                          trailing: Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                                onTap: () async {
                                  await MyApp.of(context).depenseController.delete(depense);
                                  depense.associatedInstance?.spends.remove(depense);
                                  depense.associatedInstance?.depense -= depense.number;
                                  setState(() {});
                                },
                                child: Icon(Icons.delete, color: Colors.red[300])),
                          ),
                        );
                      }),
                    ),
                  ),
                );
              }),
            ),
          );
        }
      ),
    );
  }
}
