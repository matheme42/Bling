library spend_view;

import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bling/color.dart';
import 'package:bling/home/body/budget_definition/body.dart';
import 'package:bling/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/budgetcategory.dart';
import '../../models/budgetinstance.dart';
import '../../models/depense.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';

part 'bottom_navigation_bar.dart';
part 'body/body.dart';
part 'body/view_selector.dart';
part 'body/gridview/grid_view.dart';
part 'body/gridview/tile.dart';
part 'body/gridview/tile_upper.dart';
part 'body/gridview/tile_lower_right.dart';
part 'body/gridview/tile_lower_left.dart';
part 'body/gridview/tile_lower_form.dart';
part 'body/listview/list_view.dart';
part 'body/listview/category_selector.dart';
part 'body/listview/list_tile.dart';

class SpendView extends StatelessWidget {
  const SpendView({super.key});

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
                  const Text("Tableau\ndes dépenses", style: TextStyle(fontWeight: FontWeight.bold, color: BlingColor.titleTextColor)),
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
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text('Janvier 2024', style: TextStyle(fontSize: 12, color: BlingColor.textColor)),
              ),
            ],
          ),
        ),
        backgroundColor: BlingColor.scaffoldColor,
        body: const SpendBody(),
        bottomNavigationBar: const SpendBottomNavigationBar(),
      ),
    );
  }
}

