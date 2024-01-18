import 'package:auto_size_text/auto_size_text.dart';
import 'package:bling/main.dart';
import 'package:bling/models/budgetcategory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class BudgetCategoryBottomSheet extends StatefulWidget {
  final BudgetCategory? budgetCategory;

  const BudgetCategoryBottomSheet({super.key, this.budgetCategory});

  static Future<void> show(BuildContext context, onBudgetAddedOrEdit,
      {BudgetCategory? budgetCategory}) async {
    var data = await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.brown[400],
        elevation: 8.0,
        clipBehavior: Clip.hardEdge,
        isDismissible: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
        builder: (context) =>
            BudgetCategoryBottomSheet(budgetCategory: budgetCategory));
    if (data != null) {
      if (data == true) {
        onBudgetAddedOrEdit();
        return;
      }
      onBudgetAddedOrEdit(data);
    }
  }

  @override
  State<StatefulWidget> createState() => BudgetCategoryBottomSheetState();
}

class BudgetCategoryBottomSheetState extends State<BudgetCategoryBottomSheet> {
  void onTapOutSide() {
    FocusScopeNode node = FocusScope.of(context);
    if (node.hasFocus) {
      node.unfocus();
      dragController.animateTo(0.5,
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
      return;
    }
  }

  late TextEditingController nameController;
  late TextEditingController iconController;
  Color selectedColor = Colors.brown;

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.budgetCategory?.name ?? "");
    iconController =
        TextEditingController(text: widget.budgetCategory?.icon ?? "🐷");
  }

  final _formKey = GlobalKey<FormState>();

  static DraggableScrollableController dragController =
      DraggableScrollableController();

  String? validatorName(String? fieldByUser) {
    // check for duplicateSection
    if (fieldByUser == null || fieldByUser.isEmpty) {
      return "ne peut pas etre vide";
    }
    if (fieldByUser.length < 3) {
      return "ne peut pas etre si court (min 3)";
    }

    for (var elm
        in Bling.of(context).budgetCategoryController.budgetCategories) {
      if (elm.name == fieldByUser &&
          widget.budgetCategory?.name != fieldByUser) {
        return "la category $fieldByUser existe déjà";
      }
    }

    return null;
  }

  static final RegExp regexEmoji = RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');

  String? validatorIcon(String? fieldByUser) {
    // check for duplicateSection
    if (fieldByUser == null || fieldByUser.isEmpty) {
      return "ne peut pas etre vide";
    }
    if (regexEmoji.firstMatch(fieldByUser)?.input.length !=
        fieldByUser.length) {
      return "doit etre un emoji";
    }
    return null;
  }

  Future<void> onSubmit() async {
    if (_formKey.currentState!.validate()) {
      BudgetCategoryController controller =
          Bling.of(context).budgetCategoryController;
      BudgetCategory budgetCategory = widget.budgetCategory ??
          await controller.getByName(nameController.text) ??
          BudgetCategory();
      budgetCategory.enable = true;
      budgetCategory.icon = iconController.text;
      budgetCategory.name = nameController.text;
      if (budgetCategory.id != null) {
        controller.update(budgetCategory).then((value) {
          Navigator.pop(context, true);
        });
        return;
      }
      budgetCategory.number = 0.0;
      budgetCategory.color = selectedColor;
      controller.insert(budgetCategory).then((value) {
        Navigator.pop(context, true);
      });
    }
  }

  void onDelete() {
    Bling.of(context)
        .budgetCategoryController
        .delete(widget.budgetCategory!)
        .then((value) {
      Navigator.pop(context, value);
    });
  }

  void onDisable() {
    widget.budgetCategory!.enable = false;
    Bling.of(context)
        .budgetCategoryController
        .update(widget.budgetCategory!)
        .then((value) {
      Bling.of(context)
          .budgetCategoryController
          .budgetCategories
          .remove(widget.budgetCategory);
      Navigator.pop(context, value);
    });
  }

  Future<void> showColorSelector() async {
    await showDialog(
        context: context,
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.9,
            widthFactor: 0.9,
            child: Material(
              borderRadius: BorderRadius.circular(32),
              clipBehavior: Clip.hardEdge,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: ColorPicker(
                            pickerAreaBorderRadius: BorderRadius.circular(32),
                            pickerColor:
                                widget.budgetCategory?.color ?? selectedColor,
                            onColorChanged: (value) {
                              if (widget.budgetCategory != null) {
                                setState(
                                        () => widget.budgetCategory?.color = value);
                              }
                              setState(() => selectedColor = value);
                            }),
                      ),
                    ),
                    MaterialButton(
                      color: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Valider'),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        onTapOutSide();
        return true;
      },
      child: Form(
        key: _formKey,
        child: DraggableScrollableSheet(
            expand: false,
            controller: dragController,
            builder: (context, scrollController) {
              AutoSizeGroup group = AutoSizeGroup();
              return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.18,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => showColorSelector(),
                            child: SizedBox(
                              height: 60,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black54),
                                      borderRadius: BorderRadius.circular(4.0),
                                      color: widget.budgetCategory?.color ??
                                          selectedColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              onTapOutside: (_) => onTapOutSide(),
                              keyboardType: TextInputType.text,
                              cursorColor: Colors.brown,
                              onTap: () {
                                dragController.animateTo(1,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease);
                              },
                              controller: nameController,
                              onEditingComplete: () => onTapOutSide(),
                              onFieldSubmitted: (_) => onTapOutSide(),
                              validator: validatorName,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white12,
                                suffixIcon: const Icon(Icons.text_fields),
                                label: Stack(
                                  children: [
                                    // Implement the stroke
                                    Text(
                                      "Name",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        foreground: Paint()
                                          ..style = PaintingStyle.stroke
                                          ..strokeWidth = 1
                                          ..color = Colors.white54,
                                      ),
                                    ),
                                    // The text inside
                                    const Text(
                                      "Name",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.brown,
                                      ),
                                    ),
                                  ],
                                ),
                                labelStyle:
                                    const TextStyle(color: Colors.brown),
                                suffixIconColor: Colors.brown,
                                prefixIconColor: Colors.brown,
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.brown, width: 2)),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.18,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              onTapOutside: (_) => onTapOutSide(),
                              keyboardType: TextInputType.text,
                              cursorColor: Colors.brown,
                              onTap: () {
                                dragController.animateTo(1,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease);
                              },
                              controller: iconController,
                              onEditingComplete: () => onTapOutSide(),
                              onFieldSubmitted: (_) => onTapOutSide(),
                              validator: validatorIcon,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white12,
                                suffixIcon: const Icon(Icons.insert_emoticon),
                                label: Stack(
                                  children: [
                                    // Implement the stroke
                                    Text(
                                      "Icon",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        foreground: Paint()
                                          ..style = PaintingStyle.stroke
                                          ..strokeWidth = 1
                                          ..color = Colors.white54,
                                      ),
                                    ),
                                    // The text inside
                                    const Text(
                                      "Icon",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.brown,
                                      ),
                                    ),
                                  ],
                                ),
                                labelStyle:
                                    const TextStyle(color: Colors.brown),
                                suffixIconColor: Colors.brown,
                                prefixIconColor: Colors.brown,
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.brown, width: 2)),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: MaterialButton(
                                color: Colors.brown,
                                textColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                onPressed: () async {
                                  final clipboardData = await Clipboard.getData(
                                      Clipboard.kTextPlain);
                                  String? clipboardText = clipboardData?.text;
                                  iconController.text = clipboardText ?? "";
                                },
                                child: const Text('Coller',
                                    style: TextStyle(color: Colors.black87))),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Spacer(flex: 7),
                        Flexible(
                          flex: 6,
                          child: Center(
                            child: MaterialButton(
                                color: Colors.green,
                                textColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                onPressed: () => onSubmit(),
                                child: Center(
                                  child: AutoSizeText('OK',
                                      style: const TextStyle(
                                          color: Colors.black87),
                                      maxLines: 1,
                                      group: group),
                                )),
                          ),
                        ),
                        const Spacer(),
                        Flexible(
                          flex: 6,
                          child: Center(
                            child: Visibility(
                              visible: widget.budgetCategory != null,
                              child: MaterialButton(
                                  color: Colors.orange,
                                  textColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0)),
                                  onPressed: () => onDisable(),
                                  child: Center(
                                    child: AutoSizeText('Desactiver',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        group: group),
                                  )),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }),
      ),
    );
  }
}
