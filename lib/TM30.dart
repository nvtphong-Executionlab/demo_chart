import 'package:arrow_path/arrow_path.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

class TM30Chart extends CustomPainter {
  final List<Offset> points;
  final List<Offset> arrowFrom;
  final List<Offset> arrowTo;
  TM30Chart(this.points, this.arrowFrom, this.arrowTo);
  @override
  void paint(Canvas canvas, Size size) {
    List<Color> colors = [
      const Color(0xFFE62828),
      const Color(0xFFE74B4B),
      const Color(0xFFFB812E),
      const Color(0xFFFFB529),
      const Color(0xFFCBCA46),
      const Color(0xFF7EB94C),
      const Color(0xFF41C06D),
      const Color(0xFF009C7C),
      const Color(0xFF16BCB0),
      const Color(0xFF00A4BF),
      const Color(0xFF0085C3),
      const Color(0xFF3B62AA),
      const Color(0xFF4568AE),
      const Color(0xFF6A4E85),
      const Color(0xFF9D69A1),
      const Color(0xFFA74F81),
    ];
    colors = colors.reversed.toList();
    final paint = Paint()..style = PaintingStyle.stroke;
    paint.color = Colors.white;
    paint.strokeWidth = 2;
    // canvas.drawCircle(Offset(size.height / 2, size.width / 2), 110, paint);
    // canvas.drawCircle(Offset(size.height / 2, size.width / 2), 130, paint);
    // canvas.drawCircle(Offset(size.height / 2, size.width / 2), 170, paint);
    // canvas.drawCircle(Offset(size.height / 2, size.width / 2), 190, paint);
    // paint.color = Colors.black;
    // canvas.drawCircle(Offset(size.height / 2, size.width / 2), 150, paint);
    paint.color = Colors.grey;
    paint.strokeWidth = 1;
    // for (int i = 0; i < 16; ++i) {
    //   var angle = 2 * pi * i / 16;
    //   var dx = cos(angle);
    //   var dy = sin(angle);
    //   canvas.drawLine(Offset(size.height / 2, size.width / 2),
    //       Offset(size.width / 2 + dx * 100, size.height / 2 + dy * 100), paint);
    // }

    final path = Path();
    path.addPolygon(points, true);
    paint.color = Colors.red;
    paint.strokeWidth = 3;
    canvas.drawPath(path, paint);
    for (int i = 0; i < arrowFrom.length; ++i) {
      paint.color = colors[i];
      Path p = Path();
      // p.moveTo(arrowFrom[i].dx, arrowFrom[i].dy);
      // p.relativeCubicTo(points[i].dx, points[i].dy);
      p.addPolygon([arrowFrom[i], points[i]], false);
      p = ArrowPath.addTip(p, isAdjusted: true, tipLength: 10);
      canvas.drawPath(p, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class TM30Diagram extends StatefulWidget {
  const TM30Diagram({super.key});

  @override
  State<TM30Diagram> createState() => _TM30DiagramState();
}

class _TM30DiagramState extends State<TM30Diagram> {
  List<Offset> points = [];
  List<Offset> arrowFrom = [];
  List<Offset> arrowTo = [];

  Future<void> getFileLines(String filename, List<Offset> list) async {
    const size = Size(393, 393);
    final rawData = await rootBundle.loadString('assets/$filename');
    List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter(eol: '\n', shouldParseNumbers: true).convert(rawData);
    for (var l in rowsAsListOfValues) {
      // print('${l[0]} ${l[1]}');
      final Offset point = Offset(size.width / 2 + l[0] * 130, size.height / 2 + l[1] * 130);
      // print(point);
      list.add(point);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getFileLines('tm30.txt', points);
    getFileLines('arrowfrom.txt', arrowFrom);
    getFileLines('arrowto.txt', arrowTo);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Image.asset('assets/TM3018Back_900x900.png'),
      Positioned(
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
        child: CustomPaint(
          size: const Size(300, 300),
          painter: TM30Chart(points, arrowFrom, arrowTo),
        ),
      )
    ]);
  }
}
