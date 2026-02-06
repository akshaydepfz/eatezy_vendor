import 'package:eatezy_vendor/utils/app_color.dart';
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
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'high_importance_channel', 'High Importance Notifications',
//     description: 'This channel is used for important notifications.',
//     importance: Importance.high,
//     playSound: true);

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);
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
