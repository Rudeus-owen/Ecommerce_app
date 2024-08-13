import 'package:flutter/material.dart';

class AllSubcategoriesScreen extends StatelessWidget {
  final List<dynamic> subcategories;
  final int selectedCategoryId;

  AllSubcategoriesScreen({required this.subcategories, required this.selectedCategoryId});

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredSubcategories = subcategories
        .where((subcategory) => subcategory['product_category_id'] == selectedCategoryId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('All Subcategories'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 3 / 2,
        ),
        itemCount: filteredSubcategories.length,
        itemBuilder: (context, index) {
          final subcategory = filteredSubcategories[index];
          return GestureDetector(
            onTap: () {
              Navigator.pop(context, subcategory['id']);
            },
            child: SubcategoryCard(subcategory['name']),
          );
        },
      ),
    );
  }
}

class SubcategoryCard extends StatelessWidget {
  final String subcategoryName;

  SubcategoryCard(this.subcategoryName);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          gradient: LinearGradient(
            colors: [Color.fromRGBO(63, 67, 101, 1), Color.fromRGBO(98, 105, 137, 1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            subcategoryName,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
