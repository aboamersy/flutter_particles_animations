import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var particles = List<Particle>.generate(
      ((Utils.screenWidth * Utils.screenHeight) /
              ((Utils.screenHeight + Utils.screenWidth) * 3))
          .round(),
      (index) => Particle());

  double posx = 0;
  double posy = 0;
  final double r = 100;
  late Ticker t;

  @override
  void initState() {
    super.initState();
    // Screen size in density independent pixels

    t = Ticker((tick) {
      setState(() {
        for (var p in particles) {
          double hitSpeedX = Utils.range(0.1, 0.5);
          double hitSpeedY = Utils.range(0.1, 0.5);
          p.offset.dx >= Utils.screenWidth ? p.dx = -hitSpeedX : p.dx;
          p.offset.dx < 10 ? p.dx = hitSpeedX : p.dx;
          p.offset.dy > Utils.screenHeight ? p.dy = -hitSpeedY : p.dy;
          p.offset.dy < 10 ? p.dy = hitSpeedY : p.dy;

          p.offset += Offset(p.dx, p.dy);
        }
      });
    })
      ..start();
  }

  @override
  void dispose() {
    t.dispose();
    super.dispose();
  }

  void onTapDown(BuildContext context, var details) {
    var posX = details.globalPosition.dx;
    var posY = details.globalPosition.dy;

    for (var p in particles) {
      if (isImpacted(posX, posY, p)) {
        detremineImpactPosition(posX, posY, p, 1);
      }
    }
  }

  bool isImpacted(double posX, double posY, Particle p) {
    double ptX = p.offset.dx;
    double ptY = p.offset.dy;
    if (((posX - r) < ptX && ptX < (posX + r)) &&
        ((posY - r) < ptY && (ptY < (posY + r)))) {
      return true;
    }
    return false;
  }

  void detremineImpactPosition(
      double posX, double posY, Particle p, double maxShift) {
    double ptX = p.offset.dx;
    double ptY = p.offset.dy;
    var dx = Utils.range(0.2, maxShift);
    var dy = Utils.range(0.2, maxShift);
    if (ptX > posX && ptY > posY) {
      //C1
      p.dx = dx;
      p.dy = dy;
    } else if (ptX < posX && ptY > posY) {
      //C2
      p.dx = -dx;
      p.dy = dy;
    } else if (ptX > posX && ptY < posY) {
      //C3
      p.dx = dx;
      p.dy = -dy;
    } else if (ptX < posX && ptY < posY) {
      //C4
      p.dx = -dx;
      p.dy = -dy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) => onTapDown(context, details),
      onPanDown: (details) => onTapDown(context, details),
      child: CustomPaint(
        painter: MyPainter(particles),
        child: Container(),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final List<Particle> particles;

  MyPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      Paint paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(p.offset, p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Particle {
  late double radius;
  late Offset offset;
  late double dx;
  late double dy;
  late Color color;
  Particle() {
    var scWidth = Utils.screenWidth;
    var scHeight = Utils.screenHeight;
    radius = Utils.range(1, 10);
    color = Utils.randomColor();
    double x = Utils.range(0, scWidth - 5);
    double y = Utils.range(0, scHeight - 5);
    dx = Utils.range(-0.2, 0.2);
    dy = Utils.range(-0.2, 0.2);
    offset = Offset(x, y);
  }
}

var rnd = Random();

class Utils {
  static double range(double min, double max) =>
      rnd.nextDouble() * (max - min) + min;
  static Color randomColor() {
    var r = rnd.nextInt(255);

    var g = rnd.nextInt(255);

    var b = rnd.nextInt(255);

    var opacity = range(0.3, 1);
    return Color.fromRGBO(r, g, b, opacity);
  }

  static double screenWidth =
      (window.physicalSize.shortestSide / window.devicePixelRatio);
  static double screenHeight =
      (window.physicalSize.longestSide / window.devicePixelRatio);
}
