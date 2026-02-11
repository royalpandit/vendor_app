import 'package:flutter/material.dart';
import 'package:vendor_app/features/authentication/presentation/screens/service_info_screen.dart';

class BusinessInfoScreen extends StatefulWidget {
  @override
  _BusinessInfoScreenState createState() => _BusinessInfoScreenState();
}

class _BusinessInfoScreenState extends State<BusinessInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for business info
  final _categoryController = TextEditingController();
  final _experienceController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Business Info')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Business Category Dropdown
              DropdownButtonFormField<String>(
                value: _categoryController.text,
                decoration: InputDecoration(labelText: 'Business Category'),
                items: ['Category 1', 'Category 2', 'Category 3']
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _categoryController.text = value!;
                  });
                },
              ),

              // Business Experience Field
              TextFormField(
                controller: _experienceController,
                decoration: InputDecoration(labelText: 'Experience in Business'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your business experience';
                  }
                  return null;
                },
              ),

              // Business Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Business Description'),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe your business';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),
              // Next Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Navigate to next screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ServiceInfoScreen()),
                    );
                  }
                },
                child: Text('Next: Service Info'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
