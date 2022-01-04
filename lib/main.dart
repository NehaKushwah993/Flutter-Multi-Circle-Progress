import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vmath;
import 'dart:math' as math;

import 'dart:ui' as UI;

import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Multi Circle Indicator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  UI.Image? img1;
  UI.Image? img2;

  @override
  void initState() {
    super.initState();

    loadUiImage("lib/assets/yoga1.png").then(
          (value) => {
        setState(() {
          img1 = value;
        }),
      },
    );
    loadUiImage("lib/assets/yoga.png").then(
          (value) => {
        setState(() {
          img2 = value;
        }),
      },
    );
  }

  Future<UI.Image> loadUiImage(String imageAssetPath) async {
    final ByteData data = await rootBundle.load(imageAssetPath);
    final Completer<UI.Image> completer = Completer();
    UI.decodeImageFromList(Uint8List.view(data.buffer), (UI.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Stack(
          children: <Widget>[
            outer(),
            middle(),
            inner(),
          ],
        ),
      ),
    );
  }

  outer() {
    return CustomPaint(
      painter: MyPainter(
        img1,
        total: 300,
        current: 230,
        radius: 90,
        strokeWidth: 15,
        strokeColor: Colors.red.shade300,
      ),
      child: Container(),
    );
  }

  middle() {
    return CustomPaint(
      painter: MyPainter(
        img2,
        total: 200,
        current: 140,
        radius: 60,
        strokeColor: Colors.pink.shade300,
        strokeWidth: 15,
      ),
      child: Container(),
    );
  }

  inner() {
    return CustomPaint(
      painter: MyPainter(
        img2,
        total: 100,
        current: 50,
        radius: 30,
        strokeWidth: 15,
      ),
      child: Container(),
    );
  }
}

class MyPainter extends CustomPainter {
  UI.Image? img;
  double radius;
  double total;
  double current;
  double strokeWidth;
  Color color;
  Color strokeColor;

  MyPainter(this.img,
      {required this.total,
        required this.current,
        this.radius = 85,
        this.color = Colors.black12,
        this.strokeColor = Colors.green,
        this.strokeWidth = 30});

  @override
  Future<void> paint(Canvas canvas, Size size) async {
    final center = Offset(size.width / 2, size.height / 2);

    double startAngle = 0;
    startAngle = startAngle - 90;
    double angle = 0;

    // calculate angle
    var percentage = current / total;
    angle = percentage * 360;

    // BG layer
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = color
        ..strokeWidth = strokeWidth,
    );
    canvas.saveLayer(
      Rect.fromCenter(
          center: center,
          width: radius * 2 + strokeWidth,
          height: radius * 2 + strokeWidth),
      // Paint()..blendMode = BlendMode.dstIn,
      Paint(),
    );
    //Progress
    canvas.drawArc(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
      vmath.radians(startAngle),
      vmath.radians(angle),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..color = strokeColor
        ..strokeWidth = strokeWidth,
    );

    Offset p = Offset(
        ((size.width / 2) +
            radius * math.cos(vmath.radians(angle + startAngle))) -
            10,
        ((size.height / 2) +
            radius * math.sin(vmath.radians(angle + startAngle))) -
            10);

    if (img != null) {
      canvas.drawImage(img!, p, Paint()..color = Colors.red);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
