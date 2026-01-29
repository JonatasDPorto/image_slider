library image_slider;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_slider_button/image_slider_style.dart';
import 'image_slider_painter.dart';
export 'package:image_slider_button/image_slider_style.dart';

/// Callback signature for when the slider drag starts
typedef ImageSliderOnStartCallback = void Function();

/// Callback signature for when the slider position updates during drag
///
/// [percentage] is a value between 0.0 and 1.0 representing the slider position
typedef ImageSliderOnUpdateCallback = void Function(double percentage);

/// Callback signature for when the slider drag ends
///
/// [position] is the index of the selected image (0-based)
typedef ImageSliderOnEndCallback = void Function(int position);

/// A customizable slider widget that displays images and allows users to select
/// one by dragging horizontally.
///
/// The slider displays a series of images along a track, and users can drag
/// to select different images. The widget supports various visual styles and
/// provides callbacks for drag events.
///
/// Example:
/// ```dart
/// ImageSlider(
///   images: [
///     AssetImage('assets/image1.png'),
///     AssetImage('assets/image2.png'),
///   ],
///   onEnd: (position) {
///     print('Selected image at position: $position');
///   },
/// )
/// ```
class ImageSlider extends StatefulWidget {
  /// List of images to display in the slider
  ///
  /// Must contain at least one image. If empty, an assertion error will be thrown.
  final List<ImageProvider> images;

  /// Initial position of the slider (0-based index)
  ///
  /// Defaults to 0. If out of bounds, will be clamped to valid range.
  final int startPosition;

  /// Callback invoked when the user starts dragging the slider
  final ImageSliderOnStartCallback? onStart;

  /// Callback invoked during slider drag with the current percentage (0.0 to 1.0)
  final ImageSliderOnUpdateCallback? onUpdate;

  /// Callback invoked when the user finishes dragging the slider
  ///
  /// Provides the final selected position (0-based index)
  final ImageSliderOnEndCallback? onEnd;

  /// Style configuration for the slider
  ///
  /// If null, defaults to [ImageSliderStyleEnum.DEFAULT] style
  final ImageSliderStyleOptions? style;

  /// Creates an [ImageSlider] widget
  ///
  /// The [images] parameter is required and must not be empty.
  ///
  /// Throws an [AssertionError] if [images] is empty.
  ImageSlider({
    Key? key,
    required this.images,
    this.startPosition = 0,
    this.onStart,
    this.onUpdate,
    this.onEnd,
    this.style,
  })  : assert(images.isNotEmpty, 'Images list cannot be empty'),
        super(key: key);

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  late double _imageCenterX;
  late double _dragPercentage;
  late int _currentPosition;
  late double _sliderWidth;
  bool _widthIsChanged = false;

  /// Default style used when no style is provided
  ImageSliderStyleOptions _defaultStyle =
      ImageSliderStyleOptions(style: ImageSliderStyleEnum.DEFAULT);

  /// Key to access the SizedBox RenderBox for accurate drag calculations
  final GlobalKey _sizedBoxKey = GlobalKey();

  /// Currently loaded image for painting
  ui.Image? _currentImage;

  /// All loaded images for painting (indexed by position)
  final Map<int, ui.Image> _loadedImages = {};

  /// Image streams for loading images
  final Map<int, ImageStream> _imageStreams = {};

  /// Image stream listeners for loading images
  final Map<int, ImageStreamListener> _imageListeners = {};

  @override
  void initState() {
    super.initState();
    _initializeStyle();
    _initializeDimensions();
    _initializePosition();
    _loadAllImages();
  }

