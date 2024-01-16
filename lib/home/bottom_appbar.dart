import 'package:flutter/material.dart';

class HomeBottomAppBar extends StatelessWidget {
  final PageController controller;
  final int activeScreen;

  const HomeBottomAppBar(
      {super.key, required this.controller, required this.activeScreen});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      height: 50,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      clipBehavior: Clip.hardEdge,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Colors.brown.shade400, Colors.brown]),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Flexible(
            child: Align(
              heightFactor: 1,
              alignment: Alignment.center,
              child: IconButton(
                splashRadius: 20,
                icon: Icon(Icons.format_list_bulleted_sharp,
                    color:
                        activeScreen == 0 ? Colors.brown[900] : Colors.white24,
                    size: activeScreen == 0 ? 35 : 25),
                onPressed: () {
                  controller.animateToPage(0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn);
                },
              ),
            ),
          ),
          Flexible(
            child: Align(
              heightFactor: 1,
              child: IconButton(
                splashRadius: 20,
                icon: Icon(Icons.data_usage_rounded,
                    color:
                        activeScreen == 1 ? Colors.brown[900] : Colors.white24,
                    size: activeScreen == 1 ? 35 : 25),
                onPressed: () {
                  controller.animateToPage(1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn);
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
