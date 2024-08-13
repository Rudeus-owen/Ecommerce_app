import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreatePromotionPage extends StatefulWidget {
  final VoidCallback onItemCreated;

  const CreatePromotionPage({Key? key, required this.onItemCreated}) : super(key: key);

  @override
  State<CreatePromotionPage> createState() => _CreatePromotionPageState();
}

class _CreatePromotionPageState extends State<CreatePromotionPage> {
  bool _isDarkMode = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _promotionNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _discountValueController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _conditionsController = TextEditingController();
  String? _selectedPromotionType;
  String? _selectedStatus;
  int _currentStep = 0;

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

  Future<void> _submitPromotion() async {
    if (_formKey.currentState!.validate()) {
      try {
        var response = await http.post(
          Uri.parse('http://10.0.2.2:8000/api/promotions'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'promotion_name': _promotionNameController.text,
            'description': _descriptionController.text,
            'promotion_type': _selectedPromotionType,
            'discount_value': double.tryParse(_discountValueController.text) ?? 0.0,
            'start_date': _startDateController.text,
            'end_date': _endDateController.text,
            'status': _selectedStatus,
            'conditions': _conditionsController.text,
          }),
        );

        if (response.statusCode == 201) {
          widget.onItemCreated();
          _showSuccessDialog('Promotion created successfully.');
          _resetForm();
        } else {
          _showErrorMessage('Failed to create promotion', 'Status code: ${response.statusCode}\nResponse: ${response.body}');
        }
      } catch (e) {
        _showErrorMessage('Error', 'Error creating promotion: $e');
      }
    }
  }

  void _resetForm() {
    _promotionNameController.clear();
    _descriptionController.clear();
    _discountValueController.clear();
    _startDateController.clear();
    _endDateController.clear();
    _conditionsController.clear();
    setState(() {
      _selectedPromotionType = null;
      _selectedStatus = null;
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
                setState(() {
                  _currentStep += 1;
                });
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
        title: Text('Promotion Details', style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
        content: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _promotionNameController,
                decoration: InputDecoration(
                  labelText: 'Promotion Name',
                  labelStyle: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: _isDarkMode ? Colors.white : Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor:  _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                ),
                style: GoogleFonts.ubuntu(color: _isDarkMode ? Colors.white : Colors.black),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the promotion name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
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
                    return 'Please enter the description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Promotion Type',
                  labelStyle: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: _isDarkMode ? Colors.white : Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                ),
                dropdownColor: _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                value: _selectedPromotionType,
                // hint: Text('Select Promotion Type', style: GoogleFonts.ubuntu(color: _isDarkMode ? Colors.white : Colors.black)),
                items: ['percentage', 'amount', 'bogo'].map<DropdownMenuItem<String>>((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type, style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPromotionType = value!;
                  });
                },
                icon: Icon(Icons.arrow_drop_down, color: _isDarkMode ? Colors.white : Colors.black),
                style: GoogleFonts.ubuntu(color: _isDarkMode ? Colors.white : Colors.black),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a promotion type';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _discountValueController,
                decoration: InputDecoration(
                  labelText: 'Discount Value',
                  labelStyle: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: _isDarkMode ? Colors.white : Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                ),
                style: GoogleFonts.ubuntu(color: _isDarkMode ? Colors.white : Colors.black),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the discount value';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Discount value must be a number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _startDateController,
                decoration: InputDecoration(
                  labelText: 'Start Date (YYYY-MM-DD)',
                  labelStyle: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: _isDarkMode ? Colors.white : Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor:  _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                ),
                style: GoogleFonts.ubuntu(color: _isDarkMode ? Colors.white : Colors.black),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the start date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _endDateController,
                decoration: InputDecoration(
                  labelText: 'End Date (YYYY-MM-DD)',
                  labelStyle: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: _isDarkMode ? Colors.white : Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                ),
                style: GoogleFonts.ubuntu(color: _isDarkMode ? Colors.white : Colors.black),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the end date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Status',
                  labelStyle: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: _isDarkMode ? Colors.white : Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                ),
                dropdownColor: _isDarkMode ? Color.fromRGBO(51, 54, 72, 1) : Colors.white,
                value: _selectedStatus,
                // hint: Text('Select Status', style: GoogleFonts.ubuntu(color: _isDarkMode ? Colors.white : Colors.black)),
                items: ['active', 'upcoming', 'expired'].map<DropdownMenuItem<String>>((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status, style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
                icon: Icon(Icons.arrow_drop_down, color: _isDarkMode ? Colors.white : Colors.black),
                style: GoogleFonts.ubuntu(color: _isDarkMode ? Colors.white : Colors.black),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a status';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _conditionsController,
                decoration: InputDecoration(
                  labelText: 'Conditions',
                  labelStyle: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: _isDarkMode ? Colors.white : Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor:  _isDarkMode ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
                ),
                style: GoogleFonts.ubuntu(color: _isDarkMode ? Colors.white : Colors.black),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the conditions';
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
      await _submitPromotion();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create Promotion",
          style: GoogleFonts.ubuntu(
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        backgroundColor:  _isDarkMode ? Color.fromARGB(255, 19, 26, 46) : const Color.fromRGBO(238, 241, 242, 1),
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
