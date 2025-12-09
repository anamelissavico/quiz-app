import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../services/api_service.dart';
import 'grupo_detalhes_screen.dart';


class GroupsScreen extends StatefulWidget {
  final Function(int)? onOpenGroup;

  const GroupsScreen({Key? key, this.onOpenGroup, required int usuarioId, required String nomeUsuario, required Null Function(dynamic i) onTabChange}) : super(key: key);

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool isLoading = true;
  String? errorMessage = null;
  List<Map<String, dynamic>> meusGrupos = [];

  final Map<String, String> iconeMap = {
    'cerebro': '🧠',
    'livros': '📚',
    'computador': '💻',
    'formatura': '🎓',
    'foguete': '🚀',
    'raio': '⚡',
    'fogo': '🔥',
    'alvo': '🎯',
    'trofeu': '🏆',
    'ideia': '💡',
    'jogo': '🎮',
    'estrela': '🌟',
  };

  Future<void> _carregarGrupos() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('usuarioId');

      if (userId == null) {
        setState(() {
          errorMessage = 'Usuário não autenticado.';
          isLoading = false;
        });
        return;
      }

      final rawList = await ApiService.buscarGruposDoUsuario(userId);

      final parsed = rawList.map<Map<String, dynamic>>((item) {
        return _parseGrupoFromApi(item as Map<String, dynamic>);
      }).toList();

      setState(() {
        meusGrupos = parsed;
        isLoading = false;
      });

      _fadeController.forward();
    } catch (e, st) {
      setState(() {
        errorMessage = 'Erro ao carregar grupos: $e';
        isLoading = false;
      });
    }
  }

  Map<String, dynamic> _parseGrupoFromApi(Map<String, dynamic> item) {
    String colorString = item['cor'] ?? '#2196F3';
    Color color = Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    String? icon = item['icon'];

    return {
      "id": item["id"],
      "nome": item["nome"],
      "codigoAcesso": item["codigoAcesso"],
      "criadorId": item["criadorId"],

      // 🔥 NOVOS CAMPOS
      "numeroMembros": item["numeroMembros"] ?? 0,
      "numeroQuizzes": item["numeroQuizzes"] ?? 0,

      // ícone e cor
      "icone": icon,
      "cores": [color, color],
    };
  }

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _carregarGrupos(); // Carrega inicialmente
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Padding(padding: EdgeInsets.all(16), child: _buildHeader()),

                // 🔥 REFRESH INDICATOR AQUI — Não muda nenhum estilo
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _carregarGrupos,
                    color: Colors.white,
                    backgroundColor: Color(0xFF7E22CE),

                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildActionButtons(),
                          SizedBox(height: 24),
                          if (meusGrupos.isNotEmpty) ...[
                            _buildSectionHeader(
                              icon: Icons.people_rounded,
                              title: 'Meus Grupos',
                            ),
                            SizedBox(height: 12),
                            ...meusGrupos
                                .asMap()
                                .entries
                                .map((entry) =>
                                _buildMyGroupCard(entry.value, entry.key))
                                .toList(),
                            SizedBox(height: 24),
                          ],
                          SizedBox(height: 24),
                          Center(
                            child: Text(
                              'Explore mais grupos e encontre sua comunidade! ✨',
                              style: TextStyle(
                                color: Color(0xFFFEF3C7),
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
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

  Widget _buildHeader() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, -0.5),
        end: Offset.zero,
      ).animate(_fadeAnimation),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BattleZone',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Participe de batalhas de conhecimento com seus amigos!',
                  style: TextStyle(
                    color: Color(0xFFFEF3C7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '🏆',
            style: TextStyle(fontSize: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1.0).animate(_fadeAnimation),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFBBF24), Color(0xFFEAB308)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFFFDE68A), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showCreateGroupDialog(),
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, color: Color(0xFF6B21A8)),
                      SizedBox(width: 8),
                      Text(
                        'Criar Grupo',
                        style: TextStyle(
                          color: Color(0xFF6B21A8),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFFC4B5FD), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showJoinGroupDialog(),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.login_rounded, color: Color(0xFF7E22CE)),
                      SizedBox(width: 8),
                      Text(
                        'Entrar',
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFFFDE68A), size: 20),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMyGroupCard(Map<String, dynamic> grupo, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        final membrosVal = grupo['numeroMembros'] ??
            grupo['NumeroMembros'] ??
            grupo['membros'] ??
            grupo['Membros'] ??
            grupo['numero_membros'] ??
            0;
        final quizzesVal = grupo['numeroQuizzes'] ??
            grupo['NumeroQuizzes'] ??
            grupo['quizzes'] ??
            grupo['Quizzes'] ??
            grupo['numero_quizzes'] ??
            0;

        final membrosText = membrosVal?.toString() ?? '0';
        final quizzesText = quizzesVal?.toString() ?? '0';

        return Transform.translate(
          offset: Offset(-20 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: EdgeInsets.only(bottom: 12),

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.25), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),

              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    final id = grupo['id'] ?? grupo['Id'] ?? grupo['grupoId'] ?? grupo['GrupoId'];

                    final grupoDetalhado = await ApiService.buscarGrupoPorId(id);

                    if (grupoDetalhado == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Erro ao carregar detalhes do grupo.")),
                      );
                      return;
                    }


                     Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (_) => GrupoDetalhesScreen(
                           grupo: grupoDetalhado,
                          grupoId: id,
                         ),
                      ),
                     );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: grupo['cores'],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              grupo['icone'],
                              style: TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      grupo['nome'],
                                      style: TextStyle(

                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  if (grupo['isPrivado'] == true) ...[
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.lock_rounded,
                                      size: 14,
                                      color: Colors.white70,
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.people_rounded,
                                    size: 14,
                                    color: Color(0xFFFDE68A),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    membrosText,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Icon(
                                    Icons.emoji_events_rounded,
                                    size: 14,
                                    color: Color(0xFFFDE68A),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '$quizzesText quizzes',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        if (grupo['ranking'] != null)
                          Column(
                            children: [
                              Icon(
                                Icons.workspace_premium_rounded,
                                color: Color(0xFFFDE68A),
                                size: 20,
                              ),
                              Text(
                                '#${grupo['ranking']}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  _showCreateGroupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreateGroupDialog(
        onClose: () => Navigator.pop(context),
        onCreate: (groupData) async {
          final prefs = await SharedPreferences.getInstance();
          final userId = prefs.getInt('usuarioId');

          final payload = {
            'Nome': groupData['Nome'],
            'Descricao': groupData['Descricao'],
            'CriadorId': groupData['CriadorId'],
            'Icon': groupData['Icon'],
            'Color': groupData['Color'],
          };

          return await ApiService.criarGrupo(payload);
        },
      ),
    );
  }

  void _showJoinGroupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => JoinGroupDialog(
        onClose: () => Navigator.pop(context),
        onJoin: (groupId) async {
          Navigator.pop(context);
          final sucesso = await ApiService.entrarNoGrupo(groupId);
          if (sucesso) {
            _carregarGrupos();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Entrou no grupo com sucesso!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                Text('Código inválido ou erro ao entrar no grupo'),
              ),
            );
          }
        },
      ),
    );
  }
}


