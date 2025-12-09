import 'package:flutter/material.dart';
import 'Screens/login_screen.dart';   // ⬅️ sua tela de login
import 'Screens/home_wrapper.dart';  // ⬅️ sua tela protegida após login

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

      home: const LoginScreen(),

      navigatorObservers: [routeObserver],

      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => HomeWrapper( startIndex: 0,
          nomeUsuario: ModalRoute.of(context)!.settings.arguments != null
              ? (ModalRoute.of(context)!.settings.arguments as Map)['nomeUsuario']
              : "",
          usuarioId: ModalRoute.of(context)!.settings.arguments != null
              ? (ModalRoute.of(context)!.settings.arguments as Map)['usuarioId']
              : 0,),
      },
    );
  }
}
