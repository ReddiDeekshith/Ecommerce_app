import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:juteapp/delivered.dart';
import 'package:juteapp/notification_provider.dart';
import 'package:juteapp/orders.dart';
import 'package:juteapp/products.dart';
import 'package:juteapp/upload_product.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    UploadProduct(),
    OrdersPage(),
    ProductListScreen(),
    DeliveredPage(),
    SpecialOrdersPage(),
  ];
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Color(0xFF2E7D32),
        title: Text(
          'Udaya Teja',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Builder(
            builder: (context) => Stack(
              children: [
                IconButton(
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                    setState(() {
                      provider.markAllAsRead();
                    });
                  },
                  icon: Icon(Icons.notifications, color: Colors.white),
                ),
                if (provider.badgeCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        provider.badgeCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 10),
        ],
        centerTitle: true,
        elevation: 10,
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: _pages[_selectedIndex],
      ),
     endDrawer: Drawer(
  child: Container(
    color: Colors.white,
    child: Column(
      children: [
        Container(
          width: double.infinity,
          color: Color(0xFF2E7D32), // Green header
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 20,
            left: 16,
            right: 16,
            bottom: 40,
          ),
          child: Center(
            child: Text(
              'Notifications',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: provider.notifications.isEmpty
              ? Center(
                  child: Text(
                    'No notifications yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  itemCount: provider.notifications.length,
                  separatorBuilder: (_, __) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final notification = provider.notifications[index];
                    return ListTile(
                      leading: Icon(
                        Icons.notifications,
                        color: notification.isNew ? Colors.green : Colors.grey,
                      ),
                      title: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: notification.isNew
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notification.message),
                          SizedBox(height: 4),
                          Text(
                            _getRelativeTime(notification.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      tileColor: notification.isNew
                          ? Colors.green[50]
                          : Colors.transparent,
                    );
                  },
                ),
        ),
      ],
    ),
  ),
),

      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        backgroundColor: Colors.transparent,
        color: Color(0xFF2E7D32),
        buttonBackgroundColor: Colors.white,
        height: 70,
        animationDuration: Duration(milliseconds: 300),
        items: [
          _buildNavItem("Home", "🏡", 0),
          _buildNavItem("Orders", "📦", 1),
          _buildNavItem("Products", "🛍️", 2),
          _buildNavItem("Delivered", "🚚", 3),
          _buildNavItem("Others", "📝", 4),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  // Format timestamp using timeago
  String _getRelativeTime(String timestamp) {
    try {
      final parsed = DateTime.parse(timestamp);
      return timeago.format(parsed);
    } catch (e) {
      return "Unknown time";
    }
  }

  // Navigation item builder
  Widget _buildNavItem(String label, String emoji, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 7),
        Text(
          emoji,
          style: TextStyle(
            fontSize: index == 0 ? 27 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        _selectedIndex != index
            ? Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : SizedBox(),
      ],
    );
  }
}

// Dummy pages




class SpecialOrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "📝 Special Orders / Reviews",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}
