import 'package:flutter/material.dart';
import 'package:quizzfront/Screens/perfil_screen.dart';
import '../widgets/quizzia_bottom_nav.dart';
import 'HistoricoScreen.dart';
import 'grupos_screen.dart';
import 'home_oficial.dart';
import 'home_screen.dart';
import 'login_screen.dart';


class HomeWrapper extends StatefulWidget {
  final int startIndex;
  final String nomeUsuario;
  final int usuarioId;

  const HomeWrapper({
    super.key,
    this.startIndex = 0,
    required this.nomeUsuario,
    required this.usuarioId,
  });

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex;
  }

  void _handleLogout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  void _navigateToGenerateQuizTab() {
    setState(() {
      _currentIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      QuizziaHomeScreen(
        nomeUsuario: widget.nomeUsuario,
        pontosTotais: 0,
        onGenerateNewQuiz: _navigateToGenerateQuizTab, onNavigateToHistorico: () {  }, onNavigateToGrupos: () {  },
      ),

      GroupsScreen(
        usuarioId: widget.usuarioId,
        nomeUsuario: widget.nomeUsuario,
        onTabChange: (i) {
          setState(() => _currentIndex = i);
        },
      ),

      const HomePage(),

      HistoricoScreen(usuarioId: widget.usuarioId),


      ProfileScreen(onLogout: _handleLogout),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: QuizziaBottomNav(
        currentIndex: _currentIndex,
        onTabChange: (i) {
          setState(() => _currentIndex = i);
        },
      ),
    );
  }
}