import 'package:flutter/material.dart';

class CIEDiagramPainter extends CustomPainter {
  CIEDiagramPainter(this.points);
  final List<Offset> points;
  @override
  void paint(Canvas canvas, Size size) {
    // Define the vertices of the CIE diagram triangle
    // final vertices = [
    //   Offset(100, size.height),
    //   const Offset(0, 10),
    //   const Offset(50, 0),
    //   const Offset(110, 10),
    //   Offset(size.width, size.height * 2 / 3)
    // ];

    final path = Path();

    // Define the colors for the gradient
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.green,
    ];

    //     final samples = 125;

    // final linspaceX = linspace(0, 1, num: samples);
    // final linspaceY = linspace(1, 0, num: samples);
    // // print(linspaceX.length);
    // // final List<double> lX = [];
    // // final List<double> lY = [];
    // // for (var x in linspaceX.l) {
    // //   lX.add(x!);
    // // }
    // // for (var y in linspaceY.l) {
    // //   lY.add(y!);
    // // }

    // final mesh = meshgrid(linspaceX, linspaceY);
    // final ii = mesh[0];
    // final jj = mesh[1];

    // final result = tstack([ii, jj]);
    // final List<List<double>> xyz = [];
    // for (var item in result) {
    //   xyz.add(xy_to_XYZ(item));
    // }

    // Create a gradient shader using the colors and vertices
    // for (var point in points) {
    //   final xyz = xy_to_XYZ([point.dx, point.dy] / 255);
    //   print(xyz);
    //   final rgb = xyzToRBG(xyz);
    //   final color = Color.fromRGBO(rgb[0].toInt(), rgb[1].toInt(), rgb[2].toInt(), 0.5);
    //   final shader = LinearGradient(
    //     begin: Alignment.topLeft,
    //     end: Alignment.bottomRight,
    //     colors: colors,
    //   ).createShader(Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height)));

    //   // Draw the CIE diagram triangle
    //   final paint = Paint()..shader = shader;
    //   // path.addPolygon(points, true);
    //   // canvas.drawPath(path, paint);
    //   path.addPolygon(points, true);
    //   canvas.drawPath(path, paint);
    // }
    final shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    ).createShader(Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height)));

    // // Draw the CIE diagram triangle
    final paint = Paint(); //..shader = shader;
    // paint.colorFilter = const ColorFilter.linearToSrgbGamma();
    path.addPolygon(points, true);
    canvas.clipPath(path, doAntiAlias: true);
    // for (var point in points) {
    //   canvas.drawPath(path, paint);
    // }

    // canvas.drawPath(_createTrianglePath(vertices), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  // Helper method to create a path for the triangle
  Path _createTrianglePath(List<Offset> vertices) {
    final path = Path();
    path.moveTo(vertices[0].dx, vertices[0].dy);
    path.quadraticBezierTo(vertices[1].dx, vertices[1].dy, vertices[2].dx, vertices[2].dy);
    path.quadraticBezierTo(vertices[3].dx, vertices[3].dy, vertices[4].dx, vertices[4].dy);
    path.lineTo(vertices[0].dx, vertices[0].dy);
    path.close();
    return path;
  }

  Path _createPath(List<Offset> vertices) {
    final path = Path();
    path.moveTo(vertices[0].dx, vertices[0].dy);
    path.lineTo(vertices[1].dx, vertices[1].dy);
    path.close();
    return path;
  }
}

extension DivideOffset on List<Offset> {
  List<Offset> operator /(int x) {
    final newList = [...this];
    for (int i = 1; i < newList.length; i += 2) {
      newList[i] = Offset(newList[i].dx / x, newList[i].dy / x);
    }
    return newList;
  }
}

extension DivideListDouble on List<double> {
  List<double> operator /(int x) {
    final newList = [...this];
    for (int i = 1; i < newList.length; i++) {
      newList[i] = newList[i] / x;
    }
    return newList;
  }
}

List<List<double>> meshgrid(List<double> x, List<double> y) {
  final xx = tile(x, y.length);
  final yy = repeat(y, x.length);

  return [xx, yy];
}

List<double> tile(List<double> array, int count) {
  final tiledList = List<double>.filled(array.length * count, 0);

  for (int i = 0; i < count; i++) {
    final startIndex = i * array.length;
    final endIndex = startIndex + array.length;
    tiledList.setRange(startIndex, endIndex, array);
  }

  return tiledList;
}

List<double> repeat(List<double> array, int count) {
  final repeatedList = List<double>.filled(array.length * count, 0);

  for (int i = 0; i < array.length; i++) {
    final startIndex = i * count;
    final endIndex = startIndex + count;
    repeatedList.fillRange(startIndex, endIndex, array[i]);
  }

  return repeatedList;
}

List<List<double>> tstack(List<List<double>> arrays) {
  final numRows = arrays[0].length;
  final numCols = arrays.length;

  final result = <List<double>>[];
  for (int i = 0; i < numRows; i++) {
    final row = arrays.map((array) => array[i]).toList();
    result.add(row);
  }

  return result;
}
