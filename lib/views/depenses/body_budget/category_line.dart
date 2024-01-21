part of spend_view;

class CategoryLine extends StatelessWidget {
  final BudgetCategory? category;

  const CategoryLine({super.key, required this.category});

  Color get textColor {
    if (category == null) return BlingColor.textColor.withAlpha(127);
    return BlingColor.textColor;
  }

  Color get iconColor {
    if (category == null) return Colors.transparent;
    return BlingColor.textColor.withAlpha(127);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Row(
        children: [
          Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
                color: category?.color,
                border: Border.all(color: BlingColor.borderColor),
                borderRadius: BorderRadius.circular(6.0)
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
                category?.name.capitalize() ?? "Nouvelle catégorie",
                style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                ),
                maxLines: 1),
          ),
          const Expanded(child: Divider(color: BlingColor.dividerColor)),
          Container(
            width: 65,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 4.0),
                  decoration: BoxDecoration(
                    color: category?.color,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                      category?.number.toInt().toString() ?? "--",
                      style: TextStyle(
                        color: textColor,
                          fontSize: 16, fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1),
                ),
                Text(
                    " €",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text("::", style: TextStyle(fontSize: 18, color: iconColor)),
          )
        ],
      ),
    );
  }

}