import 'package:bling/main.dart';
import 'package:flutter/material.dart';

import '../../models/budgetcategory.dart';

class DropdownItem extends StatefulWidget {
  final void Function(BudgetCategory) onBudgetSelect;

  const DropdownItem({super.key, required this.onBudgetSelect});

  @override
  State<StatefulWidget> createState() => _DropdownItemState();
}

class _DropdownItemState extends State<DropdownItem> {
  String? selectedValue;

  List<DropdownMenuItem<String>> get dropdownItems {
    List<BudgetCategory> categories =
        Bling.of(context).budgetCategoryController.budgetCategories;
    List<DropdownMenuItem<String>> menuItems =
        List.generate(categories.length, (index) {
      BudgetCategory category = categories[index];
      return DropdownMenuItem(
          value: category.name,
          child: Text("${category.icon} ${category.name}"));
    });
    return menuItems;
  }

  void onFirstCategorySelected() {
    BudgetCategory category =
        Bling.of(context).budgetCategoryController.budgetCategories.first;
    selectedValue ??= category.name;
    widget.onBudgetSelect(category);
  }

  @override
  Widget build(BuildContext context) {
    if (selectedValue == null) onFirstCategorySelected();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DropdownButtonFormField(
          hint: const Text('Category'),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          dropdownColor: Colors.white,
          validator: (value) {
            if (value == null) return "selection obligatoire";
            return null;
          },
          borderRadius: BorderRadius.circular(0.0),
          elevation: 0,
          value: selectedValue,
          onChanged: (v) => setState(() {
                selectedValue = v!;
                List<BudgetCategory> l =
                    Bling.of(context).budgetCategoryController.budgetCategories;
                widget.onBudgetSelect(l.firstWhere((e) => e.name == v));
              }),
          items: dropdownItems),
    );
  }
}
