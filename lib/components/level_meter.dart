import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LevelColor {
  final Color healthy;
  final Color warning;
  final Color danger;
  final Color background;

  LevelColor(this.healthy, this.warning, this.danger, this.background);
}

class LevelMeter extends StatelessWidget {
  LevelMeter({
    Key? key,
    this.colors,
    this.barWidth = 8,
    required this.left,
    required this.right,
  }) : super(key: key);


  final LevelColor defaultColor = LevelColor(
    Color.fromRGBO(79, 160, 118, 1),
    Color.fromRGBO(46, 130, 84, 1),
    Color.fromRGBO(45, 79, 55, 1),
    Color.fromRGBO(200, 200, 200, 1),
  );
  final LevelColor? colors;
  final double left;
  final double right;
  final double barWidth;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        backgroundColor: Colors.transparent,
        barTouchData: BarTouchData(
          enabled: false,
        ),
        titlesData: FlTitlesData(
          show: false,
        ),
        gridData: FlGridData(
          show: false,
        ),
        borderData: FlBorderData(
          show: false,
        ),
        groupsSpace: 1,
        barGroups: getData(),
      ),
      swapAnimationDuration: Duration(milliseconds: 100), // Optional
      swapAnimationCurve: Curves.linear,
    );
  }

  List<double> meterSplit(double input, double max, [double? min]) {
    double absMin = min != null ? min : 0;
    double bottom = (input < absMin) ? input : absMin;
    double top = (input > max) ? max : input;
    return [bottom, top];
  }

  List<BarChartGroupData> getData() {
    double leftConverted = ((left + 100) * 1000000000);
    double rightConverted = ((right + 100) * 1000000000);
    LevelColor? givenColor = colors;
    LevelColor levelColor = givenColor != null ? givenColor : defaultColor;

    double healthy = 75 * 1000000000;
    double warning = 90 * 1000000000;
    double danger = 100 * 1000000000;

    List<double> leftHealthy = meterSplit(leftConverted, healthy, 0);
    List<double> rightHealthy = meterSplit(rightConverted, healthy, 0);
    List<double> leftWarning = meterSplit(leftConverted, warning, healthy);
    List<double> rightWarning = meterSplit(rightConverted, warning, healthy);
    List<double> leftDanger = meterSplit(leftConverted, danger, warning);
    List<double> rightDanger = meterSplit(rightConverted, danger, warning);
    List<double> leftTop =
        meterSplit(leftConverted, 100000000000, leftConverted);
    List<double> rightTop =
        meterSplit(rightConverted, 100000000000, rightConverted);

    return [
      BarChartGroupData(
        x: 0,
        barsSpace: 2,
        barRods: [
          BarChartRodData(
            width: barWidth,
              y: 100000000000,
              rodStackItems: [
                BarChartRodStackItem(
                  leftHealthy[0],
                  leftHealthy[1],
                  levelColor.healthy,
                ),
                BarChartRodStackItem(
                  leftWarning[0],
                  leftWarning[1],
                  levelColor.warning,
                ),
                BarChartRodStackItem(
                  leftDanger[0],
                  leftDanger[1],
                  levelColor.danger,
                ),
                BarChartRodStackItem(
                  leftTop[0],
                  100000000000,
                  levelColor.background,
                ),
              ],
              borderRadius: const BorderRadius.all(Radius.zero)),
          BarChartRodData(
              width: barWidth,
              y: 100000000000,
              rodStackItems: [
                BarChartRodStackItem(
                  rightHealthy[0],
                  rightHealthy[1],
                  levelColor.healthy,
                ),
                BarChartRodStackItem(
                  rightWarning[0],
                  rightWarning[1],
                  levelColor.warning,
                ),
                BarChartRodStackItem(
                  rightDanger[0],
                  rightDanger[1],
                  levelColor.danger,
                ),
                BarChartRodStackItem(
                  rightTop[0],
                  100000000000,
                  levelColor.background,
                ),
              ],
              borderRadius: const BorderRadius.all(Radius.zero)),
        ],
      ),
    ];
  }
}
