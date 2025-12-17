import 'package:flutter/material.dart';
import 'package:resqpet/theme.dart';

class ResQPetButton extends StatelessWidget {

  final String text;
  final Color background;
  final Color foreground;
  final int? padding;
  final void Function()? onPressed;

  const ResQPetButton({
    super.key,
    required this.text,
    this.onPressed,
    this.padding = 12,
    this.background = ResQPetColors.accent,
    this.foreground = ResQPetColors.white
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: background
      ),
      onPressed: onPressed, 
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          text,
          style: TextStyle(
            color: foreground,
            fontWeight: FontWeight.w800
          )
        )
      )
    );
  }
}