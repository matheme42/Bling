part of spend_view;

class UpperSpendGridViewTile extends StatelessWidget {
  final BudgetCategory category;
  final AutoSizeGroup group;
  final bool selected;
  final void Function(BudgetCategory?) onSelectedCategory;
  final void Function(BudgetCategory?) onTapDepense;

  const UpperSpendGridViewTile({
    super.key,
    required this.category,
    required this.group,
    required this.selected,
    required this.onSelectedCategory,
    required this.onTapDepense
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.5,
      child: AspectRatio(
        aspectRatio: 1,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              _UpperSpendGridViewTileBackgroundColor(category),
              _UpperSpendGridViewTileContent(
                  category: category,
                  group: group,
                  selected: selected,
                  onSelectedCategory: onSelectedCategory,
                  onTapDepense: onTapDepense,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpperSpendGridViewTileContent extends StatelessWidget {
  final BudgetCategory category;
  final AutoSizeGroup group;
  final bool selected;
  final void Function(BudgetCategory?) onSelectedCategory;
  final void Function(BudgetCategory?) onTapDepense;


  const _UpperSpendGridViewTileContent({
    required this.category,
    required this.group,
    required this.selected,
    required this.onSelectedCategory,
    required this.onTapDepense});

  @override
  Widget build(BuildContext context) {
    BudgetInstance instance = category.activeInstance!;
    return Container(
      padding: const EdgeInsets.all(8.0),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: BlingColor.borderColor),
          borderRadius: BorderRadius.circular(16.0)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FractionallySizedBox(
              widthFactor: 1,
              child: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: AutoSizeText(
              category.name.capitalize(),
              maxLines: 1,
              minFontSize: 10,
              group: group,
              style: const TextStyle(color: BlingColor.textColor),
            ),
          )),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedFlipCounter(
                  value: (instance.number - instance.depense).toInt(),
                  duration: const Duration(seconds: 1),
                  curve: Curves.elasticOut,
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: BlingColor.textColor,
                      fontSize: 28)
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(" /${instance.number.toInt()}",
                    style: const TextStyle(fontSize: 10, color: BlingColor.textColor)),
              )
            ],
          ),
          Material(
            type: MaterialType.transparency,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                    onTap: () => onTapDepense(category),
                    borderRadius: BorderRadius.circular(8),
                    radius: 15,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                        child: Row(
                          children: [
                            AnimatedFlipCounter(
                              value: instance.spends.length,
                              duration: const Duration(seconds: 1),
                              curve: Curves.elasticOut,
                              textStyle: const TextStyle(fontSize: 10, color: BlingColor.textColor)
                            ),
                            const Text(" dépenses", style: TextStyle(fontSize: 10, color: BlingColor.textColor)),
                          ],
                        ))),
                InkWell(
                    onTap: () => onSelectedCategory(selected ? null : category),
                    radius: 30,
                    borderRadius: BorderRadius.circular(64),
                    child: Icon(selected ? Icons.close : Icons.add, color: BlingColor.textColor)
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _UpperSpendGridViewTileBackgroundColor extends StatelessWidget {
  final BudgetCategory category;

  const _UpperSpendGridViewTileBackgroundColor(this.category);

  @override
  Widget build(BuildContext context) {
    BudgetInstance? instance = category.activeInstance;
    if (instance == null) return const SizedBox.shrink();
    double heightFactor = 0;
    if (instance.number > 0) {
      heightFactor = (instance.number - instance.depense) / instance.number;
      if (heightFactor > 1) heightFactor = 1;
      if (heightFactor < 0) heightFactor = 0;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        color: BlingColor.scaffoldColor,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: AnimatedFractionallySizedBox(
              heightFactor: heightFactor,
              widthFactor: 1,
              duration: const Duration(seconds: 1),
              child: Container(color: category.color)
          ),
        ),
      ),
    );
  }
}