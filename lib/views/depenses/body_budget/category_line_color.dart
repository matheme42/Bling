part of spend_view;

class CategoryLineColor extends StatefulWidget {
  final BudgetCategory category;
  final void Function(Color) onColorChange;

  const CategoryLineColor({super.key, required this.category, required this.onColorChange});

  static Future<dynamic> show(BuildContext context, BudgetCategory category, void Function(Color) onColorChange) async {
    return await showModalBottomSheet(
      backgroundColor: BlingColor.scaffoldColor,
        context: context, builder: (context) {
          return CategoryLineColor(
              category: category,
              onColorChange: onColorChange
          );
        });
  }

  @override
  State<StatefulWidget> createState() => CategoryLineColorState();
}


class CategoryLineColorState extends State<CategoryLineColor> {

  Color color = Colors.transparent;

  @override
  void initState() {
    super.initState();
    color =  widget.category.color;
  }

  void onColorChange(Color c) {
    widget.onColorChange(c);
    setState(() => color = c);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Column(
        children: [
          Text(widget.category.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500
          ),
          ),
          HueRingPicker(
              colorPickerHeight: 200,
              enableAlpha: false,
              portraitOnly: true,
              displayThumbColor: false,
              pickerColor: color,
              pickerAreaBorderRadius: BorderRadius.circular(6),
              onColorChanged: onColorChange),
        ],
      )
    );
  }

}