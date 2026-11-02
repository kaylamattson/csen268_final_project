import 'package:flutter/material.dart';

class Base extends StatelessWidget {
  final Widget child;
  final Widget? bottom;
  const Base({super.key, required this.child, this.bottom});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
            child: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: child))),
        bottomNavigationBar:
            bottom == null ? null : SafeArea(top: false, child: bottom!),
      );
}
