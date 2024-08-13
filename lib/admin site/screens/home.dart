import 'package:flutter/foundation.dart';
import 'package:new_ecommerce_app/admin%20site/create_screens/create_category.dart';
import 'package:new_ecommerce_app/admin%20site/create_screens/create_promotion.dart';
import 'package:new_ecommerce_app/admin%20site/create_screens/create_screen.dart';
import 'package:new_ecommerce_app/admin%20site/create_screens/create_subcategory.dart';
import 'package:new_ecommerce_app/admin%20site/screens/search.dart';
import 'package:new_ecommerce_app/admin%20site/view_created_screen/view_category.dart';
import 'package:new_ecommerce_app/admin%20site/view_created_screen/view_product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../widgets/ABNBar.dart';
import '../widgets/Sidebar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _isDarkMode = false;
  bool _isDrawerOpen = false;
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _controller;
  late AnimationController _productCardController;
  late AnimationController _categoryCardController;
  late AnimationController _subcategoryCardController;
  late Animation<Offset> _productCardAnimation;
  late Animation<Offset> _categoryCardAnimation;
  late Animation<Offset> _subcategoryCardAnimation;
  int productCount = 0;
  int categoryCount = 0;
  int subcategoryCount = 0;
  int promotionCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
    _fetchData();

    _controller = AnimationController(
      duration: const Duration(seconds: 16), // Total duration for a complete cycle (4 colors * 4 seconds each)
      vsync: this,
    )..repeat();

    _productCardController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );

    _categoryCardController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _subcategoryCardController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _productCardAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _productCardController,
      curve: Curves.easeInOutQuad,
    ));

    _categoryCardAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _categoryCardController,
      curve: Curves.easeInOutQuad,
    ));

    _subcategoryCardAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _subcategoryCardController,
      curve: Curves.easeInOutQuad,
    ));

    _productCardController.forward();
    _categoryCardController.forward();
    _subcategoryCardController.forward();
  }

  Future<void> _fetchData() async {
    try {
      final productResponse = await http.get(Uri.parse('http://10.0.2.2:8000/api/products'));
      final categoryResponse = await http.get(Uri.parse('http://10.0.2.2:8000/api/productcategories'));
      final subcategoryResponse = await http.get(Uri.parse('http://10.0.2.2:8000/api/subcategories'));
      final promotionResponse = await http.get(Uri.parse('http://10.0.2.2:8000/api/promotions'));

      if (productResponse.statusCode == 200) {
        setState(() {
          productCount = jsonDecode(productResponse.body).length;
        });
      } else {
        print('Failed to load products');
      }

      if (categoryResponse.statusCode == 200) {
        setState(() {
          categoryCount = jsonDecode(categoryResponse.body).length;
        });
      } else {
        print('Failed to load categories');
      }

      if (subcategoryResponse.statusCode == 200) {
        setState(() {
          subcategoryCount = jsonDecode(subcategoryResponse.body).length;
        });
      } else {
        print('Failed to load subcategories');
      }

      if (promotionResponse.statusCode == 200) {
        setState(() {
          promotionCount = jsonDecode(promotionResponse.body).length;
        });
      } else {
        print('Failed to load promotions');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _productCardController.dispose();
    _categoryCardController.dispose();
    _subcategoryCardController.dispose();
    super.dispose();
  }

  Future<void> _loadDarkModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleDarkMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
    setState(() {
      _isDarkMode = value;
    });
  }

  void _toggleDrawer() {
    if (_isDrawerOpen) {
      Navigator.of(context).pop();
    } else {
      _scaffoldKey.currentState?.openDrawer();
    }
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  void _navigateToCreatePage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePage(
          onItemCreated: _fetchData, // Pass the callback function
        ),
      ),
    );
    _fetchData(); // Refresh data when returning to HomePage
  }

  void _navigateToCreateCategoryPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateCategoryPage(
          onItemCreated: _fetchData, // Pass the callback function
        ),
      ),
    );
    _fetchData(); // Refresh data when returning to HomePage
  }

  void _navigateToCreateSubCategoryPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSubCategoryPage(
          onItemCreated: _fetchData, // Pass the callback function
        ),
      ),
    );
    _fetchData(); // Refresh data when returning to HomePage
  }

  void _navigateToCreatePromotionPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePromotionPage(
          onItemCreated: _fetchData, // Pass the callback function
        ),
      ),
    );
    _fetchData(); // Refresh data when returning to HomePage
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    Color appBarColor = Color.fromARGB(255, 19, 26, 46);
    Color backgroundColor = _isDarkMode ? Color.fromARGB(255, 19, 26, 46) : const Color.fromRGBO(238, 241, 242, 1);
    Color appBarText = _isDarkMode ? Colors.white : Colors.white;
    Color cardtext = _isDarkMode ? Colors.white : const Color(0xFF17203A);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            _isDrawerOpen ? Icons.close : Icons.menu,
            color: appBarText,
          ),
          onPressed: _toggleDrawer,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search, color: appBarText),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height / 2.7, // Adjust height to end just above "My Creation"
              decoration: BoxDecoration(
                color:   Color.fromARGB(255, 19, 26, 46),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _buildStatusCards(context, cardtext),
                    const SizedBox(height: 40), // Adjusted space between "Create Product" card and "My Creation" text
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5), // Adjust left padding to match card margin
                            child: AnimatedTextKit(
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  'My Creation',
                                  textStyle: TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: GoogleFonts.lato().fontFamily,
                                    color: const Color.fromRGBO(241, 151, 96, 1),
                                  ),
                                  speed: const Duration(milliseconds: 200),
                                ),
                              ],
                              totalRepeatCount: 1,
                              pause: const Duration(milliseconds: 1000),
                              displayFullTextOnTap: true,
                              stopPauseOnTap: true,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 5), // Adjust right padding to match card margin
                          child: Icon(
                            Icons.lightbulb_outline,
                            color: const Color.fromRGBO(241, 151, 96, 1),
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10), // Adjusted space between "My Creation" title and task cards
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 80), // Add padding to the bottom
                        child: Column(
                          children: [
                            _buildTaskCard('Products', '$productCount products', _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white, cardtext, _isDarkMode ? Colors.purple : Colors.purple, Icons.shopping_bag),
                            const SizedBox(height: 11),
                            _buildTaskCard('Categories', '$categoryCount categories', _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white, cardtext, _isDarkMode ? Colors.orange : Colors.orange, Icons.category),
                            const SizedBox(height: 11),
                            _buildTaskCard('Subcategories', '$subcategoryCount subcategories', _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white, cardtext, _isDarkMode ? Colors.green : Colors.green, Icons.subdirectory_arrow_right),
                            const SizedBox(height: 11),
                            _buildTaskCard('Promotions', '$promotionCount promotions', _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white, cardtext, _isDarkMode ? Colors.red : Colors.red, Icons.local_offer),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomBottomNavigationBar(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
                isDarkMode: _isDarkMode,
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Sidebar(
          isDarkMode: _isDarkMode,
          toggleDarkMode: _toggleDarkMode,
        ),
      ),
      onDrawerChanged: (isOpen) {
        setState(() {
          _isDrawerOpen = isOpen;
        });
      },
    );
  }

  Widget _buildStatusCards(BuildContext context, Color cardtext) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildStatusCard('Product', const Color.fromRGBO(63, 67, 101, 1), Icons.shopping_bag, context, 160, _productCardAnimation),
              const SizedBox(height: 6),
              _buildStatusCard('Category', const Color.fromRGBO(241, 151, 96, 1), Icons.category, context, 100, _categoryCardAnimation), // Category card height
            ],
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            children: [
              _buildStatusCard('Subcategory', const Color.fromRGBO(241, 151, 96, 1), Icons.subdirectory_arrow_right, context, 100, _subcategoryCardAnimation), // Subcategory card height
              const SizedBox(height: 6),
              _buildStatusCard('Promotion', const Color.fromRGBO(63, 67, 101, 1), Icons.local_offer, context, 160, null), // Promotion card height
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(String status, Color color, IconData icon, BuildContext context, double height, Animation<Offset>? animation) {
    return animation == null
        ? ElevatedButton(
            onPressed: () {
              _navigateToCreatePageByStatus(status);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              padding: EdgeInsets.zero, // Remove default padding
            ),
            child: _buildStatusCardContent(status, color, icon, height),
          )
        : SlideTransition(
            position: animation,
            child: ElevatedButton(
              onPressed: () {
                _navigateToCreatePageByStatus(status);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                padding: EdgeInsets.zero, // Remove default padding
              ),
              child: _buildStatusCardContent(status, color, icon, height),
            ),
          );
  }

  Widget _buildStatusCardContent(String status, Color color, IconData icon, double height) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      height: height, // Set height for each card
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0), // Add padding
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 30), // Adjust icon size
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Create', // Optional subtitle
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 8,
            right: 8,
            child: Icon(Icons.add_circle, color: Colors.white, size: 20), // Small create icon
          ),
        ],
      ),
    );
  }

  void _navigateToCreatePageByStatus(String status) {
    if (status == 'Product') {
      _navigateToCreatePage();
    } else if (status == 'Category') {
      _navigateToCreateCategoryPage();
    } else if (status == 'Subcategory') {
      _navigateToCreateSubCategoryPage();
    } else if (status == 'Promotion') {
      _navigateToCreatePromotionPage();
    }
  }

  Widget _buildTaskCard(String title, String members, Color backgroundColor, Color cardtext, Color borderColor, IconData icon) {
    return ElevatedButton(
      onPressed: () {
        if (title == 'Products') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewProductPage(),
            ),
          );
        }else if (title == 'Categories') {
          Navigator.push(
           context ,
           MaterialPageRoute(builder: (context) => ViewCategoryPage(),),);
        }
        // Add navigation logic for other cards if needed
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: backgroundColor, // Background color of the button
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color:const Color.fromRGBO(63, 67, 101, 1), width: 2), // Border color and width
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        width: double.infinity, // Full width
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: cardtext,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: cardtext,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        members,
                        style: TextStyle(color: cardtext.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
