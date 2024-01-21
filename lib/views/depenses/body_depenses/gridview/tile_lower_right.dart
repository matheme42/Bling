part of spend_view;

class LowerSpendGridViewTileRight extends StatefulWidget {
  final bool visible;
  final BudgetCategory category;
  final Function(Depense) onSubmitDepense;

  const LowerSpendGridViewTileRight(
      {super.key, required this.visible, required this.category, required this.onSubmitDepense});

  @override
  State<StatefulWidget> createState() => LowerSpendGridViewTileRightState();
}

class LowerSpendGridViewTileRightState
    extends State<LowerSpendGridViewTileRight> {
  bool hider = true;
  bool visible = false;

  Timer? timer;

  @override
  void didUpdateWidget(covariant LowerSpendGridViewTileRight oldWidget) {
    if (oldWidget.visible == false && widget.visible == true) {
      hider = true;
      visible = true;
      timer?.cancel();
      timer = Timer(const Duration(milliseconds: 300), () {
        timer = null;
        hider = false;
        if (!mounted) return ;
        setState(() {});
      });
    }
    if (oldWidget.visible == true && widget.visible == false) {
      timer?.cancel();
      timer = Timer(const Duration(milliseconds: 300), () {
        hider = true;
        if (!mounted) return ;
        timer = Timer(const Duration(milliseconds: 700), () {
          timer = null;
          visible = false;
          if (!mounted) return ;
          setState(() {});
        });
        setState(() {});
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Visibility(
          visible: visible,
          child: FractionallySizedBox(
              widthFactor: 1,
              child: AspectRatio(
                  aspectRatio: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                          border: Border.all(color: BlingColor.borderColor),
                          color: widget.category.color.withAlpha(127),
                          borderRadius: BorderRadius.circular(16.0)),
                      child: FractionallySizedBox(
                          widthFactor: 0.5,
                          alignment: Alignment.centerRight,
                          child: LowerFormSpendGridViewTile(
                              category: widget.category,
                              onSubmitDepense: widget.onSubmitDepense)),
                    ),
                  ))),
        ),
        Visibility(
            visible: hider,
            child: Center(
              child: FractionallySizedBox(
                  widthFactor: 0.25,
                  child: AspectRatio(
                      aspectRatio: 0.5,
                      child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            color: BlingColor.scaffoldColor,
                          )))),
            ))
      ],
    );
  }
}
