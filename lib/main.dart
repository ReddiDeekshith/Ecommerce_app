import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:juteapp/home.dart';
import 'package:provider/provider.dart';
import 'notification_provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔄 Background Message: ${message.notification?.title}");
  // You can handle background messages here.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _fcmToken = "Fetching token...";
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  bool _showNotification = false;
  String _notificationMessage = "";

  @override
  void initState() {
    super.initState();
    initFCM();
  }

  Future<void> initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request notification permissions
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("✅ Notification permission granted");

      // Get the FCM token
      String? token = await messaging.getToken();
      print("📲 FCM Token: $token");
      setState(() {
        _fcmToken = token;
      });

      // Send token to your backend API (if needed)
      await sendTokenToBackend(token);

      // Subscribe to a topic (e.g., all-users)
      await messaging.subscribeToTopic('all-users');
      print("📲 Subscribed to all-users topic");

      // Foreground message handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("📥 Foreground message: ${message.notification?.title}");
        // Show custom notification overlay
        showNotificationOverlay(
          message.notification?.title ?? 'New Notification',
          message.notification!.body ?? 'Hello',
        );
      });

      // When the notification is tapped and the app opens
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("➡️ Notification tapped: ${message.notification?.title}");
        // Handle tap event if needed
      });
    } else {
      print("❌ Notification permission denied");
    }
  }

  // Function to send FCM token to the backend
  Future<void> sendTokenToBackend(String? token) async {
    if (token != null) {
      try {
        final response = await http.post(
          Uri.parse(
            'http://localhost:8000/saveToken',
          ), // Replace with your backend URL
          body: {'fcm_token': token},
        );
        if (response.statusCode == 200) {
          print("FCM token successfully sent to backend");
        } else {
          print("Failed to send FCM token to backend");
        }
      } catch (e) {
        print("Error sending token to backend: $e");
      }
    }
  }

  // Show custom notification overlay when a message is received in the foreground
  void showNotificationOverlay(String title, String message) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    provider.addNotification(title, message); // Add notification to provider

    setState(() {
      _notificationMessage = message;
      _showNotification = true;
    });

    // Hide the notification after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _showNotification = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.white,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey:
          _scaffoldMessengerKey, // Use the scaffoldMessengerKey
      home: Stack(
        children: [
          // Your background or content
          Container(color: Colors.white),
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Align(
                alignment: Alignment.center,
                child: Image.asset("assets/logo.png", fit: BoxFit.contain),
              ),
            ),
          ),
          // Your main content or Home page
          MyHome(),
        ],
      ),
    );
  }
}
