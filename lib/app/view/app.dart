import 'package:drawing_app/drawing_canvas/view/drawing_canvas_screen.dart';
import 'package:drawing_app/l10n/l10n.dart';
import 'package:drawing_canvas_ui/drawing_canvas_ui.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: DcTheme.darkTheme().colorScheme,
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const DrawingCanvasScreen(),
    );
  }
}
