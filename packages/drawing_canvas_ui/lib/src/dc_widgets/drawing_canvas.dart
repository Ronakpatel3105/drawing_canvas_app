import 'dart:ui' as ui;
import 'package:drawing_canvas_ui/drawing_canvas_ui.dart';
import 'package:flutter/material.dart';

/*class DrawingCanvas extends CustomPainter {
  final List<DrawingPoint> drawingPoints;
  final ui.Image? editableImage;

  DrawingCanvas({
    required this.drawingPoints,
    this.editableImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw editable image if it exists
    if (editableImage != null) {
      final rect = Rect.fromLTWH(0, 0, size.width, size.height);
      canvas.drawImageRect(
        editableImage!,
        Rect.fromLTWH(
          0,
          0,
          editableImage!.width.toDouble(),
          editableImage!.height.toDouble(),
        ),
        rect,
        Paint(),
      );
    }

    // Draw the drawing points
    for (int i = 0; i < drawingPoints.length - 1; i++) {
      if (drawingPoints[i].offset == Offset.zero ||
          drawingPoints[i + 1].offset == Offset.zero) {
        continue;
      }

      canvas.drawLine(
        drawingPoints[i].offset,
        drawingPoints[i + 1].offset,
        drawingPoints[i].paint,
      );
    }

    // Draw the last point if it exists
    if (drawingPoints.isNotEmpty && drawingPoints.last.offset != Offset.zero) {
      canvas.drawCircle(
        drawingPoints.last.offset,
        drawingPoints.last.paint.strokeWidth / 2,
        drawingPoints.last.paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DrawingCanvas oldDelegate) {
    return oldDelegate.drawingPoints != drawingPoints ||
        oldDelegate.editableImage != editableImage;
  }
}
*/
/*class DrawingCanvas extends CustomPainter {
  final List<DrawingPoint> drawingPoints;
  final ui.Image? editableImage;

  DrawingCanvas({
    required this.drawingPoints,
    this.editableImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the prescription pad (editableImage) as the base layer
    if (editableImage != null) {
      final rect = Rect.fromLTWH(0, 0, size.width, size.height);
      canvas.drawImageRect(
        editableImage!,
        Rect.fromLTWH(
          0,
          0,
          editableImage!.width.toDouble(),
          editableImage!.height.toDouble(),
        ),
        rect,
        Paint(),
      );
    }

    // Draw the drawing points on top of the prescription pad
    for (int i = 0; i < drawingPoints.length - 1; i++) {
      if (drawingPoints[i].offset == Offset.zero ||
          drawingPoints[i + 1].offset == Offset.zero) {
        continue;
      }

      canvas.drawLine(
        drawingPoints[i].offset,
        drawingPoints[i + 1].offset,
        drawingPoints[i].paint,
      );
    }

    // Draw the last point if it exists
    if (drawingPoints.isNotEmpty && drawingPoints.last.offset != Offset.zero) {
      canvas.drawCircle(
        drawingPoints.last.offset,
        drawingPoints.last.paint.strokeWidth / 2,
        drawingPoints.last.paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DrawingCanvas oldDelegate) {
    return oldDelegate.drawingPoints != drawingPoints ||
        oldDelegate.editableImage != editableImage;
  }
}*/

class DrawingCanvas extends CustomPainter {
  final List<DrawingPoint> drawingPoints;
  final ui.Image? editableImage;

  DrawingCanvas({
    required this.drawingPoints,
    this.editableImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the prescription pad (editableImage) as the base layer
    if (editableImage != null) {
      final rect = Rect.fromLTWH(0, 0, size.width, size.height);
      canvas.drawImageRect(
        editableImage!,
        Rect.fromLTWH(
          0,
          0,
          editableImage!.width.toDouble(),
          editableImage!.height.toDouble(),
        ),
        rect,
        Paint(),
      );
    }

    // Draw the drawing points on top of the prescription pad
    for (int i = 0; i < drawingPoints.length - 1; i++) {
      if (drawingPoints[i].offset == Offset.zero ||
          drawingPoints[i + 1].offset == Offset.zero) {
        continue;
      }

      canvas.drawLine(
        drawingPoints[i].offset,
        drawingPoints[i + 1].offset,
        drawingPoints[i].paint,
      );
    }

    // Draw the last point if it exists
    if (drawingPoints.isNotEmpty && drawingPoints.last.offset != Offset.zero) {
      canvas.drawCircle(
        drawingPoints.last.offset,
        drawingPoints.last.paint.strokeWidth / 2,
        drawingPoints.last.paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DrawingCanvas oldDelegate) {
    return oldDelegate.drawingPoints != drawingPoints ||
        oldDelegate.editableImage != editableImage;
  }
}
