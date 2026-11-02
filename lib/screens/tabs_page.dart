import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import 'home_screen.dart';
import 'practice_screen.dart';
import 'stats_screen.dart';

class TabsPage extends StatefulWidget {
  final int initialIndex;
  const TabsPage({super.key, this.initialIndex = 0});
  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  late int tab = widget.initialIndex;
  @override
  Widget build(BuildContext context) => Base(
        bottom: Container(
            height: 72,
            decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(color: Color(0xFF999999), width: .6))),
            child: Row(children: [
              navItem(0, Icons.home_outlined, 'Home'),
              navItem(1, Icons.sports_esports_outlined, 'Practice'),
              navItem(2, Icons.bar_chart_outlined, 'Stats'),
            ])),
        child: switch (tab) {
          0 => const HomeScreen(),
          1 => const PracticeScreen(),
          _ => const StatsScreen()
        },
      );
  Widget navItem(int i, IconData icon, String title) => Expanded(
      child: InkWell(
          onTap: () => setState(() => tab = i),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon,
                size: 31, color: tab == i ? C.ink : const Color(0xFF26262A)),
            Text(title,
                style: TextStyle(
                    fontSize: 11,
                    color: tab == i ? C.ink : Colors.black,
                    fontWeight: tab == i ? FontWeight.bold : FontWeight.w500))
          ])));
}
