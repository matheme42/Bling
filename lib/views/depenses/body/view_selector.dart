part of spend_view;

class ViewSelector extends StatelessWidget {
  final int index;
  final void Function(int) onChange;

  const ViewSelector({super.key, required this.index, required this.onChange});

  Color getColor(int buttonIndex) {
    if (buttonIndex == index) return BlingColor.enableButtonColor;
    return BlingColor.disableButtonColor;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Text('Vue:', style: TextStyle(fontWeight: FontWeight.bold, color: BlingColor.textColor)),
          ),
          MaterialButton(
            onPressed: () => onChange(0),
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            minWidth: 40,
            height: 30,
            textColor: getColor(0),
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: getColor(0)),
                borderRadius: BorderRadius.circular(6.0)
            ),
            child: const Text('Categories', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
              height: 20,
              child: const VerticalDivider(width: 1,color: BlingColor.dividerColor)),
          MaterialButton(
            onPressed: () => onChange(1),
            minWidth: 40,
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            textColor: getColor(1),
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: getColor(1)),
                borderRadius: BorderRadius.circular(6.0)
            ),
            child: const Text('Dépenses', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

}