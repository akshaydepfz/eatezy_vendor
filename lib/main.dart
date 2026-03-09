import 'package:eatezy_vendor/utils/app_color.dart';
import 'package:eatezy_vendor/utils/notification_service.dart';
import 'package:eatezy_vendor/view/auth/screens/login_screen.dart';
import 'package:eatezy_vendor/view/auth/services/login_service.dart';
import 'package:eatezy_vendor/view/chat/services/chat_service.dart';
import 'package:eatezy_vendor/view/home/screens/landing_screen.dart';
import 'package:eatezy_vendor/view/home/services/home_provider.dart';
import 'package:eatezy_vendor/view/offer/services/offer_service.dart';
import 'package:eatezy_vendor/view/orders/services/order_service.dart';
import 'package:eatezy_vendor/view/product/services/product_service.dart';
import 'package:eatezy_vendor/view/profile/service/profile_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  if (kIsWeb) {
    // Web Firebase configuration
    // To get your web app ID:
    // 1. Go to https://console.firebase.google.com/
    // 2. Select your project (eatezy-63f35)
    // 3. Click the gear icon ⚙️ > Project settings
    // 4. Scroll down to "Your apps" section
    // 5. If you don't have a web app, click "Add app" and select Web (</>)
    // 6. Copy the "App ID" (format: 1:366816004932:web:xxxxx)
    // 7. Replace "YOUR_WEB_APP_ID" below with your actual web app ID
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDof_SGroqWurKEaW0XuFwLpDsmV1Y34S4",
        appId: "1:366816004932:web:ef4dd7f4ed5cf4de3de511",
        messagingSenderId: "366816004932",
        projectId: "eatezy-63f35",
        storageBucket: "eatezy-63f35.firebasestorage.app",
        authDomain: "eatezy-63f35.firebaseapp.com",
      ),
    );
  } else {
    // Mobile platforms (Android/iOS) - uses google-services.json / GoogleService-Info.plist
    await Firebase.initializeApp();
  }
  if (!kIsWeb) {
    await initializeNotificationService();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // ignore: unused_local_variable
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  } else {
    // Web: Firebase Messaging setup - avoid requestPermission during load (Safari blocks it)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  final pref = await SharedPreferences.getInstance();
  String token = pref.getString('token') ?? '';
  runApp(MyApp(
    token: token,
  ));
}

class MyApp extends StatelessWidget {
  final String token;
  const MyApp({super.key, required this.token});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HomeProvider()),
        ChangeNotifierProvider(create: (context) => ProductService()),
        ChangeNotifierProvider(create: (context) => OfferService()),
        ChangeNotifierProvider(create: (context) => OrderService()),
        ChangeNotifierProvider(create: (context) => LoginService()),
        ChangeNotifierProvider(create: (context) => ProfileService()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Eatezy Vendor',
          theme: ThemeData(
            textTheme: GoogleFonts.rubikTextTheme(Theme.of(context).textTheme),
            colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primary),
            useMaterial3: true,
          ),
          home: token == '' ? const LoginScreen() : const LandingScreen()),
    );
  }
}
