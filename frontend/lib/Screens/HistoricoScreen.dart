import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HistoricoScreen extends StatefulWidget {
  final int usuarioId;

  const HistoricoScreen({super.key, required this.usuarioId});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen>
    with TickerProviderStateMixin {
  late Future<List<dynamic>> _historicoFuture;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _historicoFuture = _fetchHistorico();

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

  Future<List<dynamic>> _fetchHistorico() async {
    try {
      return await ApiService.obterHistoricoUsuario(widget.usuarioId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao carregar histórico: ${e.toString()}")),
        );
      }
      return [];
    }
  }

  void _abrirDetalhesTentativa(BuildContext contextTela, Map tentativa) {
    final List respostas = tentativa['respostas'] ?? [];
    final String quizzTitulo = tentativa['quizzTitulo'] ?? 'Quiz Desconhecido';
    final int pontosObtidos = tentativa['pontosObtidos'] ?? 0;
    final int pontosTotal = tentativa['pontosTotal'] ?? 0;

    showDialog(
      context: contextTela,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFFDE68A), width: 2),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxHeight: 550),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        quizzTitulo,
                        style: const TextStyle(
                          color: Color(0xFF6B21A8),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
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
                Text(
                  "Pontuação: $pontosObtidos/$pontosTotal pts",
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFFFDE68A), thickness: 1),
                const SizedBox(height: 12),

                Expanded(
                  child: respostas.isEmpty
                      ? const Center(
                    child: Text(
                      "Detalhes das respostas não disponíveis.",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                  )
                      : ListView.builder(
                    itemCount: respostas.length,
                    itemBuilder: (_, i) {
                      final resposta = respostas[i];
                      // CHAVES CORRIGIDAS AQUI
                      final String perguntaTexto = resposta["perguntaTexto"] ?? 'Pergunta sem texto';
                      final String alternativaEscolhida = resposta["alternativaEscolhida"] ?? 'N/A';
                      final bool correta = resposta["correta"] ?? false;

                      return _buildRespostaCard(perguntaTexto, alternativaEscolhida, correta);
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

  Widget _buildRespostaCard(String pergunta, String escolha, bool correta) {
    Color iconColor = correta ? Colors.green[600]! : Colors.red[600]!;
    IconData icon = correta ? Icons.check_circle : Icons.cancel;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: correta ? Colors.green.shade200 : Colors.red.shade200),
        boxShadow: [
          BoxShadow(
            color: correta ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pergunta,
                  style: const TextStyle(
                    color: Color(0xFF6B21A8),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 28.0),
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Sua Resposta: ',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                    ),
                  ),
                  TextSpan(
                    text: escolha,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' (${correta ? 'Certa' : 'Errada'})',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                _buildHeader(),
                const SizedBox(height: 8),
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: _historicoFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Erro: ${snapshot.error}",
                            style: const TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            "Nenhuma tentativa de quiz registrada.",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        );
                      }

                      final historico = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: historico.length,
                        itemBuilder: (context, index) {
                          final tentativa = historico[index];
                          return _buildHistoricoCard(context, tentativa);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          const Expanded(
            child: Text(
              "Histórico de Quizzes",
              style: TextStyle(
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

  Widget _buildHistoricoCard(BuildContext contextTela, Map tentativa) {
    // CHAVES CORRIGIDAS AQUI
    final String titulo = tentativa['quizzTitulo'] ?? 'Quiz sem Título';
    final int pontosObtidos = tentativa['pontosObtidos'] ?? 0;
    final int totalPerguntas = tentativa['totalPerguntas'] ?? 1;
    final int acertos = tentativa['acertos'] ?? 0;
    final String data = tentativa['dataResposta'] != null
        ? tentativa['dataResposta'].substring(0, 10)
        : 'S/D';

    String statusLabel = "Acertos: $acertos/$totalPerguntas";
    Color statusColor = (acertos / totalPerguntas) > 0.5
        ? Colors.greenAccent.withOpacity(0.8)
        : Colors.redAccent.withOpacity(0.8);

    final String pontosLabel = "$pontosObtidos pts";

    return GestureDetector(
      onTap: () => _abrirDetalhesTentativa(contextTela, tentativa),
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
                Icons.history_toggle_off_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Data: $data',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
                const SizedBox(height: 4),
                Text(
                  pontosLabel,
                  style: const TextStyle(
                    color: Color(0xFFFDE68A),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
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
  }
}