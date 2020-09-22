library image_slider;

import 'package:flutter/material.dart';

import 'image_slider_painter.dart';

class ImageSlider extends StatefulWidget {
  final double width;
  final double height;
  final double imageWidth;
  final double anchorWidth;
  final double strokeWidth;
  final double borderWidth;
  final Color color;
  final Color borderColor;
  final Function onStart;
  final Function onUpdate;
  final Function onEnd;
  final List<ImageProvider> images;
  const ImageSlider({
    @required this.images,
    this.width = 350,
    this.height = 100,
    this.imageWidth = 100,
    this.anchorWidth = 40,
    this.strokeWidth = 60,
    this.color = Colors.grey,
    this.borderColor = Colors.white,
    this.borderWidth = 1.0,
    this.onStart,
    this.onUpdate,
    this.onEnd,
  });

  @override
  _ImageSliderState createState() {
    return _ImageSliderState(imageWidth, borderWidth);
  }
}

class _ImageSliderState extends State<ImageSlider> {
  double dragPosition;

  double dragPercentage = 0.0;

  int currentPosition = 0;

  _ImageSliderState(double imageWidth, double borderWidth)
      : dragPosition = (imageWidth / 2) + borderWidth;

  void _updateDragPosition(Offset offset) {
    double newDragPosition = 0;

    if (offset.dx <= 0) {
      newDragPosition = 0;
    } else if (offset.dx >= widget.width) {
      newDragPosition = widget.width;
    } else {
      newDragPosition = offset.dx;
    }

    setState(() {
      dragPosition = newDragPosition;
      dragPercentage = dragPosition / widget.width;
    });
  }

  void _updateDragPositionEnd() {
    int newCurrentPosition = 0;
    double newDragPosition = 0;
    int len = widget.images.length;
    for (var i = 0; i <= len; i++) {
      if (i == len) {
        newCurrentPosition = i - 1;
        newDragPosition =
            widget.width - (widget.imageWidth / 2) - widget.borderWidth;
        break;
      }
      if (dragPosition < ((widget.width * (i + 1)) / len)) {
        newCurrentPosition = i;
        newDragPosition = widget.borderWidth +
            (widget.imageWidth / 2) +
            (((widget.width - widget.imageWidth - (widget.borderWidth * 2)) *
                    (i)) /
                (len - 1));

        break;
      }
    }

    setState(() {
      dragPosition = newDragPosition;
      dragPercentage = dragPosition / widget.width;
      currentPosition = newCurrentPosition;
    });
  }

  void _onDragUpdate(BuildContext context, DragUpdateDetails update) {
    RenderBox box = context.findRenderObject();
    Offset offset = box.globalToLocal(update.globalPosition);
    _updateDragPosition(offset);
    if (widget.onUpdate != null) {
      widget.onUpdate(dragPercentage);
    }
  }

  void _onDragStart(BuildContext context, DragStartDetails start) {
    RenderBox box = context.findRenderObject();
    Offset offset = box.globalToLocal(start.globalPosition);
    _updateDragPosition(offset);
    if (widget.onStart != null) {
      widget.onStart();
    }
  }

  void _onDragEnd(BuildContext context, DragEndDetails end) {
    _updateDragPositionEnd();
    if (widget.onEnd != null) {
      widget.onEnd(currentPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        child: Stack(
          children: <Widget>[
            Container(
              width: widget.width,
              height: widget.height,
              child: CustomPaint(
                painter: ImageSliderPainter(
                  color: widget.color,
                  sliderPercentage: dragPercentage,
                  sliderPosition: dragPosition,
                  len: widget.images.length - 1,
                  strokeWidth: widget.strokeWidth,
                  anchorWidth: widget.anchorWidth,
                  imageWidth: widget.imageWidth,
                  borderWidth: widget.borderWidth,
                  borderColor: widget.borderColor,
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(dragPosition - (widget.imageWidth / 2),
                  (widget.height - widget.imageWidth) + widget.borderWidth),
              child: Container(
                width: widget.imageWidth,
                height: widget.imageWidth,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: widget.images[currentPosition],
                  ),
                ),
              ),
            ),
          ],
        ),
        onHorizontalDragUpdate: (update) => _onDragUpdate(context, update),
        onHorizontalDragStart: (start) => _onDragStart(context, start),
        onHorizontalDragEnd: (end) => _onDragEnd(context, end),
      ),
    );
  }
}
