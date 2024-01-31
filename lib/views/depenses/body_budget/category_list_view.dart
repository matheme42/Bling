part of spend_view;

class SpendBodyBudgetListView extends StatelessWidget {
  final List<BudgetCategory> categories;
  final BudgetCategory newBudgetCategory;
  final void Function(int, int) onReorder;
  final void Function(BudgetCategory) onInsertNewCategories;
  final void Function() onWantReloadView;
  final List<ValueNotifier<Color>> notifiers;

  const SpendBodyBudgetListView({
    super.key,required this.categories,
    required this.onReorder,
    required this.onInsertNewCategories,
    required this.newBudgetCategory, required this.onWantReloadView,
    required this.notifiers});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: BlingColor.scaffoldColor),
      child: ReorderableListView(
          onReorder: onReorder,
          children: List<Widget>.generate(
              categories.length + 1,
              (index) {
                bool overflow = (index == categories.length);
                BudgetCategory category = overflow ? newBudgetCategory : categories[index];
                return ValueListenableBuilder(
                  key: ValueKey("${category.hashCode} $index"),
                  valueListenable: notifiers[index],
                  builder: (context, _, __) {
                    return CategoryLine(
                        category: category,
                        onColorChange: (c) {
                          notifiers[index].value = c;
                          category.color = c;
                        },
                        onInsertNewCategories: onInsertNewCategories,
                        onWantReloadView: onWantReloadView);
                  },
                );
              })
      ),
    );
  }

}