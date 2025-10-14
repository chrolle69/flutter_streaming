import 'package:flutter/material.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({
    super.key,
  });


  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home'
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search'
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile'
        )
      ],
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      currentIndex: index,
      onTap: (i) => setState(() {
        index = i;
      })
    );
  }
}