import 'dart:io';

import 'package:new_ecommerce_app/admin%20site/screens/Update_profile.dart';
import 'package:new_ecommerce_app/user%20site/screens/first_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/ABNBar.dart';
import '../widgets/Sidebar.dart';
import 'search.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  int _selectedIndex = 2;
  bool _isDarkMode = false;
 
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
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
  
   void _logout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Optionally clear all shared preferences or specific ones
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => FirstScreen()), 
    (Route<dynamic> route) => false, // This will remove all the routes off the navigator
  );
}

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color appBarColor = _isDarkMode ?  Color.fromARGB(255, 19, 26, 46): const Color.fromRGBO(238, 241, 242, 1); //const Color.fromRGBO(51,54,72, 1)
    Color textColor = _isDarkMode ? Colors.white : Colors.black;
     Color backgroundColor = _isDarkMode ?  Color.fromARGB(255, 19, 26, 46): const Color.fromRGBO(238, 241, 242, 1);//const Color(0xFF17203A) 

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Profile Page",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: appBarColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: textColor),
          onPressed: _openDrawer,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search, color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _getImage,
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: _image != null
                                ? Image.file(_image!, fit: BoxFit.cover)
                                : const Image(
                                    image:
                                        AssetImage("assets/images/world.jpg"),
                                    fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.blue,
                            ),
                            child: const Icon(
                              LineAwesomeIcons.alternate_pencil,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      Text(
                        "C R I S",
                        style: TextStyle(fontSize: 20, color: textColor),
                      ),
                      const SizedBox(
                        height: 9,
                      ),
                      Text(
                        "Profile Subheading",
                        style: TextStyle(color: textColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                             UpdateProfileScreen(), // Replace ProfilePage with your actual profile page
                      ),
                    );
                  },
                  child: const Text("Edit Profile"),
                ),
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 10),
                _buildMenu("Settings", LineAwesomeIcons.cog, () {}),
                _buildMenu("Billing Details", LineAwesomeIcons.wallet, () {}),
                _buildMenu(
                    "User Management", LineAwesomeIcons.user_check, () {}),
                const Divider(),
                const SizedBox(height: 10),
                _buildMenu("Information", LineAwesomeIcons.info, () {}),
               _buildMenu("Logout", LineAwesomeIcons.alternate_sign_out, _logout),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        isDarkMode: _isDarkMode,
      ),
   drawer: Sidebar(
  isDarkMode: _isDarkMode,
  toggleDarkMode: _toggleDarkMode,
),


    );
  }

 Widget _buildMenu(String title, IconData icon, VoidCallback onPress) {
    return ListTile(
      onTap: onPress,
      leading: Icon(
        icon,
        color: _isDarkMode ? Colors.white : Colors.black,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: _isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
