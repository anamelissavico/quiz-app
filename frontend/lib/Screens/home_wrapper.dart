import 'package:flutter/material.dart';
import 'home_screen.dart';        // QuizziaHomeScreen
import 'login_screen.dart';
import 'perfil_screen.dart';     // ProfileScreen
import '../widgets/quizzia_bottom_nav.dart';
import 'home_oficial.dart';      // HomePage = tela de criar quiz

class HomeWrapper extends StatefulWidget {
  final int startIndex;

  const HomeWrapper({super.key, this.startIndex = 0});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  late int _currentIndex;

  final String _userName = 'Jogador Quizzia';
  final int _userPoints = 1250;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex;
  }

  void _onTabChange(int index) {
    setState(() => _currentIndex = index);
  }

  void _handleLogout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  // 🔥 Lista FINAL de telas — AGORA 100% compatível com a nav bar
  List<Widget> get pages => [
    QuizziaHomeScreen(
      nomeUsuario: _userName,
      pontosTotais: _userPoints,
      onGenerateNewQuiz: () => _onTabChange(1), // botão gerar → index 1
    ),

    const HomePage(), // Criar quizz (index 1)

    ProfileScreen(onLogout: _handleLogout), // Perfil (index 2)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: QuizziaBottomNav(
        currentIndex: _currentIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}
