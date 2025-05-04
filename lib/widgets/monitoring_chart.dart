import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:apms/models/farm_data_model.dart';
import 'package:intl/intl.dart';

class MonitoringChart extends StatelessWidget {
  final List<FarmData> data;
  final String dataKey;
  final String unit;
  final Color color;

  const MonitoringChart({
    Key? key,
    required this.data,
    required this.dataKey,
    required this.unit,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Sort data by timestamp
    final sortedData = List<FarmData>.from(data)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
          },
          getDrawingVerticalLine: (value) {
            return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= sortedData.length || value.toInt() < 0) {
                  return const SizedBox();
                }
                final date = sortedData[value.toInt()].timestamp;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('MM/dd').format(date),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _calculateInterval(),
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}$unit',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        minX: 0,
        maxX: sortedData.length - 1.0,
        minY: _getMinY(),
        maxY: _getMaxY(),
        lineBarsData: [
          LineChartBarData(
            spots: _getSpots(sortedData),
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: color,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getSpots(List<FarmData> sortedData) {
    final spots = <FlSpot>[];
    for (int i = 0; i < sortedData.length; i++) {
      final value = _getValueForKey(sortedData[i]);
      spots.add(FlSpot(i.toDouble(), value));
    }
    return spots;
  }

  double _getValueForKey(FarmData data) {
    switch (dataKey) {
      case 'temperature':
        return data.temperature;
      case 'humidity':
        return data.humidity;
      case 'feedLevel':
        return data.feedLevel;
      case 'waterLevel':
        return data.waterLevel;
      default:
        return 0;
    }
  }

  double _getMinY() {
    if (data.isEmpty) return 0;

    double minValue = double.infinity;
    for (final item in data) {
      final value = _getValueForKey(item);
      if (value < minValue) {
        minValue = value;
      }
    }

    // Round down to nearest multiple of interval
    final interval = _calculateInterval();
    return (minValue ~/ interval) * interval.toDouble();
  }

  double _getMaxY() {
    if (data.isEmpty) return 100;

    double maxValue = double.negativeInfinity;
    for (final item in data) {
      final value = _getValueForKey(item);
      if (value > maxValue) {
        maxValue = value;
      }
    }

    // Round up to nearest multiple of interval
    final interval = _calculateInterval();
    return ((maxValue ~/ interval) + 1) * interval.toDouble();
  }

  double _calculateInterval() {
    if (data.isEmpty) return 10;

    double minValue = double.infinity;
    double maxValue = double.negativeInfinity;

    for (final item in data) {
      final value = _getValueForKey(item);
      if (value < minValue) {
        minValue = value;
      }
      if (value > maxValue) {
        maxValue = value;
      }
    }

    final range = maxValue - minValue;

    if (range <= 10) return 1;
    if (range <= 20) return 2;
    if (range <= 50) return 5;
    if (range <= 100) return 10;
    if (range <= 200) return 20;
    return 50;
  }
}
