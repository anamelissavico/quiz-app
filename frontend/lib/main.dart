import 'package:flutter/material.dart';
import 'Screens/login_screen.dart';   // ⬅️ sua tela de login
import 'Screens/home_wrapper.dart';  // ⬅️ sua tela protegida após login

// 🔥 Adiciona um RouteObserver global
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quizzia',

      // 🔥 Agora a primeira tela é o LOGIN
      home: const LoginScreen(),

      // 🔥 Adiciona o observer aqui
      navigatorObservers: [routeObserver],

      // (Opcional) Rotas da aplicação
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeWrapper(),
      },
    );
  }
}
