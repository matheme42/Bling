part of spend_view;

class SpendBodyBudget extends StatefulWidget {
  const SpendBodyBudget({super.key});

  @override
  State<StatefulWidget> createState() => SpendBodyBudgetState();
}

class SpendBodyBudgetState extends State<SpendBodyBudget> {

  @override
  Widget build(BuildContext context) {
    var budgetCategoryController = Bling.of(context).budgetCategoryController;
    List<BudgetCategory> categories = budgetCategoryController.budgetCategories;

    double budget = 0;
    for (var c in categories) {
      budget += c.number;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text("Catégories", style: TextStyle(color: BlingColor.textColor, fontSize: 24)),
          ),
          Expanded(
              child: ListView.builder(
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                bool overflow = (index == categories.length);
                BudgetCategory? category = overflow ? null : categories[index];
                return CategoryLine(category: category);
              })),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(children: [
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('Budget dépenses:        ', style: TextStyle(color: BlingColor.textColor)),
              ),
              Text("${budget.toInt()}€", style: const TextStyle(color: BlingColor.textColor, fontWeight: FontWeight.bold, fontSize: 24)),
            ]),
          ),
          const Divider(color: BlingColor.dividerColor),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              const Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 2.0),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text('Total épargné: --  ', style: TextStyle(color: Color(0xffbab4a8))),
                    ),
                    Text('€', style: TextStyle(color: Color(0xffbab4a8), fontSize: 24))
                  ],
                ),
              ),
              MaterialButton(
                  onPressed: (){},
                visualDensity: VisualDensity.compact,
                minWidth: 20,
                height: 12,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: const BorderSide(color: BlingColor.disableButtonColor)),
                child: const Text('Définir un revenu', style: TextStyle(color: BlingColor.disableButtonColor, fontSize: 12)),
              )
            ]),
          ),
        ],
      ),
    );
  }
}