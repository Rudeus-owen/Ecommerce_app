import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:new_ecommerce_app/admin%20site/create_screens/create_category.dart';
import 'package:new_ecommerce_app/admin%20site/screens/home.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/Sidebar.dart';
import '../screens/search.dart';

class ViewCategoryPage extends StatefulWidget {
  const ViewCategoryPage({Key? key}) : super(key: key);

  @override
  State<ViewCategoryPage> createState() => _ViewCategoryPageState();
}

class _ViewCategoryPageState extends State<ViewCategoryPage> with TickerProviderStateMixin {
  bool _isDarkMode = false;
  List<Map<String, dynamic>> categories = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<void> _fetchCategoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
    _fetchCategoriesFuture = _fetchCategories();
  }

  @override
  void didUpdateWidget(ViewCategoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fetchCategoriesFuture = _fetchCategories();
  }

  Future<void> _loadDarkModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/productcategories'));

      if (response.statusCode == 200) {
        final List<dynamic> categoriesData = jsonDecode(response.body);

        setState(() {
          categories = categoriesData.map<Map<String, dynamic>>((category) {
            return {
              'id': category['id'],
              'category_name': category['category_name'],
            };
          }).toList();
        });
      } else {
        setState(() {
          categories = [];
        });
      }
    } catch (e) {
      setState(() {
        categories = [];
      });
    }
  }

  IconData _getIconForCategory(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'electronics':
        return Icons.electrical_services;
      case 'home':
        return Icons.home;
      case 'book':
        return Icons.book;
      case 'class':
        return Icons.class_;
      case 'snack':
        return Icons.fastfood;
      case 'gold':
        return Icons.monetization_on;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = _isDarkMode ?  Color.fromARGB(255, 19, 26, 46) : const Color.fromRGBO(238, 241, 242, 1);
    Color cardColor = _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white;
    Color textColor = _isDarkMode ? Colors.white : const Color(0xFF17203A);
    Color appBarColor = Color.fromARGB(255, 19, 26, 46);
    Color appBarTextColor = Colors.white;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.circlePlus, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateCategoryPage(onItemCreated: () {})));

              if (result == true) {
                await _fetchCategories(); // Refresh the category list
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _fetchCategoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading categories'));
          } else {
            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final categoryName = category['category_name'] ?? 'Unknown Category';
                final categoryIcon = _getIconForCategory(categoryName);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Add navigation logic if needed
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(color: Color.fromRGBO(63, 67, 101, 1), width: 1),
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                          padding: const EdgeInsets.all(8),
                          width: double.infinity,
                          child: Row(
                            children: [
                              Icon(categoryIcon, size: 40, color: textColor),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      categoryName,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
