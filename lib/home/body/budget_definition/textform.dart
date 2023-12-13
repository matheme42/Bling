import 'package:flutter/material.dart';

class BudgetTextForm extends StatelessWidget {
  final Widget? prefixIcon;
  final String? label;
  final double? globalBudget;
  final double? value;
  final Color color;
  final Function(double?) onChange;
  final bool sliderOff;

  const BudgetTextForm(
      {super.key,
      this.prefixIcon,
      this.label,
      required this.globalBudget,
      required this.onChange,
      required this.value,
      this.sliderOff = false,
      required this.color});

  void onCompletionChange(
      TextEditingController controller, FocusScopeNode node) {
    node.unfocus();
    double? value = double.tryParse(controller.text);
    if (value == null) controller.clear();
    onChange(value);
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controller =
        TextEditingController(text: value?.toStringAsFixed(2));
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
      child: Builder(builder: (context) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextFormField(
                    onTapOutside: (_) =>
                        onCompletionChange(controller, FocusScope.of(context)),
                    keyboardType: TextInputType.number,
                    cursorColor: Colors.brown,
                    controller: controller,
                    onEditingComplete: () =>
                        onCompletionChange(controller, FocusScope.of(context)),
                    onFieldSubmitted: (_) =>
                        onCompletionChange(controller, FocusScope.of(context)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white54,
                      prefixIcon: SizedBox(
                          height: 20,
                          width: 20,
                          child: Center(child: prefixIcon)),
                      suffixIcon: const Icon(Icons.euro),
                      label: Stack(
                        children: [
                          // Implement the stroke
                          Text(
                            label ?? "",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2
                                ..color = Colors.white54,
                            ),
                          ),
                          // The text inside
                          Text(
                            label ?? "",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                          ),
                        ],
                      ),
                      suffixIconColor: Colors.brown,
                      prefixIconColor: Colors.brown,
                      focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.brown, width: 2)),
                      enabledBorder:  OutlineInputBorder(
                        borderSide: BorderSide(
                          color: color
                        )
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
