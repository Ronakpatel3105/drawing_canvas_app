part of 'drawing_canvas_bloc.dart';

class DrawingState extends Equatable {
  const DrawingState({
    this.drawingPoints = const [],
    this.isDrawing = false,
    this.isPenSelected = true,
    this.isEraserSelected = false,
    this.strokeWidth = 5.0,
    this.backgroundImage,
    this.editableImage, // New field for editable image
    this.isLoading = false,
    this.errorMessage,
    this.savedImagePath,
    this.savedDocumentPath,
    this.isEditing = false,
    this.loadedImagePath,
  });

  final List<DrawingPoint> drawingPoints;
  final bool isDrawing;
  final bool isPenSelected;
  final bool isEraserSelected;
  final double strokeWidth;
  final ui.Image? backgroundImage;
  final ui.Image?
      editableImage; // Editable image for working with loaded images
  final bool isLoading;
  final String? errorMessage;
  final String? savedImagePath;
  final String? savedDocumentPath;
  final bool isEditing;
  final String? loadedImagePath;

  DrawingState copyWith({
    List<DrawingPoint>? drawingPoints,
    bool? isDrawing,
    bool? isPenSelected,
    bool? isEraserSelected,
    double? strokeWidth,
    ui.Image? backgroundImage,
    ui.Image? editableImage, // Include editableImage
    bool? isLoading,
    String? errorMessage,
    String? savedImagePath,
    String? savedDocumentPath,
    bool? isEditing,
    String? loadedImagePath,
  }) {
    return DrawingState(
      drawingPoints: drawingPoints ?? this.drawingPoints,
      isDrawing: isDrawing ?? this.isDrawing,
      isPenSelected: isPenSelected ?? this.isPenSelected,
      isEraserSelected: isEraserSelected ?? this.isEraserSelected,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      editableImage:
          editableImage ?? this.editableImage, // Ensure editableImage is copied
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      savedImagePath: savedImagePath ?? this.savedImagePath,
      savedDocumentPath: savedDocumentPath ?? this.savedDocumentPath,
      isEditing: isEditing ?? this.isEditing,
      loadedImagePath: loadedImagePath ?? this.loadedImagePath,
    );
  }

  @override
  List<Object?> get props => [
        drawingPoints,
        isDrawing,
        isPenSelected,
        isEraserSelected,
        strokeWidth,
        backgroundImage,
        editableImage, // Add to equality check
        isLoading,
        errorMessage,
        savedImagePath,
        savedDocumentPath,
        isEditing,
        loadedImagePath,
      ];
}
