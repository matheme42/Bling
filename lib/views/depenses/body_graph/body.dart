part of spend_view;

class SpendBodyGraph extends StatelessWidget {
  const SpendBodyGraph({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    int currentDay = now.day;
    int dayInMonth = DateTime(now.year, now.month + 1, 0).day;
    int lessDay = dayInMonth - currentDay;

    var budgetCategoryController = Bling.of(context).budgetCategoryController;
    List<BudgetCategory> categories = budgetCategoryController.budgetCategories;

    double budgetRestant = 0;
    for (var c in categories) {
      if (c.activeInstance == null) continue ;
      budgetRestant += c.activeInstance!.number - c.activeInstance!.depense;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text('il reste $lessDay jour${lessDay > 1 ? "s" : ""}', style: const TextStyle(color: BlingColor.textColor, fontSize: 12)),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: categories.length,
                itemBuilder: (context, index) {
                BudgetCategory category = categories[index];
                return SpendCategoryGraph(category: category);
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text('Budget total restant:  ', style: TextStyle(color: BlingColor.textColor, fontSize: 12)),
                ),
                Text('${budgetRestant.toInt()} €', style: const TextStyle(color: BlingColor.textColor, fontWeight: FontWeight.bold, fontSize: 24)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}