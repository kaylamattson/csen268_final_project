import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class Pill extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;
  final double width;
  const Pill(
      {super.key,
      required this.text,
      required this.onTap,
      this.color = C.teal,
      this.textColor = C.ink,
      this.width = 200});
  @override
  Widget build(BuildContext context) => SizedBox(
      width: width,
      height: 52,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            elevation: 0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            maxLines: 1,
            softWrap: false,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ));
}
