import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:bloc/bloc.dart';
import 'package:drawing_canvas_ui/drawing_canvas_ui.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'drawing_canvas_event.dart';
part 'drawing_canvas_state.dart';

class DrawingBloc extends Bloc<DrawingEvent, DrawingState> {
  DrawingBloc() : super(const DrawingState()) {
    on<OnStartDrawing>(_onStartDrawing);
    on<OnDrawing>(_onDrawing);
    on<OnStopDrawing>(_onStopDrawing);
    on<OnClearDrawing>(_onClearDrawing);
    on<OnSelectPen>(_onSelectPen);
    on<OnSelectEraser>(_onSelectEraser);
    on<OnChangePenWidth>(_onChangePenWidth);
    on<OnLoadImage>(_onLoadImage);
    on<OnSaveDrawing>(_onSaveDrawing);
    on<OnEnableEditing>(_onEnableEditing);
    on<OnSaveDocument>(_onSaveDocument);
    on<OnFetchDocument>(_onFetchDocument);
  }

  final ImagePicker _imagePicker = ImagePicker();

  Paint _getCurrentPaint() {
    return Paint()
      ..color = state.isEraserSelected ? Colors.white : Colors.black
      ..strokeWidth = state.strokeWidth
      ..strokeCap = StrokeCap.round;
  }

  void _onStartDrawing(OnStartDrawing event, Emitter<DrawingState> emit) {
    final paint = _getCurrentPaint();
    final points = List<DrawingPoint>.from(state.drawingPoints)
      ..add(
        DrawingPoint(
          offset: event.offset,
          paint: paint,
          isStartOfLine: true,
          isEraser: state.isEraserSelected,
        ),
      );

    emit(state.copyWith(isDrawing: true, drawingPoints: points));
  }

  void _onDrawing(OnDrawing event, Emitter<DrawingState> emit) {
    if (!state.isDrawing) return;

    final paint = _getCurrentPaint();
    final points = List<DrawingPoint>.from(state.drawingPoints)
      ..add(
        DrawingPoint(
          offset: event.offset,
          paint: paint,
          isStartOfLine: false,
          isEraser: state.isEraserSelected,
        ),
      );

    emit(state.copyWith(drawingPoints: points));
  }

  void _onStopDrawing(OnStopDrawing event, Emitter<DrawingState> emit) {
    if (!state.isDrawing) return;

    final points = List<DrawingPoint>.from(state.drawingPoints)
      ..add(
        DrawingPoint(
          offset: Offset.zero,
          paint: Paint(),
          isStartOfLine: true,
          isEraser: false,
        ),
      );

    emit(state.copyWith(isDrawing: false, drawingPoints: points));
  }

  void _onClearDrawing(OnClearDrawing event, Emitter<DrawingState> emit) {
    emit(state.copyWith(drawingPoints: []));
  }

  void _onSelectPen(OnSelectPen event, Emitter<DrawingState> emit) {
    emit(
      state.copyWith(
        isPenSelected: !state.isPenSelected,
        isEraserSelected: false,
      ),
    );
  }

  void _onSelectEraser(OnSelectEraser event, Emitter<DrawingState> emit) {
    emit(
      state.copyWith(
        isEraserSelected: !state.isEraserSelected,
        isPenSelected: false,
      ),
    );
  }

  void _onChangePenWidth(OnChangePenWidth event, Emitter<DrawingState> emit) {
    emit(state.copyWith(strokeWidth: event.width));
  }

  Future<void> _onLoadImage(
    OnLoadImage event,
    Emitter<DrawingState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final XFile? imageFile;
      if (event.fromGallery) {
        imageFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      } else {
        final result =
            await FilePicker.platform.pickFiles(type: FileType.image);
        imageFile = result != null ? XFile(result.files.first.path!) : null;
      }

      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        final image = frame.image;

        emit(
          state.copyWith(
            editableImage: image, // Load image as editable, not background
            isLoading: false,
            drawingPoints: [], // Reset drawing points
            savedImagePath: imageFile.path,
          ),
        );
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load image: $e',
        ),
      );
    }
  }

  Future<void> _onSaveDrawing(
      OnSaveDrawing event, Emitter<DrawingState> emit) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      final boundary = event.canvasKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Failed to find canvas boundary');
      }

      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to convert canvas to image');
      }

      final bytes = byteData.buffer.asUint8List();

      final result = await ImageGallerySaver.saveImage(bytes, name: 'drawing');
      if (result['isSuccess'] == true) {
        emit(state.copyWith(
          isLoading: false,
          savedImagePath: result['filePath'] as String?,
        ));
      } else {
        throw Exception('Failed to save image');
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to save image: $e',
        ),
      );
    }
  }

  Future<void> _onSaveDocument(
      OnSaveDocument event, Emitter<DrawingState> emit) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      final documentData = {
        'drawingPoints':
            state.drawingPoints.map((point) => point.toJson()).toList(),
        'backgroundImagePath': state.savedImagePath,
        'strokeWidth': state.strokeWidth,
        'isEraserSelected': state.isEraserSelected,
        'isPenSelected': state.isPenSelected,
      };

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'document_${DateTime.now().millisecondsSinceEpoch}.json';
      final filePath = path.join(directory.path, fileName);

      final file = File(filePath);
      await file.writeAsString(jsonEncode(documentData));

      emit(state.copyWith(
        isLoading: false,
        savedDocumentPath: filePath,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save document: $e',
      ));
    }
  }

  Future<void> _onFetchDocument(
      OnFetchDocument event, Emitter<DrawingState> emit) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      final file = File(event.documentPath);
      final jsonString = await file.readAsString();
      final documentData = jsonDecode(jsonString);

      final drawingPoints = (documentData['drawingPoints'] as List?)
              ?.map(
                  (json) => DrawingPoint.fromJson(json as Map<String, dynamic>))
              .toList() ??
          [];

      // Load image as an editable layer, NOT a background
      String? imagePath = documentData['backgroundImagePath'] as String?;

      ui.Image? editableImage;
      if (imagePath != null && File(imagePath).existsSync()) {
        final bytes = await File(imagePath).readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        editableImage = frame.image;
      }

      emit(state.copyWith(
        drawingPoints: drawingPoints, // Load previous drawing data
        editableImage: editableImage, // Load image in editable mode
        strokeWidth: (documentData['strokeWidth'] as num?)?.toDouble(),
        isEraserSelected: documentData['isEraserSelected'] as bool?,
        isPenSelected: documentData['isPenSelected'] as bool?,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to fetch document: $e',
      ));
    }
  }

  void _onEnableEditing(OnEnableEditing event, Emitter<DrawingState> emit) {
    emit(state.copyWith(isEditing: !state.isEditing));
  }
}
