import 'package:flutter/material.dart';
import 'package:vendor_app/features/authentication/presentation/screens/document_upload_screen.dart';

class ServiceInfoScreen extends StatefulWidget {
  @override
  _ServiceInfoScreenState createState() => _ServiceInfoScreenState();
}

class _ServiceInfoScreenState extends State<ServiceInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _benefitsController = TextEditingController();
  final _priceRangeController = TextEditingController();
  final _coverageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Service Info')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Benefits Field
              TextFormField(
                controller: _benefitsController,
                decoration: InputDecoration(labelText: 'Benefits'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe the benefits';
                  }
                  return null;
                },
              ),

              // Price Range Slider
              Slider(
                value: double.tryParse(_priceRangeController.text) ?? 50000,
                min: 0,
                max: 200000,
                divisions: 10,
                label: '₹${_priceRangeController.text}',
                onChanged: (double value) {
                  setState(() {
                    _priceRangeController.text = value.toStringAsFixed(0);
                  });
                },
              ),

              // Service Coverage Field
              TextFormField(
                controller: _coverageController,
                decoration: InputDecoration(labelText: 'Service Coverage'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please specify where you provide services';
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
                      MaterialPageRoute(builder: (context) => DocumentUploadScreen()),
                    );
                  }
                },
                child: Text('Next: Document Upload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
