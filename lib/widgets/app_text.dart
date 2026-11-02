import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

Widget heading(String s, {double size = 27, Color color = C.ink}) => Text(s,
    style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w800,
        letterSpacing: .25));
Widget labelText(String s,
        {double size = 16,
        Color color = C.ink,
        FontWeight weight = FontWeight.w500,
        TextAlign? align}) =>
    Text(s,
        textAlign: align,
        style: TextStyle(
            color: color, fontSize: size, fontWeight: weight, height: 1.3));
