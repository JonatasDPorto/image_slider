import 'dart:ui';

import 'package:flutter/material.dart';

class ImageSliderPainter extends CustomPainter {
  final double sliderPosition;
  final double sliderPercentage;
  final int len;
  final Color color;
  final Color borderColor;
  final double imageWidth;
  final double strokeWidth;
  final double anchorWidth;
  final double borderWidth;
  final Paint fillPainter;

  final Paint sliderPainter;
  final Paint borderFillPainter;
  final Paint borderSliderPainter;
  final Paint imagePainter;

  int currentPosition;

  ImageSliderPainter({
    @required this.sliderPosition,
    @required this.sliderPercentage,
    @required this.color,
    @required this.imageWidth,
    @required this.borderColor,
    @required this.strokeWidth,
    @required this.anchorWidth,
    @required this.borderWidth,
    @required this.len,
  })  : fillPainter = Paint()
          ..color = color
          ..style = PaintingStyle.fill,
        borderFillPainter = Paint()
          ..color = borderColor
          ..style = PaintingStyle.fill,
        sliderPainter = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
        borderSliderPainter = Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = ((imageWidth) + (borderWidth * 2)),
        imagePainter = Paint();

  _paintAnchors(Canvas canvas, Size size) {
    var y = size.height / 2;

    for (var i = 0.0; i <= len; i++) {
      double x = (i * ((size.width - imageWidth - (borderWidth * 2)) / len)) +
          (imageWidth / 2) +
          borderWidth;
      canvas.drawCircle(Offset(x, y), anchorWidth, fillPainter);
      canvas.drawCircle(Offset(x, y), anchorWidth / 10, borderFillPainter);
    }
  }

  _paintBorder(Canvas canvas, Size size) {
    if (borderWidth != 0) {
      var y = size.height / 2;
      var end = size.width - (imageWidth / 2) - borderWidth;
      var start = (imageWidth / 2) + borderWidth;
      Path path = Path();
      path.moveTo(start, y);
      path.lineTo(end, y);
      canvas.drawPath(path, borderSliderPainter);
      canvas.drawCircle(Offset(start, y), ((imageWidth / 2) + borderWidth),
          borderFillPainter);
      canvas.drawCircle(
          Offset(end, y), ((imageWidth / 2) + borderWidth), borderFillPainter);
    }
  }

  _paintLine(Canvas canvas, Size size) {
    var y = size.height / 2;
    var end = size.width - (imageWidth / 2) - borderWidth;
    var start = (imageWidth / 2) + borderWidth;
    Path path = Path();
    path.moveTo(start, y);
    path.lineTo(end, y);
    canvas.drawPath(path, sliderPainter);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintBorder(canvas, size);
    _paintLine(canvas, size);
    _paintAnchors(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
