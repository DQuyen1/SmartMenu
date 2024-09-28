import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_menu/models/store_product.dart';
import 'package:smart_menu/presentation/screens/manage_display.dart';
import 'package:smart_menu/presentation/screens/manage_template.dart';
import 'package:smart_menu/presentation/screens/manage_store_collection.dart';
import 'package:smart_menu/presentation/screens/manage_store_device.dart';
import 'package:smart_menu/presentation/screens/manage_store_menu.dart';
import 'package:smart_menu/presentation/screens/manage_store_product.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smart_menu/presentation/widgets/custom_navigation.dart';
import 'package:smart_menu/repository/store_product_repository.dart';
import 'package:smart_menu/presentation/screens/shared/navbar.dart';

class DashBoardScreen extends StatefulWidget {
  final String userId;
  final String token;
  final int brandId;
  final int storeId;

  const DashBoardScreen({
    Key? key,
    required this.userId,
    required this.token,
    required this.brandId,
    required this.storeId,
  }) : super(key: key);
  @override
  _DashBoardScreenState createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<StoreProduct> _storeProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStoreProduct();
  }

  void _fetchStoreProduct() async {
    try {
      final StoreProductRepository _repository = StoreProductRepository();
      List<StoreProduct> products = await _repository.getAll(widget.storeId);

      setState(() {
        _storeProducts = products;
        _isLoading = false;
      });
    } catch (error) {
      print("Error fetching store products: $error");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
          title: const Text('Home Screen'),
          backgroundColor: Colors.green.shade800,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          )),
      drawer: NavBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Popular',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    _carouselSlider(context),
                    const SizedBox(height: 24),
                    // _buildKeyMetrics(),
                    const SizedBox(height: 24),
                    _buildManageOptions(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildKeyMetrics() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
      ),
    );
  }

  Widget _buildManageOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Manage Options",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildManageButton(
                context,
                "View Template",
                Icons.description,
                Colors.green,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TemplateListScreen(brandId: widget.brandId)))),
            _buildManageButton(
                context,
                "Store Menu",
                Icons.restaurant_menu,
                Colors.orange,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StoreMenuListScreen(
                            storeId: widget.storeId,
                            brandId: widget.brandId)))),
            _buildManageButton(
                context,
                "Store Device",
                Icons.devices,
                Colors.red,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            StoreDeviceListScreen(storeId: widget.storeId)))),
            _buildManageButton(
                context,
                "Store Collection",
                Icons.collections,
                Colors.purple,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StoreCollectionListScreen(
                            storeId: widget.storeId,
                            brandId: widget.brandId)))),
            _buildManageButton(
                context,
                "Store Product",
                Icons.shopping_basket,
                Colors.teal,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StoreProductListScreen(
                            storeId: widget.storeId,
                            brandId: widget.brandId)))),
            _buildManageButton(
                context,
                "Manage Display",
                Icons.tv,
                Colors.amber,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DisplayListScreen(
                            storeId: widget.storeId,
                            brandId: widget.brandId)))),
          ],
        ),
      ],
    );
  }

  Widget _buildManageButton(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.7), color.withOpacity(0.9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.white),
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
      ),
    );
  }

  Widget _carouselSlider(BuildContext context) {
    if (_storeProducts.isEmpty) {
      return const Center(child: Text('No products available'));
    }

    final randomProducts = _storeProducts..shuffle();
    final displayedProducts = randomProducts.take(5).toList();

    return CarouselSlider(
      items: displayedProducts.map((product) {
        final imageUrl = (product.product?.productImgPath != null &&
                product.product!.productImgPath!.isNotEmpty)
            ? product.product!.productImgPath!
            : 'https://via.placeholder.com/300';

        return Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        );
      }).toList(),
      options: CarouselOptions(
        height: 300,
        autoPlay: true,
        enlargeCenterPage: true,
        enableInfiniteScroll: true,
      ),
    );
  }
}
