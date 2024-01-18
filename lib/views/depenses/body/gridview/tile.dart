part of spend_view;

class SpendGridViewTile extends StatefulWidget {
  final BudgetCategory category;
  final AutoSizeGroup group;
  final Alignment alignment;
  final bool selected;
  final void Function(BudgetCategory?) onSelectedCategory;


  const SpendGridViewTile(
      {super.key,
        required this.category,
        required this.group,
        required this.onSelectedCategory,
        this.selected = false,
        required this.alignment
      });

  @override
  State<StatefulWidget> createState() => SpendGridViewTileState();
}

class SpendGridViewTileState extends State<SpendGridViewTile> {

  @override
  Widget build(BuildContext context) {
    if (widget.category.activeInstance == null) return const SizedBox.shrink();
    return Stack(
      children: [
        AnimatedAlign(
          alignment: widget.selected ? Alignment.centerLeft : widget.alignment,
          duration: const Duration(seconds: 1),
          child: UpperSpendGridViewTile(
              category: widget.category,
              group: widget.group,
              selected: widget.selected,
              onSelectedCategory: widget.onSelectedCategory
          ),
        ),
      ],
    );
  }
}