import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RespostaUsuario {
  final int perguntaId;
  final String alternativaEscolhida;

  RespostaUsuario({required this.perguntaId, required this.alternativaEscolhida});

  Map<String, dynamic> toJson() => {
    'perguntaId': perguntaId,
    'alternativaEscolhida': alternativaEscolhida,
  };
}

class AvaliacaoQuizzRequest {
  final int userId;
  final int quizzId;
  final List<RespostaUsuario> respostas;

  AvaliacaoQuizzRequest({
    required this.userId,
    required this.quizzId,
    required this.respostas,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'quizzId': quizzId,
    'respostas': respostas.map((r) => r.toJson()).toList(),
  };
}

class QuizScreen extends StatefulWidget {
  final int quizzId;

  const QuizScreen({super.key, required this.quizzId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _isLoading = true;
  List<dynamic> _perguntas = [];
  int _currentIndex = 0;
  bool _respostaSelecionada = false;
  bool _acertou = false;
  List<RespostaUsuario> respostasUsuario = [];

  @override
  void initState() {
    super.initState();
    _carregarPerguntas();
  }

  Future<void> _carregarPerguntas() async {
    setState(() => _isLoading = true);
    try {
      final perguntas = await ApiService.obterPerguntas(widget.quizzId);
      setState(() {
        _perguntas = perguntas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao carregar quiz: $e')));
    }
  }

  void _selecionarResposta(String alternativa) {
    if (_respostaSelecionada) return;

    final pergunta = _perguntas[_currentIndex];
    final correta = pergunta['respostaCorreta'];

    respostasUsuario.add(
      RespostaUsuario(
        perguntaId: pergunta['id'],
        alternativaEscolhida: alternativa,
      ),
    );

    setState(() {
      _respostaSelecionada = true;
      _acertou = alternativa == correta;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_currentIndex < _perguntas.length - 1) {
        setState(() {
          _currentIndex++;
          _respostaSelecionada = false;
          _acertou = false;
        });
      } else {
        _enviarRespostas();
      }
    });
  }

  Future<void> _enviarRespostas() async {
    final avaliacao = AvaliacaoQuizzRequest(
      userId: 1,
      quizzId: widget.quizzId,
      respostas: respostasUsuario,
    );

    try {
      final resultado = await ApiService.avaliarQuizz(avaliacao.toJson());

      final pontos = resultado['pontos'];
      final pontosTotais = resultado['pontosTotaisUsuario'];

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Quiz finalizado!'),
          content: Text('Você ganhou $pontos pontos!\nTotal: $pontosTotais'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar respostas: $e')),
      );
    }
  }

  Color _corBotao(String letra) {
    if (!_respostaSelecionada) return Colors.blue;

    final pergunta = _perguntas[_currentIndex];
    final correta = pergunta['respostaCorreta'];

    if (letra == correta) return Colors.green;
    if (_respostaSelecionada && letra != correta) return Colors.red;

    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_perguntas.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Nenhuma pergunta disponível.')),
      );
    }

    final pergunta = _perguntas[_currentIndex];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF7C3AED), // roxo-600
              Color(0xFF6D28D9), // roxo-700
              Color(0xFFEAB308), // amarelo-400
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                Text(
                  'Pergunta ${_currentIndex + 1}/${_perguntas.length}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Card da Pergunta
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      pergunta['perguntaTexto'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Alternativas
                Expanded(
                  child: ListView(
                    children: ['A', 'B', 'C', 'D'].map((letra) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: _corBotao(letra),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          onPressed: () => _selecionarResposta(letra),
                          child: Text(
                            '$letra) ${pergunta['alternativa$letra']}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