  @override
  void didUpdateWidget(ImageSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.images.length != widget.images.length ||
        oldWidget.startPosition != widget.startPosition ||
        oldWidget.style != widget.style) {
      _initializeStyle();
      _initializeDimensions();
      _initializePosition();
      _loadAllImages();
    }
  }

  @override
  void dispose() {
    _removeAllImageListeners();
    super.dispose();
  }

  /// Removes all image listeners
  void _removeAllImageListeners() {
    for (final entry in _imageStreams.entries) {
      final index = entry.key;
      final stream = entry.value;
      final listener = _imageListeners[index];
      if (listener != null) {
        stream.removeListener(listener);
      }
    }
    _imageStreams.clear();
    _imageListeners.clear();
  }

  /// Removes a specific image listener
  void _removeImageListener(int index) {
    final stream = _imageStreams[index];
    final listener = _imageListeners[index];
    if (stream != null && listener != null) {
      stream.removeListener(listener);
      _imageStreams.remove(index);
      _imageListeners.remove(index);
    }
  }

  /// Loads all images for painting
  void _loadAllImages() {
    for (int i = 0; i < widget.images.length; i++) {
      _loadImageAtIndex(i);
    }
  }

  /// Loads a specific image at the given index
  void _loadImageAtIndex(int index) {
    // Remove existing listener if any
    _removeImageListener(index);

    final imageProvider = widget.images[index];
    final imageStream = imageProvider.resolve(ImageConfiguration.empty);
    final imageListener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) =>
          _onImageLoaded(index, info, synchronousCall),
    );

    imageStream.addListener(imageListener);
    _imageStreams[index] = imageStream;
    _imageListeners[index] = imageListener;
  }

  /// Callback when image is loaded
  void _onImageLoaded(int index, ImageInfo info, bool synchronousCall) {
    if (mounted) {
      setState(() {
        _loadedImages[index] = info.image;
        // Update current image if this is the current position
        if (index == _currentPosition) {
          _currentImage = info.image;
        }
      });
    }
  }

  /// Initializes the style, using default if none provided
  void _initializeStyle() {
    _defaultStyle = widget.style ??
        ImageSliderStyleOptions(style: ImageSliderStyleEnum.DEFAULT);
  }

  /// Initializes slider dimensions
  void _initializeDimensions() {
    _sliderWidth = _defaultStyle.width;
    _widthIsChanged = false;
  }

  /// Initializes the slider position and calculates initial image center position
  void _initializePosition() {
    _currentPosition = _clampPosition(widget.startPosition);
    _imageCenterX = _calculateImageCenterX(_currentPosition);
    _dragPercentage = _sliderWidth > 0 ? _imageCenterX / _sliderWidth : 0.0;
  }

  /// Clamps the position to valid range [0, images.length - 1]
  int _clampPosition(int position) {
    if (position < 0) return 0;
    if (position >= widget.images.length) return widget.images.length - 1;
    return position;
  }

  /// Calculates the X coordinate of the image center for a given index
  /// This must match exactly with ImageSliderPainter._calculateAnchorX
  double _calculateImageCenterX(int index) {
    final computedOptions = _defaultStyle.computedOptions;
    final imageWidth = computedOptions.imageWidth;
    final imageWidthHalf = imageWidth / 2;

    // Ensure index is valid
    final clampedIndex = index.clamp(0, widget.images.length - 1);
    final numImages = widget.images.length;

    // Single image: center it
    if (numImages == 1) {
      return _sliderWidth / 2;
    }

    // Calculate the space available for distributing image centers
    // The first image center should be at imageWidthHalf from the left edge
    // The last image center should be at sliderWidth - imageWidthHalf from the left edge
    // Border width doesn't affect the positioning - it's just visual padding
    final startX = imageWidthHalf;
    final endX = _sliderWidth - imageWidthHalf;
    final availableWidth = endX - startX;

    // If available width is invalid, center the image
    if (availableWidth <= 0) {
      return _sliderWidth / 2;
    }

    // Distribute image centers evenly across available width
    // For numImages images, we have numImages-1 segments
    final numSegments = numImages - 1;
    final segmentWidth = numSegments > 0 ? availableWidth / numSegments : 0.0;

    // Calculate center X position for the given index
    // Formula: startX + (index * segmentWidth)
    final centerX = startX + (clampedIndex * segmentWidth);

    return centerX;
  }

  /// Gets the minimum valid image center X position (first anchor)
  double _getMinImageCenterX() {
    if (widget.images.length <= 1) {
      return _sliderWidth / 2;
    }
    return _calculateImageCenterX(0);
  }

  /// Gets the maximum valid image center X position (last anchor)
  double _getMaxImageCenterX() {
    if (widget.images.length <= 1) {
      return _sliderWidth / 2;
    }
    final computedOptions = _defaultStyle.computedOptions;
    final imageWidthHalf = computedOptions.imageWidth / 2;

    // Calculate last anchor position
    final lastAnchorX = _calculateImageCenterX(widget.images.length - 1);

    // Ensure image doesn't go out of bounds
    final maxPossibleX = _sliderWidth - imageWidthHalf;

    return lastAnchorX.clamp(0.0, maxPossibleX);
  }

  /// Updates the image position based on drag offset
  void _updateImagePosition(double offsetX) {
    final minX = _getMinImageCenterX();
    final maxX = _getMaxImageCenterX();

    // Clamp to valid range
    final newCenterX = offsetX.clamp(minX, maxX);

    if (mounted) {
      setState(() {
        _imageCenterX = newCenterX;
        _dragPercentage = _sliderWidth > 0 ? _imageCenterX / _sliderWidth : 0.0;
      });
    }
  }

  /// Finds the nearest anchor index to the current image position
  int _findNearestAnchorIndex() {
    if (widget.images.length <= 1) return 0;

    int nearestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < widget.images.length; i++) {
      final anchorCenterX = _calculateImageCenterX(i);
      final distance = (_imageCenterX - anchorCenterX).abs();
      if (distance < minDistance) {
        minDistance = distance;
        nearestIndex = i;
      }
    }

    return nearestIndex;
  }

  /// Snaps the image to the nearest anchor position
  void _snapToNearestAnchor() {
    final nearestIndex = _findNearestAnchorIndex();
    final newCenterX = _calculateImageCenterX(nearestIndex);

    if (mounted) {
      setState(() {
        _imageCenterX = newCenterX;
        _dragPercentage = _sliderWidth > 0 ? _imageCenterX / _sliderWidth : 0.0;
        final oldPosition = _currentPosition;
        _currentPosition = nearestIndex;

        // Update current image if position changed
        if (oldPosition != _currentPosition) {
          _currentImage = _loadedImages[_currentPosition];
        }
      });
    }
  }

  /// Handles drag update events
  void _onDragUpdate(DragUpdateDetails update) {
    final renderBox = _sizedBoxKey.currentContext?.findRenderObject();
    if (renderBox is! RenderBox) return;

    final localOffset = renderBox.globalToLocal(update.globalPosition);
    _updateImagePosition(localOffset.dx);
    widget.onUpdate?.call(_dragPercentage);
  }

  /// Handles drag start events
  void _onDragStart(DragStartDetails start) {
    final renderBox = _sizedBoxKey.currentContext?.findRenderObject();
    if (renderBox is! RenderBox) return;

    final localOffset = renderBox.globalToLocal(start.globalPosition);
    _updateImagePosition(localOffset.dx);
    widget.onStart?.call();
  }

  /// Handles drag end events
  void _onDragEnd(BuildContext context, DragEndDetails end) {
    _snapToNearestAnchor();
    if (mounted) {
      widget.onEnd?.call(_currentPosition);
    }
  }

  /// Calculates the minimum allowed width for the slider
  double _calculateMinWidth() {
    final computedOptions = _defaultStyle.computedOptions;
    // Border is visual only, doesn't need extra space in min width calculation
    return computedOptions.imageWidth + _SliderConstants.minWidthBuffer;
  }

  /// Adjusts width based on available constraints
  void _adjustWidthForConstraints(BoxConstraints constraints) {
    if (_widthIsChanged || _sliderWidth <= constraints.maxWidth) return;

    // Use same margin calculation as build method - border doesn't need extra space
    final margin = _SliderConstants.marginBuffer;
    final minWidth = _calculateMinWidth();
    final maxAvailableWidth = constraints.maxWidth - (margin * 2);

    _sliderWidth = maxAvailableWidth.clamp(minWidth, double.infinity);
    _widthIsChanged = true;

    // Recalculate image position with new width
    _imageCenterX = _calculateImageCenterX(_currentPosition);
    _dragPercentage = _sliderWidth > 0 ? _imageCenterX / _sliderWidth : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _adjustWidthForConstraints(constraints);

        final computedOptions = _defaultStyle.computedOptions;
        // Borderless works because there's no margin - apply same logic for all styles
        // Border is visual only, doesn't need extra margin space
        final margin = EdgeInsets.all(_SliderConstants.marginBuffer);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: margin,
            child: SizedBox(
              key: _sizedBoxKey,
              width: _sliderWidth,
              height: computedOptions.height,
              child: CustomPaint(
                painter: ImageSliderPainter(
                  color: _defaultStyle.color,
                  sliderPercentage: _dragPercentage,
                  sliderPosition: _imageCenterX,
                  numImages: widget.images.length,
                  strokeWidth: computedOptions.strokeWidth,
                  anchorWidth: computedOptions.anchorWidth,
                  imageWidth: computedOptions.imageWidth,
                  borderWidth: computedOptions.borderWidth,
                  borderColor: _defaultStyle.borderColor,
                  currentImage: _currentImage,
                  currentPosition: _currentPosition,
                  allImages: _loadedImages,
                  sliderWidth: _sliderWidth,
                ),
              ),
            ),
          ),
          onHorizontalDragUpdate: (update) => _onDragUpdate(update),
          onHorizontalDragStart: (start) => _onDragStart(start),
          onHorizontalDragEnd: (end) => _onDragEnd(context, end),
        );
      },
    );
  }
}

/// Internal constants for slider calculations
class _SliderConstants {
  _SliderConstants._(); // Private constructor

  /// Minimum width buffer to ensure slider remains usable
  static const double minWidthBuffer = 10.0;

  /// Margin buffer for container margins
  static const double marginBuffer = 1.0;
}
