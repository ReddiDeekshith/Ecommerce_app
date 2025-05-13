import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<dynamic>? productsList;

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.242.91:8000/products'),
      );
      if (response.statusCode == 200) {
        setState(() {
          productsList = jsonDecode(response.body);
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      print('Error fetching products: $error');
    }
  }

  Future<void> updateProduct(
    String id,
    String name,
    String desc,
    String price,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('http://192.168.242.91:8000/edit-product/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ProductName': name,
          'ProductDescription': desc,
          'Price': price,
        }),
      );
      if (response.statusCode == 200) {
        fetchProducts();
      } else {
        throw Exception('Failed to update product');
      }
    } catch (error) {
      print('Error updating product: $error');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.242.91:8000/delete-product/$id'),
      );
      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        fetchProducts();
      } else {
        throw Exception('Failed to delete product');
      }
    } catch (error) {
      print('Error deleting product: $error');
    }
  }

  void showEditDialog(BuildContext context, Map<String, dynamic> product) {
    TextEditingController nameController = TextEditingController(
      text: product['ProductName'],
    );
    TextEditingController descController = TextEditingController(
      text: product['ProductDescription'],
    );
    TextEditingController priceController = TextEditingController(
      text: product['Price'].toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: EdgeInsets.all(20),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 500, // Prevent overflow on wide screens
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.edit, color: Color(0xFF2E7D32)),
                          SizedBox(width: 8),
                          Text(
                            'Edit Product',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          SizedBox(width: 80),
                          Expanded(
                            child: IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                deleteProduct(product['_id']);
                              },
                              icon: Icon(Icons.delete, color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      AspectRatio(
                        aspectRatio: 3 / 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            product['Image'][0],
                            fit: BoxFit.contain,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    Icon(Icons.broken_image, size: 100),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Product Name',

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: descController,
                        decoration: InputDecoration(
                          labelText: 'Description',

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Price',

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(Icons.cancel, color: Colors.white),
                              label: Text(
                                "Cancel",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  117,
                                  116,
                                  116,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                updateProduct(
                                  product['_id'],
                                  nameController.text,
                                  descController.text,
                                  priceController.text,
                                );
                              },
                              icon: Icon(Icons.save, color: Colors.white),
                              label: Text(
                                "Save",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF2E7D32),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body:
          productsList == null
              ? Center(child: CircularProgressIndicator())
              : GridView.builder(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 10,
                  bottom: 80,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: productsList!.length,
                itemBuilder: (context, index) {
                  var product = productsList![index];
                  return GestureDetector(
                    onTap: () => showEditDialog(context, product),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(10),
                            ),
                            child: Image.network(
                              product['Image'][0],
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.fill,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      Icon(Icons.broken_image, size: 200),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['ProductName'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  product['ProductDescription'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "₹${product['Price']}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
