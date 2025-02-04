import 'package:drawing_app/drawing_canvas/bloc/drawing_canvas_bloc.dart';
import 'package:drawing_app/drawing_canvas/view/drawing_canvas_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DrawingCanvasScreen extends StatefulWidget {
  const DrawingCanvasScreen({super.key});

  @override
  State<DrawingCanvasScreen> createState() => _DrawingCanvasScreenState();
}

class _DrawingCanvasScreenState extends State<DrawingCanvasScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DrawingBloc(),
      child: const DrawingCanvasView(),
    );
  }
}
