part of spend_view;

class SpendListView extends StatefulWidget {
  final BudgetCategory? category;

  const SpendListView({super.key, required this.category});

  @override
  State<StatefulWidget> createState() => SpendListViewState();
}

class SpendListViewState extends State<SpendListView> {

  BudgetCategory? selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.category;
  }

  void onCategorySelected(BudgetCategory? category) {
    setState(() {
      selectedCategory = category;
    });
  }


  @override
  Widget build(BuildContext context) {
    var categoryController = Bling.of(context).budgetCategoryController;
    var budgetController = Bling.of(context).depenseController;

    BudgetInstance? instance = selectedCategory?.activeInstance;
    List<Depense> depenses = instance?.spends ?? budgetController.depenses;

    return Column(
      children: [
        CategorySelector(
            categorySelected: selectedCategory,
            categories: categoryController.budgetCategories,
            onCategorySelected: onCategorySelected
        ),
        Expanded(child: ListView.builder(
            itemCount: depenses.length,
            itemBuilder: (context, index) {
              Depense depense = depenses[index];
              return SpendListTile(depense: depense);
            }))
      ],
    );
  }
}