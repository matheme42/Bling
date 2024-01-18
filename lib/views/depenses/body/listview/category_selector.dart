part of spend_view;

class CategorySelector extends StatelessWidget {
  final void Function(BudgetCategory?) onCategorySelected;
  final List<BudgetCategory> categories;
  final BudgetCategory? categorySelected;

  const CategorySelector({
    super.key,
    required this.onCategorySelected,
    required this.categories,
    this.categorySelected
  });

  Color getColor(BudgetCategory? category) {
    if (category == categorySelected) return BlingColor.enableButtonColor;
    return BlingColor.disableButtonColor;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List<Widget>.generate(categories.length + 1, (index) {
            index = index - 1;
            BudgetCategory? category = index == -1 ? null : categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: MaterialButton(
                  height: 12,
                  minWidth: 20,
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(color: getColor(category))
                  ),
                  child: Text(category?.name ?? 'Toutes', style: TextStyle(color: getColor(category), fontSize: 12)),
                    onPressed: () => onCategorySelected(category)),
              );
          }),
        ),
      ),
    );
  }

}