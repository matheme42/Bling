part of spend_view;

class SpendCategoryGraph extends StatelessWidget {
  final BudgetCategory category;

  const SpendCategoryGraph({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    BudgetInstance? instance = category.activeInstance;
    if (instance == null) return const SizedBox.shrink();
    int depense = (instance.number - instance.depense).toInt();
    Color redError = const Color(0xfff15a24);
    double ratio = depense / instance.number;
    if (ratio < 0) ratio = 0;
    if (ratio > 1) ratio = 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.name, style: const TextStyle(color: BlingColor.textColor, fontWeight: FontWeight.w600, fontSize: 16)),
          Container(
            clipBehavior: Clip.hardEdge,
            height: 25,
            decoration: BoxDecoration(
              border: Border.all(color: depense < 0 ? redError : BlingColor.borderColor),
              borderRadius: BorderRadius.circular(6)
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                FractionallySizedBox(
                  widthFactor: ratio,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                        color: category.color,
                        borderRadius: BorderRadius.circular(5)
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(depense.toString(), style: TextStyle(color: depense < 0 ? redError : BlingColor.textColor, fontSize: 12, fontWeight: FontWeight.w600)),
                          Text("/${instance.number.toInt().toString()}€", style: TextStyle(color: depense < 0 ? redError : BlingColor.textColor, fontSize: 12)),
                        ]),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

}