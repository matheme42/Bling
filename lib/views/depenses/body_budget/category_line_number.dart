part of spend_view;

class CategoryLineNumber extends StatefulWidget {
  final BudgetCategory category;
  final Color? textColor;
  final void Function(BudgetCategory) onInsertNewCategories;

  const CategoryLineNumber({super.key, required this.category, this.textColor, required this.onInsertNewCategories});

  @override
  State<StatefulWidget> createState() => CategoryLineNumberState();
}

class CategoryLineNumberState extends State<CategoryLineNumber> {

  late TextEditingController controller;
  FocusNode node = FocusNode();
  double width = 0;
  static const hintText = "--";
  bool error = false;

  @override
  void initState() {
    super.initState();
    String? value = widget.category.id == null ? null : widget.category.number.toInt().toString();
    controller = TextEditingController(text: value);
    width = (value?.length ?? 0) * 10 + 30;
    if (value == null || value.isEmpty) {
      width = (hintText.length * 10) + 30;
    }
  }


  void recalculateWidth() {
    if (widget.category.id == null) return ;
    String value = widget.category.number.toInt().toString();
    controller.text = value;
    width = (value.length) * 10 + 30;
  }

  @override
  void didUpdateWidget(covariant CategoryLineNumber oldWidget) {
    if (oldWidget.textColor?.value != widget.textColor?.value) {
      recalculateWidth();
    }
    super.didUpdateWidget(oldWidget);
  }

  TextStyle get textStyle {
    Color redError = const Color(0xfff15a24);
    return TextStyle(
        color: error ? redError : widget.textColor,
        fontSize: 16,
        fontWeight: FontWeight.bold);
  }

  void onChange(String? value) {
    validator(value);
    value = controller.text;
    setState(() => width = (value?.length ?? 0) * 10 + 30);
    if (value.isEmpty) {
      width = (hintText.length * 10) + 30;
    }
  }

  void validator(String? value) {
    int? val;
    if (value?.isEmpty == true) {
      val = -1;
    } else {
      val = int.tryParse(value ?? "");
    }
    error = (val == null) ? true : false;
    if (val != null && val > 99999) controller.text = "999999";
    if (val != null && val < 0) controller.text = "0";
    onSubmit();
  }

  Future <void> onSubmit() async {
    BudgetCategory category = widget.category;
    Bling bling = Bling.of(context);
    if (error) return ;
    double value = double.parse(controller.text);
    category.number = value;
    if (category.id == null) return ;
    await bling.budgetCategoryController.update(category);
    if (category.activeInstance != null) {
      category.activeInstance!.number = value;
      await bling.budgetInstanceController.update(category.activeInstance!);
    }
  }

  Future <void> submitNewCategory() async {
    BudgetCategory category = widget.category;
    Bling bling = Bling.of(context);
    if (category.id != null) return ;
    validator(controller.text);
    if (error || category.name.isEmpty) {
      setState(() => error = false);
      return ;
    }
    await bling.budgetCategoryController.insert(category);
    widget.onInsertNewCategories(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 30,
      padding: const EdgeInsets.only(left: 8.0),
      alignment: Alignment.centerRight,
      child: Container(
          padding: const EdgeInsets.only(left: 4.0),
          decoration: BoxDecoration(
            color: widget.category.color,
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: TextField(
            onChanged: onChange,
            focusNode: node,
            controller: controller,
            textAlign: TextAlign.end,
            keyboardType: const TextInputType.numberWithOptions(),
            onTapOutside: (_) {
              if (node.hasFocus == false) return;
              controller.text = widget.category.number.toInt().toString();
              setState(() => error = false);
              submitNewCategory();
              node.unfocus();
            },
            onSubmitted: (_) => submitNewCategory(),
            style: textStyle,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(bottom: 10.0),
                suffixIcon: Text('€', style: textStyle),
                suffixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
                hintText: hintText,
                hintStyle: textStyle,
                suffixStyle: textStyle,
                border: InputBorder.none,
                disabledBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none),
          )),
    );
  }

}