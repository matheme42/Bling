import 'dart:ui';

import 'package:bling/color.dart';
import 'package:bling/home/body/budget_definition/body.dart';
import 'package:bling/home/body/budget_depense/dart/body.dart';
import 'package:bling/home/body/budget_shart/shart.dart';
import 'package:bling/home/dialog/ticket.dart';
import 'package:bling/main.dart';
import 'package:bling/models/budgetcategory.dart';
import 'package:bling/models/budgetinstance.dart';
import 'package:bling/models/depense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'bottom_appbar.dart';
import 'body/budget_depense_shart/body.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<Home> {
  int activeScreen = 0;
  List<BudgetInstance> budgetInstances = [];

  late PageController controllerBudget;
  late PageController controllerDepense;
  late PageController activeController;
  late PageController globalController;

  GlobalKey<BudgetDepenseBodyState> budgetDepenseBody =
      GlobalKey<BudgetDepenseBodyState>();
  GlobalKey<BarChartSample1State> chartBodyKey =
      GlobalKey<BarChartSample1State>();

  @override
  void initState() {
    super.initState();
    globalController = PageController(initialPage: 1);
    controllerBudget = PageController();
    controllerDepense = PageController();
    activeController = controllerDepense;
  }

  Future<void> updateBudgetInstance() async {
    BudgetInstanceController instanceController =
        Bling.of(context).budgetInstanceController;
    DepenseController depenseController = Bling.of(context).depenseController;

    List<BudgetCategory> categories =
        Bling.of(context).budgetCategoryController.budgetCategories;
    for (var category in categories) {
      if (category.activeInstance == null) {
        List<BudgetInstance> instances = await instanceController.getsCurrent();
        List<BudgetInstance> ic = instances
            .where((e) => e.categoryId == category.id)
            .toList(growable: false);
        if (ic.isNotEmpty) {
          category.activeInstance = ic.first;
          await depenseController
              .getsDepenseOfCategoriesInstance(category.activeInstance!);
          continue;
        }

        BudgetInstance instance = BudgetInstance();
        instance.year = DateTime.now().year;
        instance.number = category.number;
        instance.categoryId = category.id!;
        instance.month = DateTime.now().month;
        instance.depense = 0.0;
        category.activeInstance = instance;
        // ignore: use_build_context_synchronously
        await instanceController.insert(instance);
      }
    }
    for (var category in categories) {
      if (category.activeInstance!.number != category.number) {
        category.activeInstance!.number == category.number;
        await instanceController.update(category.activeInstance!);
      }
    }
  }

  bool lockFloatingActionButton = false;

  Future<void> onWantAddDepense() async {
    if (Bling.of(context).budgetCategoryController.budgetCategories.isEmpty) {
      return;
    }
    await showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => const Ticket(),
      animationType: DialogTransitionType.slideFromBottom,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(seconds: 1),
    );
    budgetDepenseBody.currentState?.setState(() {});
    chartBodyKey.currentState?.setState(() {});
  }

  Future<void> onTapFloatingActionButton() async {
    if (lockFloatingActionButton == true) return;
    lockFloatingActionButton = true;
    if (globalController.page?.toInt() == 0) await updateBudgetInstance();
    lockFloatingActionButton = false;
    globalController
        .animateToPage(globalController.page?.toInt() == 0 ? 1 : 0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn)
        .then((value) {
      if (mounted) setState(() {});
    });
  }

  String get pageTitle {
    if (activeController == controllerBudget) {
      if (activeScreen == 0) return "Definition Du Budget";
      return "Repartition Du Budget";
    }
    if (activeScreen == 0) return "Tableau Des Depenses";
    return "Statistique Des Depenses";
  }

  static ImageProvider logo = const AssetImage("images/budget_background.png");

  @override
  Widget build(BuildContext context) {
    precacheImage(logo, context);
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: logo,
              fit: BoxFit.cover,
              opacity: 1)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            bottom: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0)
                ),
                color: BlingColor.scaffoldColor,
                  onPressed: () {
                    Navigator.pushNamed(context, '/second');
                  },
                child: const Text('Nouvelle Interface'),
              ),
            ),
            title: Stack(
              children: [
                // Implement the stroke
                Text(
                  pageTitle,
                  style: TextStyle(
                    fontSize: 20,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 1
                      ..color = Colors.white54,
                  ),
                ),
                // The text inside
                Text(
                  pageTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            leading: const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundImage: AssetImage("images/logo.png"),
                )),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Colors.black, Colors.brown]),
              ),
            ),
            actions: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SmoothPageIndicator(
                  controller: activeController,
                  count: 2,
                  effect: const JumpingDotEffect(
                    activeDotColor: Colors.black,
                    dotColor: Colors.white30,
                    dotHeight: 16,
                    dotWidth: 16,
                    jumpScale: 0.7,
                    verticalOffset: 15,
                  ),
                ),
              ),
            ],
          ),
          body: PageView(
            controller: globalController,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            onPageChanged: (page) {
              setState(() {
                if (page == 0) {
                  activeController = controllerBudget;
                } else {
                  activeController = controllerDepense;
                }

                if (activeController.positions.isEmpty) {
                  activeScreen = activeController.initialPage;
                  return;
                }
                activeScreen = activeController.page!.toInt();
              });
            },
            children: [
              PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: controllerBudget,
                scrollDirection: Axis.horizontal,
                onPageChanged: (value) {
                  if (activeController != controllerBudget) return;
                  setState(() => activeScreen = value);
                },
                children: const [HomeBody(), BudgetPieChart()],
              ),
              PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: controllerDepense,
                scrollDirection: Axis.horizontal,
                onPageChanged: (value) {
                  if (activeController != controllerDepense) return;
                  setState(() => activeScreen = value);
                },
                children: [
                  BudgetDepenseBody(key: budgetDepenseBody),
                  BarChartSample1(key: chartBodyKey)
                ],
              ),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Builder(builder: (context) {
            bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;
            if (isKeyboardOpen) return const SizedBox.shrink();
            return InkWell(
              onLongPress: onTapFloatingActionButton,
              child: Theme(
                data: Theme.of(context).copyWith(useMaterial3: false),
                child: FloatingActionButton(
                  onPressed: () {
                    if (activeController == controllerBudget) {
                      onTapFloatingActionButton();
                      return;
                    }
                    onWantAddDepense();
                  },
                  backgroundColor: Colors.transparent,
                  child: Container(
                    alignment: Alignment.center,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage('images/logo.png'))),
                    child: activeController != controllerDepense
                        ? BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text(
                                "Valider",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            );
          }),
          bottomNavigationBar: HomeBottomAppBar(
              controller: activeController, activeScreen: activeScreen),
        ),
      ),
    );
  }
}
