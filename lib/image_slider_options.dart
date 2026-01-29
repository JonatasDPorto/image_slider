import 'image_slider_style.dart';

/// Internal style configuration class that computes dimension values
/// based on a style preset and image width
/// 
/// This class is used internally by [ImageSliderStyleOptions] to calculate
/// the appropriate dimensions for different visual styles.
class ImageSliderStyle {
  /// Width (and height) of the draggable image indicator
  final double imageWidth;

  /// Width of the border around the slider track
  final double borderWidth;

  /// Width of the stroke used to draw the slider track
  final double strokeWidth;

  /// Width of the anchor points along the track
  final double anchorWidth;

  /// Height of the slider track (equals imageWidth)
  final double height;

  /// Private constructor for creating style instances
  const ImageSliderStyle._({
    required this.imageWidth,
    required this.borderWidth,
    required this.strokeWidth,
    required this.anchorWidth,
  }) : height = imageWidth;

  /// Factory constructor that creates a style based on the preset and image width
  /// 
  /// Returns a [ImageSliderStyle] instance with dimensions calculated according
  /// to the provided [style] preset and [imgWidth] parameter.
  /// 
  /// If an unknown style is provided, defaults to [ImageSliderStyleEnum.DEFAULT].
  factory ImageSliderStyle(ImageSliderStyleEnum style, double imgWidth) {
    assert(imgWidth > 0, 'Image width must be positive');

    switch (style) {
      case ImageSliderStyleEnum.DEFAULT:
        return ImageSliderStyle._(
          imageWidth: imgWidth,
          borderWidth: _StyleConstants.defaultBorderWidth,
          strokeWidth: imgWidth,
          anchorWidth: imgWidth / 2,
        );

      case ImageSliderStyleEnum.NODE_BORDERLESS:
        return ImageSliderStyle._(
          imageWidth: imgWidth,
          borderWidth: _StyleConstants.noBorderWidth,
          strokeWidth: imgWidth * _StyleConstants.nodeStrokeRatio,
          anchorWidth: imgWidth / 2,
        );

      case ImageSliderStyleEnum.BORDERLESS:
        return ImageSliderStyle._(
          imageWidth: imgWidth,
          borderWidth: _StyleConstants.noBorderWidth,
          strokeWidth: imgWidth,
          anchorWidth: imgWidth / 2,
        );

      case ImageSliderStyleEnum.NODE:
        return ImageSliderStyle._(
          imageWidth: imgWidth,
          borderWidth: _StyleConstants.defaultBorderWidth,
          strokeWidth: imgWidth * _StyleConstants.nodeStrokeRatio,
          anchorWidth: imgWidth / 2,
        );

      case ImageSliderStyleEnum.LINE:
        return ImageSliderStyle._(
          imageWidth: imgWidth,
          borderWidth: _StyleConstants.defaultBorderWidth,
          strokeWidth: _StyleConstants.lineStrokeWidth,
          anchorWidth: _StyleConstants.lineStrokeWidth,
        );

      case ImageSliderStyleEnum.LINE_BORDERLESS:
        return ImageSliderStyle._(
          imageWidth: imgWidth,
          borderWidth: _StyleConstants.noBorderWidth,
          strokeWidth: _StyleConstants.lineStrokeWidth,
          anchorWidth: _StyleConstants.lineStrokeWidth,
        );
    }
  }
}

/// Internal constants for style calculations
class _StyleConstants {
  _StyleConstants._(); // Private constructor

  /// Default border width for styles that include borders
  static const double defaultBorderWidth = 5.0;

  /// Border width for borderless styles
  static const double noBorderWidth = 0.0;

  /// Stroke width for line-style presets
  static const double lineStrokeWidth = 5.0;

  /// Ratio of image width used for node-style stroke width (3/4)
  static const double nodeStrokeRatio = 0.75;
}
