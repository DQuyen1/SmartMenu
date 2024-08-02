import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            title: const Text(
              'Dashboard',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.blue.shade100,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Key Metrics
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetricCard("Total Sales", "\$5,000", Colors.blue),
                  _buildMetricCard("New Orders", "25", Colors.green),
                ],
              ),
              const SizedBox(height: 20),

              // Section 2: Charts or Graphs
              _buildChartCard("Sales Trend"), // Example chart

              const SizedBox(height: 20),

              // Section 3: Recent Activity
              const Text(
                "Recent Activity",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _buildActivityItem(
                "Order #1234 placed",
                Icons.shopping_cart,
                Colors.orange,
              ),
              _buildActivityItem(
                "Payment received for Order #5678",
                Icons.attach_money,
                Colors.green,
              ),
              const SizedBox(height: 20),

              // Section 4: Manage Buttons
              const Text(
                "Manage Options",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildManageButtonCard(
                    context,
                    "Manage Menu",
                    Icons.menu_book,
                    Colors.blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenuListScreen(brandId: brandId),
                      ),
                    ),
                  ),
                  _buildManageButtonCard(
                    context,
                    "Manage Template",
                    Icons.description,
                    Colors.green,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TemplateListScreen(brandId: brandId),
                      ),
                    ),
                  ),
                  _buildManageButtonCard(
                    context,
                    "Manage Store Menu",
                    Icons.store,
                    Colors.orange,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StoreMenuListScreen(storeId: storeId),
                      ),
                    ),
                  ),
                  _buildManageButtonCard(
                    context,
                    "Manage Store Device",
                    Icons.devices,
                    Colors.red,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StoreDeviceListScreen(storeId: storeId),
                      ),
                    ),
                  ),
                  _buildManageButtonCard(
                    context,
                    "Manage Store Collection",
                    Icons.collections,
                    Colors.purple,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StoreCollectionListScreen(storeId: storeId),
                      ),
                    ),
                  ),
                  _buildManageButtonCard(
                    context,
                    "Manage Store Product",
                    Icons.shopping_bag,
                    Colors.teal,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StoreProductListScreen(storeId: storeId),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return SizedBox(
      width: 170,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.4),
              ], // Gradient example
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
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
                  gridData:
                      FlGridData(show: false), // Optional: hide grid lines
                  borderData:
                      FlBorderData(show: false), // Optional: hide chart border
                  titlesData:
                      FlTitlesData(show: false), // Optional: hide axis titles
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

  Widget _buildManageButtonCard(BuildContext context, String title,
      IconData icon, Color color, VoidCallback onPressed) {
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
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.4),
              ], // Gradient example
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
