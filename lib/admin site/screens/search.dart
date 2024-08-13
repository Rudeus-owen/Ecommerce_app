import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  String searchResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
  title: TextField(
    controller: searchController,
    decoration:const InputDecoration(
      hintText: 'Search...',
      border: InputBorder.none,
    ),
    onChanged: (value) {
      // Handle onChanged
    },
    onSubmitted: (value) {
      // Handle onSubmitted (e.g., perform search)
      print('Searching for: $value');
      performSearch(value);
    },
    style: TextStyle(color: Colors.black),
  ),
  backgroundColor: Colors.white,
  elevation: 0,
  leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () {
      Navigator.pop(context);
    },
  ),
  actions: <Widget>[
    IconButton(
      icon: Icon(Icons.search, color: Colors.black),
      onPressed: () {
        // Handle search icon press
        performSearch(searchController.text);
      },
    ),
  ],
),

      body: SafeArea(
        child: Center(
          child: searchResult.isNotEmpty
              ? Text(
                  'Search Result: $searchResult',
                  style: TextStyle(fontSize: 18),
                )
              : const Text(
                  'Your searching is not found',
                  style: TextStyle(fontSize: 18),
                ),
        ),
      ),
    );
  }

  void performSearch(String value) {
    // Perform your search logic here
    // For now, let's just set a dummy search result
    setState(() {
      if (value == 'apple') {
        searchResult = 'Apple';
      } else if (value == 'banana') {
        searchResult = 'Banana';
      } else {
        searchResult = '';
      }
    });
  }

  @override
  void dispose() {
    // Dispose the controller when the widget is disposed
    searchController.dispose();
    super.dispose();
  }
}
