import 'package:eatezy_vendor/utils/app_color.dart';
import 'package:eatezy_vendor/utils/app_spacing.dart';
import 'package:eatezy_vendor/view/auth/screens/login_screen.dart';
import 'package:eatezy_vendor/view/chat/screens/chat_screen.dart';

import 'package:eatezy_vendor/view/profile/screens/edit_profile_screen.dart';
import 'package:eatezy_vendor/view/profile/screens/my_earnings_screen.dart';
import 'package:eatezy_vendor/view/profile/screens/reviews_screen.dart';
import 'package:eatezy_vendor/view/profile/service/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    Provider.of<ProfileService>(context, listen: false).getVendor();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileService>(context);
    return Scaffold(
      body: provider.vendor == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: provider.vendor!.banner.isNotEmpty
                              ? NetworkImage(provider.vendor!.banner)
                              : const NetworkImage(
                                  'https://images.unsplash.com/photo-1566438480900-0609be27a4be?q=80&w=3094&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -50,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 47,
                          backgroundImage:
                              NetworkImage(provider.vendor!.shopImage),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                Text(
                  provider.vendor!.shopName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                AppSpacing.h20,
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileEditScreen()));
                  },
                  leading: Icon(
                    Icons.person,
                    color: AppColor.primary,
                  ),
                  title: Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 17),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ReviewsScreen()));
                  },
                  leading: Icon(
                    Icons.star,
                    color: AppColor.primary,
                  ),
                  title: Text(
                    'Reviews',
                    style: TextStyle(fontSize: 17),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyEarningsScreen()));
                  },
                  leading: Icon(
                    Icons.currency_rupee,
                    color: AppColor.primary,
                  ),
                  title: Text(
                    'Earnings',
                    style: TextStyle(fontSize: 17),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ChatScreen()));
                  },
                  leading: Icon(
                    Icons.chat,
                    color: AppColor.primary,
                  ),
                  title: Text(
                    'Chats',
                    style: TextStyle(fontSize: 17),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                ListTile(
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Confirm Logout"),
                          content: Text("Are you sure you want to logout?"),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(), // Dismiss dialog
                              child: Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final pref =
                                    await SharedPreferences.getInstance();
                                pref.clear();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen()),
                                  (Route<dynamic> route) => false,
                                );
                              },
                              child: Text("Logout"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  leading: Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                  title: Text(
                    'Logout',
                    style: TextStyle(fontSize: 17, color: Colors.red),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
    );
  }
}
