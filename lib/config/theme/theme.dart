
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryBlue = Colors.blue;
  static const Color lightBackground = Colors.white;

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: lightBackground,
        brightness: Brightness.light,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        minWidth: 80,
        groupAlignment: -0.9,
        indicatorColor: primaryBlue.withOpacity(0.15),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 3,
        height: 80,
        indicatorColor: primaryBlue.withOpacity(0.15),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}


class AppColors {
// text colors
  static const whiteText = Color(0xFFFFFFFF);
  static const blackText = Color(0xFF000000);
  static const greyText = Color(0xFF8A8A8A);
  static const secondaryText = Color(0xff8b8b8b);
  static const primaryText = Color(0xFF1976D2);
  static const hintColor = Color(0xFF797979);
  static const secondary =  Color(0xff333333);
  static const pink =  Color(0xfffae9e6);
  static const red =  Color(0xffe36c71);
  static const finishColor =  Color(0xff646464);
  static const Color green = Color(0xFF4CAF4F);
  static const Color greenL = Color(0xFFDCFCE7);
  static const Color black = Color(0xFF000000);
  static const Color gray = Color(0xFFF5F5F5);
  static const Color colorPrimary = Color(0xFFE27A34);
  static const Color gold = Color(0xFFFFE298);
  static const Color white = Color(0xFFFFFFFF);
  static const Color buttonColor = Color(0xFF7A8194);
  static const Color bgColor = Color(0xFF0F0F0F);
  static const Color redFill = Color(0xFFE32932);

}


class AppTextStyles extends TextStyle {
   AppTextStyles({
    double size = 14.0,
    FontWeight weight = FontWeight.w400,
    Color super.color = Colors.black,
    super.decoration,
    String fontFamily = 'PanagramMedium',
  }) : super(
    fontSize: size,
    fontWeight: weight,
    fontFamily: fontFamily,

  );

  // -------------------------
  // HEADINGS
  // -------------------------
   AppTextStyles.h1({
    Color super.color = Colors.black,
    double size = 24.0,
    FontWeight weight = FontWeight.w700,
    super.decoration,
    String fontFamily = 'PanagramMedium',
  }) : super(
    fontSize: size,
    fontWeight: weight,
    fontFamily: fontFamily,
  );

   AppTextStyles.h2({
    Color super.color = Colors.black,
    double size = 20.0,
    FontWeight weight = FontWeight.w600,
    super.decoration,
    String fontFamily = 'PanagramMedium',
  }) : super(
    fontSize: size,
    fontWeight: weight,
    fontFamily: fontFamily,
  );

   AppTextStyles.h3({
    Color super.color = Colors.black,
    double size = 18.0,
    FontWeight weight = FontWeight.w600,
    super.decoration,
    String fontFamily = 'PanagramMedium',
  }) : super(
    fontSize: size,
    fontWeight: weight,
    fontFamily: fontFamily,
  );

  // -------------------------
  // BODY SMALL
  // -------------------------
   AppTextStyles.bodySmall({
    Color super.color = Colors.black,
    double size = 12.0,
    FontWeight weight = FontWeight.w400,
    super.decoration,
    String fontFamily = 'PanagramMedium',
  }) : super(
    fontSize: size,
    fontWeight: weight,
    fontFamily: fontFamily,
  );

   AppTextStyles.bodySmallW500({
    Color super.color = Colors.black,
    double size = 12.0,
    super.decoration,
    String fontFamily = 'PanagramMedium',
  }) : super(
    fontSize: size,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
  );

   AppTextStyles.bodySmallSemiBold({
    Color super.color = Colors.black,
    double size = 12.0,
    super.decoration,
    String fontFamily = 'PanagramMedium',
  }) : super(
    fontSize: size,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
  );

   AppTextStyles.bodySmallBold({
    Color super.color = Colors.black,
    double size = 12.0,
    super.decoration,
    String fontFamily = 'PanagramMedium',
  }) : super(
    fontSize: size,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
  );

  // -------------------------
  // BODY MEDIUM
  // -------------------------
   AppTextStyles.bodyMedium({
    Color super.color = Colors.black,
    double size = 14.0,
    FontWeight weight = FontWeight.w400,
    super.decoration,
    String fontFamily = 'PanagramMedium',
  }) : super(
    fontSize: size,
    fontWeight: weight,
    fontFamily: fontFamily,
  );

   AppTextStyles.bodyMediumW500({
    Color super.color = Colors.black,
    double size = 14.0,
    super.decoration,
    String fontFamily = 'PanagramMedium',
  }) : super(
    fontSize: size,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
  );

   AppTextStyles.bodyMediumSemiBold({
    Color super.color = Colors.black,
    double size = 14.0,
    super.decoration,
    String fontFamily = 'PanagramMedium',
  }) : super(
    fontSize: size,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
  );

   AppTextStyles.bodyMediumBold({
    Color super.color = Colors.black,
    double size = 14.0,
    super.decoration,
    String fontFamily = 'PanagramMedium',
  }) : super(
    fontSize: size,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
  );

  // -------------------------
  // BODY LARGE
  // -------------------------
   AppTextStyles.bodyLarge({
    Color super.color = Colors.black,
    double size = 16.0,
    FontWeight weight = FontWeight.w400,
    super.decoration,
    String fontFamily = 'PanagramMedium',
  }) : super(
    fontSize: size,
    fontWeight: weight,
    fontFamily: fontFamily,
  );

   AppTextStyles.bodyLargeW500({
    Color super.color = Colors.black,
    double size = 16.0,
    super.decoration,
    String fontFamily = 'PanagramMedium',
  }) : super(
    fontSize: size,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
  );

   AppTextStyles.bodyLargeSemiBold({
    Color super.color = Colors.black,
    double size = 16.0,
    super.decoration,
    String fontFamily = 'PanagramMedium',
  }) : super(
    fontSize: size,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
  );

   AppTextStyles.bodyLargeBold({
    Color super.color = Colors.black,
    double size = 16.0,
    super.decoration,
    String fontFamily = 'PanagramMedium',
  }) : super(
    fontSize: size,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
  );

  // -------------------------
  // CAPTION
  // -------------------------
   AppTextStyles.caption({
    Color super.color = Colors.grey,
    double size = 10.0,
    FontWeight weight = FontWeight.w500,
    super.decoration,
    String fontFamily = 'PanagramMedium',
  }) : super(
    fontSize: size,
    fontWeight: weight,
    fontFamily: fontFamily,
  );

  // -------------------------
  // BUTTON
  // -------------------------
   AppTextStyles.button({
    Color super.color = Colors.blue,
    double size = 14.0,
    FontWeight weight = FontWeight.w700,
    super.decoration,
    String fontFamily = 'PanagramMedium',
  }) : super(
    fontSize: size,
    fontWeight: weight,
    fontFamily: fontFamily,
  );

  // -------------------------
  // CHAT
  // -------------------------
   AppTextStyles.chatMessage({
    Color super.color = Colors.black,
    double size = 12.0,
    FontWeight weight = FontWeight.w400,
    super.decoration,
    String fontFamily = 'PanagramMedium',
  }) : super(
    fontSize: size,
    fontWeight: weight,
    fontFamily: fontFamily,
  );

   AppTextStyles.chatMessageReceived({
    Color super.color = Colors.grey,
    double size = 12.0,
    FontWeight weight = FontWeight.w400,
    super.decoration,
    String fontFamily = 'PanagramMedium',
  }) : super(
    fontSize: size,
    fontWeight: weight,
    fontFamily: fontFamily,
  );
}




