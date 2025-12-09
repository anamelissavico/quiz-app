import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class QuizziaHomeScreen extends StatefulWidget {
  final String nomeUsuario;
  final int pontosTotais;
  final VoidCallback onGenerateNewQuiz;
  final VoidCallback onNavigateToHistorico;
  final VoidCallback onNavigateToGrupos;

  const QuizziaHomeScreen({
    Key? key,
    this.nomeUsuario = 'Jogador',
    this.pontosTotais = 0,
    required this.onGenerateNewQuiz,
    required this.onNavigateToHistorico,
    required this.onNavigateToGrupos,
  }) : super(key: key);

  @override
  State<QuizziaHomeScreen> createState() => _QuizziaHomeScreenState();
}

class _QuizziaHomeScreenState extends State<QuizziaHomeScreen>
    with TickerProviderStateMixin {
  int _pontosTotais = 0;
  String _nomeUsuario = 'Carregando...';
  bool _isLoading = true;
  String? _error;

  late AnimationController _headerController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );

    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (!mounted) return;
    try {
      final data = await ApiService.obterDadosUsuario();
      if (mounted) {
        setState(() {
          _pontosTotais = data['pontosTotais'] ?? widget.pontosTotais;
          _nomeUsuario = data['nome'] ?? widget.nomeUsuario;
          _isLoading = false;
        });
        _headerController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Falha ao carregar dados: ${e.toString()}';
          _isLoading = false;
        });
        _headerController.forward();
      }
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9333EA),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF9333EA),
              Color(0xFF7E22CE),
              Color(0xFFEAB308),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildGenerateQuizButton(),
                  const SizedBox(height: 24),
                  _buildActionShortcuts(),
                  const SizedBox(height: 32),
                  _buildFooter(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String saudacao = _obterSaudacao();
    String pontos = _pontosTotais.toString();
    String nomeExibido = _nomeUsuario;

    return FadeTransition(
      opacity: _headerAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.2),
          end: Offset.zero,
        ).animate(_headerAnimation),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$saudacao 👋',
                        style: const TextStyle(
                          color: Color(0xFFFEF9C3),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nomeExibido,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    border:
                    Border.all(color: const Color(0xFFFDE047), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star_rate_rounded,
                              color: Color(0xFFCA8A04), size: 24),
                          const SizedBox(width: 8),
                          Text(
                            pontos,
                            style: const TextStyle(
                              color: Color(0xFF7E22CE),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Pontos Totais',
                        style: TextStyle(
                          color: Color(0xFFA855F7),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Pronto para mais desafios?',
              style: TextStyle(
                color: Color(0xFFFEF9C3),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateQuizButton() {
    return ScaleTransition(
      scale: const AlwaysStoppedAnimation(1.0),
      child: GestureDetector(
        onTap: widget.onGenerateNewQuiz,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF22C55E),
                Color(0xFF16A34A),
                Color(0xFF14532D),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD9F99D), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_fix_high, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Criar é o melhor jeito de aprender!',
                    style: TextStyle(
                      color: Color(0xFFD9F99D),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Gerar Novo Quizz',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              // O Container agora é permitido aqui
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row( // <-- Pode manter o 'const' no Row
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Começar a Criação',
                      style: TextStyle(
                        color: Color(0xFF14532D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios,
                        color: Color(0xFF14532D), size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionShortcuts() {
    return Row(
      children: [
        _buildShortcutCard(
          title: 'Meu Histórico',
          icon: Icons.history_edu_rounded,
          color: const Color(0xFFFACC15), // yellow-400
          onTap: widget.onNavigateToHistorico,
          gradientColors: const [Color(0xFFFDE68A), Color(0xFFD97706)], // light yellow to dark yellow
          iconColor: const Color(0xFF854D0E), // brown
        ),
        const SizedBox(width: 16),
        _buildShortcutCard(
          title: 'Meus Grupos',
          icon: Icons.groups_rounded,
          color: const Color(0xFFC084FC), // purple-400
          onTap: widget.onNavigateToGrupos,
          gradientColors: const [Color(0xFFC4B5FD), Color(0xFF9333EA)], // light purple to purple
          iconColor: const Color(0xFF4C1D95), // deep purple
        ),
      ],
    );
  }

  Widget _buildShortcutCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required List<Color> gradientColors,
    required Color iconColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Text(
                    'Acessar',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_right_alt_rounded,
                      color: Colors.black54, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt, color: Color(0xFFFDE047), size: 16),
            SizedBox(width: 8),
            Text(
              'Continue aprendendo e se divertindo!',
              style: TextStyle(
                color: Color(0xFFFEF9C3),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _obterSaudacao() {
    final hora = DateTime.now().hour;
    if (hora >= 5 && hora < 12) {
      return 'Bom dia';
    } else if (hora >= 12 && hora < 18) {
      return 'Boa tarde';
    } else {
      return 'Boa noite';
    }
  }
}