part of 'drawing_canvas_bloc.dart';

abstract class DrawingEvent extends Equatable {
  const DrawingEvent();

  @override
  List<Object?> get props => [];
}

class OnStartDrawing extends DrawingEvent {
  const OnStartDrawing(this.offset);
  final Offset offset;

  @override
  List<Object?> get props => [offset];
}

class OnDrawing extends DrawingEvent {
  const OnDrawing(this.offset);
  final Offset offset;

  @override
  List<Object?> get props => [offset];
}

class OnStopDrawing extends DrawingEvent {
  const OnStopDrawing();
}

class OnClearDrawing extends DrawingEvent {
  const OnClearDrawing();
}

class OnSelectPen extends DrawingEvent {
  const OnSelectPen();
}

class OnSelectEraser extends DrawingEvent {
  const OnSelectEraser();
}

class OnChangePenWidth extends DrawingEvent {
  const OnChangePenWidth(this.width);
  final double width;

  @override
  List<Object?> get props => [width];
}

class OnLoadImage extends DrawingEvent {
  const OnLoadImage({required this.fromGallery});
  final bool fromGallery;

  @override
  List<Object?> get props => [fromGallery];
}

class OnSaveDrawing extends DrawingEvent {
  const OnSaveDrawing(this.canvasKey);
  final GlobalKey canvasKey;

  @override
  List<Object?> get props => [canvasKey];
}

class OnSaveScreenshot extends DrawingEvent {
  const OnSaveScreenshot(this.canvasKey);
  final GlobalKey canvasKey;

  @override
  List<Object?> get props => [canvasKey];
}

class OnEnableEditing extends DrawingEvent {
  const OnEnableEditing();
}

class OnSaveDocument extends DrawingEvent {
  const OnSaveDocument();
}

class OnFetchDocument extends DrawingEvent {
  const OnFetchDocument(this.documentPath);
  final String documentPath;

  @override
  List<Object?> get props => [documentPath];
}

class OnLoadPrescriptionPad extends DrawingEvent {
  const OnLoadPrescriptionPad(this.imagePath);
  final String imagePath;

  @override
  List<Object?> get props => [imagePath];
}
