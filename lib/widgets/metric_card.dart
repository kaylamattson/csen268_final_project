import 'package:flutter/material.dart';
import '../widgets/app_text.dart';

class MetricCard extends StatelessWidget {
  final String value, title;
  const MetricCard({super.key, required this.value, required this.title});
  @override
  Widget build(BuildContext context) => Container(
      height: 95,
      decoration: BoxDecoration(
          color: const Color(0xFFBDD4D7),
          borderRadius: BorderRadius.circular(28)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        heading(value, size: 26, color: Colors.black),
        labelText(title, color: Colors.black)
      ]));
}
