import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:smart_menu/models/category.dart';
import 'package:smart_menu/models/store_product.dart';
import 'package:smart_menu/repository/category_repository.dart';
import 'package:smart_menu/repository/store_product_repository.dart';
import 'package:smart_menu/presentation/screens/partner/store_product_form.dart';

class StoreProductListScreen extends StatefulWidget {
  final int storeId;
  final int brandId;

  const StoreProductListScreen(
      {super.key, required this.storeId, required this.brandId});

  @override
  _StoreProductListScreenState createState() => _StoreProductListScreenState();
}

class _StoreProductListScreenState extends State<StoreProductListScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<StoreProduct>> _futureStoreProducts;
  final StoreProductRepository _repository = StoreProductRepository();
  AnimationController? _animationController;
  Animation<double>? _animation;
  List<Category>? _cateList;
  String _searchQuery = '';
  int? _selectedCategory;
  // bool _isAscendingOrder = true;
  String _sortOption = 'newest';

  @override
  void initState() {
    super.initState();
    _fetchCategory();
    _fetchStoreProduct();
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

  void _fetchStoreProduct() {
    setState(() {
      _futureStoreProducts = _repository
          .getAll(widget.storeId, searchString: _searchQuery)
          .then((storeProducts) {
        switch (_sortOption) {
          case 'newest':
            storeProducts
                .sort((a, b) => b.storeProductId.compareTo(a.storeProductId));
            break;
          case 'oldest':
            storeProducts
                .sort((a, b) => a.storeProductId.compareTo(b.storeProductId));
            break;
          case 'name_asc':
            storeProducts.sort((a, b) =>
                (a.product?.productName?.toLowerCase() ?? '')
                    .compareTo(b.product?.productName?.toLowerCase() ?? ''));
            break;
          case 'name_desc':
            storeProducts.sort((a, b) =>
                (b.product?.productName?.toLowerCase() ?? '')
                    .compareTo(a.product?.productName?.toLowerCase() ?? ''));
            break;
          case 'price_asc':
            storeProducts.sort((a, b) =>
                (a.product?.productSizePrices?.first.price ?? 0)
                    .compareTo(b.product?.productSizePrices?.first.price ?? 0));
          case 'price_desc':
            storeProducts.sort((a, b) =>
                (b.product?.productSizePrices?.first.price ?? 0)
                    .compareTo(b.product?.productSizePrices?.first.price ?? 0));
          default:
            storeProducts
                .sort((a, b) => b.storeProductId.compareTo(a.storeProductId));
        }
        if (_searchQuery.isNotEmpty) {
          storeProducts = storeProducts
              .where((storeProduct) =>
                  storeProduct.product?.productName
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false)
              .toList();
        }
        return storeProducts;
      });
    });
  }

  List<StoreProduct> _filterProducts(List<StoreProduct> storeProducts) {
    if (_selectedCategory != null) {
      return storeProducts
          .where((storeProduct) =>
              storeProduct.product?.categoryId == _selectedCategory)
          .toList();
    }
    return storeProducts;
  }

  void _navigateToStoreProductForm({StoreProduct? storeProduct}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreProductFormScreen(
          storeProduct: storeProduct,
          storeId: widget.storeId,
        ),
      ),
    );

    if (result == true) {
      _fetchStoreProduct();
    }
  }

  void _deleteStoreProduct(int storeProductId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Store Product',
            style: TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20)),
        content:
            const Text('Are you sure you want to delete this store product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _repository.deleteStoreProduct(storeProductId);
      _fetchStoreProduct();
      if (success) {
        _showSnackBar('Failed to delete product', Colors.red);
      } else {
        _showSnackBar('Product deleted successfully', Colors.green);
      }
    }
  }

  void _toggleAvailability(StoreProduct storeProduct) async {
    final success = await _repository.updateStoreProduct(
      storeProduct.storeProductId,
      !storeProduct.isAvailable,
    );
    if (success) {
      setState(() {
        storeProduct.isAvailable = !storeProduct.isAvailable;
      });
    } else {
      _showSnackBar('Failed to update product availability', Colors.red);
    }
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
              'Store Products',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.teal,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchUI(),
          _buildFilterUI(),
          Expanded(
            child: FutureBuilder<List<StoreProduct>>(
              future: _futureStoreProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No product found'));
                } else {
                  final storeProducts = _filterProducts(snapshot.data!);
                  return ListView.builder(
                    itemCount: storeProducts.length,
                    itemBuilder: (context, index) {
                      final storeProduct = storeProducts[index];
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
                                child: Column(
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 2,
                                      child: Image.network(
                                        storeProduct.product?.productImgPath ??
                                            '',
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
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
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  storeProduct.product
                                                          ?.productName ??
                                                      'Unknown Product',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 22,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  storeProduct.product
                                                          ?.productDescription ??
                                                      'No description available',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                                const SizedBox(height: 4),
                                                const SizedBox(height: 8),
                                                _buildSizesAndPrices(
                                                    storeProduct)
                                              ],
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  storeProduct.isAvailable
                                                      ? Icons.toggle_on
                                                      : Icons.toggle_off,
                                                  color:
                                                      storeProduct.isAvailable
                                                          ? Colors.green
                                                          : Colors.red,
                                                ),
                                                iconSize: 32,
                                                onPressed: () =>
                                                    _toggleAvailability(
                                                        storeProduct),
                                              ),
                                              const SizedBox(height: 10),
                                              // InkWell(
                                              //   onTap: () {
                                              //     _navigateToStoreProductForm(
                                              //         storeProduct:
                                              //             storeProduct);
                                              //   },
                                              //   child: const Icon(
                                              //     Icons.edit,
                                              //     color: Colors.blue,
                                              //   ),
                                              // ),
                                              const SizedBox(height: 10),
                                              InkWell(
                                                onTap: () {
                                                  _deleteStoreProduct(
                                                      storeProduct
                                                          .storeProductId);
                                                },
                                                child: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          _navigateToStoreProductForm();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSizesAndPrices(StoreProduct storeProduct) {
    if (storeProduct.product?.productSizePrices == null ||
        storeProduct.product!.productSizePrices.isEmpty) {
      return Text("No prices available");
    }

    var sizePrices = storeProduct.product!.productSizePrices;
    bool isVND = storeProduct.product!.productPriceCurrency == 1;

    String formatPrice(double price) {
      if (isVND) {
        return '${price.toStringAsFixed(0)} đ';
      } else {
        return '\$${price.toStringAsFixed(2)}';
      }
    }

    if (sizePrices.length == 1) {
      return Text(
        formatPrice(sizePrices[0].price),
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
        priceLabels.add(formatPrice(psp.price));
      }
    });

    if (sizeLabels.isEmpty) {
      return Text("");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Prices:",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 8),
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
        SizedBox(height: 4),
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
                _fetchStoreProduct();
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
                _fetchStoreProduct();
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
                      _fetchStoreProduct();
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
                  _fetchStoreProduct();
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
