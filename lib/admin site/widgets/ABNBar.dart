import 'package:new_ecommerce_app/admin%20site/screens/home.dart';
import 'package:new_ecommerce_app/admin%20site/screens/order.dart';
import 'package:new_ecommerce_app/admin%20site/screens/profile.dart';
import 'package:new_ecommerce_app/admin%20site/screens/chart.dart';
import 'package:flutter/material.dart';

// final Color bottomNavBgColor = Colors.lightGreen;

class CustomBottomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool isDarkMode;

  CustomBottomNavigationBar({
    required this.selectedIndex,
    required this.onItemTapped,
    required this.isDarkMode,
  });

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    // print('Rebuilding CustomBottomNavigationBar with color: $bottomNavBgColor');
    return Container(
      height: 60,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.fromLTRB(24, 0, 24, 5), // Adjusted margin to move it up
      decoration: BoxDecoration(
        color:  Color.fromARGB(255, 19, 26, 46),
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.add_home_rounded,
                color: widget.selectedIndex == 0 ?   Color.fromRGBO(241, 151, 96, 1): Colors.grey),
            onPressed: () {
              widget.onItemTapped(0);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.bar_chart,
                color: widget.selectedIndex == 1 ?  Color.fromRGBO(241, 151, 96, 1): Colors.grey),
            onPressed: () {
              widget.onItemTapped(1);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_bag,
                color: widget.selectedIndex == 3 ?  Color.fromRGBO(241, 151, 96, 1): Colors.grey),
            onPressed: () {
              widget.onItemTapped(3);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle,
                color: widget.selectedIndex == 2 ?  Color.fromRGBO(241, 151, 96, 1): Colors.grey),
            onPressed: () {
              widget.onItemTapped(2);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
