import 'package:flutter/material.dart';
import 'package:real_estate/textstyles/text_colors.dart';

const TextStyle h1TitleStyleBlack = TextStyle(
  fontFamily: "Inter",
  fontSize: 25,
  fontWeight: FontWeight.w900,
);
const TextStyle h1TitleStyleWhite = TextStyle(
  fontFamily: "Inter",
  fontSize: 25,
  fontWeight: FontWeight.w900,
  color : secondryColor,
);
const TextStyle h2TitleStylePrimary = TextStyle(
  fontFamily: "Inter",
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: primaryColor,
);
const TextStyle h2TitleStyleGrey = TextStyle(
  fontFamily: "Inter",
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: greyText,
);
const TextStyle h2TitleStyleWhite = TextStyle(
  fontFamily: "Inter",
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: secondryColor,
);
const TextStyle h2TitleStyleBlack = TextStyle(
  fontFamily: "Inter",
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: blackText,
);
const TextStyle h3TitleStylePrimary = TextStyle(
  fontFamily: "Inter",
  fontSize: 17,
  fontWeight: FontWeight.w700,
  color: primaryColor,
);
const TextStyle h3TitleStyleBlack = TextStyle(
  fontFamily: "Inter",
  fontSize: 17,
  fontWeight: FontWeight.w700,
  color: Colors.black,
);
const TextStyle h4TitleStyleGrey = TextStyle(
  fontFamily: "Inter",
  fontSize: 15,
  fontWeight: FontWeight.w700,
  color: greyText,
);
const TextStyle h4TitleStylePrimary = TextStyle(
  fontFamily: "Inter",
  fontSize: 15,
  fontWeight: FontWeight.w700,
  color: primaryColor,
);
const TextStyle h4TitleStyleBlack = TextStyle(
  fontFamily: "Inter",
  fontSize: 15,
  fontWeight: FontWeight.w700,
  color: Colors.black,
);
const TextStyle h4TitleStyleWhite = TextStyle(
  fontFamily: "Inter",
  fontSize: 15,
  fontWeight: FontWeight.w700,
  color: secondryColor,
);
const TextStyle h4TitleStyleRed = TextStyle(
  fontFamily: "Inter",
  fontSize: 15,
  fontWeight: FontWeight.w700,
  color: Colors.red,
);
const TextStyle buttonTextStyleWhite = TextStyle(
  fontFamily: "Inter",
  fontSize: 22,
  fontWeight: FontWeight.w700,
  color: secondryColor,
);
const TextStyle buttonTextStylePrimary = TextStyle(
  fontFamily: "Inter",
  fontSize: 22,
  fontWeight: FontWeight.w700,
  color: primaryColor,
);
final ThemeData myLightTheme = ThemeData(

  appBarTheme: AppBarTheme(
    titleTextStyle: h2TitleStyleBlack.copyWith(
      fontSize: 20,
    ),
  ),
  listTileTheme: const ListTileThemeData(
    titleTextStyle: h4TitleStyleBlack,
  ),
  
  textTheme:  const TextTheme(
    titleSmall: h4TitleStyleBlack,
    titleMedium: h4TitleStyleBlack,
    titleLarge: h2TitleStyleBlack,
    bodySmall: h4TitleStyleBlack,
    bodyMedium: h4TitleStyleBlack,
    bodyLarge: h2TitleStyleBlack,
  ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryColor,
    brightness: Brightness.light,
    
  ),
  useMaterial3: true,
);

final ThemeData myDarkTheme = ThemeData(
  textTheme: const TextTheme(

    titleSmall: h4TitleStyleWhite,
    titleMedium: h4TitleStyleWhite,
    titleLarge: h2TitleStyleWhite,
    bodySmall: h4TitleStyleWhite,
    bodyMedium: h4TitleStyleWhite,
    bodyLarge: h2TitleStyleWhite,
  ),
 
  appBarTheme: AppBarTheme(
    titleTextStyle: h2TitleStyleWhite.copyWith(
      fontSize: 20,
    ),
  ),
  listTileTheme: const ListTileThemeData(
    titleTextStyle: h4TitleStyleWhite,
  ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryColor,
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
);
