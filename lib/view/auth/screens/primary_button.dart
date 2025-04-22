import 'package:eatezy_vendor/utils/app_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.title,
    required this.isLoading,
    required this.onTap,
  });

  final String title;
  final Function() onTap;
  final bool isLoading;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12), color: AppColor.primary),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 55,
                  child: CupertinoActivityIndicator(
                    color: Colors.white,
                  ),
                )
              : Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
