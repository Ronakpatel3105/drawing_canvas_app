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
  final GlobalKey canvasKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            iconSize: 30,
            onPressed: () {
              context.read<DrawingBloc>().add(OnSaveDrawing(canvasKey));
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
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            iconSize: 30,
            onPressed: () {
              context.read<DrawingBloc>().add(const OnEnableEditing());
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
          } else if (state.savedImagePath != null) {
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
                    margin: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 30,
                      bottom: 30,
                    ),
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
                                backgroundImage: state.backgroundImage,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
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

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        'Tools',
        style:
            theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ToolButton(
            icon: Icons.edit_outlined,
            label: 'Pen',
            isSelected: context.watch<DrawingBloc>().state.isPenSelected,
            onTap: () => context.read<DrawingBloc>().add(const OnSelectPen()),
          ),
          ToolButton(
            icon: Icons.auto_fix_normal,
            label: 'Eraser',
            isSelected: context.watch<DrawingBloc>().state.isEraserSelected,
            onTap: () =>
                context.read<DrawingBloc>().add(const OnSelectEraser()),
          ),
        ],
      ),
      const SizedBox(height: 32),
      Text(
        'Image',
        style:
            theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ImageButton(
            icon: Icons.photo_library_outlined,
            label: 'Gallery',
            onTap: () =>
                context.read<DrawingBloc>().add(OnLoadImage(fromGallery: true)),
          ),
          ImageButton(
            icon: Icons.folder_outlined,
            label: 'File',
            onTap: () =>
                context.read<DrawingBloc>().add(OnLoadImage(fromGallery: true)),
          ),
        ],
      ),
      const SizedBox(height: 32),
      BlocBuilder<DrawingBloc, DrawingState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.isEraserSelected ? 'Eraser Size' : 'Stroke Width',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    state.strokeWidth.round().toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Slider(
                value: state.strokeWidth,
                min: 1,
                max: state.isEraserSelected ? 50 : 20,
                onChanged: (value) =>
                    context.read<DrawingBloc>().add(OnChangePenWidth(value)),
              ),
            ],
          );
        },
      ),
    ]);
  }
}
