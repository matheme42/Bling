import 'package:bling/home/body/budget_definition/body.dart';
import 'package:bling/main.dart';
import 'package:bling/models/budgetcategory.dart';
import 'package:bling/models/budgetinstance.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartSample1 extends StatefulWidget {
  const BarChartSample1({super.key});

  List<Color> get availableColors => const <Color>[
        Colors.purple,
        Colors.yellow,
        Colors.blue,
        Colors.orange,
        Colors.pink,
        Colors.red,
      ];

  final Color barBackgroundColor = Colors.white30;
  final Color barColor = Colors.white;
  final Color touchedBarColor = Colors.green;

  @override
  State<StatefulWidget> createState() => BarChartSample1State();
}

class BarChartSample1State extends State<BarChartSample1> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    int len =
        Bling.of(context).budgetCategoryController.budgetCategories.length;
    return Builder(builder: (context) {
      if (Bling.of(context).budgetCategoryController.budgetCategories.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
              child: Text('Categories vides',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center)),
        );
      }
      double lenWidth = len * 70;
      double originalWidth = MediaQuery.of(context).size.width;
      return Align(
        alignment: Alignment.topCenter,
        child: FractionallySizedBox(
          heightFactor: 0.9,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: lenWidth < originalWidth ? originalWidth : lenWidth,
              child: BarChart(
                mainBarData(),
                swapAnimationDuration: const Duration(milliseconds: 250),
              ),
            ),
          ),
        ),
      );
    });
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color? barColor,
    double width = 22,
    required BudgetInstance instance,
    required BudgetCategory category,
  }) {
    Color backgroundColor = Colors.white30;
    Color touchedColor = Colors.green;

    if (isTouched) {
      y += instance.number * 0.1;
      if (y > instance.number) y = instance.number;
    }
    if (y < 0) {
      y = -y;
      backgroundColor = Colors.red.withAlpha(100);
      barColor = Colors.red.withAlpha(200);
      touchedColor = Colors.red;
    }
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: isTouched ? touchedColor : category.color,
          width: width,
          borderSide: !isTouched
              ? BorderSide(color: category.color, width: 1)
              : const BorderSide(color: Colors.white, width: 1),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: instance.number,
            color: backgroundColor,
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> showingGroups() {
    List<BudgetCategory> categories =
        Bling.of(context).budgetCategoryController.budgetCategories;
    return List.generate(categories.length, (i) {
      BudgetCategory category = categories[i];
      BudgetInstance instance = category.activeInstance!;
      return makeGroupData(i, instance.number - instance.depense,
          isTouched: i == touchedIndex, instance: instance, category: category);
    });
  }

  BarChartData mainBarData() {
    int len =
        Bling.of(context).budgetCategoryController.budgetCategories.length;
    bool isLeft = touchedIndex >= len * 0.5;

    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.brown,
          tooltipHorizontalAlignment:
              isLeft ? FLHorizontalAlignment.left : FLHorizontalAlignment.right,
          tooltipMargin: -50,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            List<BudgetCategory> categories =
                Bling.of(context).budgetCategoryController.budgetCategories;
            BudgetCategory category = categories[group.x];
            BudgetInstance instance = category.activeInstance!;
            return BarTooltipItem(
              '${category.name.toLowerCase().capitalize()}\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              children: <TextSpan>[
                TextSpan(
                  text:
                      "${(instance.number - instance.depense).toStringAsFixed(2)}€",
                  style: TextStyle(
                    color: Colors.brown[300],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                getTitlesWidget: getTopTitles)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      barGroups: showingGroups(),
      gridData: const FlGridData(show: false),
    );
  }

  Widget getTopTitles(double value, TitleMeta meta) {
    List<BudgetCategory> categories =
        Bling.of(context).budgetCategoryController.budgetCategories;
    BudgetCategory category = categories[value.toInt()];
    BudgetInstance budgetInstance = category.activeInstance!;

    double data = budgetInstance.number - budgetInstance.depense;
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 5,
      child: Text("${data.toStringAsFixed(2)}€",
          style: TextStyle(
            color: data >= 0 ? Colors.white : Colors.red,
            fontWeight: FontWeight.bold,
          )),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    List<BudgetCategory> categories =
        Bling.of(context).budgetCategoryController.budgetCategories;
    BudgetCategory category = categories[value.toInt()];

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 5,
      child: Text(category.icon,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          )),
    );
  }
}
