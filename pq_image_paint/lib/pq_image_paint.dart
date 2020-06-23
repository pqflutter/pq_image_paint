library pq_image_paint;

import 'package:flutter/material.dart';
import 'dart:ui' as UI;

import 'package:flutter/services.dart';

class PQImagePaint extends CustomPainter {
  PQImagePaint({
    this.value,
    this.image,
    this.radius = 20,
  });

  final double value;
  UI.Image image;
  final double radius;

  /// 加载图片
  static Future<UI.Image> loadImage(String path,
      {int width, int height}) async {
    try {
      var data = await rootBundle.load(path);
      var codec = await UI.instantiateImageCodec(data.buffer.asUint8List(),
          targetHeight: height, targetWidth: width);
      var info = await codec.getNextFrame();
      return info.image;
    } catch (e) {
      print("load image error $e");
      return null;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawAxis(value, canvas, radius, Paint());
  }

  drawAxis(double value, Canvas canvas, double radius, Paint paint) {
    final circlePath = Path()
      ..addOval(Rect.fromCircle(center: Offset.zero, radius: radius));
    var firstAxis = circlePath;
    UI.PathMetrics pathMetrics = firstAxis.computeMetrics();
    for (UI.PathMetric pathMetric in pathMetrics) {
      Path extractPath = pathMetric.extractPath(
        0.0,
        pathMetric.length * value,
      );
      try {
        var metric = extractPath.computeMetrics().first;
        final offset = metric.getTangentForOffset(metric.length).position;
        if (this.image != null) {
          canvas.drawImage(this.image, offset, paint);
        } else {
          print("xxxxxxxxxxxxxxxxxxxxxx 图为为空，画个啥？？？？？");
        }
      } catch (e) {}
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class PQCirclePathAnimation extends StatefulWidget {
  final Duration duration;
  final String asset;
  final int width;
  final int height;
  final double radius;

  PQCirclePathAnimation({
    this.duration = const Duration(seconds: 1),
    this.asset,
    this.width,
    this.height,
    this.radius,
  });

  @override
  _PQCirclePathAnimationState createState() => _PQCirclePathAnimationState();
}

class _PQCirclePathAnimationState extends State<PQCirclePathAnimation>
    with TickerProviderStateMixin {
  AnimationController _controller;
  UI.Image image;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    PQImagePaint.loadImage(
      widget.asset,
      width: widget.width,
      height: widget.height,
    ).then((value) {
      this.image = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, snapshot) {
        return Center(
          child: CustomPaint(
            painter: PQImagePaint(
              value: _controller.value,
              image: this.image,
              radius: widget.radius,
            ),
          ),
        );
      },
    );
  }
}
