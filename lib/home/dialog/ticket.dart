import 'package:barcode/barcode.dart';
import 'package:bling/home/dialog/drop_down.dart';
import 'package:bling/main.dart';
import 'package:bling/models/budgetcategory.dart';
import 'package:bling/models/depense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Ticket extends StatefulWidget {
  const Ticket({super.key});

  @override
  State<StatefulWidget> createState() => TicketState();
}

class TicketState extends State<Ticket> {
  static final Widget svgBarCode = SvgPicture.string(
    Barcode.code128()
        .toSvg('Bling Depense', width: 200, height: 60, drawText: false),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        FocusScope.of(context).unfocus();
      });
    });
  }

  TextEditingController libelleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  BudgetCategory budgetCategorySelected = BudgetCategory();

  void onBudgetSelect(BudgetCategory category) {
    budgetCategorySelected = category;
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool error = false;

  void onSubmit() {
    error = !formKey.currentState!.validate();
    if (!error == true) {
      Depense d = Depense();
      d.number = double.parse(priceController.text);
      d.budgetInstanceId = budgetCategorySelected.activeInstance!.id!;
      d.labelle = libelleController.text;
      d.associatedInstance = budgetCategorySelected.activeInstance;
      d.associatedInstance!.spends.add(d);
      d.associatedInstance!.depense += d.number;
      Bling.of(context).depenseController.insert(d);
      Navigator.pop(context);
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: FocusScope.of(context).hasFocus == false,
      onPopInvoked: (value) => FocusScope.of(context).unfocus(),
      child: Form(
        key: formKey,
        child: Center(
          child: FractionallySizedBox(
            heightFactor: error ? 1 : 0.7,
            widthFactor: 0.8,
            child: Center(
              child: SingleChildScrollView(
                child: Card(
                  elevation: 16,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text('Bling depense',
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                fontSize: 20)),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: libelleController,
                            validator: (value) {
                              if (value == null || value.length < 3) {
                                return "le labelle n'est pas assez long";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                labelText: "Libelle",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0.0))),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Ticket de vente',
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20)),
                        ),
                        DropdownItem(onBudgetSelect: onBudgetSelect),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true, signed: true),
                            controller: priceController,
                            validator: (source) {
                              double? value = double.tryParse(source ?? '');
                              if (value == null || value == 0) {
                                return "valeur incorrect";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                labelText: "0.00",
                                suffixIcon: const Icon(Icons.euro),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0.0))),
                          ),
                        ),
                        svgBarCode,
                        MaterialButton(
                          onPressed: onSubmit,
                          color: Colors.green,
                          child: const Text('Ajouter'),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
