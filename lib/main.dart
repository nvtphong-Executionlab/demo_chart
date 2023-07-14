import 'package:csv/csv.dart';
import 'package:demo_chart/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Offset> points = [];
  Future<void> getFileLines() async {
    final rawData = await rootBundle.loadString('assets/data.txt');
    List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter(eol: '\n', shouldParseNumbers: true).convert(rawData);
    for (var l in rowsAsListOfValues) {
      // print('${l[0]} ${l[1]}');
      final Offset point = Offset(l[0], l[1]);
      // print(point);
      points.add(point);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // getFileLines();
  }

  ChartSeriesController? seriesController;
  Color selectedColor = Colors.transparent;
  Offset offset = const Offset(0, 0);

  // final _appRouter = AppRouter();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CIE Diagram'),
        ),
        body: Column(
          children: [
            Stack(
              children: [
                const SizedBox(
                  height: 500,
                  width: 500,
                ),
                Positioned(
                  left: 36,
                  bottom: 30,
                  child: Image.asset(
                    'assets/cie2.png',
                    width: 300,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  width: 350,
                  height: 383,
                  child:

                      // ScatterChart(ScatterChartData(
                      //     minX: 0,
                      //     minY: 0,
                      //     gridData: const FlGridData(horizontalInterval: 0.1),
                      //     maxX: 0.8,
                      //     maxY: 0.9,
                      //     titlesData: const FlTitlesData(
                      //         topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      //         rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
                      //     scatterTouchData: ScatterTouchData(
                      //       touchCallback: (p0, p1) {
                      //         print('------');
                      //         print(p0.);
                      //         print(p0.localPosition?.dy);
                      //       },
                      //     )))

                      SfCartesianChart(
                    borderColor: Colors.red,
                    primaryXAxis: NumericAxis(maximum: 0.75, interval: 0.1),
                    primaryYAxis: NumericAxis(maximum: 0.85),
                    series: [
                      ScatterSeries(
                          dataSource: [offset], xValueMapper: (o, _) => offset.dx, yValueMapper: (o, _) => o.dy)
                    ],
                    onChartTouchInteractionUp: (tapArgs) {
                      final relativeX = (tapArgs.position.dx - 29) / 305 * 0.75;
                      final relativeY = (350 - tapArgs.position.dy) / 350 * 0.85;
                      final rgb = xyBriToRgb(relativeX, relativeY, 255);
                      // print(rgb);
                      setState(() {
                        offset = Offset(relativeX, relativeY);
                        selectedColor = Color.fromRGBO(rgb['r'], rgb['g'], rgb['b'], 1);
                      });
                    },
                  ),
                ),
              ],
            ),
            Container(
              width: 100,
              height: 100,
              color: selectedColor,
            )
          ],
        ),
      ),
    );
  }
}
