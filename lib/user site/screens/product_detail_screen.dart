import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:logging/logging.dart';

class ProductViewScreen extends StatefulWidget {
  final int productId;

  const ProductViewScreen({required this.productId});

  @override
  ProductViewScreenState createState() => ProductViewScreenState();
}

class ProductViewScreenState extends State<ProductViewScreen> {
  Map<String, dynamic> productDetail = {};
  List<dynamic> items = [];
  Map<int, List<String>> itemImages =
      {}; // Map to store multiple images for each item
  List<dynamic> productColors = [];
  List<dynamic> variations = [];
  int selectedItemIndex = 0;
  int selectedVariationIndex = 0; // Separate index for selected variation
  bool showAbout = true;
    bool isFavorite = false;

  final ScrollController _scrollController = ScrollController();
  final Logger logger = Logger('ProductViewScreen');

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
    fetchItems();
    fetchItemImages();
    fetchProductColors();
    fetchVariations();
  }

  void fetchProductDetails() async {
    final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/products/${widget.productId}'));
    if (response.statusCode == 200) {
      setState(() {
        productDetail = json.decode(response.body);
      });
    } else {
       logger.warning('Failed to load product details');
    }
  }

  void fetchItems() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8000/api/items'));
    if (response.statusCode == 200) {
      setState(() {
        items = (json.decode(response.body) as List)
            .where((item) => item['product_id'] == widget.productId)
            .toList();
      });
      logger.info('Items loaded: $items');
    } else {
      logger.warning('Failed to load items');
    }
  }

  void fetchItemImages() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8000/api/itemImages'));
    if (response.statusCode == 200) {
      setState(() {
        final jsonResponse = json.decode(response.body);
        List<dynamic> imagesList;
        if (jsonResponse is List) {
          imagesList = jsonResponse;
        } else if (jsonResponse is Map) {
          imagesList = jsonResponse['data'] as List<dynamic>;
        } else {
          imagesList = [];
        }
        itemImages = {
          for (var image in imagesList)
            image['product_item_id']: [
              ...?itemImages[image['product_item_id']],
              _bufferToUrlString(image['image']['data'])
            ]
        };
      });
      logger.info('Item images loaded: $itemImages');
    } else {
      logger.warning('Failed to load item images');
    }
  }

  // Function to convert Buffer to URL string
  String _bufferToUrlString(List<dynamic> buffer) {
    return String.fromCharCodes(buffer.cast<int>());
  }

  void fetchProductColors() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8000/api/product-colors'));
    if (response.statusCode == 200) {
      setState(() {
        productColors = json.decode(response.body) as List<dynamic>;
      });
    } else {
      logger.warning('Failed to load product colors');
    }
  }

  void fetchVariations() async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:8000/api/product-variations'));
    if (response.statusCode == 200) {
      setState(() {
        variations = (json.decode(response.body) as List)
            .where((variation) =>
                items.any((item) => item['id'] == variation['item_id']))
            .toList();
      });
    } else {
      logger.warning('Failed to load variations');
    }
  }

  String calculateRemainingDays(String endDate) {
    try {
      final endDateTime = DateTime.parse(endDate);
      final now = DateTime.now();
      final difference = endDateTime.difference(now).inDays;
      return difference > 0 ? difference.toString() : "Expired";
    } catch (e) {
      return "Invalid date";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Flatten all item images into a single list, including the itemId for each image
    final allImages = items.expand((item) {
      final images =
          itemImages[item['id']] ?? ['https://via.placeholder.com/400'];
      return images
          .map((imageUrl) => {'itemId': item['id'], 'imageUrl': imageUrl});
    }).toList();

    final selectedItem = items.isNotEmpty && selectedItemIndex < items.length
        ? items[selectedItemIndex]
        : null;
    final selectedImages =
        selectedItem != null && itemImages.containsKey(selectedItem['id'])
            ? itemImages[selectedItem['id']]
            : [];

    // Get the color name based on the selected image's item ID
    final selectedItemColor = selectedItem != null
        ? productColors.firstWhere(
            (color) => color['product_item_id'] == selectedItem['id'],
            orElse: () => {'color_name': 'N/A'},
          )
        : null;
    final selectedColorName =
        selectedItemColor != null ? selectedItemColor['color_name'] : 'N/A';

    final selectedVariations = variations
        .where((variation) => variation['item_id'] == selectedItem?['id'])
        .toList();
    final selectedVariation = selectedVariations.isNotEmpty
        ? selectedVariations[selectedVariationIndex]
        : null;

    // Determine the price and original price based on the selected variation
    final price =
        selectedVariation != null ? selectedVariation['price'] : 'N/A';
    final promotionPrice =
        selectedVariation != null ? selectedVariation['promotion_price'] : null;
    final endDate =
        selectedVariation != null ? selectedVariation['end_date'] : null;
    final remainingDays =
        endDate != null ? calculateRemainingDays(endDate) : "N/A";

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          if (selectedImages!.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 400,
                child: PageView.builder(
                  itemCount: selectedImages.length,
                  itemBuilder: (context, index) {
                    // Ensure index is within bounds
                    if (index >= selectedImages.length) {
                      return const SizedBox.shrink();
                    }
                    return Image.network(
                      selectedImages[index],
                      height: 400,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            )
          else
            Image.network(
              'https://via.placeholder.com/400',
              height: 400,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Positioned(
            top: 40,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(11),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 20),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
               child: IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: isFavorite ? Colors.red : Colors.white, // Change color based on the isFavorite state
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    isFavorite = !isFavorite; // Toggle the favorite state when the icon is pressed
                  });
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 240, 239, 239),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6), // Subtle shadow color
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(0, 4), // Shadow position
                  ),
                ],
              ),
              child: Scrollbar(
                controller: _scrollController,
                thickness: 4, // Adjust the thickness to make it smaller
                radius: const Radius.circular(10),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              'Myanmar, Asia',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Text(
                              productDetail['name'] ?? 'Unknown Product',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 1),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.star, color: Colors.orange),
                            const SizedBox(width: 4),
                            const Text(
                              '4.5 (15 Review)',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$price\MMK',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: promotionPrice != null
                                            ? FontWeight.w500
                                            : FontWeight.bold,
                                        decoration: promotionPrice != null
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (promotionPrice != null)
                                      Text(
                                        '/$promotionPrice\MMK',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                  ],
                                ),
                                Text(
                                  '$remainingDays days',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text(
                              'Available Colors:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              selectedColorName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Display all images from all items in the horizontal ListView
                        SizedBox(
                          height: 60,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: allImages.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, imgIndex) {
                              final imageInfo = allImages[imgIndex];
                              final imageUrl = imageInfo['imageUrl'];
                              final itemId = imageInfo['itemId'];
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedItemIndex = items.indexWhere(
                                        (item) => item['id'] == itemId);
                                    selectedVariationIndex = 0;
                                  });
                                },
                                child: Container(
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: selectedItemIndex ==
                                              items.indexWhere((item) =>
                                                  item['id'] == itemId)
                                          ? Colors.blue
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Various Options:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 60,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: selectedVariations.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final variation = selectedVariations[index]
                                      ['variation_name'] ??
                                  '';
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedVariationIndex =
                                        index; // Change the selected variation
                                  });
                                },
                                child: Container(
                                  width: 60,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: selectedVariationIndex == index
                                        ? const Color.fromARGB(255, 219, 219, 219)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    variation,
                                    style: TextStyle(
                                      color: selectedVariationIndex == index
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showAbout = true;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: showAbout
                                          ? Colors.black
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  'About',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        showAbout ? Colors.black : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showAbout = false;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: !showAbout
                                          ? Colors.black
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  'Reviews',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        !showAbout ? Colors.black : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (showAbout)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productDetail['description'] ?? '',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          )
                        else
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Review 1: This place is amazing!',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                'Review 2: Had a wonderful time here.',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                'Review 3: A must visit place.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        // SizedBox(height: 16),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: ElevatedButton(
                        //         onPressed: () {
                        //           // Handle add to cart
                        //         },
                        //         child: Text('Add to Cart'),
                        //       ),
                        //     ),
                        //     SizedBox(width: 8),
                        //     Expanded(
                        //       child: ElevatedButton(
                        //         onPressed: () {
                        //           // Handle buy now
                        //         },
                        //         child: Text('Buy Now'),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
            bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 255, 255, 255),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Handle add to cart
                  },
                  // style: ElevatedButton.styleFrom(
                  //   foregroundColor: Colors.white, backgroundColor: Colors.green, // foreground
                  // ),
                  child: const Text('Add to Cart'),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Handle buy now
                  },
                  // style: ElevatedButton.styleFrom(
                  //   foregroundColor: Colors.white, backgroundColor: Colors.blue, // foreground
                  // ),
                  child: const Text('Buy Now'),
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
