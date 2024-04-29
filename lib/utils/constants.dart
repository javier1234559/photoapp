import 'package:flutter/material.dart';

const favoriteLogoPath = "assets/images/favorite_logo.png";
const recycleBinLogoPath = "assets/images/recyclebin_logo.png";

const kPrimaryColor = Color(0xFFff6961);
const kPrimaryLightColor = Color(0xFFFFECDF);
const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFff6961), Color(0xFFff6961)],
);
const kSecondaryColor = Color(0xFF979797);
const kTextColor = Colors.black;
const kAnimationDuration = Duration(milliseconds: 200);
const headingStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);
const defaultDuration = Duration(milliseconds: 250);
final otpInputDecoration = InputDecoration(
  contentPadding: const EdgeInsets.symmetric(vertical: 16),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: kTextColor),
  );
}

// Dark Theme
const kDarkPrimaryColor = Color(0xFF212121);
const kDarkSecondaryColor = Color(0xFF373737);
const kDarkTextColor = Color(0xFFE0E0E0);
