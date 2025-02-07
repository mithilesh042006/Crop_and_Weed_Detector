import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  String? _selectedModel; // Null initially (placeholder)
  final List<String> _modelChoices = ["Model A", "Model B", "Model C"];

  Future _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // ✅ Ensures scrollability without covering the bottom navigation
      child: Padding(
        padding: EdgeInsets.all(16.0), // ✅ Adds spacing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 Image Placeholder Box
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: _image == null
                  ? Center(
                      child: Text(
                        "No Image Selected",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(_image!, fit: BoxFit.cover),
                    ),
            ),
            SizedBox(height: 20),

            // 🔹 Model Selection Dropdown
            Container(
              width: 250,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: _selectedModel,
                dropdownColor: Colors.white, // ✅ Light background
                icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                isExpanded: true,
                underline: SizedBox(), // Removes the default underline
                hint: Text(
                  "Choose Model",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedModel = newValue!;
                  });
                },
                items: _modelChoices.map<DropdownMenuItem<String>>((String model) {
                  return DropdownMenuItem<String>(
                    value: model,
                    child: Text(
                      model,
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),

            // 🔹 Upload Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: Icon(Icons.image),
                  label: Text("Gallery"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera),
                  label: Text("Camera"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // 🔹 Upload Button (Always Visible)
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Upload button clicked!"))
                );
              },
              icon: Icon(Icons.upload_file),
              label: Text("Upload for Detection"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
