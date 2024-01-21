library spend_view;

import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bling/color.dart';
import 'package:bling/home/body/budget_definition/body.dart';
import 'package:bling/main.dart';
import 'package:bling/models/budget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/budgetcategory.dart';
import '../../models/budgetinstance.dart';
import '../../models/depense.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';

part 'bottom_navigation_bar.dart';
part 'body_depenses/body.dart';
part 'body_depenses/view_selector.dart';
part 'body_depenses/gridview/grid_view.dart';
part 'body_depenses/gridview/tile.dart';
part 'body_depenses/gridview/tile_upper.dart';
part 'body_depenses/gridview/tile_lower_right.dart';
part 'body_depenses/gridview/tile_lower_left.dart';
part 'body_depenses/gridview/tile_lower_form.dart';
part 'body_depenses/listview/list_view.dart';
part 'body_depenses/listview/category_selector.dart';
part 'body_depenses/listview/list_tile.dart';

part 'body_graph/body.dart';
part 'body_graph/category_graph.dart';

part 'body_budget/body.dart';
part 'body_budget/category_line.dart';

class SpendView extends StatefulWidget {
  const SpendView({super.key});

  @override
  State<StatefulWidget> createState() => SpendViewState();
}

class SpendViewState extends State<SpendView> {

  int selectedView = 1;
  PageController pageController = PageController(initialPage: 1);

  void onItemTap(int index) {
    setState(() {
      selectedView = index;
    });
    pageController.jumpToPage(index);
  }

  String get pageViewTitle {
    switch (selectedView) {
      case 0:
        return "Définition\ndu budget";
      case 1:
        return "Tableau\ndes dépenses";
      case 2 :
        return "Graphiques\ndes dépenses";
    }
    return "";
  }

  static const List<String> _months = [
    "Janvier",
    "février",
    "mars",
    "avril",
    "mai",
    "juin",
    "juillet",
    "août",
    "septembre",
    "octobre",
    "novembre",
    "décembre"
  ];

  String get subtitle {
    DateTime now = DateTime.now();
    return "${_months[now.month - 1]} ${now.year}";
  }

  @override
  Widget build(BuildContext context) {
    Size mediaSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 16,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: mediaSize.height * 0.2,
          backgroundColor: BlingColor.appBarColor,
          centerTitle: false,
          bottom: const PreferredSize(
            preferredSize: Size.zero,
            child: Divider(height: 1, color: BlingColor.dividerColor),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pageViewTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: BlingColor.titleTextColor)),
                  MaterialButton(
                    onPressed: (){},
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(color: BlingColor.disableButtonColor)
                    ),
                    child: const Text('Historique', style: TextStyle(color: BlingColor.disableButtonColor)),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(subtitle, style: const TextStyle(fontSize: 12, color: BlingColor.textColor)),
              ),
            ],
          ),
        ),
        backgroundColor: BlingColor.scaffoldColor,
        body: PageView(
          controller: pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            SpendBodyBudget(),
            SpendBody(),
            SpendBodyGraph()
          ],
        ),
        bottomNavigationBar: SpendBottomNavigationBar(
          onItemTap: onItemTap,
          index: selectedView
        ),
      ),
    );
  }
}

