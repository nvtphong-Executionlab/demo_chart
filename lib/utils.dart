import 'dart:math' as math;

List<double> apply3x3Matrix(List<double> xyz, List<double> xyzmatrix) {
  double r = xyz[0] * xyzmatrix[0] + xyz[1] * xyzmatrix[1] + xyz[2] * xyzmatrix[2];
  double g = xyz[0] * xyzmatrix[3] + xyz[1] * xyzmatrix[4] + xyz[2] * xyzmatrix[5];
  double b = xyz[0] * xyzmatrix[6] + xyz[1] * xyzmatrix[7] + xyz[2] * xyzmatrix[8];
  return [r, g, b];
}

List<double> xyzFromsRGBD50(List<double> rgb) {
  List<double> lin = sRGBToLinear3(rgb);
  // D65/2 sRGB matrix adapted to D50/2
  return apply3x3Matrix(lin, [
    0.436027535573195,
    0.385097932872408,
    0.143074531554397,
    0.222478677613186,
    0.716902127457834,
    0.0606191949289806,
    0.0139242392790820,
    0.0970836931437703,
    0.714092067577148,
  ]);
}

List<double> xyzTosRGBD50(List<double> xyz) {
  // D65/2 sRGB matrix adapted to D50/2
  List<double> rgb = apply3x3Matrix(xyz, [
    3.13424933163426,
    -1.61717292521282,
    -0.490692377104512,
    -0.978746070339639,
    1.91611436125945,
    0.0334415219513205,
    0.0719490494816283,
    -0.228969853236611,
    1.40540126012171,
  ]);
  return sRGBFromLinear3(rgb);
}

List<double> xyzFromsRGB(List<double> rgb) {
  List<double> lin = sRGBToLinear3(rgb);
  // D65/2 sRGB matrix
  return apply3x3Matrix(lin, [
    0.4123907992659591,
    0.35758433938387796,
    0.18048078840183424,
    0.21263900587151016,
    0.7151686787677559,
    0.0721923153607337,
    0.01933081871559181,
    0.11919477979462596,
    0.9505321522496605,
  ]);
}

List<double> xyzToRBG(List<double> xyz) {
  return apply3x3Matrix(xyz, [
    // 3.2409699419045235,
    // -1.5373831775700944,
    // -0.49861076029300355,
    // -0.9692436362808797,
    // 1.8759675015077204,
    // 0.0415550574071756,
    // 0.05563007969699365,
    // -0.20397695888897652,
    // 1.0569715142428786,
    2.36461385,
    -0.896,
    -0.468,
    -0.515,
    1.4264081,
    0.0887581,
    0.005,
    -0.014,
    1.009,
  ]);
}

List<double> xyzTosRGB(List<double> xyz) {
  // D65/2 sRGB matrix
  List<double> rgb = apply3x3Matrix(xyz, [
    3.2409699419045235,
    -1.5373831775700944,
    -0.49861076029300355,
    -0.9692436362808797,
    1.8759675015077204,
    0.0415550574071756,
    0.05563007969699365,
    -0.20397695888897652,
    1.0569715142428786,
  ]);
  return sRGBFromLinear3(rgb);
}

double SRGBFromLinear(double c) {
  if (c <= 0.0031308) {
    return 12.92 * c;
  }
  return math.pow(c, 1.0 / 2.4) * 1.055 - 0.055;
}

double SRGBToLinear(double c) {
  if (c <= 0.04045) {
    return c / 12.92;
  }
  return math.pow((c + 0.055) / 1.055, 2.4).toDouble();
}

List<double> sRGBToLinear3(List<double> c) {
  return [SRGBToLinear(c[0]), SRGBToLinear(c[1]), SRGBToLinear(c[2])];
}

List<double> sRGBFromLinear3(List<double> c) {
  return [SRGBFromLinear(c[0]), SRGBFromLinear(c[1]), SRGBFromLinear(c[2])];
}

// -----------------------------------
List<double> XYZToxyY(List<double> xyz) {
  double sum = xyz[0] + xyz[1] + xyz[2];
  if (sum == 0) {
    return [0, 0, 0];
  }
  return [xyz[0] / sum, xyz[1] / sum, xyz[1]];
}

List<double> XYZFromxyY(List<double> xyy) {
  // NOTE: Results undefined if xyy[1] == 0
  return [
    xyy[0] * xyy[2] / xyy[1],
    xyy[2],
    xyy[2] * (1 - xyy[0] - xyy[1]) / xyy[1],
  ];
}

List<double> XYZTouvY(List<double> xyz) {
  double sum = xyz[0] + xyz[1] * 15.0 + xyz[2] * 3.0;
  if (sum == 0) {
    return [0, 0, 0];
  }
  return [4.0 * xyz[0] / sum, 9.0 * xyz[1] / sum, xyz[1]];
}

List<double> xy_to_xyY(List<double> xy) {
  return [xy[0], xy[1], 1];
}

List<double> xy_to_XYZ(List<double> xy) {
  return XYZFromxyY(xy_to_xyY(xy));
}

Map xyBriToRgb(x, y, bri) {
  double getReversedGammaCorrectedValue(value) {
    return value <= 0.0031308 ? 12.92 * value : (1.0 + 0.055) * math.pow(value, (1.0 / 2.4)) - 0.055;
  }

  final z = 1.0 - x - y;
  final Y = bri / 255;
  final X = (Y / y) * x;
  final Z = (Y / y) * z;
  double r = X * 1.656492 - Y * 0.354851 - Z * 0.255038;
  double g = -X * 0.707196 + Y * 1.655397 + Z * 0.036152;
  double b = X * 0.051713 - Y * 0.121364 + Z * 1.011530;

  r = getReversedGammaCorrectedValue(r);
  g = getReversedGammaCorrectedValue(g);
  b = getReversedGammaCorrectedValue(b);

  // Bring all negative components to zero
  r = math.max(r, 0);
  g = math.max(g, 0);
  b = math.max(b, 0);

  // If one component is greater than 1, weight components by that value
  final max = math.max(r, math.max(g, b));
  if (max > 1) {
    r = r / max;
    g = g / max;
    b = b / max;
  }

  return {
    'r': (r * 255).floor(),
    'g': (g * 255).floor(),
    'b': (b * 255).floor(),
  };
}
