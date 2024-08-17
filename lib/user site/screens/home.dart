import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_ecommerce_app/user%20site/screens/all_Subcategories_screen.dart';
import 'package:new_ecommerce_app/user%20site/screens/all_categories_screen.dart';
import 'package:new_ecommerce_app/user%20site/screens/messages_screen.dart';
import 'package:new_ecommerce_app/user%20site/screens/notification_screen.dart';
import 'package:new_ecommerce_app/user%20site/screens/profile_screen.dart';
import 'package:new_ecommerce_app/user%20site/screens/Topic_screen.dart';
import 'package:new_ecommerce_app/user%20site/widget/bottom_navigatior_bar.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeContent(),
    HomeContent(),
    TopicScreen(),
    NotificationScreen(),
    MessageScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GEEZE'),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromRGBO(238, 241, 242, 1),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigate to CartScreen
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  int? selectedCategoryId;
  int? selectedSubcategoryId;
  String label = "Products (ALL)";
  List<dynamic> categories = [];
  List<dynamic> subcategories = [];
  List<dynamic> products = [];
  List<dynamic> items = [];
  List<dynamic> variations = [];
  Map<int, String> productImages = {};
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchSubcategories();
    fetchProducts();
    fetchItems();
    fetchVariations();
  }

  void fetchCategories() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8000/api/productcategories'));
    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body);
      });
    }
  }

  void fetchSubcategories() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8000/api/subcategories'));
    if (response.statusCode == 200) {
      setState(() {
        subcategories = json.decode(response.body);
      });
    }
  }

  Future<void> fetchProducts() async {
    final productResponse =
        await http.get(Uri.parse('http://10.0.2.2:8000/api/products'));
    final productImageResponse =
        await http.get(Uri.parse('http://10.0.2.2:8000/api/productImages'));

    if (productResponse.statusCode == 200 &&
        productImageResponse.statusCode == 200) {
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
        } else if (productImage['product_img'] is Map &&
            productImage['product_img']['data'] is List) {
          try {
            productImageUrl = String.fromCharCodes(
                productImage['product_img']['data'].cast<int>());
          } catch (e) {
            productImageUrl = '';
          }
        }

        return {
          ...product,
          'product_img': productImageUrl,
        };
      }).toList();

      setState(() {});
    }
  }

  void fetchItems() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8000/api/items'));
    if (response.statusCode == 200) {
      setState(() {
        items = json.decode(response.body);
      });
    }
  }

  void fetchVariations() async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:8000/api/product-variations'));
    if (response.statusCode == 200) {
      setState(() {
        variations = json.decode(response.body);
      });
    }
  }

  void onCategorySelected(int categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
      selectedSubcategoryId = null;
      label = categories.firstWhere(
          (category) => category['id'] == categoryId)['category_name'];
      searchQuery = "";
    });
    fetchSubcategories();
  }

  void onSubcategorySelected(int subcategoryId) {
    setState(() {
      selectedSubcategoryId = subcategoryId;
      final subcategory =
          subcategories.firstWhere((sub) => sub['id'] == subcategoryId);
      final category = categories
          .firstWhere((cat) => cat['id'] == subcategory['product_category_id']);
      label = '${category['category_name']} (${subcategory['name']})';
      searchQuery = "";
    });
  }

  void onShowAllSelected() {
    setState(() {
      selectedCategoryId = null;
      selectedSubcategoryId = null;
      label = "Products (ALL)";
      searchQuery = "";
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) => TopicScreen()));
  }

  void onSearchChanged(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      selectedCategoryId = null; // Clear the selected category
      selectedSubcategoryId = null; // Clear the selected subcategory
      label = query.isEmpty ? "Products (ALL)" : "Your search results";
    });
  }

  Future<void> navigateToAllCategories(BuildContext context) async {
    final selectedCategoryId = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllCategoriesScreen(categories: categories),
      ),
    );
    if (selectedCategoryId != null) {
      onCategorySelected(selectedCategoryId);
    }
  }

  Future<void> navigateToAllSubcategories(BuildContext context) async {
    final selectedSubcategoryId = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllSubcategoriesScreen(
          subcategories: subcategories,
          selectedCategoryId: selectedCategoryId!,
        ),
      ),
    );
    if (selectedSubcategoryId != null) {
      onSubcategorySelected(selectedSubcategoryId);
    }
  }

  List<dynamic> getFilteredProducts() {
    List<dynamic> filteredProducts = products;

    if (selectedCategoryId != null) {
      filteredProducts = filteredProducts
          .where((product) => product['category_id'] == selectedCategoryId)
          .toList();
    }

    if (selectedSubcategoryId != null) {
      filteredProducts = filteredProducts
          .where(
              (product) => product['sub_category_id'] == selectedSubcategoryId)
          .toList();
    }

    if (searchQuery.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        final productName = product['name'].toString().toLowerCase();
        final categoryName = categories
            .firstWhere((category) => category['id'] == product['category_id'],
                orElse: () => {'category_name': ''})['category_name']
            .toString()
            .toLowerCase();
        final subcategoryName = subcategories
            .firstWhere(
                (subcategory) =>
                    subcategory['id'] == product['sub_category_id'],
                orElse: () => {'name': ''})['name']
            .toString()
            .toLowerCase();
        return productName.contains(searchQuery) ||
            categoryName.contains(searchQuery) ||
            subcategoryName.contains(searchQuery);
      }).toList();
    }

    return filteredProducts;
  }

  void navigateToProductDetail(int productId) {
    Navigator.pushNamed(context, '/product-detail', arguments: productId);
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredSubcategories = subcategories
        .where((subcategory) =>
            subcategory['product_category_id'] == selectedCategoryId)
        .toList();

    List<dynamic> filteredProducts = getFilteredProducts();
    filteredProducts.sort((a, b) =>
        b['id'].compareTo(a['id'])); // Sort products by most recently created

    return Container(
      color: Color.fromARGB(255, 218, 220, 222),
      child: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            floating: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 70.0,
              maxHeight: 70.0,
              child: Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                padding: const EdgeInsets.all(8.0),
                color: const Color.fromRGBO(238, 241, 242, 1),
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search for products...',
                    prefixIcon: const Icon(Icons.search),
                    fillColor: const Color.fromRGBO(238, 241, 242, 1),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                // Categories Card
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(238, 241, 242, 1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Categories',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () => navigateToAllCategories(context),
                              child: const Text('See All'),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 80, // Keep the height same
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 3.0,
                                  vertical:
                                      10.0), // Increase padding to make scroll area more prominent
                              child: CategoryCard(
                                categoryName: category['category_name'],
                                isSelected:
                                    category['id'] == selectedCategoryId,
                                onSelect: () =>
                                    onCategorySelected(category['id']),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Subcategories Card
                if (selectedCategoryId != null &&
                    filteredSubcategories.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 0),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(238, 241, 242, 1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Subcategories',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              TextButton(
                                onPressed: () =>
                                    navigateToAllSubcategories(context),
                                child: const Text('See All'),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 80, // Keep the height same
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: filteredSubcategories.length,
                            itemBuilder: (context, index) {
                              final subcategory = filteredSubcategories[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2.0,
                                    vertical:
                                        10.0), // Increase padding to make scroll area more prominent
                                child: CategoryCard(
                                  categoryName: subcategory['name'],
                                  isSelected: subcategory['id'] ==
                                      selectedSubcategoryId,
                                  onSelect: () =>
                                      onSubcategorySelected(subcategory['id']),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                // Products Card
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(238, 241, 242, 1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.6),
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: onShowAllSelected,
                              child: const Text('Show All'),
                            ),
                          ],
                        ),
                      ),
                      filteredProducts.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  searchQuery.isNotEmpty
                                      ? "No products found for your search"
                                      : "No products exist",
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio:
                                      0.49, // Adjusted aspect ratio
                                ),
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = filteredProducts[index];
                                  final itemVariations = variations
                                      .where((variation) => items.any((item) =>
                                          item['id'] == variation['item_id'] &&
                                          item['product_id'] == product['id']))
                                      .toList();

                                  final imageUrl = product['product_img'] ?? '';

                                  return GestureDetector(
                                    onTap: () {
                                      navigateToProductDetail(product['id']);
                                    },
                                    child: ProductCard(
                                      id: product['id'],
                                      name: product['name'],
                                      description: product['description'],
                                      variations: itemVariations,
                                      imageUrl: imageUrl,
                                    ),
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  _SliverAppBarDelegate({
    required this.child,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class CategoryCard extends StatefulWidget {
  final String categoryName;
  final bool isSelected;
  final Function onSelect;

  CategoryCard(
      {required this.categoryName,
      required this.isSelected,
      required this.onSelect});

  @override
  _CategoryCardState createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onSelect(),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: Container(
            width: 80,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isSelected || _isHovered
                    ? [
                        const Color.fromRGBO(63, 67, 101, 1),
                        const Color.fromRGBO(98, 105, 137, 1)
                      ]
                    : [Colors.white, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Text(
                widget.categoryName,
                style: TextStyle(
                  color: widget.isSelected || _isHovered
                      ? Colors.white
                      : const Color.fromARGB(255, 25, 25, 25),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final int id;
  final String name;
  final String description;
  final List<dynamic> variations;
  final String imageUrl;

  ProductCard({
    required this.id,
    required this.name,
    required this.description,
    required this.variations,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Get the first variation's price
    final firstVariation = variations.isNotEmpty ? variations.first : null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: const Color.fromRGBO(238, 241, 242, 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(8.0)),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 250, // Adjusted height for product showcase
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.grey,
                  child: const Icon(Icons.image, size: 50, color: Colors.white),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
          ),
          if (firstVariation != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\MMK ${firstVariation['price']}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                        decoration: firstVariation['promotion_price'] != null
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    if (firstVariation['promotion_price'] != null)
                      Text(
                        '\MMK ${firstVariation['promotion_price']}',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
