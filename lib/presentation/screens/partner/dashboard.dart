import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_menu/presentation/screens/manage_display.dart';
import 'package:smart_menu/presentation/screens/manage_menu.dart';
import 'package:smart_menu/presentation/screens/manage_store_collection.dart';
import 'package:smart_menu/presentation/screens/manage_store_device.dart';
import 'package:smart_menu/presentation/screens/manage_store_menu.dart';
import 'package:smart_menu/presentation/screens/manage_store_product.dart';
import 'package:smart_menu/presentation/screens/manage_template.dart';

class DashboardScreen extends StatelessWidget {
  final String userId;
  final int brandId;
  final int storeId;

  const DashboardScreen(
      {super.key,
      required this.userId,
      required this.brandId,
      required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.green.shade800,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildKeyMetrics(),
              const SizedBox(height: 20),
              _buildSalesChart(),
              const SizedBox(height: 20),
              _buildManageOptions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMetricCard(
            "Total Sales", "\$5,000", Colors.blue, Icons.attach_money),
        _buildMetricCard("New Orders", "25", Colors.green, Icons.shopping_cart),
        _buildMetricCard("Active Users", "1,423", Colors.orange, Icons.people),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: 100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(show: false),
                  minX: 0,
                  maxX: 11,
                  minY: 0,
                  maxY: 6,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 3),
                        const FlSpot(2.6, 2),
                        const FlSpot(4.9, 5),
                        const FlSpot(6.8, 3.1),
                        const FlSpot(8, 4),
                        const FlSpot(9.5, 3),
                        const FlSpot(11, 4),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 5,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
      String description, IconData icon, Color iconColor) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(description),
      trailing: Text(
        DateFormat('MMM d, h:mm a').format(DateTime.now()),
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  Widget _buildSalesChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Sales Trend",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 6,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 3),
                        FlSpot(1, 2),
                        FlSpot(2, 5),
                        FlSpot(3, 3.1),
                        FlSpot(4, 4),
                        FlSpot(5, 3),
                        FlSpot(6, 4),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                          show: true, color: Colors.blue.withOpacity(0.3)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManageOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Manage Options",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // _buildManageButton(
            //     context, "Manage Menu", Icons.menu_book, Colors.blue, () {
            //   Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => MenuListScreen(brandId: brandId)));
            // }),
            _buildManageButton(
                context, "Manage Template", Icons.description, Colors.green,
                () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TemplateListScreen(brandId: brandId)));
            }),
            _buildManageButton(
                context, "Store Menu", Icons.store, Colors.orange, () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StoreMenuListScreen(
                            storeId: storeId,
                            brandId: brandId,
                          )));
            }),
            _buildManageButton(
                context, "Store Device", Icons.devices, Colors.red, () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          StoreDeviceListScreen(storeId: storeId)));
            }),
            _buildManageButton(
                context, "Store Collection", Icons.collections, Colors.purple,
                () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StoreCollectionListScreen(
                            storeId: storeId,
                            brandId: brandId,
                          )));
            }),
            _buildManageButton(context, "Store Product",
                Icons.production_quantity_limits, Colors.teal, () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StoreProductListScreen(
                            storeId: storeId,
                            brandId: brandId,
                          )));
            }),
            _buildManageButton(
                context, "Manage Display", Icons.display_settings, Colors.amber,
                () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DisplayListScreen(
                          storeId: storeId, brandId: brandId)));
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildManageButton(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
