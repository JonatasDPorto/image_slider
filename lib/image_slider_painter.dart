import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Custom painter for rendering the ImageSlider track, anchors, borders, and image
/// 
/// This painter handles ALL visual elements of the slider, ensuring perfect alignment
/// since everything uses the same coordinate system.
class ImageSliderPainter extends CustomPainter {
  /// Current position of the slider along the track (in pixels) - center of image
  final double sliderPosition;

  /// Current position of the slider as a percentage (0.0 to 1.0)
  final double sliderPercentage;

  /// Number of images in the slider
  final int numImages;

  /// Color of the slider track and anchors
  final Color color;

  /// Color of the slider border
  final Color borderColor;

  /// Width (and height) of the draggable image indicator
  final double imageWidth;

  /// Width of the stroke used to draw the slider track
  final double strokeWidth;

  /// Width of the anchor points along the track
  final double anchorWidth;

  /// Width of the border around the slider track
  final double borderWidth;

  /// The loaded image to display at the current position
  final ui.Image? currentImage;

  /// Current selected position index
  final int currentPosition;

  /// All loaded images indexed by position
  final Map<int, ui.Image> allImages;

  /// Total width of the slider
  final double sliderWidth;

  /// Paint object for filling anchor points
  final Paint _fillPainter;

  /// Paint object for drawing the slider track line
  final Paint _sliderPainter;

  /// Paint object for filling border elements
  final Paint _borderFillPainter;

  /// Paint object for drawing border lines
  final Paint _borderSliderPainter;

