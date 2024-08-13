import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http_parser/http_parser.dart';
import 'package:new_ecommerce_app/admin%20site/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class CreatePage extends StatefulWidget {
  final VoidCallback onItemCreated;

  const CreatePage({Key? key, required this.onItemCreated}) : super(key: key);

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  bool _isDarkMode = false;
  final _formKeys = List.generate(7, (_) => GlobalKey<FormState>());
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _colorNameController = TextEditingController();
  final TextEditingController _colorCodeController = TextEditingController();
  final TextEditingController _qtyInStockController = TextEditingController();
  final TextEditingController _variationNameController = TextEditingController();
  final TextEditingController _variationQtyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  int? _selectedCategoryId;
  int? _selectedSubCategoryId;
  int? _selectedPromotionId;
  int? _selectedProductId;
  int? _selectedMainImageProductId;
  int? _selectedItemId;
  List<dynamic> _categories = [];
  List<dynamic> _subCategories = [];
  List<dynamic> _promotions = [];
  List<dynamic> _products = [];
  List<dynamic> _items = [];
  List<Map<String, dynamic>> _variations = [];
  File? _image;
  List<File> _productImages = [];
  final ImagePicker _picker = ImagePicker();
  int _currentStep = 0;
  int? _productId;

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
    _fetchCategories();
    _fetchPromotions();
    _fetchProducts();
    _fetchItems();
  }

  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    _colorNameController.clear();
    _colorCodeController.clear();
    _qtyInStockController.clear();
    _variationNameController.clear();
    _variationQtyController.clear();
    _priceController.clear();
    setState(() {
      _selectedCategoryId = null;
      _selectedSubCategoryId = null;
      _selectedPromotionId = null;
      _selectedProductId = null;
      _selectedMainImageProductId = null;
      _selectedItemId = null;
      _image = null;
      _productImages.clear();
      _variations.clear();
      _currentStep = 0;
    });
  }

  Future<void> _loadDarkModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:8000/api/productcategories'));
      if (response.statusCode == 200) {
        setState(() {
          _categories = jsonDecode(response.body);
          _categories = _categories.reversed.toList();
          if (_categories.isNotEmpty) {
            _selectedCategoryId = null;
          } else {
            _selectedCategoryId = null;
          }
        });
      } else {
        _showErrorMessage('Failed to fetch categories',
            'Status code: ${response.statusCode}\nResponse: ${response.body}');
      }
    } catch (e) {
      _showErrorMessage('Error', 'Error fetching categories: $e');
    }
  }

  Future<void> _fetchSubCategories(int categoryId) async {
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:8000/api/subcategories'));
      if (response.statusCode == 200) {
        setState(() {
          _subCategories = jsonDecode(response.body)
              .where((subCategory) =>
                  subCategory['product_category_id'] == categoryId)
              .toList();
          _subCategories = _subCategories.reversed.toList();
          if (_subCategories.isNotEmpty) {
            _selectedSubCategoryId =
                _selectedSubCategoryId ?? _subCategories[0]['id'];
          } else {
            _selectedSubCategoryId = null;
          }
        });
      } else {
        _showErrorMessage('Failed to fetch subcategories',
            'Status code: ${response.statusCode}\nResponse: ${response.body}');
      }
    } catch (e) {
      _showErrorMessage('Error', 'Error fetching subcategories: $e');
    }
  }

  Future<void> _fetchPromotions() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:8000/api/promotions'));
      if (response.statusCode == 200) {
        setState(() {
          _promotions = jsonDecode(response.body);
          _promotions = _promotions.reversed.toList();
          if (_promotions.isNotEmpty) {
            _selectedPromotionId =
                _selectedPromotionId ?? _promotions[0]['promotion_id'];
          } else {
            _selectedPromotionId = null;
          }
        });
      } else {
        _showErrorMessage('Failed to fetch promotions',
            'Status code: ${response.statusCode}\nResponse: ${response.body}');
      }
    } catch (e) {
      _showErrorMessage('Error', 'Error fetching promotions: $e');
    }
  }

  Future<void> _fetchProducts() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:8000/api/products'));
      if (response.statusCode == 200) {
        setState(() {
          _products = jsonDecode(response.body);
          _products = _products.reversed.toList();
          if (_products.isNotEmpty) {
            _selectedProductId = _selectedProductId ?? _products[0]['id'];
            _selectedMainImageProductId =
                _selectedMainImageProductId ?? _products[0]['id'];
          } else {
            _selectedProductId = null;
            _selectedMainImageProductId = null;
          }
        });
      } else {
        _showErrorMessage('Failed to fetch products',
            'Status code: ${response.statusCode}\nResponse: ${response.body}');
      }
    } catch (e) {
      _showErrorMessage('Error', 'Error fetching products: $e');
    }
  }

  Future<void> _fetchItems() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:8000/api/items'));
      if (response.statusCode == 200) {
        setState(() {
          _items = jsonDecode(response.body);
          _items = _items.reversed.toList();
          if (_items.isNotEmpty) {
            _selectedItemId = _selectedItemId ?? _items[0]['id'];
          } else {
            _selectedItemId = null;
          }
        });
      } else {
        _showErrorMessage('Failed to fetch items',
            'Status code: ${response.statusCode}\nResponse: ${response.body}');
      }
    } catch (e) {
      _showErrorMessage('Error', 'Error fetching items: $e');
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickProductImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _productImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  void _removeMainImage() {
    setState(() {
      _image = null;
    });
  }

  void _removeProductImage(int index) {
    setState(() {
      _productImages.removeAt(index);
    });
  }

  void _addVariation() {
    if (_variationNameController.text.isNotEmpty &&
        _variationQtyController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _selectedItemId != null &&
        _selectedPromotionId != null) {
      setState(() {
        _variations.add({
          'variation_name': _variationNameController.text,
          'qty_instock': int.parse(_variationQtyController.text),
          'price': double.parse(_priceController.text),
          'item_id': _selectedItemId,
          'promotion_id': _selectedPromotionId,
        });
        _variationNameController.clear();
        _variationQtyController.clear();
        _priceController.clear();
        _selectedItemId = null;
        _selectedPromotionId = null;
      });
    } else {
      _showErrorMessage('Error', 'All fields are required to add a variation.');
    }
  }

  Future<void> _submitProductDetails() async {
    if (_formKeys[0].currentState!.validate()) {
      var productResponse = await _createProduct();
      if (productResponse != null && productResponse.statusCode == 201) {
        await _fetchProducts();
        widget.onItemCreated();
        _showSuccessDialog(
            'Product created successfully. Do you want to proceed to the next step?');
      } else {
        _showErrorMessage('Failed to create product', 'Please try again.');
      }
    }
  }

  Future<void> _createItem() async {
    if (_formKeys[2].currentState!.validate()) {
      var itemResponse = await _createItemRequest();
      if (itemResponse != null && itemResponse.statusCode == 201) {
        await _fetchItems();
        widget.onItemCreated();
        _showSuccessDialog(
            'Item created successfully. Do you want to proceed to the next step?');
      } else {
        _showErrorMessage('Failed to create item', 'Please try again.');
      }
    }
  }

  Future<void> _uploadProductImage() async {
    if (_formKeys[1].currentState!.validate()) {
      if (_image == null) {
        _showErrorMessage('Error', 'Please select an image.');
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:8000/api/productImages'),
      );

      request.fields['product_id'] = _selectedMainImageProductId.toString();
      request.files.add(
        await http.MultipartFile.fromPath(
          'product_img',
          _image!.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var response = await request.send();
      if (response.statusCode == 201) {
        await _showSuccessDialog(
            'Main image uploaded successfully. Do you want to proceed to the next step?');
      } else {
        _showErrorMessage('Failed to upload product image',
            'Status code: ${response.statusCode}');
      }
    }
  }

  Future<void> _uploadItemImage() async {
    if (_formKeys[3].currentState!.validate()) {
      if (_selectedItemId == null || _productImages.isEmpty) {
        _showErrorMessage(
            'Error', 'Please select an item and upload an image.');
        return;
      }

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://10.0.2.2:8000/api/itemImages'),
        );

        request.fields['product_item_id'] = _selectedItemId.toString();

        var image = _productImages.first;
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            image.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 201) {
          await _showSuccessDialog(
              'Image uploaded successfully. Do you want to proceed to the next step?');
        } else {
          var responseBody = response.body;
          _showErrorMessage('Failed to upload image',
              'Status code: ${response.statusCode}\nResponse: $responseBody');
        }
      } catch (e) {
        _showErrorMessage('Error', 'Error uploading image: $e');
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKeys[_currentStep].currentState!.validate()) {
      switch (_currentStep) {
        case 0:
          await _submitProductDetails();
          break;
        case 1:
          await _uploadProductImage();
          break;
        case 2:
          await _createItem();
          break;
        case 3:
          await _uploadItemImage();
          break;
        case 4:
          var colorResponse = await _createProductColor();
          if (colorResponse != null && colorResponse.statusCode == 201) {
            _showSuccessDialog(
                'Product color created successfully. Do you want to proceed to the next step?');
          } else {
            _showErrorMessage(
                'Failed to create product color', 'Please try again.');
          }
          break;
        case 5:
          if (_productId == null) {
            _showErrorMessage('Error',
                'Product ID is null. Cannot create product variation.');
            return;
          }
          var variationResponse = await _createProductVariation();
          if (variationResponse != null && variationResponse.statusCode == 201) {
            _showVariationDialog(
                'Product and variations created successfully. Do you want to create more items for your product?');
          } else {
            _showErrorMessage(
                'Failed to create variation', 'Please try again.');
          }
          break;
      }
    }
  }

  Future<http.Response?> _createProductColor() async {
    if (_selectedItemId == null) return null;
    try {
      var response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/product-colors'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'color_name': _colorNameController.text,
          'color_code': _colorCodeController.text,
          'qty_instock': int.tryParse(_qtyInStockController.text) ?? 0,
          'product_item_id': _selectedItemId,
        }),
      );
      if (response.statusCode != 201) {
        _showErrorMessage('Failed to create product color',
            'Status code: ${response.statusCode}\nResponse: ${response.body}');
      }
      return response;
    } catch (e) {
      _showErrorMessage('Error', 'Error creating product color: $e');
      return null;
    }
  }

  Future<http.Response?> _createProduct() async {
    try {
      var response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/products'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': _nameController.text,
          'description': _descriptionController.text,
          'category_id': _selectedCategoryId,
          'sub_category_id': _selectedSubCategoryId,
        }),
      );
      if (response.statusCode == 201) {
        var responseBody = jsonDecode(response.body);
        setState(() {
          _productId = responseBody['id'];
        });
        return response;
      } else {
        _showErrorMessage('Failed to create product',
            'Status code: ${response.statusCode}\nResponse: ${response.body}');
        return null;
      }
    } catch (e) {
      _showErrorMessage('Error', 'Error creating product: $e');
      return null;
    }
  }

  Future<http.Response?> _createItemRequest() async {
    if (_selectedProductId == null || _selectedPromotionId == null) return null;
    try {
      var response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/items'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'product_id': _selectedProductId,
          'promotion_id': _selectedPromotionId,
        }),
      );
      if (response.statusCode == 201) {
        jsonDecode(response.body);
        setState(() {
        });
        return response;
      } else {
        _showErrorMessage('Failed to create item',
            'Status code: ${response.statusCode}\nResponse: ${response.body}');
        return null;
      }
    } catch (e) {
      _showErrorMessage('Error', 'Error creating item: $e');
      return null;
    }
  }

  Future<http.Response?> _createProductVariation() async {
    if (_variations.isEmpty) {
      _showErrorMessage('Error', 'No variations to create');
      return null;
    }

    try {
      var response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/product-variations/bulk'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'variations': _variations}),
      );

      if (response.statusCode != 201) {
        var responseBody = response.body;
        _showErrorMessage('Failed to create variations',
            'Status code: ${response.statusCode}\nResponse: $responseBody');
      }
      return response;
    } catch (e) {
      _showErrorMessage('Error', 'Error creating variations: $e');
      return null;
    }
  }

  Future<void> _showSuccessDialog(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Next'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ],
        );
      },
    ).then((_) {
      setState(() {
        _currentStep += 1;
      });
    });
  }

  Future<void> _showVariationDialog(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                _resetForm();
                setState(() {
                  _currentStep = 2;
                });
              },
            ),
            TextButton(
              child: Text('No (Go Home)'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                _resetForm();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: Text('Product Details',
            style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
        content: SingleChildScrollView(
          child: Form(
            key: _formKeys[0],
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    labelStyle: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isDarkMode ? Colors.white : Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  ),
                  style: GoogleFonts.ubuntu(
                      color: _isDarkMode ? Colors.white : Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the product name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isDarkMode ? Colors.white : Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  ),
                  style: GoogleFonts.ubuntu(
                      color: _isDarkMode ? Colors.white : Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isDarkMode ? Colors.white : Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  ),
                  dropdownColor:
                      _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  value: _selectedCategoryId,
                  items: _categories.map<DropdownMenuItem<int>>((category) {
                    return DropdownMenuItem<int>(
                      value: category['id'],
                      child: Text(category['category_name'],
                          style: TextStyle(
                              color: _isDarkMode ? Colors.white : Colors.black)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                      _fetchSubCategories(value!);
                    });
                  },
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: _categories.isNotEmpty
                        ? (_isDarkMode ? Colors.white : Colors.black)
                        : Colors.grey,
                  ),
                  style: GoogleFonts.ubuntu(
                      color: _isDarkMode ? Colors.white : Colors.black),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Sub Category',
                    labelStyle: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isDarkMode ? Colors.white : Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  ),
                  dropdownColor:
                      _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  value: _selectedSubCategoryId,
                  items: _subCategories.map<DropdownMenuItem<int>>((subCategory) {
                    return DropdownMenuItem<int>(
                      value: subCategory['id'],
                      child: Text(subCategory['name'],
                          style: TextStyle(
                              color: _isDarkMode ? Colors.white : Colors.black)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubCategoryId = value;
                    });
                  },
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: _subCategories.isNotEmpty
                        ? (_isDarkMode ? Colors.white : Colors.black)
                        : Colors.grey,
                  ),
                  style: GoogleFonts.ubuntu(
                      color: _isDarkMode ? Colors.white : Colors.black),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a sub category';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text('Main Image',
            style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
        content: SingleChildScrollView(
          child: Form(
            key: _formKeys[1],
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Product ID',
                    labelStyle: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isDarkMode ? Colors.white : Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  ),
                  dropdownColor:
                      _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  value: _selectedMainImageProductId,
                  items: _products.map<DropdownMenuItem<int>>((product) {
                    return DropdownMenuItem<int>(
                      value: product['id'],
                      child: Text(product['name'],
                          style: TextStyle(
                              color: _isDarkMode ? Colors.white : Colors.black)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMainImageProductId = value;
                    });
                  },
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: _products.isNotEmpty
                        ? (_isDarkMode ? Colors.white : Colors.black)
                        : Colors.grey,
                  ),
                  style: GoogleFonts.ubuntu(
                      color: _isDarkMode ? Colors.white : Colors.black),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a product';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickImage,
                  child: Card(
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 180, 175, 175),
                            Colors.grey[600]!
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: _image == null
                            ? Icon(Icons.add_a_photo,
                                size: 50,
                                color: _isDarkMode ? Colors.white : Colors.black)
                            : Stack(
                                alignment: Alignment.topRight,
                                children: <Widget>[
                                  Container(
                                    width: double.infinity,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          8),
                                      image: DecorationImage(
                                        image: FileImage(_image!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: _removeMainImage,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red,
                                        ),
                                        child: const Icon(Icons.cancel,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text('Item Details',
            style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
        content: SingleChildScrollView(
          child: Form(
            key: _formKeys[2],
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Product ID',
                    labelStyle: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isDarkMode ? Colors.white : Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  ),
                  dropdownColor:
                      _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  value: _selectedProductId,
                  items: _products.map<DropdownMenuItem<int>>((product) {
                    return DropdownMenuItem<int>(
                      value: product['id'],
                      child: Text(product['name'],
                          style: TextStyle(
                              color: _isDarkMode ? Colors.white : Colors.black)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProductId = value;
                    });
                  },
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: _products.isNotEmpty
                        ? (_isDarkMode ? Colors.white : Colors.black)
                        : Colors.grey,
                  ),
                  style: GoogleFonts.ubuntu(
                      color: _isDarkMode ? Colors.white : Colors.black),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a product';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Promotion ID',
                    labelStyle: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isDarkMode ? Colors.white : Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  ),
                  dropdownColor:
                      _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  value: _selectedPromotionId,
                  items: _promotions.map<DropdownMenuItem<int>>((promotion) {
                    return DropdownMenuItem<int>(
                      value: promotion['promotion_id'],
                      child: Text(promotion['promotion_name'],
                          style: TextStyle(
                              color: _isDarkMode ? Colors.white : Colors.black)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPromotionId = value;
                    });
                  },
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: _promotions.isNotEmpty
                        ? (_isDarkMode ? Colors.white : Colors.black)
                        : Colors.grey,
                  ),
                  style: GoogleFonts.ubuntu(
                      color: _isDarkMode ? Colors.white : Colors.black),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a promotion';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text('Additional Images',
            style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
        content: SingleChildScrollView(
          child: Form(
            key: _formKeys[3],
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Item ID',
                    labelStyle: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isDarkMode ? Colors.white : Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  ),
                  dropdownColor:
                      _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  value: _selectedItemId,
                  items: _items.map<DropdownMenuItem<int>>((item) {
                    return DropdownMenuItem<int>(
                      value: item['id'],
                      child: Text(item['id'].toString(),
                          style: TextStyle(
                              color: _isDarkMode ? Colors.white : Colors.black)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedItemId = value;
                    });
                  },
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: _items.isNotEmpty
                        ? (_isDarkMode ? Colors.white : Colors.black)
                        : Colors.grey,
                  ),
                  style: GoogleFonts.ubuntu(
                      color: _isDarkMode ? Colors.white : Colors.black),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select an item';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickProductImages,
                  child: Card(
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 180, 175, 175),
                            Colors.grey[600]!
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: _productImages.isEmpty
                            ? Icon(Icons.add_photo_alternate,
                                size: 50,
                                color: _isDarkMode ? Colors.white : Colors.black)
                            : Stack(
                                alignment: Alignment.topRight,
                                children: <Widget>[
                                  Container(
                                    width: double.infinity,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          8),
                                      image: DecorationImage(
                                        image: FileImage(_productImages[
                                            0]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeProductImage(
                                          0),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red,
                                        ),
                                        child: const Icon(Icons.cancel,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text('Color',
            style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
        content: SingleChildScrollView(
          child: Form(
            key: _formKeys[4],
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Item ID',
                    labelStyle: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isDarkMode ? Colors.white : Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  ),
                  dropdownColor:
                      _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  value: _selectedItemId,
                  items: _items.map<DropdownMenuItem<int>>((item) {
                    return DropdownMenuItem<int>(
                      value: item['id'],
                      child: Text(item['id'].toString(),
                          style: TextStyle(
                              color: _isDarkMode ? Colors.white : Colors.black)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedItemId = value;
                    });
                  },
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: _items.isNotEmpty
                        ? (_isDarkMode ? Colors.white : Colors.black)
                        : Colors.grey,
                  ),
                  style: GoogleFonts.ubuntu(
                      color: _isDarkMode ? Colors.white : Colors.black),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select an item';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _colorNameController,
                  decoration: InputDecoration(
                    labelText: 'Color Name',
                    labelStyle: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isDarkMode ? Colors.white : Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor:  _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  ),
                  style: GoogleFonts.ubuntu(
                      color: _isDarkMode ? Colors.white : Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the color name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _colorCodeController,
                  decoration: InputDecoration(
                    labelText: 'Color Code',
                    labelStyle: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isDarkMode ? Colors.white : Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  ),
                  style: GoogleFonts.ubuntu(
                      color: _isDarkMode ? Colors.white : Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the color code';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _qtyInStockController,
                  decoration: InputDecoration(
                    labelText: 'Quantity In Stock',
                    labelStyle: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isDarkMode ? Colors.white : Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor:  _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  ),
                  style: GoogleFonts.ubuntu(
                      color: _isDarkMode ? Colors.white : Colors.black),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the quantity in stock';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Quantity must be a number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        isActive: _currentStep >= 4,
        state: _currentStep > 4 ? StepState.complete : StepState.indexed,
      ),
        Step(
      title: Text('Variation',
          style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
      content: Container(
        height: 400, // Set a fixed height for the step content
        child: SingleChildScrollView(
          child: Form(
            key: _formKeys[5],
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Item ID',
                    labelStyle: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isDarkMode ? Colors.white : Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  ),
                  dropdownColor:
                      _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  value: _selectedItemId,
                  items: _items.map<DropdownMenuItem<int>>((item) {
                    return DropdownMenuItem<int>(
                      value: item['id'],
                      child: Text(item['id'].toString(),
                          style: TextStyle(
                              color: _isDarkMode ? Colors.white : Colors.black)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedItemId = value;
                    });
                  },
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: _items.isNotEmpty
                        ? (_isDarkMode ? Colors.white : Colors.black)
                        : Colors.grey,
                  ),
                  style: GoogleFonts.ubuntu(
                      color: _isDarkMode ? Colors.white : Colors.black),
                  // validator: (value) {
                  //   if (value == null) {
                  //     return 'Please select an item';
                  //   }
                  //   return null;
                  // },
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Promotion ID',
                    labelStyle: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isDarkMode ? Colors.white : Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  ),
                  dropdownColor:
                      _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  value: _selectedPromotionId,
                  items: _promotions.map<DropdownMenuItem<int>>((promotion) {
                    return DropdownMenuItem<int>(
                      value: promotion['promotion_id'],
                      child: Text(promotion['promotion_name'],
                          style: TextStyle(
                              color: _isDarkMode ? Colors.white : Colors.black)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPromotionId = value;
                    });
                  },
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: _promotions.isNotEmpty
                        ? (_isDarkMode ? Colors.white : Colors.black)
                        : Colors.grey,
                  ),
                  style: GoogleFonts.ubuntu(
                      color: _isDarkMode ? Colors.white : Colors.black),
                  // validator: (value) {
                  //   if (value == null) {
                  //     return 'Please select a promotion';
                  //   }
                  //   return null;
                  // },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _variationNameController,
                  decoration: InputDecoration(
                    labelText: 'Variation Name',
                    labelStyle: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isDarkMode ? Colors.white : Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor:  _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  ),
                  style: GoogleFonts.ubuntu(
                      color: _isDarkMode ? Colors.white : Colors.black),
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please enter the variation name';
                  //   }
                  //   return null;
                  // },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _variationQtyController,
                  decoration: InputDecoration(
                    labelText: 'Quantity In Stock',
                    labelStyle: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isDarkMode ? Colors.white : Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor:  _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  ),
                  style: GoogleFonts.ubuntu(
                      color: _isDarkMode ? Colors.white : Colors.black),
                  keyboardType: TextInputType.number,
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please enter the quantity in stock';
                  //   }
                  //   if (int.tryParse(value) == null) {
                  //     return 'Quantity must be a number';
                  //   }
                  //   return null;
                  // },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isDarkMode ? Colors.white : Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor:  _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                  ),
                  style: GoogleFonts.ubuntu(
                      color: _isDarkMode ? Colors.white : Colors.black),
                  keyboardType: TextInputType.number,
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please enter the price';
                  //   }
                  //   if (double.tryParse(value) == null) {
                  //     return 'Price must be a number';
                  //   }
                  //   return null;
                  // },
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _addVariation,
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text('Add Variation'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: _isDarkMode
                        ? const Color.fromRGBO(63, 67, 101, 1)
                        : const Color.fromRGBO(63, 67, 101, 1),
                  ),
                ),
                SizedBox(height: 10),
                if (_variations.isNotEmpty)
                  Container(
                    height: 200, // Set a fixed height for the list of variations
                    child: SingleChildScrollView(
                      child: Column(
                        children: _variations.map((variation) {
                          return Card(
                            elevation: 3,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(
                                variation['variation_name'],
                                style: GoogleFonts.ubuntu(
                                  textStyle: TextStyle(
                                    color: _isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                              subtitle: Text(
                                'Qty: ${variation['qty_instock']} | Price: \MMK${variation['price']}',
                                style: GoogleFonts.ubuntu(
                                  textStyle: TextStyle(
                                    color: _isDarkMode ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _variations.remove(variation);
                                  });
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.space_between,
                //   children: [
                //     ElevatedButton(
                //       onPressed: _currentStep == 0 ? null : () {
                //         setState(() {
                //           _currentStep -= 1;
                //         });
                //       },
                //       child: Text('Back'),
                //       style: ElevatedButton.styleFrom(
                //         foregroundColor: Colors.white,
                //         backgroundColor: Colors.grey,
                //       ),
                //     ),
                //     ElevatedButton(
                //       onPressed: () async {
                //         if (_formKeys[_currentStep].currentState!.validate()) {
                //           await _submitForm();
                //         }
                //       },
                //       child: Text('Submit'),
                //       style: ElevatedButton.styleFrom(
                //         foregroundColor: Colors.white,
                //         backgroundColor: _isDarkMode
                //             ? const Color.fromRGBO(63, 67, 101, 1)
                //             : const Color.fromRGBO(63, 67, 101, 1),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
      isActive: _currentStep >= 5,
      state: _currentStep > 5 ? StepState.complete : StepState.indexed,
    ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create Product",
          style: GoogleFonts.ubuntu(
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        backgroundColor: _isDarkMode ? Color.fromARGB(255, 19, 26, 46) : const Color.fromRGBO(238, 241, 242, 1),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _isDarkMode ? Colors.white : Colors.black),
          onPressed: () {
            if (_currentStep == 0) {
              Navigator.pop(context);
            } else {
              setState(() {
                _currentStep -= 1;
              });
            }
          },
        ),
      ),
      backgroundColor: _isDarkMode ? Color.fromARGB(255, 19, 26, 46) : const Color.fromRGBO(238, 241, 242, 1),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Stepper(
              currentStep: _currentStep,
              onStepContinue: () async {
                if (_formKeys[_currentStep].currentState!.validate()) {
                  await _submitForm();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() {
                    _currentStep -= 1;
                  });
                } else {
                  Navigator.pop(context);
                }
              },
              steps: _buildSteps(),
              controlsBuilder: (BuildContext context, ControlsDetails details) {
                return Column(
                  children: <Widget>[
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: _currentStep == 1
                              ? _uploadProductImage
                              : (_currentStep == 3
                                  ? _uploadItemImage
                                  : details.onStepContinue),
                          child: Text(_currentStep == _buildSteps().length - 1
                              ? 'Submit'
                              : 'Continue'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: _isDarkMode
                                ? Colors.black
                                : Colors.white,
                            backgroundColor: _isDarkMode
                                ? Colors.white
                                : const Color.fromRGBO(63, 67, 101, 1),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (_currentStep > 0)
                          ElevatedButton(
                            onPressed: details.onStepCancel,
                            child: const Text('Back'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
