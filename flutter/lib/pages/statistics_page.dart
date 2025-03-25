import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/nav/bottom_nav_bar.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String selectedPeriod = "Daily";

  final Map<String, List<FlSpot>> incomeData = {
    "Daily": [
      FlSpot(0, 50), FlSpot(1, 60), FlSpot(2, 45), FlSpot(3, 70), FlSpot(4, 55), FlSpot(5, 65), FlSpot(6, 80),
    ],
    "Weekly": [
      FlSpot(0, 350), FlSpot(1, 400), FlSpot(2, 320), FlSpot(3, 500),
    ],
    "Yearly": [
      FlSpot(0, 18250), FlSpot(1, 19000), FlSpot(2, 17500), FlSpot(3, 20000), FlSpot(4, 21000),
    ],
  };

  final Map<String, List<String>> xAxisLabels = {
    "Daily": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
    "Weekly": ["Week 1", "Week 2", "Week 3", "Week 4"],
    "Yearly": ["2020", "2021", "2022", "2023", "2024"],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Statistics")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Income Chart",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedPeriod,
                items: ["Daily", "Weekly", "Yearly"].map((String period) {
                  return DropdownMenuItem<String>(
                    value: period,
                    child: Text(period),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPeriod = newValue ?? "Daily";
                  });
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: selectedPeriod == "Yearly" ? 25000 : null,
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            List<String> labels = xAxisLabels[selectedPeriod] ?? [];
                            return index >= 0 && index < labels.length
                                ? Text(labels[index], style: const TextStyle(fontSize: 12))
                                : const Text("");
                          },
                          interval: 1,
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false), // Hides top labels
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false), // Hides right labels
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: incomeData[selectedPeriod] ?? [],
                        isCurved: true,
                        gradient: LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false), // Hides the points
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Income Overview",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildIncomeCard("Daily Income", 50.0, Colors.blue),
              _buildIncomeCard("Weekly Income", 350.0, Colors.green),
              _buildIncomeCard("Yearly Income", 18250.0, Colors.orange),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 1),
    );
  }

  Widget _buildIncomeCard(String title, double amount, Color color) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(Icons.attach_money, color: color, size: 30),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: Text(
          "\$${amount.toStringAsFixed(2)}",
          style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}