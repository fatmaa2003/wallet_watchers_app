import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/pages/home_page.dart';
import 'package:wallet_watchers_app/pages/signup_page.dart';
import 'package:wallet_watchers_app/pages/login_page.dart';
import 'package:wallet_watchers_app/models/user.dart';
import 'package:wallet_watchers_app/services/api_service.dart';
import 'package:wallet_watchers_app/providers/categories_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider(
          create: (context) => CategoriesProvider(apiService),
        ),
      ],
      child: MaterialApp(
        title: 'Expense Manager',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignUpPage(),
          '/home': (context) {
            final user = ModalRoute.of(context)!.settings.arguments;
            if (user == null || user is! User) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'User not provided!\nPlease log in again.',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return HomePage(user: user as User);
          },
        },
      ),
    );
  }
}
