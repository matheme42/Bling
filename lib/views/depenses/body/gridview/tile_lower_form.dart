part of spend_view;

class LowerFormSpendGridViewTile extends StatefulWidget {
  final BudgetCategory category;
  final Function(Depense) onSubmitDepense;

  const LowerFormSpendGridViewTile({super.key, required this.category, required this.onSubmitDepense});

  @override
  State<StatefulWidget> createState() => FormSpendGridViewTileState();
}

class FormSpendGridViewTileState extends State<LowerFormSpendGridViewTile> {

  GlobalKey<FormState> formKey = GlobalKey();

  DateTime selectedDate = DateTime.now();

  FocusNode nodeLabel = FocusNode();
  FocusNode nodeNumber = FocusNode();
  FocusNode nodeDate = FocusNode();

  TextEditingController labelController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  late TextEditingController dateController;

  void onWantAddSpend() {
    if (formKey.currentState?.validate() != true) return ;
    // create depense
    Depense d = Depense();
    d.number = double.parse(numberController.text);
    d.budgetInstanceId = widget.category.activeInstance!.id!;
    d.labelle = labelController.text;
    d.date = selectedDate;
    d.associatedInstance = widget.category.activeInstance;
    widget.onSubmitDepense(d);
  }

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController(text: convertSelectedDateToString);
  }

  String get convertSelectedDateToString {
    return "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year.toString().substring(2)}";
  }

  Future <void> onClickDate() async {
    var currentDate = DateTime.now();
    DateTime? picked = await showDatePicker(
        context: context,
        currentDate: currentDate,
        firstDate: DateTime(currentDate.year, currentDate.month),
        lastDate: DateTime(currentDate.year, currentDate.month, DateTime(currentDate.year, currentDate.month + 1, 0).day),
        initialDate: selectedDate
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = convertSelectedDateToString;
      });
    }
  }

  String? validatorLabel(String? value) {
    if (value == null || value.isEmpty) return "ne peut etre vide";
    if (value.length < 3) return "trop court minimum 3";
    return null;
  }

  String? validatorNumber(String? value) {
    if (value == null || value.isEmpty) return "ne peut etre vide";
    double? val = double.tryParse(value);
    if (val == null) return "valeur incorrect";
    if (val == 0) return "ne peut etre égal à zero";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
        padding: const EdgeInsets.only(left: 4.0, right: 8.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Nouvelle dépense:", style: TextStyle(fontSize: 10, color: BlingColor.textColor), textAlign: TextAlign.left)),
                ),
                TextFormField(
                  controller: labelController,
                  focusNode: nodeLabel,
                  style: const TextStyle(fontSize: 12),
                  onTapOutside: (_) => nodeLabel.unfocus(),
                  cursorColor: BlingColor.borderColor,
                  validator: validatorLabel,
                  decoration: InputDecoration(
                    hintText: "Encore un kébab ?",
                    focusColor: BlingColor.borderColor,
                    focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: BlingColor.borderColor)
                    ),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: BlingColor.borderColor)
                    ),
                    enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: BlingColor.borderColor)
                    ),
                    errorMaxLines: 1,
                    errorStyle: const TextStyle(fontStyle: FontStyle.italic, fontSize: 10, height: 0.1),
                    hintStyle: TextStyle(fontSize: 12, color: BlingColor.textColor.withAlpha(127)),
                    isDense: true,
                    contentPadding: EdgeInsets.zero
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8.0, right: 12.0,),
                  child: Text('Montant:', style: TextStyle(color: BlingColor.textColor, fontSize: 11)),
                ),
                Expanded(
                  child: TextFormField(
                    focusNode: nodeNumber,
                    controller: numberController,
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.right,
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    onTapOutside: (_) => nodeNumber.unfocus(),
                    cursorColor: BlingColor.borderColor,
                    validator: validatorNumber,
                    decoration: InputDecoration(
                        hintText: "7,00€",
                        hintStyle: TextStyle(fontSize: 12, color: BlingColor.textColor.withAlpha(127)),
                        hintTextDirection: TextDirection.rtl,
                        isDense: true,
                        errorMaxLines: 1,
                        errorStyle: const TextStyle(fontStyle: FontStyle.italic, fontSize: 0, height: 0.1),
                        focusColor: BlingColor.borderColor,
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: BlingColor.borderColor)
                        ),
                        border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: BlingColor.borderColor)
                        ),
                        enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: BlingColor.borderColor)
                        ),
                        contentPadding: EdgeInsets.zero
                    ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8.0, right: 12.0),
                  child: Text('Date:', style: TextStyle(color: BlingColor.textColor, fontSize: 11)),
                ),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    onTap: () => onClickDate(),
                    focusNode: nodeDate,
                    controller: dateController,
                    onTapOutside: (_) => nodeDate.unfocus(),
                    style: const TextStyle(fontSize: 10, color: BlingColor.textColor),
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                        isDense: true,
                        focusColor: BlingColor.borderColor,
                        focusedBorder: InputBorder.none,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero
                    ),
                  ),
                ),
              ],
            ),
            MaterialButton(
                onPressed: () => onWantAddSpend(),
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 32.0),
                minWidth: 20,
                height: 20,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                    side: const BorderSide(color: BlingColor.borderColor)
                ),
                color: widget.category.color,
              visualDensity: VisualDensity.compact,
                child: const Text('Ajouter', style: TextStyle(fontSize: 10)),
            )
          ],
        ),
      ),
    );
  }

}