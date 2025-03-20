import 'package:drawing_app/drawing_canvas/bloc/drawing_canvas_bloc.dart';
import 'package:drawing_canvas_ui/drawing_canvas_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class DrawingCanvasView extends StatefulWidget {
  const DrawingCanvasView({super.key});

  @override
  State<DrawingCanvasView> createState() => _DrawingCanvasViewState();
}

class _DrawingCanvasViewState extends State<DrawingCanvasView> {
  bool isSidebarOpen = false;
  bool isPrescriptionPadEnabled = false; // Toggle for prescription pad
  final GlobalKey canvasKey = GlobalKey();
  final GlobalKey prescriptionPadKey =
      GlobalKey(); // Define the prescription pad key

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate),
            tooltip: 'Add Existing Pad',
            iconSize: 30,
            onPressed: () {
              context
                  .read<DrawingBloc>()
                  .add(const OnLoadImage(fromGallery: true));
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            iconSize: 30,
            onPressed: () {
              context.read<DrawingBloc>().add(OnSaveScreenshot(canvasKey));
            },
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: 'Save Screenshot',
            iconSize: 30,
            onPressed: () {
              context.read<DrawingBloc>().add(OnSaveScreenshot(canvasKey));
            },
          ),
          IconButton(
            icon: const Icon(Icons.medical_services),
            tooltip: 'Prescription Pad',
            iconSize: 30,
            onPressed: () async {
              setState(() {
                isPrescriptionPadEnabled = !isPrescriptionPadEnabled;
              });

              if (isPrescriptionPadEnabled) {
                const imagePath =
                    'assets/images/doctor.jpg'; // Path to the prescription pad image
                context
                    .read<DrawingBloc>()
                    .add(const OnLoadImage(fromGallery: false));
                context
                    .read<DrawingBloc>()
                    .add(const OnLoadPrescriptionPad(imagePath));
              } else {
                context.read<DrawingBloc>().add(const OnClearDrawing());
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear',
            iconSize: 30,
            onPressed: () {
              context.read<DrawingBloc>().add(const OnClearDrawing());
            },
          ),
          BlocBuilder<DrawingBloc, DrawingState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.isEraserSelected
                      ? Icons.brush
                      : Icons.cleaning_services,
                ),
                tooltip: state.isEraserSelected
                    ? 'Switch to Pen'
                    : 'Switch to Eraser',
                iconSize: 30,
                onPressed: () {
                  context.read<DrawingBloc>().add(
                        state.isEraserSelected
                            ? const OnSelectPen() // Switch to pen
                            : const OnSelectEraser(), // Switch to eraser
                      );
                },
              );
            },
          ),
        ],
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'Drawing Canvas',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(isSidebarOpen ? Icons.close : Icons.menu),
          onPressed: () => setState(() {
            isSidebarOpen = !isSidebarOpen;
          }),
        ),
      ),
      body: BlocConsumer<DrawingBloc, DrawingState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          } else if (state.savedDocumentPath != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image saved successfully!')),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Main Canvas
              Positioned.fill(
                child: RepaintBoundary(
                  key: canvasKey,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: GestureDetector(
                        onPanStart: (details) {
                          context
                              .read<DrawingBloc>()
                              .add(OnStartDrawing(details.localPosition));
                        },
                        onPanUpdate: (details) {
                          context
                              .read<DrawingBloc>()
                              .add(OnDrawing(details.localPosition));
                        },
                        onPanEnd: (details) {
                          context
                              .read<DrawingBloc>()
                              .add(const OnStopDrawing());
                        },
                        child: BlocBuilder<DrawingBloc, DrawingState>(
                          builder: (context, state) {
                            return CustomPaint(
                              painter: DrawingCanvas(
                                drawingPoints: state.drawingPoints,
                                editableImage: state.editableImage,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              if (isPrescriptionPadEnabled)
                Positioned.fill(
                  child: RepaintBoundary(
                    key: prescriptionPadKey, // Use the new key here
                    child: Stack(
                      children: [
                        // Prescription Pad Background
                        Opacity(
                          opacity: 0.5,
                          child: Image.asset(
                            'assets/images/doctor.jpg',
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                          ),
                        ),
                        // Drawing Canvas on Top of the Prescription Pad
                        GestureDetector(
                          onPanStart: (details) {
                            context
                                .read<DrawingBloc>()
                                .add(OnStartDrawing(details.localPosition));
                          },
                          onPanUpdate: (details) {
                            context
                                .read<DrawingBloc>()
                                .add(OnDrawing(details.localPosition));
                          },
                          onPanEnd: (details) {
                            context
                                .read<DrawingBloc>()
                                .add(const OnStopDrawing());
                          },
                          child: BlocBuilder<DrawingBloc, DrawingState>(
                            builder: (context, state) {
                              return CustomPaint(
                                painter: DrawingCanvas(
                                  drawingPoints: state.drawingPoints,
                                  editableImage: state.editableImage,
                                ),
                                child:
                                    Container(), // Ensures the canvas is interactive
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Collapsible Sidebar
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: 0,
                bottom: 0,
                left: isSidebarOpen ? 0 : -280,
                child: Container(
                  width: 280,
                  color: theme.colorScheme.surface,
                  padding: const EdgeInsets.all(24),
                  child: _buildSidebarContent(context),
                ),
              ),

              // Loading Indicator
              if (state.isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidebarContent(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tools',
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        // Add more tools here if needed
      ],
    );
  }
}
