part of spend_view;

class SpendBodyBudget extends StatefulWidget {
  const SpendBodyBudget({super.key});

  @override
  State<StatefulWidget> createState() => SpendBodyBudgetState();
}

class SpendBodyBudgetState extends State<SpendBodyBudget> {

  List<BudgetCategory>? categories;
  List<ValueNotifier<Color>>? valueNotifiers;
  BudgetCategory newBudgetCategory = BudgetCategory();

  double get calculateBudget {
    double budget = 0;
    for (var c in categories!) {
      budget += c.number;
    }
    return budget;
  }

  void onInsertNewCategory(BudgetCategory category) {
    newBudgetCategory = BudgetCategory();
    valueNotifiers!.add(ValueNotifier(newBudgetCategory.color));
    BudgetInstance instance = BudgetInstance();
    instance.categoryId = category.id!;
    instance.number = category.number;
    instance.depense = 0;
    instance.year = DateTime.now().year;
    instance.month = DateTime.now().month;
    category.activeInstance = instance;
    Bling.of(context).budgetInstanceController.insert(instance);
  }

  void onReorder(int oldIndex, int newIndex) {
    if (oldIndex == categories!.length) return ;
    BudgetCategory category = categories![oldIndex];
    setState(() {
      categories!.removeAt(oldIndex);
      if (newIndex > oldIndex) {
        categories!.insert(newIndex - 1, category);
      } else {
        categories!.insert(newIndex, category);
      }
    });
    Bling.of(context).budgetCategoryController.updates(categories!);
  }

  List<ValueNotifier<Color>> generateValueNotifier() {
    List<ValueNotifier<Color>> data = [];
    for (var element in categories!) {
      data.add(ValueNotifier(element.color));
    }
    data.add(ValueNotifier(newBudgetCategory.color));
    return data;
  }

  @override
  Widget build(BuildContext context) {
    var budgetCategoryController = Bling.of(context).budgetCategoryController;
    categories ??= budgetCategoryController.budgetCategories;
    valueNotifiers ??= generateValueNotifier();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.67,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: Text("Catégories", style: TextStyle(color: BlingColor.textColor, fontSize: 24)),
              ),
              Expanded(
                  child: SpendBodyBudgetListView(
                    categories: categories!,
                    onReorder: onReorder,
                    onInsertNewCategories: onInsertNewCategory,
                    newBudgetCategory: newBudgetCategory,
                    onWantReloadView: () => setState(() {}),
                    notifiers: valueNotifiers!)),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, left: 8.0, right: 8.0),
                child: Row(children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text('Budget dépenses:        ', style: TextStyle(color: BlingColor.textColor)),
                  ),
                  Text("${calculateBudget.toInt()}€", style: const TextStyle(color: BlingColor.textColor, fontWeight: FontWeight.bold, fontSize: 24)),
                ]),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Divider(color: BlingColor.dividerColor),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, top: 8.0, left: 8.0, right: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0, bottom: 2.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text('Total épargné: --  ', style: TextStyle(color: Color(0xffbab4a8))),
                        ),
                        Text('€', style: TextStyle(color: Color(0xffbab4a8), fontSize: 24))
                      ],
                    ),
                  ),
                  MaterialButton(
                    onPressed: (){},
                    visualDensity: VisualDensity.compact,
                    minWidth: 20,
                    height: 12,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: const BorderSide(color: BlingColor.disableButtonColor)),
                    child: const Text('Définir un revenu', style: TextStyle(color: BlingColor.disableButtonColor, fontSize: 12)),
                  )
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}