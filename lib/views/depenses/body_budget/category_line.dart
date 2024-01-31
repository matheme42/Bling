part of spend_view;

class CategoryLine extends StatelessWidget {
  final BudgetCategory category;
  final void Function(Color) onColorChange;
  final void Function(BudgetCategory) onInsertNewCategories;
  final void Function() onWantReloadView;


  const CategoryLine({
    super.key,
    required this.category,
    required this.onColorChange,
    required this.onInsertNewCategories, required this.onWantReloadView});

  Color get textColor {
    if (category.id == null) return BlingColor.textColor.withAlpha(127);
    return BlingColor.textColor;
  }

  Color get iconColor {
    if (category.id == null) return Colors.transparent;
    return BlingColor.textColor.withAlpha(127);
  }

  Future<void> changeColor(BuildContext context) async {
    Bling bling = Bling.of(context);
    await CategoryLineColor.show(context, category, onColorChange);
    if (category.id == null) return ;
    bling.budgetCategoryController.update(category);
    onWantReloadView();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0, top: 8.0, left: 8.0, right: 8.0),
      child: Row(
        children: [
          InkWell(
            onTap: () => changeColor(context),
            splashFactory: NoSplash.splashFactory,
            child: Container(
              height: 20,
              width: 20,
              margin: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0),
              decoration: BoxDecoration(
                  color: category.color,
                  border: Border.all(color: BlingColor.borderColor),
                  borderRadius: BorderRadius.circular(6.0)),
            ),
          ),
          Expanded(
              child: CategoryLineLabel(
                  category: category,
                  textColor: textColor,
                  onInsertNewCategories: onInsertNewCategories)
          ),
          CategoryLineNumber(category: category, textColor: textColor,
            onInsertNewCategories: onInsertNewCategories),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: trailingIcon
          )
        ],
      ),
    );
  }


  Widget get trailingIcon {
    return Image.asset('images/draggable.png', height: 20);
  }
}
