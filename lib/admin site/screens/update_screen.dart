import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'search.dart'; // Make sure this is correctly linked

class UpdatePage extends StatefulWidget {
  const UpdatePage({Key? key}) : super(key: key);

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  final TextEditingController _nameController =
      TextEditingController(text: "Sample Product Name");
  final TextEditingController _descriptionController =
      TextEditingController(text: "Product Description here...");
  final TextEditingController _colorController =
      TextEditingController(text: "Red");
  final TextEditingController _choiceController =
      TextEditingController(text: "Model X");
  final TextEditingController _stockController =
      TextEditingController(text: "25");
  final TextEditingController _priceController =
      TextEditingController(text: "\$999.99");
  String _selectedCategory = 'Electronics';
  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Home',
    'Garden',
    'Toys',
    'Books',
     'shoes',
     'food',
     'Phone',
     'Laptop'
  ];
  File? _profileImage;
  List<File> _detailImages = [];

  bool _isDarkMode = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
  }

  void _toggleDarkMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
    setState(() {
      _isDarkMode = value;
    });
  }

  Future<void> _loadDarkModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDetailImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _detailImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  void _saveProduct() {
    // Implement your save functionality here
    print('Product details saved.');
  }

  Color get appBarColor =>
      _isDarkMode ? const Color.fromRGBO(51, 54, 72, 1) : Colors.white;
  Color get backgroundColor => _isDarkMode
      ? const Color.fromRGBO(51, 54, 72, 1)
      : const Color.fromRGBO(238, 241, 242, 1);
  Color get productBackgroundColor =>
      _isDarkMode ? const Color.fromRGBO(61, 65, 84, 1) : Colors.white;
  Color get textColor => _isDarkMode ? Colors.white : Colors.black;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.ubuntuTextTheme().copyWith(
          headlineMedium:  TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 18),
          bodyLarge: TextStyle(fontSize: 16),
        ),
      ),
      home: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: appBarColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: textColor,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Update Product',
            style: TextStyle(color: textColor),
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.save_as_rounded),
                onPressed: _saveProduct,
                color: textColor),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_profileImage != null) Image.file(_profileImage!),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Select Profile Image'),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                children: _detailImages
                    .map((file) => Image.file(file, width: 100, height: 100))
                    .toList(),
              ),
              ElevatedButton(
                onPressed: _pickDetailImages,
                child: const Text('Select Detail Images'),
              ),
              const SizedBox(height: 20),
              _editableTextField('Product Name', _nameController,textColor,textColor),
              const SizedBox(height: 20),
              _editableTextField('Description', _descriptionController,textColor,textColor),
              const SizedBox(height: 20),
              _editableTextField('Color', _colorController,textColor,textColor),
              const SizedBox(height: 20),
              _dropdownCategory(),
              const SizedBox(height: 20),
              _editableTextField('Choice', _choiceController,textColor,textColor),
              const SizedBox(height: 20),
              _editableTextField('Stock', _stockController,textColor,textColor),
              const SizedBox(height: 20),
              _editableTextField('Price', _priceController,textColor,textColor),
            ],
          ),
        ),
      ),
    );
  }

 Widget _editableTextField(String label, TextEditingController controller, Color labelColor, Color textColor) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: labelColor), // Set the label text color here
      border: OutlineInputBorder(),
      floatingLabelBehavior: FloatingLabelBehavior.always, // Ensure the label floats inside the border
    ),
    style: TextStyle(color: textColor), // Set the text color of the TextField here
  );
}
Widget _dropdownCategory() {
  return DropdownButtonFormField(
    decoration: InputDecoration(
      labelText: 'Category',
      labelStyle: TextStyle(color: textColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0), // Adjust border radius
      ),
      filled: true,
      fillColor: _isDarkMode ? productBackgroundColor : Colors.grey[200],
    ),
    dropdownColor: _isDarkMode ? productBackgroundColor : Colors.white,
    value: _selectedCategory,
    onChanged: (String? newValue) {
      setState(() {
        if (newValue != null) {
          _selectedCategory = newValue;
        }
      });
    },
    items: _categories.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(
          value,
          style: TextStyle(
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      );
    }).toList(),
  );
}
}