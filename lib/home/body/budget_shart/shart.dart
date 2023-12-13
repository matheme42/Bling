import 'dart:async';

import 'package:bling/home/body/budget_definition/body.dart';
import 'package:bling/main.dart';
import 'package:bling/models/budget.dart';
import 'package:bling/models/budgetcategory.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BudgetPieChart extends StatefulWidget {
  const BudgetPieChart({super.key});

  @override
  State<StatefulWidget> createState() => BudgetPieChartState();
}

class BudgetPieChartState extends State<BudgetPieChart> {
  int touchedIndex = -1;

  StreamSubscription? detectChange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      detectChange =
          MyApp.of(context).budgetCategoryController.onChange.listen((event) {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    detectChange?.pause();
    detectChange?.cancel();
    super.dispose();
  }

  List<BudgetCategory> get budgetCategories {
    List<BudgetCategory> lst =
        MyApp.of(context).budgetCategoryController.budgetCategories;
    return lst.where((e) => e.number != 0).toList();
  }

  Budget get budget {
    return MyApp.of(context).budgetController.budget!;
  }

  void touchedCallback(FlTouchEvent event, touchResponse) => setState(() {
        if (!event.isInterestedForInteractions) {
          touchedIndex = -1;
          return;
        }
        touchedIndex = touchResponse.touchedSection?.touchedSectionIndex ?? -1;
      });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(touchCallback: touchedCallback),
          borderData: FlBorderData(show: true),
          sectionsSpace: 8,
          centerSpaceRadius: 80,
          sections: showingSections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    List<PieChartSectionData> data = [];
    if (budget.number > 0) {
      int len = budgetCategories.length;
      data = List.generate(len, (i) {
        final isTouched = i == touchedIndex;
        final fontSize = isTouched ? 25.0 : 16.0;
        final radius = isTouched ? 80.0 : 60.0;
        const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
        BudgetCategory budgetCategory = budgetCategories[i];

        String getTitle() {
          int percent = ((budgetCategory.number / budget.number) * 100).toInt();
          if (!isTouched) {
            return '$percent %';
          }

          return budgetCategory.name.toLowerCase().capitalize();
        }

        return PieChartSectionData(
          color: budgetCategory.color,
          value:
              (budget.number == 0 ? 0 : budgetCategory.number / budget.number),
          title: getTitle(),
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            shadows: shadows,
          ),
        );
      });
    }

    double totalBudgetCategory = 0;
    for (var elm in budgetCategories) {
      totalBudgetCategory += elm.number;
    }
    double missing = (budget.number - totalBudgetCategory) / budget.number;
    if (totalBudgetCategory != budget.number || budget.number == 0) {
      final isTouched = budgetCategories.length == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 90.0 : 70.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      String getTitle() {
        if (missing.isNaN) return '';
        if (!isTouched) {
          return '${(missing * 100).toInt()}%';
        }
        return 'Restants';
      }

      data.add(PieChartSectionData(
        color: missing.isNaN ? Colors.deepOrange : Colors.green,
        value: missing.isNaN ? 100 : missing,
        title: getTitle(),
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          shadows: shadows,
        ),
      ));
    }
    return data;
  }
}
