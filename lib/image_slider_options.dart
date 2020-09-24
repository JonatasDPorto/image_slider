import 'image_slider_style.dart';
import 'package:flutter/material.dart';

class ImageSliderStyle {
  final double imageWidth;
  final double borderWidth;
  final double strokeWidth;
  final double anchorWidth;
  final double height;

  const ImageSliderStyle._({
    @required this.imageWidth,
    @required this.borderWidth,
    @required this.strokeWidth,
    @required this.anchorWidth,
  }) : this.height = imageWidth;

  factory ImageSliderStyle(style, imgWidth) {
    switch (style) {
      case ImageSliderStyleEnum.DEFAULT:
        return ImageSliderStyle._(
          imageWidth: imgWidth,
          borderWidth: 5,
          strokeWidth: imgWidth,
          anchorWidth: imgWidth / 2,
        );
        break;
      case ImageSliderStyleEnum.NODE_BORDERLESS:
        return ImageSliderStyle._(
          imageWidth: imgWidth,
          borderWidth: 0,
          strokeWidth: (imgWidth / 4) * 3,
          anchorWidth: imgWidth / 2,
        );
        break;
      case ImageSliderStyleEnum.BORDERLESS:
        return ImageSliderStyle._(
          imageWidth: imgWidth,
          borderWidth: 0,
          strokeWidth: imgWidth,
          anchorWidth: imgWidth / 2,
        );
        break;
      case ImageSliderStyleEnum.NODE:
        return ImageSliderStyle._(
          imageWidth: imgWidth,
          borderWidth: 5,
          strokeWidth: (imgWidth / 4) * 3,
          anchorWidth: imgWidth / 2,
        );
        break;
      default:
        return ImageSliderStyle(ImageSliderStyleEnum.DEFAULT, imgWidth);
    }
  }
}