  /// Creates an [ImageSliderPainter] with the given configuration
  ImageSliderPainter({
    required this.sliderPosition,
    required this.sliderPercentage,
    required this.color,
    required this.imageWidth,
    required this.borderColor,
    required this.strokeWidth,
    required this.anchorWidth,
    required this.borderWidth,
    required this.numImages,
    required this.sliderWidth,
    required this.currentPosition,
    required this.allImages,
    this.currentImage,
  })  : _fillPainter = Paint()
          ..color = color
          ..style = PaintingStyle.fill,
        _borderFillPainter = Paint()
          ..color = borderColor
          ..style = PaintingStyle.fill,
        _sliderPainter = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
        _borderSliderPainter = Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth > 0 ? imageWidth + (borderWidth * 2) : 0
          ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    // Paint in order: border (back), line, anchors, then images (front)
    // This ensures images are always visible on top
    _paintBorder(canvas, size);
    _paintLine(canvas, size);
    _paintAnchors(canvas, size);
    _paintAllImages(canvas, size);
  }

  /// Calculates the X coordinate of an anchor center for a given index
  /// This must match exactly with _ImageSliderState._calculateImageCenterX
  double _calculateAnchorX(int index, double width) {
    final imageWidthHalf = imageWidth / 2;
    
    // Border width doesn't affect positioning - it's just visual padding
    // The first anchor should be at imageWidthHalf from the left edge
    // The last anchor should be at width - imageWidthHalf from the left edge
    final startX = imageWidthHalf;
    final endX = width - imageWidthHalf;
    final availableWidth = endX - startX;

    if (numImages == 1) {
      return width / 2;
    }

    if (availableWidth <= 0) {
      return width / 2;
    }

    final numSegments = numImages - 1;
    final segmentWidth = numSegments > 0 ? availableWidth / numSegments : 0.0;
    final anchorX = startX + (index * segmentWidth);

    return anchorX;
  }

  /// Paints the border around the slider track (if borderWidth > 0)
  void _paintBorder(Canvas canvas, Size size) {
    if (borderWidth <= 0) return;

    final centerY = size.height / 2;
    final imageWidthHalf = imageWidth / 2;
    // Border is drawn around the track line, starting from imageWidthHalf
    final startX = imageWidthHalf;
    final endX = size.width - imageWidthHalf;
    final borderRadius = imageWidthHalf + borderWidth;

    // Draw border line (this is the outer border around the track)
    final borderPath = Path()
      ..moveTo(startX, centerY)
      ..lineTo(endX, centerY);
    canvas.drawPath(borderPath, _borderSliderPainter);

    // Draw border circles at ends
    canvas.drawCircle(Offset(startX, centerY), borderRadius, _borderFillPainter);
    canvas.drawCircle(Offset(endX, centerY), borderRadius, _borderFillPainter);
  }

  /// Paints the main slider track line
  void _paintLine(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final imageWidthHalf = imageWidth / 2;
    // Track line spans from first to last image center
    final startX = imageWidthHalf;
    final endX = size.width - imageWidthHalf;

    final linePath = Path()
      ..moveTo(startX, centerY)
      ..lineTo(endX, centerY);
    canvas.drawPath(linePath, _sliderPainter);
  }

  /// Paints the anchor points along the slider track
  void _paintAnchors(Canvas canvas, Size size) {
    if (numImages <= 0) return;

    final centerY = size.height / 2;

    for (var i = 0; i < numImages; i++) {
      final x = _calculateAnchorX(i, size.width);
      
      // Draw outer anchor circle
      canvas.drawCircle(Offset(x, centerY), anchorWidth, _fillPainter);
      
      // Draw inner anchor dot
      final innerRadius = anchorWidth / _PainterConstants.innerDotRatio;
      canvas.drawCircle(Offset(x, centerY), innerRadius, _borderFillPainter);
    }
  }

  /// Paints all images: non-selected ones in grayscale at anchor positions,
  /// and the selected one normally at the slider position
  void _paintAllImages(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final imageWidthHalf = imageWidth / 2;

    // First, paint all non-selected images in grayscale at their anchor positions
    for (int i = 0; i < numImages; i++) {
      final image = allImages[i];
      if (image == null) continue;

      // Skip the current position - it will be painted separately at slider position
      if (i == currentPosition) continue;

      final anchorX = _calculateAnchorX(i, size.width);
      
      // Always draw non-selected images in grayscale at their anchor positions
      _paintImageAtPosition(
        canvas,
        image,
        anchorX,
        centerY,
        imageWidthHalf,
        grayscale: true,
      );
    }

    // Finally, paint the current/selected image normally at the slider position
    if (currentImage != null) {
      _paintImageAtPosition(
        canvas,
        currentImage!,
        sliderPosition,
        centerY,
        imageWidthHalf,
        grayscale: false,
      );
    }
  }

  /// Paints a single image at a specific position
  /// Uses the exact same coordinate system as anchors, ensuring perfect alignment
  void _paintImageAtPosition(
    Canvas canvas,
    ui.Image image,
    double centerX,
    double centerY,
    double imageWidthHalf, {
    required bool grayscale,
  }) {
    // Calculate the bounds for the image
    final imageLeft = centerX - imageWidthHalf;
    final imageTop = centerY - imageWidthHalf;
    final imageRect = Rect.fromLTWH(
      imageLeft,
      imageTop,
      imageWidth,
      imageWidth,
    );

    // Draw the image using drawImageRect for precise control
    final srcRect = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    
    // Use a Paint with anti-aliasing for smooth edges
    final imagePaint = Paint()
      ..isAntiAlias = true;
    
    // Apply grayscale filter if needed
    if (grayscale) {
      // Create a grayscale color filter
      // Using matrix for grayscale conversion: [0.2126, 0.7152, 0.0722] for RGB weights
      imagePaint.colorFilter = const ColorFilter.matrix([
        0.2126, 0.7152, 0.0722, 0, 0, // Red channel
        0.2126, 0.7152, 0.0722, 0, 0, // Green channel
        0.2126, 0.7152, 0.0722, 0, 0, // Blue channel
        0, 0, 0, 1, 0, // Alpha channel
      ]);
    }
    
    // Draw the image in a circle using clipPath
    canvas.save();
    final clipPath = Path()
      ..addOval(imageRect);
    canvas.clipPath(clipPath);
    canvas.drawImageRect(
      image,
      srcRect,
      imageRect,
      imagePaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(ImageSliderPainter oldDelegate) {
    // Always repaint if position changed (use exact comparison for reliability)
    return sliderPosition != oldDelegate.sliderPosition ||
        sliderPercentage != oldDelegate.sliderPercentage ||
        color != oldDelegate.color ||
        borderColor != oldDelegate.borderColor ||
        imageWidth != oldDelegate.imageWidth ||
        strokeWidth != oldDelegate.strokeWidth ||
        anchorWidth != oldDelegate.anchorWidth ||
        borderWidth != oldDelegate.borderWidth ||
        numImages != oldDelegate.numImages ||
        sliderWidth != oldDelegate.sliderWidth ||
        currentPosition != oldDelegate.currentPosition ||
        currentImage != oldDelegate.currentImage ||
        allImages.length != oldDelegate.allImages.length ||
        _hasImagesChanged(oldDelegate);
  }

  /// Checks if any images in the map have changed
  bool _hasImagesChanged(ImageSliderPainter oldDelegate) {
    if (allImages.length != oldDelegate.allImages.length) return true;
    
    for (final entry in allImages.entries) {
      final oldImage = oldDelegate.allImages[entry.key];
      if (oldImage != entry.value) return true;
    }
    
    return false;
  }
}

/// Internal constants for painter calculations
class _PainterConstants {
  _PainterConstants._(); // Private constructor

  /// Ratio used to calculate inner dot radius (1/10 of anchor width)
  static const double innerDotRatio = 10.0;
}