class CreateGroupDialog extends StatefulWidget {
  final VoidCallback onClose;
  final Future<dynamic> Function(Map<String, dynamic>) onCreate;

  const CreateGroupDialog({
    Key? key,
    required this.onClose,
    required this.onCreate,
  }) : super(key: key);

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  String _icone = '🧠';
  List<Color> _cores = [Color(0xFF8B5CF6), Color(0xFF6D28D9)];
  bool _isPrivado = false;
  bool _showSuccess = false;
  String _generatedId = '';
  bool _copied = false;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  final List<String> icones = [
    '🧠',
    '📚',
    '💻',
    '🎓',
    '🚀',
    '⚡',
    '🔥',
    '🎯',
    '🏆',
    '💡',
    '🎮',
    '🌟'
  ];

  final List<List<Color>> coresList = [
    [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    [Color(0xFF10B981), Color(0xFF059669)],
    [Color(0xFFF59E0B), Color(0xFFF97316)],
    [Color(0xFFEC4899), Color(0xFFDB2777)],
    [Color(0xFFEF4444), Color(0xFFDC2626)],
    [Color(0xFF6366F1), Color(0xFF4F46E5)],
    [Color(0xFF14B8A6), Color(0xFF0D9488)],
  ];

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    );
    _scaleController.forward();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleCreate() async {
    if (_nomeController.text.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('usuarioId');

    // Converte a cor principal para hex
    String colorHex = _cores.isNotEmpty
        ? '#${_cores.first.value.toRadixString(16).substring(2).toUpperCase()}'
        : '#8B5CF6';

    final payload = {
      'Nome': _nomeController.text.trim(),
      'Descricao': _descricaoController.text.trim(),
      'CriadorId': userId,
      'Icon': _icone,
      'Color': colorHex,
      'Privado': _isPrivado,
    };

    print('Payload JSON enviado para API: ${jsonEncode(payload)}');

    try {
      final response = await widget.onCreate(payload);

      if (response != null) {
        setState(() {
          _generatedId = response['codigoAcesso']?.toString() ?? '';
          _showSuccess = true;
        });
      }
    } catch (e) {
      print('Erro ao criar grupo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) return _buildSuccessDialog();

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16),
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFAF5FF), Color(0xFFFEFCE8)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Color(0xFFFDE68A), width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.add_rounded, color: Colors.white),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Criar Grupo',
                              style: TextStyle(
                                color: Color(0xFF6B21A8),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Nova Battlezone',
                              style: TextStyle(
                                color: Color(0xFF9333EA),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onClose,
                        icon: Icon(Icons.close_rounded, color: Color(0xFF7E22CE)),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xFFC4B5FD), width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pré-visualização',
                          style: TextStyle(
                            color: Color(0xFF9333EA),
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: _cores,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(_icone, style: TextStyle(fontSize: 32)),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _nomeController.text.isEmpty
                                        ? 'Nome do Grupo'
                                        : _nomeController.text,
                                    style: TextStyle(
                                      color: Color(0xFF6B21A8),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.people_rounded,
                                          size: 14, color: Color(0xFF9333EA)),
                                      SizedBox(width: 4),
                                      Text(
                                        '1 membro',
                                        style: TextStyle(
                                          color: Color(0xFF9333EA),
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        _isPrivado
                                            ? Icons.lock_rounded
                                            : Icons.public_rounded,
                                        size: 14,
                                        color: Color(0xFF9333EA),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // NOME
                  Text(
                    'Nome do Grupo *',
                    style: TextStyle(
                      color: Color(0xFF7E22CE),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _nomeController,
                    maxLength: 40,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Ex: Mestres do Quiz',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Color(0xFFC4B5FD), width: 2),
                      ),
                      counterText: '',
                    ),
                  ),

                  SizedBox(height: 16),

                  // DESCRIÇÃO
                  Text(
                    'Descrição (opcional)',
                    style: TextStyle(
                      color: Color(0xFF7E22CE),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _descricaoController,
                    maxLength: 150,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Descreva o objetivo do grupo...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Color(0xFFC4B5FD), width: 2),
                      ),
                      counterText: '',
                    ),
                  ),

                  SizedBox(height: 16),

                  Text(
                    'Escolha um Ícone',
                    style: TextStyle(
                      color: Color(0xFF7E22CE),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: icones.length,
                    itemBuilder: (context, index) {
                      final ic = icones[index];
                      final isSelected = ic == _icone;

                      return GestureDetector(
                        onTap: () => setState(() => _icone = ic),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                              colors: [
                                Color(0xFFFBBF24),
                                Color(0xFFF59E0B)
                              ],
                            )
                                : null,
                            color: isSelected ? null : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Color(0xFFFBBF24)
                                  : Color(0xFFC4B5FD),
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [
                              BoxShadow(
                                color: Color(0xFFFBBF24)
                                    .withOpacity(0.4),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              )
                            ]
                                : null,
                          ),
                          child: Center(
                            child: Text(ic, style: TextStyle(fontSize: 24)),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 16),

                  Text(
                    'Escolha uma Cor',
                    style: TextStyle(
                      color: Color(0xFF7E22CE),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: coresList.length,
                    itemBuilder: (context, index) {
                      final cores = coresList[index];
                      final isSelected = cores == _cores;

                      return GestureDetector(
                        onTap: () => setState(() => _cores = cores),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: cores,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                              color: Color(0xFFFBBF24),
                              width: 4,
                            )
                                : null,
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 16),



                  // BOTÕES
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onClose,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                                color: Color(0xFFC4B5FD), width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Color(0xFF7E22CE),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: _nomeController.text
                                .trim()
                                .isEmpty
                                ? null
                                : LinearGradient(
                              colors: [
                                Color(0xFFFBBF24),
                                Color(0xFFF59E0B)
                              ],
                            ),
                            color: _nomeController.text.trim().isEmpty
                                ? Color(0xFFE5E7EB)
                                : null,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFFFDE68A),
                              width: 2,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _nomeController.text.trim().isEmpty
                                  ? null
                                  : _handleCreate,
                              borderRadius: BorderRadius.circular(12),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_rounded,
                                    color: _nomeController.text
                                        .trim()
                                        .isEmpty
                                        ? Color(0xFF9CA3AF)
                                        : Color(0xFF6B21A8),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Criar',
                                    style: TextStyle(
                                      color: _nomeController.text
                                          .trim()
                                          .isEmpty
                                          ? Color(0xFF9CA3AF)
                                          : Color(0xFF6B21A8),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessDialog() {
    Future.delayed(Duration(seconds: 10), () {
      if (mounted) Navigator.of(context).pop();
    });

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 400),
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFAF5FF), Color(0xFFFEFCE8)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Color(0xFFFDE68A), width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF4ADE80), Color(0xFF059669)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 48),
                      ),
                    );
                  },
                ),
                SizedBox(height: 24),
                Text(
                  'Grupo Criado!',
                  style: TextStyle(
                    color: Color(0xFF6B21A8),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Compartilhe o ID com seus amigos para entrarem',
                  style:
                  TextStyle(color: Color(0xFF9333EA), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),

                // ID DO GRUPO
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Color(0xFFC4B5FD), width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'ID do Grupo',
                        style: TextStyle(
                          color: Color(0xFF9333EA),
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Text(
                            _generatedId,
                            style: TextStyle(
                              color: Color(0xFF6B21A8),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          IconButton(
                            onPressed: () {
                              setState(() => _copied = true);
                              Future.delayed(Duration(seconds: 2),
                                      () {
                                    if (mounted)
                                      setState(() => _copied = false);
                                  });
                            },
                            icon: Icon(
                              _copied
                                  ? Icons.check_circle_rounded
                                  : Icons.copy_rounded,
                              color: _copied
                                  ? Color(0xFF059669)
                                  : Color(0xFF9333EA),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                Text('🎉✨🏆', style: TextStyle(fontSize: 32)),
                SizedBox(height: 16),
                Text(
                  'Redirecionando para o grupo...',
                  style: TextStyle(
                    color: Color(0xFF9333EA),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              icon:
              Icon(Icons.close, color: Colors.grey[700]),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================
// DIALOG PARA ENTRAR NO GRUPO
// =========================================

class JoinGroupDialog extends StatefulWidget {
  final VoidCallback onClose;
  final Function(String) onJoin;

  const JoinGroupDialog({
    Key? key,
    required this.onClose,
    required this.onJoin,
  }) : super(key: key);

  @override
  State<JoinGroupDialog> createState() => _JoinGroupDialogState();
}

class _JoinGroupDialogState extends State<JoinGroupDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _groupIdController = TextEditingController();
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    );
    _scaleController.forward();
  }

  @override
  void dispose() {
    _groupIdController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16),
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFAF5FF), Color(0xFFFEFCE8)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Color(0xFFFDE68A), width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.login_rounded, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Entrar no Grupo',
                          style: TextStyle(
                            color: Color(0xFF6B21A8),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Digite o ID do grupo',
                          style: TextStyle(
                            color: Color(0xFF9333EA),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: Icon(Icons.close_rounded, color: Color(0xFF7E22CE)),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text('🎯', style: TextStyle(fontSize: 64)),
              SizedBox(height: 12),
              Text(
                'Peça o ID do grupo para o administrador',
                style: TextStyle(
                  color: Color(0xFF9333EA),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              // Input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID do Grupo',
                    style: TextStyle(
                      color: Color(0xFF7E22CE),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _groupIdController,
                    textAlign: TextAlign.center,
                    maxLength: 12,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'ABC123XYZ',
                      prefixIcon: Icon(Icons.tag_rounded, color: Color(0xFF9333EA)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFFC4B5FD), width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFFC4B5FD), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFFFBBF24), width: 2),
                      ),
                      counterText: '',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              // Botões
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onClose,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Color(0xFFC4B5FD), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Color(0xFF7E22CE),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: _groupIdController.text.trim().isEmpty
                            ? null
                            : LinearGradient(
                          colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                        ),
                        color: _groupIdController.text.trim().isEmpty
                            ? Color(0xFFE5E7EB)
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFFDE68A), width: 2),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _groupIdController.text.trim().isEmpty
                              ? null
                              : () => widget.onJoin(_groupIdController.text.trim()),
                          borderRadius: BorderRadius.circular(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.login_rounded,
                                color: _groupIdController.text.trim().isEmpty
                                    ? Color(0xFF9CA3AF)
                                    : Color(0xFF6B21A8),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Entrar',
                                style: TextStyle(
                                  color: _groupIdController.text.trim().isEmpty
                                      ? Color(0xFF9CA3AF)
                                      : Color(0xFF6B21A8),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

