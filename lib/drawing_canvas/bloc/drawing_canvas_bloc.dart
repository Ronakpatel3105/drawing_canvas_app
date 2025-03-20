import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bloc/bloc.dart';
import 'package:drawing_canvas_ui/drawing_canvas_ui.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
    //on<OnSaveDrawing>(_onSaveDrawing);
    on<OnEnableEditing>(_onEnableEditing);
    //  on<OnSaveDocument>(_onSaveDocument);
    on<OnFetchDocument>(_onFetchDocument);
    on<OnSaveScreenshot>(_onSaveScreenshot);
    on<OnLoadPrescriptionPad>(_onLoadPrescriptionPad);
  }

  final ImagePicker _imagePicker = ImagePicker();

  Paint _getCurrentPaint() {
    return Paint()
      ..color = state.isPenSelected ? Colors.black : Colors.white
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

  // For kIsWeb
  Future<void> _onSaveScreenshot(
      OnSaveScreenshot event, Emitter<DrawingState> emit) async {
    final canvasKey = event.canvasKey;
    try {
      // Request storage permission
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied.');
      }

      final boundary = canvasKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Canvas boundary not found.');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to capture image.');
      }
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Get the app-specific external storage directory
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Failed to get external storage directory.');
      }

      // Create a subdirectory for the app
      final appDirectory = Directory('${directory.path}/DrawingApp');
      if (!await appDirectory.exists()) {
        await appDirectory.create(recursive: true);
      }

      // Save the image
      final imagePath =
          '${appDirectory.path}/prescription_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      // Save the drawing points
      final documentPath =
          '${appDirectory.path}/prescription_${DateTime.now().millisecondsSinceEpoch}.json';
      final documentData = {
        'drawingPoints': state.drawingPoints
            .map((point) => point.toJson())
            .toList(), // Convert drawing points to JSON
        'backgroundImagePath': imagePath,
        'strokeWidth': state.strokeWidth,
        'isEraserSelected': state.isEraserSelected,
        'isPenSelected': state.isPenSelected,
      };
      final documentFile = File(documentPath);
      await documentFile.writeAsString(jsonEncode(documentData));

      emit(state.copyWith(
        savedImagePath: imagePath,
        savedDocumentPath: documentPath,
      ));

      print('Prescription saved to $documentPath');
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Error saving prescription: $e',
      ));
    }
  }
  /* Future<void> _onSaveScreenshot(
      OnSaveScreenshot event, Emitter<DrawingState> emit) async {
    final canvasKey = event.canvasKey;
    try {
      final boundary = canvasKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Canvas boundary not found.');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to capture image.');
      }
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      if (kIsWeb) {
        // For Flutter Web
        final blob = html.Blob([pngBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..target = 'blank'
          ..download = 'screenshot.png';
        anchor.click();
        html.Url.revokeObjectUrl(url);
      } else {
        // For Mobile/Desktop
        final directory = await getApplicationDocumentsDirectory();
        final filePath =
            '${directory.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(filePath);
        await file.writeAsBytes(pngBytes);

        print('Screenshot saved to $filePath');
      }
    } catch (e) {
      print('Error saving screenshot: $e');
    }
  }
*/
  /* Future<void> _onLoadPrescriptionPad(
      OnLoadPrescriptionPad event, Emitter<DrawingState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));

      if (kIsWeb) {
        // For Flutter Web
        final html.HttpRequest request = await html.HttpRequest.request(
          event.imagePath,
          responseType: 'arraybuffer',
        );
        final bytes = Uint8List.view(request.response as ByteBuffer);
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        final image = frame.image;

        emit(state.copyWith(
          editableImage: image,
          isLoading: false,
        ));
      } else {
        // For Mobile/Desktop
        final file = File(event.imagePath);

        if (!await file.exists()) {
          throw Exception('File not found: ${event.imagePath}');
        }

        final bytes = await file.readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        final image = frame.image;

        emit(state.copyWith(
          editableImage: image,
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load prescription pad: $e',
      ));
    }
  }*/

  /*Future<void> _onLoadPrescriptionPad(
      OnLoadPrescriptionPad event, Emitter<DrawingState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));

      final file = File(event.imagePath);

      if (!await file.exists()) {
        throw Exception('File not found: ${event.imagePath}');
      }

      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      emit(state.copyWith(
        editableImage: image,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load prescription pad: $e',
      ));
    }
  }
*/
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

      // Load the prescription pad image
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
        errorMessage: 'Failed to fetch prescription: $e',
      ));
    }
  }

  Future<Uint8List> fetchImageBytes(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('File not found: $imagePath');
    }
    return await file.readAsBytes();
  }

  Future<void> _onLoadPrescriptionPad(
      OnLoadPrescriptionPad event, Emitter<DrawingState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));

      final bytes = await fetchImageBytes(event.imagePath);
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      emit(state.copyWith(
        editableImage: image,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load prescription pad: $e',
      ));
    }
  }

  /* Future<void> _onFetchDocument(
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
*/
  void _onEnableEditing(OnEnableEditing event, Emitter<DrawingState> emit) {
    emit(state.copyWith(isEditing: !state.isEditing));
  }
}

Future<bool> _requestStoragePermission() async {
  if (Platform.isAndroid) {
    // For Android 11+ (Scoped Storage)
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    // For Android 10 and below
    if (await Permission.storage.request().isGranted) {
      return true;
    }

    // For Android 13+ (Photos permission)
    if (await Permission.photos.request().isGranted) {
      return true;
    }

    return false; // Permission denied
  }
  return true; // iOS does not require extra permission
}
