import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_menu/models/category.dart';
import 'package:smart_menu/models/product.dart';
import 'package:smart_menu/repository/category_repository.dart';
import 'package:smart_menu/repository/store_menu_repository.dart';

class StoreMenuDetail extends StatefulWidget {
  final int menuId;
  final int brandId;

  const StoreMenuDetail(
      {super.key, required this.menuId, required this.brandId});

  @override
  State<StoreMenuDetail> createState() => _StoreMenuDetailState();
}

class _StoreMenuDetailState extends State<StoreMenuDetail>
    with SingleTickerProviderStateMixin {
  final StoreMenuRepository _storeMenuRepository = StoreMenuRepository();
  late Future<List<Product>> _futureProducts;
  AnimationController? _animationController;
  Animation<double>? _animation;
  List<Category>? _cateList;
  String _searchQuery = '';
  int? _selectedCategory;
  bool _isAscendingOrder = true;
  String _sortOption = 'newest';

  @override
  void initState() {
    super.initState();
    _fetchCategory();
    _fetchProducts();
    HttpOverrides.global = _DevHttpOverrides();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeIn,
    );
    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _fetchCategory() async {
    try {
      final cateRepository = CategoryRepository();
      _cateList = await cateRepository.getAll(widget.brandId);
      setState(() {});
    } catch (e) {
      _showSnackBar('Failed to load category: $e', Colors.red);
    }
  }

  void _fetchProducts() {
    setState(() {
      _futureProducts =
          _storeMenuRepository.getListProduct(widget.menuId).then((products) {
        switch (_sortOption) {
          case 'newest':
            products.sort((a, b) => b.productId.compareTo(a.productId));
            break;
          case 'oldest':
            products.sort((a, b) => a.productId.compareTo(b.productId));
            break;
          case 'name_asc':
            products.sort((a, b) => (a.productName.toLowerCase() ?? '')
                .compareTo(b.productName.toLowerCase() ?? ''));
            break;
          case 'name_desc':
            products.sort((a, b) => (b.productName.toLowerCase() ?? '')
                .compareTo(a.productName.toLowerCase() ?? ''));
            break;
          case 'price_asc':
            products.sort((a, b) => (a.productSizePrices.first.price ?? 0)
                .compareTo(b.productSizePrices.first.price ?? 0));
          case 'price_desc':
            products.sort((a, b) => (b.productSizePrices.first.price ?? 0)
                .compareTo(b.productSizePrices.first.price ?? 0));
          default:
            products.sort((a, b) => b.productId.compareTo(a.productId));
        }
        if (_searchQuery.isNotEmpty) {
          products = products
              .where((product) =>
                  product.productName
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false)
              .toList();
        }
        return products;
      });
    });
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  List<Product> _filterProducts(List<Product> products) {
    if (_selectedCategory != null) {
      return products
          .where((product) => product.categoryId == _selectedCategory)
          .toList();
    }
    return products;
  }

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
              'Store Menus',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.orange.shade100,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchUI(),
          _buildFilterUI(),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No product found'));
                } else {
                  final products = _filterProducts(snapshot.data!);
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return AnimatedBuilder(
                        animation: _animationController!,
                        builder: (context, child) {
                          return FadeTransition(
                              opacity: _animation!,
                              child: Transform(
                                  transform: Matrix4.translationValues(
                                      0, 50 * (1 - _animation!.value), 0),
                                  child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.6),
                                            offset: const Offset(4, 4),
                                            blurRadius: 16,
                                          ),
                                        ],
                                      ),
                                      child: Column(children: [
                                        AspectRatio(
                                          aspectRatio: 2,
                                          child: Image.network(
                                            product.productImgPath ?? '',
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                const Icon(Icons.broken_image,
                                                    size: 40,
                                                    color: Colors.red),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                              left: 16,
                                              right: 16,
                                              top: 8,
                                              bottom: 16),
                                          child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        product?.productName ??
                                                            'Unknown Product',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 22,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        product?.productDescription ??
                                                            'No description available',
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 2,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      const SizedBox(height: 8),
                                                      _buildSizesAndPrices(
                                                          product)
                                                    ],
                                                  ),
                                                ),
                                              ]),
                                        ),
                                      ]))));
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizesAndPrices(Product product) {
    if (product.productSizePrices == null ||
        product.productSizePrices.isEmpty) {
      return Text("No prices available");
    }

    var sizePrices = product.productSizePrices;

    if (sizePrices.length == 1) {
      return Text(
        "Price: \$${sizePrices[0].price}",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.blue,
        ),
      );
    }

    Map<int, String> sizeLabelsMap = {
      0: "S",
      1: "M",
      2: "L",
    };

    List<String> sizeLabels = [];
    List<String> priceLabels = [];

    sizePrices.forEach((psp) {
      String sizeLabel = sizeLabelsMap[psp.productSizeType] ?? "Unknown";

      if (sizeLabel != "Unknown") {
        sizeLabels.add(sizeLabel);
        priceLabels.add("\$${psp.price}");
      }
    });

    if (sizeLabels.isEmpty) {
      return Text("No sizes available");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: sizeLabels
              .map((label) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: priceLabels
              .map((price) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        price,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildFilterUI() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
      child: Row(
        children: [
          DropdownButton<int?>(
            hint: Text("Category"),
            value: _selectedCategory,
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text("All"),
              ),
              ..._cateList?.map((category) {
                    return DropdownMenuItem<int?>(
                      value: category.categoryId,
                      child: Text(category.categoryName),
                    );
                  }).toList() ??
                  [],
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
                _fetchProducts();
              });
            },
          ),
          SizedBox(width: 16),
          DropdownButton<String>(
            value: _sortOption,
            items: [
              DropdownMenuItem<String>(
                value: 'newest',
                child: Text('Newest'),
              ),
              DropdownMenuItem<String>(
                value: 'oldest',
                child: Text('Oldest'),
              ),
              DropdownMenuItem<String>(
                value: 'name_asc',
                child: Text('Name A-Z'),
              ),
              DropdownMenuItem<String>(
                value: 'name_desc',
                child: Text('Name Z-A'),
              ),
              DropdownMenuItem<String>(
                value: 'price_asc',
                child: Text('Price Ascending'),
              ),
              DropdownMenuItem<String>(
                value: 'price_desc',
                child: Text('Price Descending'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _sortOption = value!;
                _fetchProducts();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchUI() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      offset: Offset(0, 2),
                      blurRadius: 8),
                ],
              ),
              margin: EdgeInsets.only(right: 16, top: 8, bottom: 8),
              child: Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _fetchProducts();
                    });
                  },
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search",
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    offset: Offset(0, 2),
                    blurRadius: 8),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  _fetchProducts();
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Icon(Icons.search, size: 20, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
