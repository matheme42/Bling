part of spend_view;

class CategoryLineLabel extends StatefulWidget {
  final BudgetCategory category;
  final Color textColor;
  final void Function(BudgetCategory) onInsertNewCategories;

  const CategoryLineLabel(
      {super.key,
      required this.category,
      required this.textColor,
      required this.onInsertNewCategories});

  @override
  State<StatefulWidget> createState() => CategoryLineLabelState();
}

class CategoryLineLabelState extends State<CategoryLineLabel> {
  late TextEditingController controller;
  FocusNode nod = FocusNode();
  double width = 0;
  bool error = false;

  @override
  void initState() {
    super.initState();
    String? value =
        widget.category.id == null ? null : widget.category.name.capitalize();
    controller = TextEditingController(text: value);
    width = textWidth(value ?? "Nouvelle catégorie");
  }

  TextStyle get textStyle {
    Color redError = const Color(0xfff15a24);
    return TextStyle(
        color: error ? redError : widget.textColor,
        fontSize: 16,
        fontWeight: FontWeight.w500);
  }

  double textWidth(String value) {
    RenderParagraph renderParagraph = RenderParagraph(
      TextSpan(text: value, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    return renderParagraph.getMinIntrinsicWidth(16).ceilToDouble() * 1.2 + 10;
  }

  void onChange(String? value) {
    if (controller.text.isNotEmpty) {
      controller.text = controller.text.capitalize();
    }
    setState(() => width = textWidth(value ?? "Nouvelle catégorie"));
    validator(value);
  }

  void validator(String? value) {
    if (value == null || value.length < 3) {
      setState(() => error = true);
      return;
    }
    var lst = Bling.of(context).budgetCategoryController.budgetCategories;
    for (var element in lst) {
      if  (element == widget.category) continue ;
        if (element.name == value) {
          setState(() => error = true);
          return ;
        }
    }
    setState(() => error = false);
    submit();
  }

  Future<void> submit() async {
    BudgetCategory category = widget.category;
    Bling bling = Bling.of(context);
    if (error) return;
    category.name = controller.text;
    if (category.id == null)  return ;
    await bling.budgetCategoryController.update(category);
  }

  Future <void> onSubmit() async {
    BudgetCategory category = widget.category;
    Bling bling = Bling.of(context);
    if (category.id != null) return ;
    validator(controller.text);
    if (error) {
      if (controller.text.isEmpty) onChange(null);
      return ;
    }
    await bling.budgetCategoryController.insert(category);
    widget.onInsertNewCategories(category);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double localWidth = constraints.maxWidth;
      double dividerWidth = localWidth - width;
      double textFormWidth = width > localWidth ? localWidth : width;
      if (dividerWidth < 0) dividerWidth = 0;
      return SingleChildScrollView(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: textFormWidth,
              child: TextFormField(
                focusNode: nod,
                style: textStyle,
                controller: controller,
                onFieldSubmitted: (_) => onSubmit(),
                onTapOutside: (_) {
                  if (nod.hasFocus == false) return;
                  controller.text = widget.category.name;
                  setState(() => error = false);
                  onSubmit();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    nod.unfocus();
                  });
                },
                onChanged: onChange,
                decoration: InputDecoration(
                    hintText: widget.category.id == null
                        ? "Nouvelle catégorie"
                        : null,
                    hintStyle: textStyle,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none),
              ),
            ),
            SizedBox(
              width: dividerWidth,
              height: 40,
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Divider(color: BlingColor.dividerColor),
              ),
            ),
          ],
        ),
      );
    });
  }
}
