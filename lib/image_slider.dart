library image_slider;

import 'package:flutter/material.dart';
import 'package:image_slider_button/image_slider_style.dart';
import 'image_slider_painter.dart';
export 'package:image_slider_button/image_slider_style.dart';

class ImageSlider extends StatefulWidget {
  final Function onStart;
  final Function onUpdate;
  final Function onEnd;
  ImageSliderStyleOptions style;
  final List<ImageProvider> images;
  final int startPosition;
  ImageSlider({
    @required this.images,
    this.startPosition = 0,
    this.onStart,
    this.onUpdate,
    this.onEnd,
    this.style,
  });

  @override
  _ImageSliderState createState() {
    if (this.style == null) {
      this.style = ImageSliderStyleOptions(style: ImageSliderStyleEnum.DEFAULT);
    }
    return _ImageSliderState();
  }
}

class _ImageSliderState extends State<ImageSlider> {
  double dragPosition;

  double dragPercentage;

  int currentPosition;
  double width;
  bool widthIsChanged;

  @override
  void initState() {
    width = widget.style.width;
    currentPosition = widget.startPosition;
    if (currentPosition < 0 || currentPosition >= widget.images.length) {
      currentPosition = 0;
    }
    dragPosition = widget.style.options.borderWidth +
        (widget.style.options.imageWidth / 2) +
        currentPosition *
            (width -
                widget.style.options.imageWidth -
                (widget.style.options.borderWidth * 2)) /
            (widget.images.length - 1);
    dragPercentage = dragPosition / width;
    widthIsChanged = false;
    super.initState();
  }

  void _updateDragPosition(Offset offset) {
    double newDragPosition = 0;

    if (offset.dx <=
        widget.style.options.borderWidth +
            (widget.style.options.imageWidth / 2)) {
      newDragPosition = widget.style.options.borderWidth +
          (widget.style.options.imageWidth / 2);
    } else if (offset.dx >=
        width -
            widget.style.options.borderWidth -
            (widget.style.options.imageWidth / 2)) {
      newDragPosition = width -
          widget.style.options.borderWidth -
          (widget.style.options.imageWidth / 2);
    } else {
      newDragPosition = offset.dx;
    }

    setState(() {
      dragPosition = newDragPosition;
      dragPercentage = dragPosition / width;
    });
  }

  void _updateDragPositionEnd() {
    int newCurrentPosition = 0;
    double newDragPosition = 0;
    int len = widget.images.length;
    for (var i = 0; i <= len; i++) {
      if (i == len) {
        newCurrentPosition = i - 1;
        newDragPosition = width -
            (widget.style.options.imageWidth / 2) -
            widget.style.options.borderWidth;
        break;
      }
      if (dragPosition < ((width * (i + 1)) / len)) {
        newCurrentPosition = i;
        newDragPosition = widget.style.options.borderWidth +
            (widget.style.options.imageWidth / 2) +
            (((width -
                        widget.style.options.imageWidth -
                        (widget.style.options.borderWidth * 2)) *
                    (i)) /
                (len - 1));

        break;
      }
    }

    setState(() {
      dragPosition = newDragPosition;
      dragPercentage = dragPosition / width;
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
    return LayoutBuilder(builder: (context, constraint) {
      if (!widthIsChanged && width > constraint.maxWidth) {
        width =
            constraint.maxWidth - (widget.style.options.borderWidth * 2) - 1;
      }
      return Container(
        margin: EdgeInsets.all(widget.style.options.borderWidth + 1),
        child: GestureDetector(
          child: Stack(
            children: <Widget>[
              Container(
                width: width,
                height: widget.style.options.height,
                child: CustomPaint(
                  painter: ImageSliderPainter(
                    color: widget.style.color,
                    sliderPercentage: dragPercentage,
                    sliderPosition: dragPosition,
                    len: widget.images.length - 1,
                    strokeWidth: widget.style.options.strokeWidth,
                    anchorWidth: widget.style.options.anchorWidth,
                    imageWidth: widget.style.options.imageWidth,
                    borderWidth: widget.style.options.borderWidth,
                    borderColor: widget.style.borderColor,
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(
                    dragPosition - (widget.style.options.imageWidth / 2), 0.0),
                child: Container(
                  width: widget.style.options.imageWidth,
                  height: widget.style.options.imageWidth,
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
    });
  }
}
