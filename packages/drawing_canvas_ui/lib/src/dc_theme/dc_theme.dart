import 'package:drawing_canvas_ui/drawing_canvas_ui.dart';
import 'package:flutter/material.dart';

abstract class DcTheme {
  static ThemeData darkTheme() {
    return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: DCColor.primaryColor,
          secondary: DCColor.secondaryColor,
          surface: DCColor.surfaceColor,
           ));
  }
}
