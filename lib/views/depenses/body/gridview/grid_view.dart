part of spend_view;

class SpendGridView extends StatefulWidget {
  const SpendGridView({super.key});

  @override
  State<StatefulWidget> createState() => SpendGridViewState();
}

class SpendGridViewState extends State<SpendGridView> {
  BudgetCategory? selectedCategory;

  void onSelectedCategory(BudgetCategory? category) {
    setState(() => selectedCategory = category);
  }

  void onSubmitDepense(Depense d) {
    DepenseController controller = Bling.of(context).depenseController;
    // update associated instance
    d.associatedInstance!.spends.add(d);
    d.associatedInstance!.spends.sort(controller.sortDepense);
    d.associatedInstance!.depense += d.number;
    controller.insert(d);
    setState(() => selectedCategory = null);
  }

  @override
  Widget build(BuildContext context) {
    var categoryController = Bling.of(context).budgetCategoryController;
    List<BudgetCategory> categories = categoryController.budgetCategories;
    var group = AutoSizeGroup();
    int len = (categories.length * 0.5).ceil();
    return SingleChildScrollView(
      child: Column(
          mainAxisSize: MainAxisSize.max,
          children: List<Widget>.generate(len, (index) {
            BudgetCategory category = categories[index << 1];
            if (index << 1 >= len) {
              return Stack(
                children: [
                  LowerSpendGridViewTileLeft(
                    visible: selectedCategory == category,
                    category: category,
                    animatedClose: true, onSubmitDepense: onSubmitDepense,
                  ),
                  SpendGridViewTile(
                    category: category,
                    group: group,
                    onSelectedCategory: onSelectedCategory,
                    selected: selectedCategory == category,
                    alignment: Alignment.centerLeft,
                  ),
                ],
              );
            }
            BudgetCategory category2 = categories[(index << 1) + 1];
            return Stack(
              children: [
                LowerSpendGridViewTileRight(
                  visible: selectedCategory == category2,
                  category: category2, onSubmitDepense: onSubmitDepense,
                ),
                SpendGridViewTile(
                  alignment: Alignment.centerLeft,
                  category: category,
                  group: group,
                  onSelectedCategory: onSelectedCategory,
                  selected: selectedCategory == category,
                ),
                SpendGridViewTile(
                  alignment: Alignment.centerRight,
                  category: category2,
                  group: group,
                  onSelectedCategory: onSelectedCategory,
                  selected: selectedCategory == category2,
                ),
                LowerSpendGridViewTileLeft(
                  onSubmitDepense: onSubmitDepense,
                  visible: selectedCategory == category,
                  animatedClose: selectedCategory != category2,
                  category: category,
                  child: SpendGridViewTile(
                    alignment: Alignment.centerLeft,
                    category: category,
                    group: group,
                    onSelectedCategory: onSelectedCategory,
                    selected: selectedCategory == category,
                  ),
                ),
              ],
            );
          })),
    );
  }
}
