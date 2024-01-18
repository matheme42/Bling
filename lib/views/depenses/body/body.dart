part of spend_view;

class SpendBody extends StatefulWidget {
  const SpendBody({super.key});

  @override
  State<StatefulWidget> createState() => SpendBodyState();
}

class SpendBodyState extends State<SpendBody> {
  int viewIndex = 0;

  PageController pageController = PageController();

  void onChangeView(int index) {
    setState(() => viewIndex = index);
    pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            ViewSelector(index: viewIndex, onChange: onChangeView),
            Expanded(child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                SpendGridView(),
                SpendListView()
              ],
            ))
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: viewIndex == 1 ? InkWell(
        onLongPress: (){},
        child: Theme(
          data: Theme.of(context).copyWith(useMaterial3: false),
          child: FloatingActionButton(
            onPressed: () {},
            backgroundColor: Colors.transparent,
            child: Container(
              alignment: Alignment.center,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                  image: const DecorationImage(
                      image: AssetImage('images/logo.png'))),
              child: const SizedBox.shrink(),
            ),
          ),
        ),
      ) : null,
    );
  }
}