import 'package:flutter/material.dart';

class DocumentUploadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Document Upload')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Document Upload Button
            ElevatedButton.icon(
              onPressed: () {
                // File picker logic
              },
              icon: Icon(Icons.photo_camera),
              label: Text('Add a photo of your business'),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // File picker logic
              },
              icon: Icon(Icons.attach_file),
              label: Text('Upload your Aadhar ID'),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // File picker logic
              },
              icon: Icon(Icons.attach_file),
              label: Text('Upload your business certificate'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Done logic
              },
              child: Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
