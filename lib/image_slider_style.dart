import 'package:flutter/material.dart';

import 'image_slider_options.dart';

enum ImageSliderStyleEnum {
  DEFAULT,
  BORDERLESS,
  NODE,
  NODE_BORDERLESS,
  LINE,
  LINE_BORDERLESS,
}

class ImageSliderStyleOptions {
  final ImageSliderStyleEnum style;
  final ImageSliderStyle options;
  final Color color;
  final Color borderColor;
  final double width;
  final double imageWidth;

  ImageSliderStyleOptions({
    this.style = ImageSliderStyleEnum.DEFAULT,
    this.color = Colors.grey,
    this.width = 200,
    this.imageWidth = 40,
    this.borderColor = Colors.white,
  }) : this.options = ImageSliderStyle(style, imageWidth);
}
