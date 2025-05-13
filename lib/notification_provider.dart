import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationModel {
  final String title;
  final String message; // ✅ New field
  final String timestamp;
  bool isNew;

  NotificationModel({
    required this.title,
    required this.message,
    required this.timestamp,
    this.isNew = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'timestamp': timestamp,
      'isNew': isNew,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['title'],
      message: json['message'] ?? '',
      timestamp: json['timestamp'],
      isNew: json['isNew'] ?? true,
    );
  }
}

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  int _badgeCount = 0;
  late Timer _timer;

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  int get badgeCount => _badgeCount;

  NotificationProvider() {
    _startPolling();
    _loadNotifications();
  }

  void _startPolling() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchNotifications();
    });
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.242.91:8000/get-notifications'),
      );

      if (response.statusCode == 200) {
        List<dynamic> responseData = json.decode(response.body);
        List<NotificationModel> fetchedNotifications =
            responseData.map((notif) => NotificationModel.fromJson(notif)).toList();

        int newNotificationsCount = 0;

        for (var fetchedNotif in fetchedNotifications) {
          bool isExisting = _notifications.any(
            (localNotif) =>
                localNotif.title == fetchedNotif.title &&
                localNotif.timestamp == fetchedNotif.timestamp,
          );
          if (!isExisting) {
            newNotificationsCount++;
          }
        }

        // ✅ Reverse and limit
        _notifications = fetchedNotifications.reversed.toList();
        if (_notifications.length > 10) {
          _notifications = _notifications.sublist(0, 10);
        }

        _badgeCount += newNotificationsCount;

        await _saveNotifications();
        notifyListeners();
      } else {
        print("Failed to load notifications from the backend.");
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    }
  }

  // ✅ Add a new notification manually
  void addNotification(String title, String message) {
    final timestamp = DateTime.now().toLocal().toString().substring(0, 19);
    NotificationModel newNotif = NotificationModel(
      title: title,
      message: message,
      timestamp: timestamp,
    );

    _notifications.insert(0, newNotif);
    

    if (_notifications.length > 10) {
      _notifications.removeLast();
    }

    _saveNotifications();
    notifyListeners();
  }

  Future<void> _saveNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notificationsJson =
        _notifications.map((notif) => json.encode(notif.toJson())).toList();
    prefs.setStringList('notifications', notificationsJson);
  }

  Future<void> _loadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notificationsJson = prefs.getStringList('notifications');

    if (notificationsJson != null) {
      _notifications.clear();
      _notifications.addAll(
        notificationsJson
            .map((notif) => NotificationModel.fromJson(json.decode(notif)))
            .toList(),
      );
    }

    notifyListeners();
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isNew = false;
    }
    _badgeCount = 0;
    _saveNotifications();
    notifyListeners();
  }

  void resetBadgeCount() {
    _badgeCount = 0;
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    _badgeCount = 0;
    _saveNotifications();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
