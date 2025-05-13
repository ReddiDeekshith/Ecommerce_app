import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:dotted_border/dotted_border.dart';

class UploadProduct extends StatefulWidget {
  const UploadProduct({super.key});

  @override
  State<UploadProduct> createState() => _UploadProductState();
}

class _UploadProductState extends State<UploadProduct> {
  final List<File> _images = [];
  final List<String> _uploadedImageUrls = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  bool _isLoading = false; // Loading state

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _uploadImages() async {
    try {
      for (var image in _images) {
        print("hello");
        var request = http.MultipartRequest(
          'POST',
          Uri.parse("http://192.168.242.91:8000/upload"),
        );
        request.files.add(
          await http.MultipartFile.fromPath("file", image.path),
        );
        var response = await request.send();
        if (response.statusCode == 200) {
          var responseData = await response.stream.bytesToString();
          var jsonData = json.decode(responseData);
          setState(() {
            _uploadedImageUrls.add(jsonData["imageUrl"]);
          });
        }
      }
    } catch (e) {
      print("Upload error: $e");
    }
  }

  Future<void> _submitProduct() async {
    if (_isLoading) return; // Prevent multiple submissions
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      if (_uploadedImageUrls.isEmpty) {
        await _uploadImages();
      }

      final productData = {
        "ProductName": _nameController.text,
        "ProductDescription": _descriptionController.text,
        "Price": _priceController.text,
        "Size": "${_heightController.text} x ${_widthController.text} cm",
        "Image": _uploadedImageUrls,
      };

      final response = await http.post(
        Uri.parse("http://192.168.242.91:8000/add-product"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(productData),
      );

      if (response.statusCode == 201) {
        print("Product added successfully!");
      } else {
        print("Failed to add product.");
      }
      _nameController.text = "";
      _descriptionController.text = "";
      _priceController.text = "";
      _heightController.text = "";
      _widthController.text = "";
      _images.clear();
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Picker Section
                SizedBox(
                  height: 180,
                  child:
                      _images.isEmpty
                          ? DottedBorder(
                            color: Colors.grey,
                            strokeWidth: 1.5,
                            dashPattern: [8, 4],
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(10),
                            child: Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Add Product Image",
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _images.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        _images[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                ),

                const SizedBox(height: 20),

                // Add Image Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image, color: Colors.white),
                    label: const Text(
                      "Add Image",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Product Name Field
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Product Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Product Description Field
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: "Product Description",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: 10),

                // Product Price Field
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Product Price",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Height & Width Fields
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Height (cm)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _widthController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Width (cm)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child:
                      _isLoading
                          ? Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF2E7D32),
                            ),
                          )
                          : ElevatedButton(
                            onPressed: () {
                              _submitProduct();
                            },
                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
