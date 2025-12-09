import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/quizzia_bottom_nav.dart';
import 'home_wrapper.dart';

class AvaliacaoPorTema {
  final String tema;
  final int acertos;
  final int perguntasRespondidas;

  AvaliacaoPorTema({
    required this.tema,
    required this.acertos,
    required this.perguntasRespondidas,
  });

  factory AvaliacaoPorTema.fromJson(Map<String, dynamic> json) {
    return AvaliacaoPorTema(
      tema: json['tema'] ?? '',
      acertos: json['acertos'] ?? 0,
      perguntasRespondidas: json['perguntasRespondidas'] ?? 0,
    );
  }
}

class AvaliacaoQuizzScreen extends StatefulWidget {
  final int pontosRecebidosQuizz;
  final int pontosTotalQuizz;
  final int pontosTotaisUsuario;
  final double percentualAcertos;
  final String mensagemMotivadora;
  final List<AvaliacaoPorTema> resumoPorTema;

  const AvaliacaoQuizzScreen({
    super.key,
    required this.pontosRecebidosQuizz,
    required this.pontosTotalQuizz,
    required this.pontosTotaisUsuario,
    required this.percentualAcertos,
    required this.mensagemMotivadora,
    required this.resumoPorTema,
  });

  @override
  State<AvaliacaoQuizzScreen> createState() => _AvaliacaoQuizzScreenState();
}

class _AvaliacaoQuizzScreenState extends State<AvaliacaoQuizzScreen>
    with TickerProviderStateMixin {
  late AnimationController _pointsController;
  late Animation<int> _pointsAnimation;

  @override
  void initState() {
    super.initState();

    _pointsController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pointsAnimation = IntTween(
      begin: 0,
      end: widget.pontosRecebidosQuizz,
    ).animate(
      CurvedAnimation(parent: _pointsController, curve: Curves.easeOutQuart),
    );

    _pointsController.forward();
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usa double.infinity para garantir que o gradient cubra toda área do body
    return Scaffold(
      // mantém comportamento normal de ajuste quando teclado aparece
      resizeToAvoidBottomInset: true,

      // CORPO com gradient preenchendo a tela
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF6D28D9), Color(0xFFEAB308)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              // garante que, se pouco conteúdo, a coluna ocupe a altura da tela
              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.vertical),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // Título principal centralizado
                  Center(
                    child: Text(
                      "🎉 Quiz Finalizado!",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(offset: Offset(0, 2), blurRadius: 4, color: Colors.black26)
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Card principal com estatísticas e mensagem motivadora
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Estatísticas do quiz
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCard(
                              Icons.star,
                              "${widget.percentualAcertos.toStringAsFixed(1)}%",
                              "Acertos",
                              const Color(0xFFEAB308),
                            ),
                            _buildStatCard(
                              Icons.emoji_events,
                              "${widget.pontosRecebidosQuizz} / ${widget.pontosTotalQuizz}",
                              "Pontos",
                              const Color(0xFF8B5CF6),
                            ),
                            _buildStatCard(
                              Icons.military_tech,
                              widget.pontosTotaisUsuario.toString(),
                              "Acumulado",
                              const Color(0xFF4ADE80),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Pontos animados
                        AnimatedBuilder(
                          animation: _pointsAnimation,
                          builder: (context, child) {
                            return Text(
                              "${_pointsAnimation.value} / ${widget.pontosTotalQuizz}",
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF581C87),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        // Mensagem motivadora dentro do card
                        Text(
                          widget.mensagemMotivadora,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Resumo por tema
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              "Resumo por Tema:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF581C87),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...widget.resumoPorTema.map((tema) => Card(
                              color: Colors.white.withOpacity(0.95),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(
                                  tema.tema,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF581C87)),
                                ),
                                subtitle: Text(
                                  'Acertos: ${tema.acertos}/${tema.perguntasRespondidas}',
                                  style: const TextStyle(color: Color(0xFF6D28D9)),
                                ),
                              ),
                            )),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            // volta para HomeWrapper mantendo aba 0 (ou ajuste se quiser outra)
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HomeWrapper( startIndex: 0,
                                  nomeUsuario: ModalRoute.of(context)!.settings.arguments != null
                                      ? (ModalRoute.of(context)!.settings.arguments as Map)['nomeUsuario']
                                      : "",
                                  usuarioId: ModalRoute.of(context)!.settings.arguments != null
                                      ? (ModalRoute.of(context)!.settings.arguments as Map)['usuarioId']
                                      : 0,),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Voltar para o Quiz',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // NAVBAR: mesma do app — quando o usuário toca em uma aba, abrimos o HomeWrapper na aba escolhida
      bottomNavigationBar: QuizziaBottomNav(
        currentIndex: 0,
        onTabChange: (i) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeWrapper( startIndex: 0,
                nomeUsuario: ModalRoute.of(context)!.settings.arguments != null
                    ? (ModalRoute.of(context)!.settings.arguments as Map)['nomeUsuario']
                    : "",
                usuarioId: ModalRoute.of(context)!.settings.arguments != null
                    ? (ModalRoute.of(context)!.settings.arguments as Map)['usuarioId']
                    : 0,),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF581C87),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6D28D9),
          ),
        ),
      ],
    );
  }
}
