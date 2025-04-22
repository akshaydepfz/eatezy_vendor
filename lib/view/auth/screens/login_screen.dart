import 'package:eatezy_vendor/utils/app_spacing.dart';
import 'package:eatezy_vendor/view/auth/screens/primary_button.dart';
import 'package:eatezy_vendor/view/auth/services/app_validations.dart';
import 'package:eatezy_vendor/view/auth/services/login_service.dart';
import 'package:eatezy_vendor/view/product/screens/add_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoginService>(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                    height: MediaQuery.of(context).size.height / 3,
                    width: MediaQuery.of(context).size.height / 3,
                    child: LottieBuilder.asset('assets/icons/login.json')),
                PrimaryTextField(
                    validator: AppValidations.validateEmail,
                    title: 'Email',
                    controller: provider.emailController),
                AppSpacing.h20,
                PrimaryTextField(
                    validator: AppValidations.validatePassword,
                    title: 'Password',
                    controller: provider.passwordController),
                const Spacer(),
                PrimaryButton(
                    title: 'Login',
                    isLoading: false,
                    onTap: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        provider.login(context);
                      }
                    }),
                AppSpacing.h20,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
