part of spend_view;

class LowerSpendGridViewTileLeft extends StatefulWidget {
  final bool visible;
  final Widget? child;
  final bool animatedClose;
  final BudgetCategory category;
  final Function(Depense) onSubmitDepense;

  const LowerSpendGridViewTileLeft(
      {super.key,
      required this.visible,
      this.child,
      required this.animatedClose,
      required this.category, required this.onSubmitDepense});

  @override
  State<StatefulWidget> createState() => LowerSpendGridViewTileLeftState();
}

class LowerSpendGridViewTileLeftState
    extends State<LowerSpendGridViewTileLeft> {
  bool visible = false;
  Alignment alignment = Alignment.centerLeft;
  bool hider = false;

  Timer? timer;

  @override
  void didUpdateWidget(covariant LowerSpendGridViewTileLeft oldWidget) {
    if (oldWidget.visible == false && widget.visible == true) {
      visible = true;
      alignment = Alignment.centerRight;
      timer?.cancel();
      timer = Timer(const Duration(milliseconds: 300), () {
        timer = null;
        hider = true;
        if (!mounted) return ;
        setState(() {});
      });
    }
    if (oldWidget.visible == true && widget.visible == false) {
      alignment = Alignment.centerLeft;
      timer?.cancel();
      timer = Timer(const Duration(milliseconds: 300), () {
        setState(() => hider = false);
        timer = Timer(const Duration(milliseconds: 700), () {
          timer = null;
          visible = false;
          if (!mounted) return ;
          setState(() {});
        });
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Visibility(
            visible: hider && widget.animatedClose,
            child: Center(
              child: FractionallySizedBox(
                  widthFactor: 0.25,
                  child: AspectRatio(
                      aspectRatio: 0.5,
                      child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: BlingColor.borderColor),
                              color: widget.category.color.withAlpha(127),
                            ),
                          )))),
            )),
        AnimatedAlign(
          alignment: alignment,
          duration: const Duration(seconds: 1),
          child: Visibility(
            visible: visible && widget.animatedClose,
            child: FractionallySizedBox(
                widthFactor: 0.5,
                child: AspectRatio(
                    aspectRatio: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(
                            color: BlingColor.scaffoldColor,
                            border: Border(
                                top: BorderSide(color: BlingColor.borderColor),
                                right: BorderSide(color: BlingColor.borderColor),
                                bottom: BorderSide(color: BlingColor.borderColor)),
                            borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(16.0))),
                        child: Container(
                          color: widget.category.color.withAlpha(127),
                          child: LowerFormSpendGridViewTile(
                              category: widget.category,
                              onSubmitDepense: widget.onSubmitDepense
                          ),
                        ),
                      ),
                    ))),
          ),
        ),
        Visibility(
            visible: visible && widget.animatedClose,
            child: FractionallySizedBox(
                widthFactor: 0.25,
                child: AspectRatio(
                    aspectRatio: 0.5,
                    child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: BlingColor.scaffoldColor,
                          ),
                        ))))),
        Visibility(
          visible: visible && widget.animatedClose,
          child: widget.child ?? const SizedBox.shrink(),
        )
      ],
    );
  }
}
