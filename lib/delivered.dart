import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DeliveredPage extends StatefulWidget {
  const DeliveredPage({super.key});

  @override
  State<DeliveredPage> createState() => _DeliveredPageState();
}

class _DeliveredPageState extends State<DeliveredPage> {
  List<dynamic> deliveredOrders = [];
  bool _isLoading = true;
  final String baseUrl =
      'https://backend-8d89.onrender.com'; // Update with your backend IP

  @override
  void initState() {
    super.initState();
    fetchDeliveredOrders();
  }

  Future<void> fetchDeliveredOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get-delivered-orders'),
      );
      if (response.statusCode == 200) {
        setState(() {
          deliveredOrders = json.decode(response.body);
        });
      } else {
        debugPrint('Failed to load delivered orders');
      }
    } catch (e) {
      debugPrint('Error fetching delivered orders: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  double calculateTotalWorth(List<dynamic> items) {
    double total = 0.0;
    for (var item in items) {
      final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
      final quantity = int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
      total += price * quantity;
    }
    return total;
  }

  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : deliveredOrders.isEmpty
              ? const Center(
                child: Text(
                  'No delivered orders',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: deliveredOrders.length,
                itemBuilder: (context, index) {
                  final order = deliveredOrders[index];
                  final orderItems = order['orders'] ?? [];
                  final totalWorth = calculateTotalWorth(orderItems);
                  final orderDate = order['OrderDate'] ?? 'N/A';
                  final city = order['City'] ?? 'N/A';

                  return Card(
                    color: Colors.white,
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ExpansionTile(
                      shape: const Border(),
                      collapsedShape: const Border(),
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      title: Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Color(0xFF2E7D32),
                            child: Icon(Icons.done, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order['Name'] ?? 'No Name',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      city,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${totalWorth.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatDate(orderDate),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      childrenPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      children: [
                        const Divider(thickness: 1),
                        _buildInfoRow(Icons.email, 'Email', order['Email']),
                        _buildInfoRow(
                          Icons.phone,
                          'Phone',
                          order['PhoneNumber'],
                        ),
                        _buildInfoRow(Icons.location_city, 'City', city),
                        _buildInfoRow(
                          Icons.pin_drop,
                          'Pincode',
                          order['PinCode'],
                        ),
                        _buildInfoRow(Icons.home, 'Address', order['Address']),
                        _buildInfoRow(
                          Icons.payment,
                          'Payment Mode',
                          order['PaymentMode'],
                        ),
                        _buildInfoRow(
                          Icons.date_range,
                          'Order Date',
                          formatDate(orderDate),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Ordered Products',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...orderItems.map<Widget>((item) {
                          final imageUrl = item['image'];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(10),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  width: 50,
                                  fit: BoxFit.fill,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(
                                            Icons.broken_image,
                                            size: 50,
                                          ),
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              title: Text('Qty: ${item['quantity']}'),
                              subtitle: Text('Price: ₹${item['price']}'),
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
