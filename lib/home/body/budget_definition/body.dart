import 'package:bling/main.dart';
import 'package:bling/models/budget.dart';
import 'package:bling/models/budgetcategory.dart';
import 'package:flutter/material.dart';

import 'budget_category_bottom_sheet.dart';
import 'new_budget_category.dart';
import 'textform.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<StatefulWidget> createState() => HomeBodyState();
}

class HomeBodyState extends State<HomeBody> with AutomaticKeepAliveClientMixin {
  bool _budgetLock = false;

  bool get budgetLock => _budgetLock;

  set budgetLock(bool value) {
    MyApp.of(context).sharedPreferences.setBool('budgetLock', value);
    _budgetLock = value;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _budgetLock =
          MyApp.of(context).sharedPreferences.getBool('budgetLock') ?? false;
      if (mounted) setState(() {});
    });
  }

  void onGlobalBudgetChange(double? newBudget) {
    setState(() => budget.number = newBudget ?? 0);
  }

  void onBudgetCategoryAdded() {
    setState(() {});
  }

  void onBudgetCategoryEdit([int? index]) {
    if (index == null) {
      setState(() {});
      return;
    }
    if (budgetLock == false) updateGlobalBudget();
    setState(() {});
  }

  Budget get budget {
    return MyApp.of(context).budgetController.budget!;
  }

  List<BudgetCategory> get budgetCategories {
    return MyApp.of(context).budgetCategoryController.budgetCategories;
  }

  void updateGlobalBudget() {
    double total = 0.0;
    for (var e in budgetCategories) {
      total += e.number;
    }
    budget.number = total;
    MyApp.of(context)
        .budgetController
        .update(MyApp.of(context).budgetController.budget!);
  }

  void updateBudgetOrSliderOnChange(int instanceSelectedIndex) {
    if (budgetLock == false) {
      updateGlobalBudget();
      return;
    }

    BudgetCategory categorySelected = budgetCategories[instanceSelectedIndex];
    // case when the number is set manually
    if (categorySelected.number >= budget.number) {
      for (var instance in budgetCategories) {
        instance.number = 0;
      }
      categorySelected.number = budget.number;
      MyApp.of(context).budgetCategoryController.update(categorySelected);
      if (categorySelected.activeInstance != null) {
        MyApp.of(context).budgetInstanceController.update(categorySelected.activeInstance!);
      }
      return;
    }

    // reduce budget of other subBudget to match with the global budget
    double budgetAvailable = budget.number - categorySelected.number;
    for (int i = instanceSelectedIndex - 1; i >= 0; i--) {
      BudgetCategory categorySelected = budgetCategories[i];
      if (categorySelected.number == 0) continue;
      budgetAvailable -= categorySelected.number;
      if (budgetAvailable < 0) {
        categorySelected.number += budgetAvailable;
        budgetAvailable = 0;
        break;
      }
    }
    if (budgetAvailable == 0) {
      MyApp.of(context).budgetCategoryController.update(categorySelected);
      if (categorySelected.activeInstance != null) {
        MyApp.of(context).budgetInstanceController.update(categorySelected.activeInstance!);
      }
      return;
    }
    for (int i = budgetCategories.length - 1; i > instanceSelectedIndex; i--) {
      BudgetCategory categorySelected = budgetCategories[i];
      if (categorySelected.number == 0) continue;
      budgetAvailable -= categorySelected.number;
      if (budgetAvailable < 0) {
        categorySelected.number += budgetAvailable;
        budgetAvailable = 0;
        break;
      }
    }
    MyApp.of(context).budgetCategoryController.update(categorySelected);
    if (categorySelected.activeInstance != null) {
      MyApp.of(context).budgetInstanceController.update(categorySelected.activeInstance!);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Form(
        child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(children: [
          Row(
            children: [
              IconButton(
                  onPressed: () => setState(() => budgetLock = !budgetLock),
                  icon: Icon(budgetLock ? Icons.lock : Icons.lock_open)),
              Expanded(
                child: AbsorbPointer(
                  absorbing: budgetLock,
                  child: BudgetTextForm(
                    label: 'Budget total',
                    prefixIcon:
                        const Text('💰', style: TextStyle(fontSize: 25)),
                    globalBudget: budget.number,
                    onChange: onGlobalBudgetChange,
                    value: budget.number,
                    sliderOff: true, color: Colors.white54
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          ...List<Widget>.generate(budgetCategories.length, (index) {
            BudgetCategory budgetCategory = budgetCategories[index];
            return Row(
              children: [
                IconButton(
                    onPressed: () {
                      BudgetCategoryBottomSheet.show(context, ([id]) {
                        if (id != null) {
                          onBudgetCategoryEdit(index);
                          return;
                        }
                        onBudgetCategoryEdit();
                      }, budgetCategory: budgetCategory);
                    },
                    icon: const Icon(Icons.more_vert_outlined)),
                Expanded(
                  child: BudgetTextForm(
                    label: budgetCategory.name.toLowerCase().capitalize(),
                    prefixIcon: Text(budgetCategory.icon,
                        style: const TextStyle(fontSize: 20)),
                    value: budgetCategories[index].number,
                    globalBudget: budget.number,
                    sliderOff: !budgetLock,
                    onChange: (value) {
                      budgetCategories[index].number = value ?? 0;
                      MyApp.of(context)
                          .budgetCategoryController
                          .update(budgetCategories[index])
                          .then((value) {
                            if (budgetCategories[index].activeInstance != null) {
                              budgetCategories[index].activeInstance!.number = budgetCategories[index].number;
                              MyApp.of(context).budgetInstanceController.update(budgetCategories[index].activeInstance!);
                            }
                        updateBudgetOrSliderOnChange(index);
                        setState(() {});
                      });
                    }, color: budgetCategories[index].color,
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          Row(
            children: [
              IconButton(
                  splashColor: Colors.transparent,
                  splashRadius: 1,
                  onPressed: () {
                    BudgetCategoryBottomSheet.show(
                        context, onBudgetCategoryAdded);
                  },
                  icon: const Icon(Icons.more_vert_outlined,
                      color: Colors.transparent)),
              Expanded(
                  child: NewBudgetCategoryTile(
                      onBudgetAdded: onBudgetCategoryAdded)),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.1)
        ]),
      ),
    ));
  }

  @override
  bool get wantKeepAlive => true;
}
