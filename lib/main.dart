import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jusconnect/core/pages/home_page.dart';
import 'package:jusconnect/features/auth/presentation/pages/login_page.dart';
import 'package:jusconnect/features/auth/presentation/pages/register_page.dart';
import 'package:jusconnect/features/profile/presentation/pages/profile_edit_page.dart';
import 'package:jusconnect/features/profile/presentation/pages/profile_page.dart';
import 'package:jusconnect/shared/themes/light_theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JusConnect',
      theme: ThemeData(
        scrollbarTheme: ScrollbarThemeData(
          thumbVisibility: .all(false),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.onPrimaryColor,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: AppColors.lightColor,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/profile': (context) => const ProfilePage(),
        '/profile/edit': (context) => const ProfileEditPage(),
      },
    );
  }
}
