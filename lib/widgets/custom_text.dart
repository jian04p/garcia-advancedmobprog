import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.color,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}
