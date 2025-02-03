import 'dart:ui' as ui;
import 'package:drawing_canvas_ui/src/model/drawing_point.dart';
import 'package:flutter/material.dart';

class DrawingCanvas extends CustomPainter {
  final List<DrawingPoint> drawingPoints;
  final ui.Image? backgroundImage;

  DrawingCanvas({
    required this.drawingPoints,
    this.backgroundImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background image if exists
    if (backgroundImage != null) {
      final rect = Rect.fromLTWH(0, 0, size.width, size.height);
      canvas.drawImageRect(
        backgroundImage!,
        Rect.fromLTWH(
          0,
          0,
          backgroundImage!.width.toDouble(),
          backgroundImage!.height.toDouble(),
        ),
        rect,
        Paint(),
      );
    }

    for (int i = 0; i < drawingPoints.length - 1; i++) {
      if (drawingPoints[i].offset == Offset.zero ||
          drawingPoints[i + 1].offset == Offset.zero) {
        continue;
      }

      if (drawingPoints[i + 1].isStartOfLine) {
        // Draw a point for single tap
        canvas.drawCircle(
          drawingPoints[i].offset,
          drawingPoints[i].paint.strokeWidth / 2,
          drawingPoints[i].paint,
        );
      } else {
        // Draw line between points
        canvas.drawLine(
          drawingPoints[i].offset,
          drawingPoints[i + 1].offset,
          drawingPoints[i].paint,
        );
      }
    }

    // Draw the last point if it exists and isn't a zero offset
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
        oldDelegate.backgroundImage != backgroundImage;
  }
}
