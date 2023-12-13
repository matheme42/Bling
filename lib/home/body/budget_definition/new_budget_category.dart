import 'package:flutter/material.dart';

import 'budget_category_bottom_sheet.dart';

class NewBudgetCategoryTile extends StatelessWidget {
  final void Function() onBudgetAdded;

  const NewBudgetCategoryTile({super.key, required this.onBudgetAdded});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          tileColor: Colors.green,
          title: const Text(
            "ajouter une category",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
          ),
          leading: const Icon(Icons.add, color: Colors.black),
          trailing: const SizedBox.shrink(),
          onTap: () => BudgetCategoryBottomSheet.show(context, onBudgetAdded),
        ),
      ),
    );
  }
}
