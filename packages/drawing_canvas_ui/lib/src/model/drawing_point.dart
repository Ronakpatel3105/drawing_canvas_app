import 'dart:ui';

class DrawingPoint {
  final Offset offset;
  final Paint paint;
  final bool isStartOfLine;
  final bool isEraser;

  DrawingPoint({
    required this.offset,
    required this.paint,
    required this.isStartOfLine,
    required this.isEraser,
  });

  Map<String, dynamic> toJson() {
    return {
      'offset': {'dx': offset.dx, 'dy': offset.dy},
      'isStartOfLine': isStartOfLine,
      'isEraser': isEraser,
    };
  }

  static DrawingPoint fromJson(Map<String, dynamic> json) {
    return DrawingPoint(
      offset: Offset(json['offset']['dx'], json['offset']['dy']),
      paint: Paint(), // Recreate paint as needed
      isStartOfLine: json['isStartOfLine'],
      isEraser: json['isEraser'],
    );
  }
}
