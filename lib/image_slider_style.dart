import 'package:flutter/material.dart';

import 'image_slider_options.dart';

/// Enumeration of available slider visual styles
enum ImageSliderStyleEnum {
  /// Default style with borders and full-width stroke
  DEFAULT,

  /// Style without borders, full-width stroke
  BORDERLESS,

  /// Style with borders and node-style stroke (3/4 width)
  NODE,

  /// Style without borders, node-style stroke (3/4 width)
  NODE_BORDERLESS,

  /// Minimal line style with borders (5px stroke)
  LINE,

  /// Minimal line style without borders (5px stroke)
  LINE_BORDERLESS,
}

/// Configuration options for the ImageSlider widget's visual appearance
///
/// This class provides a convenient way to customize the slider's appearance
/// including colors, dimensions, and style preset.
///
/// Example:
/// ```dart
/// ImageSliderStyleOptions(
///   style: ImageSliderStyleEnum.DEFAULT,
///   width: 300,
///   imageWidth: 50,
///   color: Colors.blue,
///   borderColor: Colors.white,
/// )
/// ```
class ImageSliderStyleOptions {
  /// The visual style preset to use
  final ImageSliderStyleEnum style;

  /// Color of the slider track and anchors
  final Color color;

  /// Color of the slider border (if applicable)
  final Color borderColor;

  /// Total width of the slider widget
  final double width;

  /// Width (and height) of the draggable image indicator
  final double imageWidth;

  /// Creates an [ImageSliderStyleOptions] instance
  ///
  /// All parameters have sensible defaults. The [options] field is automatically
  /// computed based on the [style] and [imageWidth] parameters.
  ///
  /// Throws an [AssertionError] if [width] or [imageWidth] are non-positive.
  ImageSliderStyleOptions({
    this.style = ImageSliderStyleEnum.DEFAULT,
    this.color = Colors.grey,
    this.width = 200,
    this.imageWidth = 40,
    this.borderColor = Colors.white,
  })  : assert(width > 0, 'Width must be positive'),
        assert(imageWidth > 0, 'Image width must be positive');

  /// Gets the computed style options based on the selected style
  ImageSliderStyle get computedOptions {
    return ImageSliderStyle(style, imageWidth);
  }

  /// Creates a copy of this [ImageSliderStyleOptions] with the given fields
  /// replaced with new values
  ImageSliderStyleOptions copyWith({
    ImageSliderStyleEnum? style,
    Color? color,
    Color? borderColor,
    double? width,
    double? imageWidth,
  }) {
    return ImageSliderStyleOptions(
      style: style ?? this.style,
      color: color ?? this.color,
      borderColor: borderColor ?? this.borderColor,
      width: width ?? this.width,
      imageWidth: imageWidth ?? this.imageWidth,
    );
  }
}
