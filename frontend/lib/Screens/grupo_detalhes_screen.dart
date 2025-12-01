import 'package:flutter/material.dart';

class GrupoDetalhesScreen extends StatefulWidget {
  final Map<String, dynamic> grupo;

  const GrupoDetalhesScreen({super.key, required this.grupo});

  @override
  State<GrupoDetalhesScreen> createState() => _GrupoDetalhesScreenState();
}

class _GrupoDetalhesScreenState extends State<GrupoDetalhesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grupo = widget.grupo;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF9333EA),
              Color(0xFF7E22CE),
              Color(0xFFEAB308),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(grupo),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGroupProfile(grupo),
                        const SizedBox(height: 24),
                        _buildStats(grupo),
                        const SizedBox(height: 24),
                        _buildActionButtons(),
                        const SizedBox(height: 32),
                        _buildQuizzesSection(grupo),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // HEADER
  // -------------------------------------------------------
  Widget _buildHeader(Map grupo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              grupo['nome'] ?? 'Grupo',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // PERFIL DO GRUPO
  // -------------------------------------------------------
  Widget _buildGroupProfile(Map grupo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE68A), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícone do grupo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: List<Color>.from(grupo['cores']),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                grupo['icone'] ?? '⭐',
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Nome + descrição
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grupo['nome'],
                  style: const TextStyle(
                    color: Color(0xFF6B21A8),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  grupo['descricao'] ?? "Sem descrição.",
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // ESTATÍSTICAS: membros + quizzes
  // -------------------------------------------------------
  Widget _buildStats(Map grupo) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFFFDE68A)),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.people_rounded,
                    color: Color(0xFF7E22CE), size: 26),
                const SizedBox(width: 8),
                Text(
                  "${grupo['numeroMembros']} membros",
                  style: const TextStyle(
                    color: Color(0xFF6B21A8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFFFDE68A)),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_rounded,
                    color: Color(0xFF7E22CE), size: 26),
                const SizedBox(width: 8),
                Text(
                  "${grupo['numeroQuizzes']} quizzes",
                  style: const TextStyle(
                    color: Color(0xFF6B21A8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  // -------------------------------------------------------
  // BOTÕES: Criar Quiz + Sair do Grupo
  // -------------------------------------------------------
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Criar Quiz
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFBBF24), Color(0xFFEAB308)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFFFDE68A), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // abrir criação de quiz
              },
              child: const Center(
                child: Text(
                  "Criar Quiz",
                  style: TextStyle(
                    color: Color(0xFF6B21A8),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Sair do grupo
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0xFFC4B5FD), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              // sair do grupo
            },
            child: Row(
              children: const [
                Icon(Icons.logout_rounded, color: Color(0xFF7E22CE)),
                SizedBox(width: 8),
                Text(
                  "Sair",
                  style: TextStyle(
                    color: Color(0xFF7E22CE),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------
  // LISTA DE QUIZZES
  // -------------------------------------------------------
  Widget _buildQuizzesSection(Map grupo) {
    final quizzes = grupo['quizzes'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.quiz_rounded, color: Color(0xFFFDE68A), size: 22),
            SizedBox(width: 8),
            Text(
              "Quizzes do Grupo",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
        const SizedBox(height: 12),

        if (quizzes.isEmpty)
          const Text(
            "Nenhum quiz criado ainda...",
            style: TextStyle(color: Color(0xFFFEF3C7), fontSize: 14),
          ),

        ...quizzes.asMap().entries.map(
              (entry) {
            final int idx = entry.key;
            final quiz = entry.value;

            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 400 + idx * 120),
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(-20 * (1 - value), 0),
                  child: child,
                ),
              ),
              child: _buildQuizCard(quiz),
            );
          },
        ),
      ],
    );
  }

  // CARD DO QUIZ
  Widget _buildQuizCard(Map quiz) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFF7E22CE), size: 32),
          const SizedBox(width: 16),

          Expanded(
            child: Text(
              quiz['titulo'] ?? "Quiz",
              style: const TextStyle(
                color: Color(0xFF6B21A8),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          const Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: Color(0xFF7E22CE)),
        ],
      ),
    );
  }
}
