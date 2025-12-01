import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Certifique-se de que o caminho está correto

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (!mounted) return;
    try {
      // ➡️ Chamada para obter os dados do usuário
      final data = await ApiService.obterDadosUsuario();
      if (mounted) {
        setState(() {
          _userData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Falha ao carregar dados. Verifique a conexão.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🎨 Propriedades para estender o corpo por trás das barras de sistema/navegação
      extendBody: true,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: const Text(
          'Meu Perfil',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent, // Fundo transparente
        elevation: 0,
      ),
      // O body aplica o Gradiente na tela toda (100% de preenchimento)
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF820AD1), Color(0xFF6D28D9), Color(0xFFEAB308)],
          ),
        ),
        // SafeArea apenas no topo para proteger o conteúdo abaixo da barra de status
        child: SafeArea(
          top: true,
          bottom: false,
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (_error != null) {
      // Exibição do erro de forma clara sobre o gradiente
      return Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final user = _userData!;
    final nome = user['nome'] ?? 'Usuário Desconhecido';
    final email = user['email'] ?? 'N/A';
    final pontos = user['pontosTotais']?.toString() ?? '0';

    // 🎯 REGRAS DE NEGÓCIO: Quizzes Respondidos = Quizzes Gerados
    final gerados = user['quizzesGerados']?.toString() ?? '0';
    final respondidos = gerados; // <--- Aplica a regra

    return SingleChildScrollView(
      // 🛑 Padding inferior ajustado para compensar a altura da NavBar
      padding: const EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 24.0, // Espaçamento abaixo do AppBar
        bottom: 140.0, // Valor ajustado para garantir que o conteúdo flutue acima da NavBar
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 👤 Cabeçalho do Perfil
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFFFDE047),
                  child: Icon(Icons.person, size: 60, color: Color(0xFF581C87)),
                ),
                const SizedBox(height: 16),
                Text(
                  nome,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  email,
                  style: const TextStyle(fontSize: 16, color: Color(0xFFFEF3C7)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 📊 Estatísticas (usando o valor de 'respondidos' corrigido)
          _buildStatCard('Pontos Totais', pontos, Icons.star_rounded, const Color(0xFFF59E0B)),
          _buildStatCard('Quizzes Gerados', gerados, Icons.create_rounded, const Color(0xFF3B82F6)),
          _buildStatCard('Quizzes Respondidos', respondidos, Icons.check_circle_outline, const Color(0xFF14B8A6)),

          const SizedBox(height: 48),

          // 🚪 Botão de Logout
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout, color: Color(0xFF581C87)),
              label: const Text(
                'Sair (Logout)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF581C87)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFFDE047), width: 3),
                ),
                elevation: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para as estatísticas
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      color: Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }
}