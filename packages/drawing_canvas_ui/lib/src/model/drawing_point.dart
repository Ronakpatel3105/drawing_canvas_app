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
      'paint': {
        'color': paint.color.value,
        'strokeWidth': paint.strokeWidth,
        'strokeCap': paint.strokeCap.index,
      },
      'isStartOfLine': isStartOfLine,
      'isEraser': isEraser,
    };
  }

  factory DrawingPoint.fromJson(Map<String, dynamic> json) {
    return DrawingPoint(
      offset: Offset(
          json['offset']['dx'] as double, json['offset']['dy'] as double),
      paint: Paint()
        ..color = Color(json['paint']['color'] as int)
        ..strokeWidth = json['paint']['strokeWidth'] as double
        ..strokeCap = StrokeCap.values[json['paint']['strokeCap'] as int],
      isStartOfLine: json['isStartOfLine'] as bool,
      isEraser: json['isEraser'] as bool,
    );
  }
}


