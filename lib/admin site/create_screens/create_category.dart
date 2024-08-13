import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateCategoryPage extends StatefulWidget {
  final VoidCallback onItemCreated;

  const CreateCategoryPage({Key? key, required this.onItemCreated}) : super(key: key);

  @override
  State<CreateCategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {
  bool _isDarkMode = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryNameController = TextEditingController();
  int _currentStep = 0;
  final int _totalSteps = 1; // Total steps in your Stepper

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

  Future<void> _submitCategory() async {
    if (_formKey.currentState!.validate()) {
      try {
        var response = await http.post(
          Uri.parse('http://10.0.2.2:8000/api/productcategories'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'category_name': _categoryNameController.text,
          }),
        );

        if (response.statusCode == 201) {
          widget.onItemCreated();
          _showSuccessDialog('Category created successfully.');
          _resetForm();
        } else {
          _showErrorMessage('Failed to create category', 'Status code: ${response.statusCode}\nResponse: ${response.body}');
        }
      } catch (e) {
        _showErrorMessage('Error', 'Error creating category: $e');
      }
    }
  }

  void _resetForm() {
    _categoryNameController.clear();
    setState(() {
      _currentStep = 0;
    });
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
                Navigator.of(context).pop();
                if (_currentStep < _totalSteps - 1) {
                  setState(() {
                    _currentStep += 1;
                  });
                } else {
                  Navigator.pop(context, true); // Returning true
                }
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
              child: Text('OK'),
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
        title: Text('Category Details', style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
        content: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _categoryNameController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  labelStyle: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: _isDarkMode ? Colors.white : Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                ),
                style: GoogleFonts.ubuntu(color: _isDarkMode ? Colors.white : Colors.black),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the category name';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
    ];
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      await _submitCategory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create Category",
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
        padding: const EdgeInsets.all(16),
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () async {
            if (_formKey.currentState!.validate()) {
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
                      onPressed: details.onStepContinue,
                      child: Text('Continue'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: _isDarkMode ? Colors.black : Colors.white,
                        backgroundColor: _isDarkMode ? Colors.white : const Color.fromRGBO(63, 67, 101, 1),
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
      ),
    );
  }
}
