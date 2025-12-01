import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quizzfront/Screens/loading_screen.dart';
import 'package:quizzfront/Screens/quiz_screen.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _objetivoController = TextEditingController();
  final TextEditingController _referenciaController = TextEditingController();
  final TextEditingController _outroTemaController = TextEditingController();

  String _nivelEscolar = 'Ensino Fundamental';

  final List<String> _temasSelecionados = [];
  final List<String> _dificuldadesSelecionadas = [];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, dynamic>> _temasDisponiveis = [
    {'id': 'História', 'nome': 'História', 'icon': Icons.menu_book, 'cor': const Color(0xFFF59E0B)},
    {'id': 'Ciências', 'nome': 'Ciências', 'icon': Icons.science, 'cor': const Color(0xFF3B82F6)},
    {'id': 'Matemática', 'nome': 'Matemática', 'icon': Icons.calculate, 'cor': const Color(0xFFEF4444)},
    {'id': 'Geografia', 'nome': 'Geografia', 'icon': Icons.public, 'cor': const Color(0xFF14B8A6)},
    {'id': 'Tecnologia', 'nome': 'Tecnologia', 'icon': Icons.computer, 'cor': const Color(0xFF6366F1)},
    {'id': 'Lingua Inglesa', 'nome': 'Lingua Inglesa', 'icon': Icons.language, 'cor': const Color(0xFF8B5CF6)},
    {'id': 'Lingua Español', 'nome': 'Lingua Español', 'icon': Icons.language, 'cor': const Color(0xFFEC4899)},
    {'id': 'Outros', 'nome': 'Outros', 'icon': Icons.edit, 'cor': const Color(0xFF9CA3AF)},
  ];

  final List<Map<String, dynamic>> _dificuldadesDisponiveis = [
    {'id': 'Fácil', 'nome': 'Fácil', 'icon': Icons.favorite, 'cor': const Color(0xFF4ADE80), 'desc': 'Perfeito para começar!'},
    {'id': 'Médio', 'nome': 'Médio', 'icon': Icons.star, 'cor': const Color(0xFFFBBF24), 'desc': 'Um desafio equilibrado'},
    {'id': 'Difícil', 'nome': 'Difícil', 'icon': Icons.local_fire_department, 'cor': const Color(0xFFF97316), 'desc': 'Para os experts!'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _numeroController.dispose();
    _objetivoController.dispose();
    _referenciaController.dispose();
    _outroTemaController.dispose();
    super.dispose();
  }

  void _toggleTema(String id) {
    setState(() {
      if (_temasSelecionados.contains(id)) {
        _temasSelecionados.remove(id);
      } else {
        _temasSelecionados.add(id);
      }
    });
  }

  void _toggleDificuldade(String id) {
    setState(() {
      if (_dificuldadesSelecionadas.contains(id)) {
        _dificuldadesSelecionadas.remove(id);
      } else {
        _dificuldadesSelecionadas.add(id);
      }
    });
  }

  Future<void> _gerarQuizz() async {
    if (!_formKey.currentState!.validate()) return;

    final numero = int.tryParse(_numeroController.text.trim()) ?? 0;
    final objetivo = _objetivoController.text.trim();
    final referencia = _referenciaController.text.trim();

    if (_temasSelecionados.contains('Outros') && _outroTemaController.text.trim().isNotEmpty) {
      _temasSelecionados.remove('Outros');
      _temasSelecionados.add(_outroTemaController.text.trim());
    }

    if (_temasSelecionados.isEmpty) {
      _showSnack('Selecione pelo menos um tema.');
      return;
    }

    if (_dificuldadesSelecionadas.isEmpty) {
      _showSnack('Selecione pelo menos uma dificuldade.');
      return;
    }

    if (numero <= 0) {
      _showSnack('Número de perguntas deve ser maior que zero.');
      return;
    }

    final payload = {
      "NivelEscolar": _nivelEscolar,
      "NumeroPerguntas": numero,
      "Objetivo": objetivo.isEmpty ? "" : objetivo,
      "Referencia": referencia.isEmpty ? "" : referencia,
      "Temas": _temasSelecionados,
      "Dificuldade": _dificuldadesSelecionadas,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizLoadingScreen(
          onComplete: () async {
            try {
              final response = await ApiService.gerarQuizz(payload);
              final quizzId = response['quizzId'];
              if (quizzId == null) throw 'ID do quiz não retornado da API';

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizScreen(quizzId: quizzId),
                ),
              );
            } catch (e) {
              _showSnack('⚠️ Erro ao gerar quiz: $e');
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF820AD1), Color(0xFF6D28D9), Color(0xFFEAB308)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildMainForm(),
                const SizedBox(height: 24),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.sports_esports, size: 40, color: Color(0xFFFDE047)),
            SizedBox(width: 8),
            Text(
              'Quizzia',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black26)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Teste seus conhecimentos e divirta-se!',
          style: TextStyle(fontSize: 18, color: Color(0xFFFEF3C7)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMainForm() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFFDE047), width: 3),
        ),
        color: Colors.white.withOpacity(0.95),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  'Configure Seu Quiz',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF581C87),
                  ),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: _nivelEscolar,
                  decoration: const InputDecoration(labelText: 'Nível escolar'),
                  items: const [
                    DropdownMenuItem(value: 'Ensino Fundamental', child: Text('Ensino Fundamental')),
                    DropdownMenuItem(value: 'Ensino Médio', child: Text('Ensino Médio')),
                    DropdownMenuItem(value: 'Ensino Superior', child: Text('Ensino Superior')),
                  ],
                  onChanged: (v) => setState(() => _nivelEscolar = v ?? _nivelEscolar),
                ),
                const SizedBox(height: 24),
                _buildTemasSection(),
                if (_temasSelecionados.contains('Outros')) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _outroTemaController,
                    decoration: const InputDecoration(
                        labelText: 'Digite o tema', hintText: 'Ex.: Filosofia'),
                  ),
                ],
                const SizedBox(height: 24),
                TextFormField(
                  controller: _objetivoController,
                  decoration: const InputDecoration(
                      labelText: 'Objetivo', hintText: 'Ex.: Quero me preparar para o ENEM'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _referenciaController,
                  decoration: const InputDecoration(
                      labelText: 'Referência (opcional)', hintText: 'Ex.: Questões do ENEM'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _numeroController,
                  decoration: const InputDecoration(
                      labelText: 'Número de perguntas', hintText: 'Ex.: 5'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe a quantidade';
                    final n = int.tryParse(v);
                    if (n == null || n <= 0) return 'Número inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildDificuldadesSection(),
                const SizedBox(height: 24),
                _buildGenerateButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTemasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Escolha um tema:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _temasDisponiveis.map((tema) {
            final selecionado = _temasSelecionados.contains(tema['id']);
            return GestureDetector(
              onTap: () => _toggleTema(tema['id']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: tema['cor'],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selecionado ? Colors.red : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tema['icon'], color: Colors.white),
                    const SizedBox(width: 8),
                    Text(tema['nome'],
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDificuldadesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Escolha a dificuldade:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _dificuldadesDisponiveis.map((dif) {
            final selecionado = _dificuldadesSelecionadas.contains(dif['id']);
            return Expanded(
              child: GestureDetector(
                onTap: () => _toggleDificuldade(dif['id']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: dif['cor'],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selecionado ? Colors.red : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(dif['icon'], color: Colors.white, size: 28),
                      const SizedBox(height: 8),
                      Text(dif['nome'],
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(dif['desc'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFEAB308)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE047), width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 8)
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _gerarQuizz,
          borderRadius: BorderRadius.circular(16),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flash_on, size: 20, color: Color(0xFF581C87)),
                SizedBox(width: 8),
                Text(
                  'Gerar Quiz Agora!',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF581C87)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        '© 2025 Quizzia',
        style: TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }
}
