import 'package:flutter/material.dart';

class ButtonComponent extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color iconColor;
  final Color buttonColor;
  final Color textColor;
  final Color borderColor;
  final int fontSize;
  final double width;
  final double height;
  final double borderWidth;
  final double iconSize;

  const ButtonComponent({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    Color? iconColor,
    this.buttonColor = Colors.white,
    this.textColor = Colors.grey,
    this.borderColor = Colors.blue,
    this.fontSize = 16,
    this.width = 120.0,
    this.height = 80.0,
    this.borderWidth = 1.0,
    double? iconSize = 24.0,
  }) : iconColor = iconColor ?? textColor,
       iconSize = iconSize ?? fontSize * 1.5;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        fixedSize: Size(width, height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
              color: borderColor,
              width: borderWidth,
          ),
        ),
        padding: EdgeInsets.zero,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (icon != null) (
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Icon(
                icon,
                color: iconColor,
                size: iconSize,
              ),
            )
          ),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize.toDouble(),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
