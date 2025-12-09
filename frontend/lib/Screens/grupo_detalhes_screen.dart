import 'package:flutter/material.dart';
import 'package:quizzfront/Screens/quiz_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../widgets/quizzia_bottom_nav.dart';
import 'home_screen.dart';
import 'home_wrapper.dart';

class GrupoDetalhesScreen extends StatefulWidget {
  final Map<String, dynamic> grupo;
  final int grupoId;

  const GrupoDetalhesScreen({
    super.key,
    required this.grupo,
    required this.grupoId,
  });

  @override
  State<GrupoDetalhesScreen> createState() => _GrupoDetalhesScreenState();
}

class _GrupoDetalhesScreenState extends State<GrupoDetalhesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late Map<String, dynamic> _grupoAtual;
  @override
  void initState() {
    super.initState();

    _grupoAtual = Map<String, dynamic>.from(widget.grupo);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // -------------------------------
  // MÉTODO RECARREGAR GRUPO
  // -------------------------------
  Future<void> _recarregarGrupo() async {
    try {
      final data = await ApiService.buscarGrupoPorId(widget.grupoId);

      if (data != null && mounted) {
        setState(() {
          _grupoAtual = data;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao recarregar grupo: $e")),
        );
      }
    }
  }

  // -------------------------------
  // ABRIR OPÇÕES DO GRUPO
  // -------------------------------
  void _abrirOpcoesGrupo(BuildContext ctx, Map grupo) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.orange),
              title: const Text("Ver Ranking do Grupo"),
              onTap: () async {
                Navigator.pop(context);

                showDialog(
                  context: ctx,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF7E22CE)),
                  ),
                );

                try {
                  final rankingCarregado = await ApiService.obterRankingDoGrupo(widget.grupoId);

                  if (mounted) Navigator.pop(ctx);

                  if (mounted) _abrirRankingGrupo(ctx, rankingCarregado);
                } catch (e) {
                  if (mounted) Navigator.pop(ctx);
                  if (mounted) {
                    final errorMessage = e.toString().contains(':')
                        ? e.toString().split(':')[1].trim()
                        : "Verifique a conexão.";

                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text("Erro ao carregar ranking: $errorMessage")),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
  // -------------------------------
  // ABRIR RANKING DO GRUPO
  // -------------------------------
  void _abrirRankingGrupo(BuildContext ctx, List membros) {
    showDialog(
      context: ctx,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFFDE68A), width: 2),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxHeight: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Ranking do Grupo",
                      style: TextStyle(
                        color: Color(0xFF6B21A8),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF6B21A8),
                        size: 26,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFFFDE68A), thickness: 1),
                const SizedBox(height: 12),
                Expanded(
                  child: membros.isEmpty
                      ? const Center(
                    child: Text(
                      "Nenhum membro encontrado.",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                  )
                      : ListView.builder(
                    itemCount: membros.length,
                    itemBuilder: (_, i) {
                      final membro = membros[i];
                      final posicao = membro["posicao"] ?? i + 1;
                      final nome = membro["nome"] ?? "Sem nome";
                      final pontos = membro["pontosTotais"] ?? 0;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        child: Row(
                          children: [
                            Text(
                              "${posicao}º",
                              style: const TextStyle(
                                color: Color(0xFF6B21A8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDE68A),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Color(0xFF6B21A8),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                nome,
                                style: const TextStyle(
                                  color: Color(0xFF6B21A8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              "$pontos pts",
                              style: const TextStyle(
                                color: Color(0xFF6B21A8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _chamarRankingQuiz(BuildContext ctx, int quizzId) async {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF7E22CE)),
      ),
    );

    try {
      final rankingCarregado = await ApiService.obterRankingPorQuizz(quizzId);

      if (mounted) Navigator.pop(ctx);

      if (mounted) _abrirRankingQuiz(ctx, rankingCarregado);
    } catch (e) {
      if (mounted) Navigator.pop(ctx);
      if (mounted) {
        final errorMessage = e.toString().contains(':')
            ? e.toString().split(':')[1].trim()
            : "Verifique a conexão.";

        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
              content:
              Text("Erro ao carregar ranking do quiz: $errorMessage")),
        );
      }
    }
  }

  void _abrirRankingQuiz(BuildContext ctx, List membros) {
    showDialog(
      context: ctx,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFFDE68A), width: 2),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxHeight: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Ranking do Quiz",
                      style: TextStyle(
                        color: Color(0xFF6B21A8),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF6B21A8),
                        size: 26,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFFFDE68A), thickness: 1),
                const SizedBox(height: 12),
                Expanded(
                  child: membros.isEmpty
                      ? const Center(
                    child: Text(
                      "Nenhum membro encontrado ou ranking vazio.",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                  )
                      : ListView.builder(
                    itemCount: membros.length,
                    itemBuilder: (_, i) {
                      final membro = membros[i];
                      final posicao = membro["posicao"] ?? i + 1;
                      final nome = membro["nome"] ?? "Sem nome";
                      final pontos = membro["pontosTotais"] ?? 0;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        child: Row(
                          children: [
                            Text(
                              "${posicao}º",
                              style: const TextStyle(
                                color: Color(0xFF6B21A8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDE68A),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Color(0xFF6B21A8),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                nome,
                                style: const TextStyle(
                                  color: Color(0xFF6B21A8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              "$pontos pts",
                              style: const TextStyle(
                                color: Color(0xFF6B21A8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: QuizziaBottomNav(
        currentIndex: 0,
        grupoId: widget.grupoId,
        onTabChange: (index) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeWrapper(
                startIndex: index,
                nomeUsuario: "Usuário",
                usuarioId: 0,
              ),
            ),
          );
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9333EA), Color(0xFF7E22CE), Color(0xFFEAB308)],
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
                _buildHeader(_grupoAtual),
                const SizedBox(height: 8),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _recarregarGrupo,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGroupProfile(_grupoAtual),
                          const SizedBox(height: 24),
                          _buildStats(_grupoAtual),
                          const SizedBox(height: 24),
                          _buildActionButtons(),
                          const SizedBox(height: 32),
                          _buildQuizzesSection(context, _grupoAtual),
                        ],
                      ),
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

  // -------------------------------
  // HEADER
  // -------------------------------
  Widget _buildHeader(Map grupo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              (grupo['nome'] ?? 'Grupo').toString(),
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

  // -------------------------------
  // PERFIL DO GRUPO
  // -------------------------------
  Widget _buildGroupProfile(Map grupo) {
    final cores = (grupo['cores'] as List?)?.whereType<Color>().toList() ??
        [Colors.purple, Colors.deepPurple];

    return GestureDetector(
      onTap: () => _abrirOpcoesGrupo(context, grupo),
      child: Container(
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: cores),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  (grupo['icone'] ?? '⭐').toString(),
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (grupo['nome'] ?? "").toString(),
                    style: const TextStyle(
                      color: Color(0xFF6B21A8),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (grupo['descricao'] ?? "Sem descrição.").toString(),
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------
  // ESTATÍSTICAS
  // -------------------------------
  Widget _buildStats(Map grupo) {
    final membros = grupo['numeroMembros'] ?? 0;
    final quizzes = grupo['numeroQuizzes'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) =>
                      ListaMembrosDialog(membros: grupo['membros'] ?? []),
                );
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.people_rounded,
                    color: Color(0xFF7E22CE),
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "$membros membros",
                    style: const TextStyle(
                      color: Color(0xFF6B21A8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
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
              border: Border.all(color: const Color(0xFFFDE68A)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFF7E22CE),
                  size: 26,
                ),
                const SizedBox(width: 8),
                Text(
                  "$quizzes quizzes",
                  style: const TextStyle(
                    color: Color(0xFF6B21A8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------
  // BOTÕES
  // -------------------------------
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFBBF24), Color(0xFFEAB308)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A), width: 2),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomePage(grupoId: widget.grupoId),
                  ),
                );
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
            onTap: () async {
              try {
                await ApiService.sairDoGrupo(widget.grupoId);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Você saiu do grupo!")),
                );

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomeWrapper(
                      startIndex: 0,
                      nomeUsuario: "Usuário",
                      usuarioId: 0,
                    ),
                  ),
                      (route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Erro ao sair do grupo: $e")),
                );
              }
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
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------
  // LISTA DE QUIZZES
  // -------------------------------
  Widget _buildQuizzesSection(BuildContext contextTela, Map grupo) {
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
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (quizzes.isEmpty)
          const Text(
            "Nenhum quiz criado ainda...",
            style: TextStyle(color: Color(0xFFFEF3C7), fontSize: 14),
          ),
        ...quizzes.asMap().entries.map((entry) {
          final int idx = entry.key;
          final quiz = entry.value;
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: (400 + idx * 120).toInt()),
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(-20 * (1 - value), 0),
                child: child,
              ),
            ),
            child: _buildQuizCard(contextTela, quiz),
          );
        }),
      ],
    );
  }

  // -------------------------------
  // CARD DO QUIZ (FINALIZAR MOSTRA MENSAGEM)
  // -------------------------------
  Widget _buildQuizCard(BuildContext contextTela, Map quiz) {
    return StatefulBuilder(
      builder: (context, setState) {
        final bool respondido = quiz["respondido"] == true;
        final bool finalizado = quiz["finalizado"] == true;
        // Adicionando quizzId para ser usado na chamada da API
        final int quizzId = quiz["id"] ?? 0;

        String statusLabel = "Pendente";
        Color statusColor = Colors.yellowAccent.withOpacity(0.8);

        if (finalizado) {
          statusLabel = "Finalizado";
          statusColor = Colors.greenAccent.withOpacity(0.8);
        } else if (respondido) {
          statusLabel = "Respondido";
          statusColor = Colors.blueAccent.withOpacity(0.8);
        }

        return GestureDetector(
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            final usuarioId = prefs.getInt('usuarioId') ?? 0;
            final int criadorId = quiz["criadorId"] ?? 0;

            showModalBottomSheet(
              context: contextTela,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // NOVA OPÇÃO: Ver Ranking do Quiz
                    ListTile(
                      leading: const Icon(Icons.leaderboard, color: Color(0xFF7E22CE)),
                      title: const Text("Ver Ranking do Quiz"),
                      onTap: () async {
                        Navigator.pop(context); // Fecha o BottomSheet

                        // Chama o método auxiliar que lida com o loading e a API
                        if (quizzId != 0) {
                          await _chamarRankingQuiz(contextTela, quizzId);
                        } else {
                          ScaffoldMessenger.of(contextTela).showSnackBar(
                            const SnackBar(content: Text("ID do Quiz inválido.")),
                          );
                        }
                      },
                    ),

                    if (usuarioId == criadorId && !finalizado)
                      ListTile(
                        leading:
                        const Icon(Icons.check_circle, color: Colors.green),
                        title: const Text("Finalizar Quiz"),
                        onTap: () async {
                          Navigator.pop(context);

                          final sucesso =
                          await ApiService.finalizarQuiz(quiz["id"]);
                          if (sucesso && mounted) {
                            ScaffoldMessenger.of(contextTela).showSnackBar(
                              SnackBar(
                                content:
                                const Text("Quiz finalizado com sucesso!"),
                                backgroundColor: Colors.green[600],
                                duration: const Duration(seconds: 3),
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );

                            await _recarregarGrupo();
                          }
                        },
                      ),
                    if (!respondido && !finalizado)
                      ListTile(
                        leading: const Icon(Icons.edit, color: Colors.blue),
                        title: const Text("Responder Quiz"),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            contextTela,
                            MaterialPageRoute(
                              builder: (_) => QuizScreen(quizzId: quiz["id"]),
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.25), width: 2),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.quiz_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    (quiz['titulo'] ?? "Quiz").toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


class ListaMembrosDialog extends StatelessWidget {
  final List membros;

  const ListaMembrosDialog({super.key, required this.membros});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFFDE68A), width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxHeight: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Membros do Grupo",
                  style: TextStyle(
                    color: Color(0xFF6B21A8),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF6B21A8),
                    size: 26,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFFDE68A), thickness: 1),
            const SizedBox(height: 12),
            Expanded(
              child: membros.isEmpty
                  ? const Center(
                child: Text(
                  "Nenhum membro encontrado.",
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: membros.length,
                itemBuilder: (_, i) {
                  final membro = membros[i];

                  final String nome = membro["nome"] ?? "Sem nome";
                  final String email = membro["email"] ?? "sem-email";

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE68A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF6B21A8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nome,
                              style: const TextStyle(
                                color: Color(0xFF6B21A8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              email,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
