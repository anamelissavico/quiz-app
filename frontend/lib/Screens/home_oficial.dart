import 'package:flutter/material.dart';

/// Home Screen do Quizzia
/// Mantém fidelidade visual com a versão React/Web
class QuizziaHomeScreen extends StatefulWidget {
  final String nomeUsuario;
  final int pontosTotais; // ⬅️ NOVO: Para exibir os pontos do usuário
  final VoidCallback onGenerateNewQuiz; // ⬅️ NOVO: Ação para ir para a HomePage

  const QuizziaHomeScreen({
    Key? key,
    this.nomeUsuario = 'Jogador',
    this.pontosTotais = 0, // Valor padrão 0
    required this.onGenerateNewQuiz, // Requer a função de navegação
  }) : super(key: key);

  @override
  State<QuizziaHomeScreen> createState() => _QuizziaHomeScreenState();
}

class _QuizziaHomeScreenState extends State<QuizziaHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;

  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();

    // Animação de entrada APENAS para o cabeçalho
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );

    // Iniciar animação
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🎯 CORREÇÃO 1: Garante que o fundo do Scaffold (incluindo a barra de status)
      // tenha a cor inicial do gradiente, eliminando o vazamento branco.
      backgroundColor: const Color(0xFF9333EA),

      // 🎯 CORREÇÃO 2: Permite que o 'body' se estenda por trás da barra de status,
      // garantindo que o gradiente cubra toda a altura da tela.
      extendBodyBehindAppBar: true,

      // 🌟 NOVA CORREÇÃO: Permite que o 'body' (o Container com o gradiente)
      // se estenda por trás da BottomNavigationBar, ocupando a tela inteira.
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
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80), // 👈 AQUI!!! Espaço no topo
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildGenerateQuizButton(),
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

  // --- WIDGETS DE CONSTRUÇÃO ---

  // Header com saudação, nome e Pontos Totais
  Widget _buildHeader() {
    String saudacao = _obterSaudacao();
    String pontos = widget.pontosTotais.toString();

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
                          color: Color(0xFFFEF9C3), // yellow-100
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.nomeUsuario,
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
                // 🏆 NOVO WIDGET: CARD DE PONTOS TOTAIS
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE047), width: 2),
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
                          const Icon(Icons.star_rate_rounded, color: Color(0xFFCA8A04), size: 24),
                          const SizedBox(width: 8),
                          Text(
                            pontos,
                            style: const TextStyle(
                              color: Color(0xFF7E22CE), // purple-700
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Pontos Totais',
                        style: TextStyle(
                          color: Color(0xFFA855F7), // purple-400
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
                color: Color(0xFFFEF9C3), // yellow-100
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🆕 NOVO WIDGET: Botão Gerar Novo Quizz
  Widget _buildGenerateQuizButton() {
    return ScaleTransition(
      scale: const AlwaysStoppedAnimation(1.0), // Mantém a animação de entrada original se você quiser adicioná-la aqui
      child: GestureDetector(
        onTap: widget.onGenerateNewQuiz, // ⬅️ Ação para ir para a HomePage
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF22C55E), // green-500
                Color(0xFF16A34A), // green-600
                Color(0xFF14532D), // green-900
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD9F99D), width: 3), // lime-200
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
                      color: Color(0xFFD9F99D), // lime-200
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Começar a Criação',
                      style: TextStyle(
                        color: Color(0xFF14532D), // green-900
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios, color: Color(0xFF14532D), size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Footer motivacional
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
    if (hora < 12) return 'Bom dia';
    if (hora < 18) return 'Boa tarde';
    return 'Boa noite';
  }
}