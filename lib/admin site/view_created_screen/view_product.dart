import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_ecommerce_app/admin%20site/screens/qr_code_scanner.dart';
import 'package:new_ecommerce_app/admin%20site/screens/view_product_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class ViewProductPage extends StatefulWidget {
  const ViewProductPage({Key? key}) : super(key: key);

  @override
  State<ViewProductPage> createState() => _ViewProductPageState();
}

class _ViewProductPageState extends State<ViewProductPage> with TickerProviderStateMixin {
  bool _isDarkMode = false;
  List<dynamic> products = [];
  String _searchQuery = '';
  late AnimationController _headerController;
  late Animation<Offset> _headerOffsetAnimation;
  List<AnimationController>? _cardControllers;

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _headerOffsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeInOutQuad,
    ));

    _headerController.forward();
  }

  Future<void> _loadDarkModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    if (_cardControllers != null) {
      for (var controller in _cardControllers!) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Future<List<dynamic>> _fetchProducts() async {
    try {
      final productResponse = await http.get(Uri.parse('http://10.0.2.2:8000/api/products'));
      final productImageResponse = await http.get(Uri.parse('http://10.0.2.2:8000/api/productImages'));

      if (productResponse.statusCode == 200 && productImageResponse.statusCode == 200) {
        final productsData = jsonDecode(productResponse.body);
        final productImagesData = jsonDecode(productImageResponse.body)['data'];

        products = productsData.map((product) {
          final productImage = productImagesData.firstWhere(
            (image) => image['product_id'] == product['id'],
            orElse: () => {'product_img': ''},
          );

          String productImageUrl = '';
          if (productImage['product_img'] is String) {
            productImageUrl = productImage['product_img'];
          } else if (productImage['product_img'] is Map && productImage['product_img']['data'] is List) {
            try {
              productImageUrl = String.fromCharCodes(productImage['product_img']['data'].cast<int>());
            } catch (e) {
              productImageUrl = '';
            }
          }

          return {
            ...product,
            'product_img': productImageUrl,
          };
        }).toList();

        _cardControllers = List.generate(products.length, (index) {
          return AnimationController(
            duration: const Duration(milliseconds: 1000),
            vsync: this,
          )..forward();
        });

        return products;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  String truncateDescription(String description, int charLimit) {
    if (description.length > charLimit) {
      return description.substring(0, charLimit) + '...';
    } else {
      return description;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = _isDarkMode ?  Color.fromARGB(255, 19, 26, 46) : const Color.fromRGBO(238, 241, 242, 1);
    Color cardColor = _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white;
    Color textColor = _isDarkMode ? Colors.white : Color.fromARGB(255, 19, 26, 46);

    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            AnimatedBuilder(
              animation: _headerController,
              builder: (context, child) {
                return SlideTransition(
                  position: _headerOffsetAnimation,
                  child: Container(
                    height: MediaQuery.of(context).size.height / 9,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 19, 26, 46),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30.0),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 13.0, sigmaY: 13.0),
                              child: Container(
                                color: Color(0xFF17203A).withOpacity(0.2),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                              ),
                              onChanged: (query) {
                                setState(() {
                                  _searchQuery = query;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => QRCodeScannerPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: FutureBuilder<List<dynamic>>(
                  future: _fetchProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('Error loading products'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No products found'));
                    } else {
                      final products = snapshot.data!;
                      return ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final productName = product['name'] ?? 'Unknown Product';
                          final productDescription = truncateDescription(product['description'] ?? 'No description available', 15);
                          final productImage = product['product_img'] ?? '';
                          final slideDirection = index % 2 == 0 ? Offset(-1, 0) : Offset(1, 0);

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add left and right margin
                            child: Column(
                              children: [
                                SlideTransition(
                                  position: Tween<Offset>(
                                    begin: slideDirection,
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: _cardControllers![index],
                                    curve: Curves.easeInOutQuad,
                                  )),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProductViewScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      backgroundColor: cardColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: const BorderSide(color: Color.fromRGBO(63, 67, 101, 1), width: 2),
                                      ),
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                                      padding: const EdgeInsets.all(8),
                                      width: double.infinity,
                                      child: Row(
                                        children: [
                                          productImage.isNotEmpty
                                              ? Image.network(
                                                  productImage,
                                                  width: 50,
                                                  height: 50,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      width: 50,
                                                      height: 50,
                                                      color: Colors.grey,
                                                      child: const Icon(Icons.image, color: Colors.white),
                                                    );
                                                  },
                                                )
                                              : Container(
                                                  width: 50,
                                                  height: 50,
                                                  color: Colors.grey,
                                                  child: const Icon(Icons.image, color: Colors.white),
                                                ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  productName,
                                                  style: TextStyle(
                                                    color: textColor,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  productDescription,
                                                  style: TextStyle(color: textColor.withOpacity(0.7)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10), // Space between cards
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
