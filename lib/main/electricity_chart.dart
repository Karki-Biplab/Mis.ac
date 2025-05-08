import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ElectricityChart extends StatelessWidget {
  final List<double> weeklyUsage;

  const ElectricityChart({required this.weeklyUsage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Using Expanded to prevent overflow for the first text
              Expanded(
                child: Text(
                  'Weekly Energy Usage',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Small spacing between the elements
              SizedBox(width: 8),
              // Wrap this in a flexible widget to ensure it doesn't overflow
              Row(
                mainAxisSize: MainAxisSize.min, // Important to minimize Row width
                children: [
                  Text(
                    'This Week',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, size: 16),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 60,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipMargin: 10,
                    getTooltipColor: (_) => Colors.blueGrey.withOpacity(0.8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toStringAsFixed(1)} kWh',
                        TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0: return Text('M', style: TextStyle(color: Colors.grey[600], fontSize: 12));
                          case 1: return Text('T', style: TextStyle(color: Colors.grey[600], fontSize: 12));
                          case 2: return Text('W', style: TextStyle(color: Colors.grey[600], fontSize: 12));
                          case 3: return Text('T', style: TextStyle(color: Colors.grey[600], fontSize: 12));
                          case 4: return Text('F', style: TextStyle(color: Colors.grey[600], fontSize: 12));
                          case 5: return Text('S', style: TextStyle(color: Colors.grey[600], fontSize: 12));
                          case 6: return Text('S', style: TextStyle(color: Colors.grey[600], fontSize: 12));
                          default: return Text('');
                        }
                      },
                      reservedSize: 20,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                barGroups: weeklyUsage.asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        color: Color(0xFF7366FF),
                        width: 16,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                      )
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}