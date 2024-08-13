import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts package
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import 'profile.dart';

class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData( // Define your theme with Google Font
        textTheme: GoogleFonts.ubuntuTextTheme().copyWith( // Use Ubuntu font for text elements
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Larger title text size
          titleMedium: TextStyle(fontSize: 18), // Larger subtitle text size
          bodyLarge:  TextStyle(fontSize: 16), // Larger body text size
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(),
                ),
              );
            },
            icon: const Icon(LineAwesomeIcons.angle_left),
          ),
          title:const Text('Edit Profile'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
             const EditableProfileField(
                label: 'Full Name',
                initialValue: 'John Doe',
              ),
              const SizedBox(height: 20),
              const EditableProfileField(
                label: 'Email',
                initialValue: 'johndoe@example.com',
              ),
              const SizedBox(height: 20),
              const EditableProfileField(
                label: 'Phone No',
                initialValue: '123-456-7890',
              ),
              const SizedBox(height: 20),
              PasswordField(),
            ],
          ),
        ),
      ),
    );
  }
}

class EditableProfileField extends StatefulWidget {
  final String label;
  final String initialValue;

  const EditableProfileField({
    Key? key,
    required this.label,
    required this.initialValue,
  }) : super(key: key);

  @override
  _EditableProfileFieldState createState() => _EditableProfileFieldState();
}

class _EditableProfileFieldState extends State<EditableProfileField> {
  bool _isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isEditing = !_isEditing;
            });
          },
          child: Row(
            children: [
              Expanded(
                child: _isEditing
                    ? TextFormField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: widget.label,
                        ),
                      )
                    : Text(widget.initialValue),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
                icon: Icon(_isEditing ? Icons.check : Icons.edit),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class PasswordField extends StatefulWidget {
  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isEditing = false;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;

  @override
  void initState() {
    super.initState();
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isEditing = !_isEditing;
            });
          },
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 18, // Larger text size for password label
                    fontWeight: FontWeight.bold, // Make the password label bold
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
                icon: Icon(_isEditing ? Icons.check : Icons.edit),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        if (_isEditing)
          Column(
            children: [
              TextFormField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Old Password',
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                ),
              ),
            ],
          )
        else
          Text('*********'), // Display asterisks for password
        SizedBox(height: 20),
      ],
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }
}

