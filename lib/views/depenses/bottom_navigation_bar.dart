part of spend_view;

class SpendBottomNavigationBar extends StatelessWidget {
  final void Function(int) onItemTap;
  final int index;

  const SpendBottomNavigationBar({
    super.key,
    required this.onItemTap,
    required this.index
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: BlingColor.dividerColor))
        ),
        child: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Définir le budget',
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Depense',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.circle_outlined),
              label: 'Graphiques',
            ),
          ],
          currentIndex: index,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          unselectedItemColor: BlingColor.disableButtonColor,
          selectedItemColor: BlingColor.enableButtonColor,
          backgroundColor: BlingColor.appBarColor,
          onTap: onItemTap,
        ),
      ),
    );
  }

}