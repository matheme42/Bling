part of spend_view;

class SpendBottomNavigationBar extends StatefulWidget {
  const SpendBottomNavigationBar({super.key});

  @override
  State<StatefulWidget> createState() => SpendBottomNavigationBarState();
}

class SpendBottomNavigationBarState extends State<SpendBottomNavigationBar> {

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
      child: BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Définir le budget',
          ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Depense',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle_outlined),
            label: 'Graphiques',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        unselectedItemColor: BlingColor.disableButtonColor,
        selectedItemColor: BlingColor.enableButtonColor,
        backgroundColor: BlingColor.appBarColor,
        onTap: _onItemTapped,
      ),
    );
  }

}