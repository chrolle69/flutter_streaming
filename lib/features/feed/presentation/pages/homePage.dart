import 'package:flutter/material.dart';
import 'package:streaming/features/feed/presentation/widgets/bottomNav.dart';
import 'package:streaming/features/feed/presentation/pages/streamListPage.dart';
import 'package:streaming/features/feed/presentation/widgets/topNav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  late Widget wid;
  @override
  Widget build(BuildContext context) {
    switch (selectedIndex) {
      case 0:
        wid = StreamListPage();
      case 1:
        wid = StreamListPage();
      case 2:
        wid = StreamListPage();
      default:
        wid = StreamListPage();
    }

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50), child: TopNav()),
      drawer: Drawer(),
      body: wid,
      bottomNavigationBar: const BottomNav(),
    );
  }
}
