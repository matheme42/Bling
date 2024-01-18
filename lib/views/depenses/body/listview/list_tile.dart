part of spend_view;

class SpendListTile extends StatelessWidget {
  final Depense depense;

  const SpendListTile({super.key, required this.depense});

  String convertSelectedDateToString(DateTime? time) {
    if (time == null) return "";
    return "${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}/${time.year.toString().substring(2)}";
  }

  @override
  Widget build(BuildContext context) {
    var budgetController = Bling.of(context).budgetCategoryController;
    var budgetCategories = budgetController.budgetCategories;
    BudgetCategory? budgetCategory;
    try {
      budgetCategory = budgetCategories.where((e) => e.id == depense.associatedInstance!.categoryId).first;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.only(right: 4.0, left: 8.0, bottom: 4.0, top: 4.0),
      decoration: BoxDecoration(
        color: budgetCategory?.color ?? BlingColor.scaffoldColor,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: BlingColor.borderColor)
      ),
      child: Row(
        children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${convertSelectedDateToString(depense.date)}  -  ${budgetCategory?.name ?? ""}',
              style: const TextStyle(fontSize: 10),
              ),
              Text(depense.labelle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))
            ],
          )),
          Text(
              "${depense.number.toStringAsFixed(2).replaceAll('.', ',')} €",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)
          )
        ],
      ),
    );
  }
}