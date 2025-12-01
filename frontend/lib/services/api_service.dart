import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ==========================================================
  //   CRIA CLIENTE HTTP QUE IGNORA CERTIFICADOS SSL
  // ==========================================================
  static Future<IOClient> _createHttpClient() async {
    final httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    return IOClient(httpClient);
  }

  // ==========================================================
  //   LOGIN  ➝ RETORNA token + dados do usuário
  // ==========================================================
  static Future<Map<String, dynamic>> login(String email, String senha) async {
    final client = await _createHttpClient();

    //final url = Uri.parse("https://192.168.3.6:7050/api/auth/login");
    final url = Uri.parse("http://192.168.3.6:5267/api/auth/login");

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email, "senha": senha}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // 🔥 SALVAR TOKEN
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", data["token"]);
      await prefs.setInt("usuarioId", data["usuarioId"]);
      await prefs.setString("nomeUsuario", data["nome"]);

      return data;
    } else {
      throw HttpException(
          'Erro ${response.statusCode}: ${response.body}', uri: url);
    }
  }

  // ==========================================================
  //   FUNÇÃO PARA PEGAR TOKEN DO STORAGE
  // ==========================================================
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // ==========================================================
  //   POST: GERAR QUIZZ (TOKEN OBRIGATÓRIO)
  // ==========================================================
  static Future<Map<String, dynamic>> gerarQuizz(
      Map<String, dynamic> payload) async {
    final client = await _createHttpClient();
    final token = await _getToken();

    //final url = Uri.parse("https://192.168.3.6:7050/api/quizz/gerar");
    final url = Uri.parse("http://192.168.3.6:5267/api/quizz/gerar");
    final response = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw HttpException(
          'Erro ${response.statusCode}: ${response.body}', uri: url);
    }
  }

  // ==========================================================
  //   GET: PERGUNTAS DO QUIZ (TOKEN OBRIGATÓRIO)
  // ==========================================================
  static Future<List<dynamic>> obterPerguntas(int quizzId) async {
    final client = await _createHttpClient();
    final token = await _getToken();

    final url =
    //Uri.parse("https://192.168.3.6:7050/api/quizz/$quizzId/perguntas");
    Uri.parse("http://192.168.3.6:5267/api/quizz/$quizzId/perguntas");
    final response = await client.get(
      url,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return data['perguntas'] ?? [];
    } else {
      throw HttpException(
          'Erro ${response.statusCode}: ${response.body}', uri: url);
    }
  }

  // ==========================================================
  //   POST: AVALIAR QUIZ (TOKEN OBRIGATÓRIO)
  // ==========================================================
  static Future<Map<String, dynamic>> avaliarQuizz(
      Map<String, dynamic> payload) async {
    final client = await _createHttpClient();
    final token = await _getToken();

    //final url = Uri.parse("https://192.168.3.6:7050/api/quizz/avaliar");
    final url = Uri.parse("http://192.168.3.6:5267/api/quizz/avaliar");

    final response = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw HttpException(
          'Erro ${response.statusCode}: ${response.body}', uri: url);
    }
  }

  static Future<Map<String, dynamic>> criarGrupo(
      Map<String, dynamic> payload) async {
    // Cria client que ignora certificado SSL
    final client = await _createHttpClient();

    // Pega token do storage
    final token = await _getToken();

    // URL do endpoint
    //final url = Uri.parse('https://192.168.3.6:7050/api/quizz/grupos/criar');
    final url = Uri.parse('http://192.168.3.6:5267/api/quizz/grupos/criar');

    // Faz requisição POST
    final response = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw HttpException(
        'Erro ${response.statusCode}: ${response.body}',
        uri: url,
      );
    }
  }


//   GET: LISTA DE GRUPOS DO USUÁRIO (tratamento flexível)
// ==========================================================
  static Future<List<dynamic>> buscarGruposDoUsuario(int usuarioId) async {
    final client = await _createHttpClient();
    final token = await _getToken();

    //final url = Uri.parse('https://192.168.3.6:7050/api/quizz/usuario/$usuarioId/grupos');
    final url = Uri.parse('http://192.168.3.6:5267/api/quizz/usuario/$usuarioId/grupos');

    print('===== [API] buscarGruposDoUsuario =====');
    print('URL: $url');

    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);

      // Se a API devolve um object com chave "Grupos" -> extrai a lista
      if (data is Map<String, dynamic>) {
        final maybeList =
            data['Grupos'] ?? data['grupos'] ?? data['GruposList'] ?? data['data'];
        if (maybeList is List) return maybeList;
        // se for um map que contém 'Quizzes' ou algo diferente, tente retornar vazio
        return [];
      }

      // Se já for uma lista direta
      if (data is List) return data;

      return [];
    } else {
      throw HttpException('Erro ${response.statusCode}: ${response.body}', uri: url);
    }
  }


  static Future<bool> entrarNoGrupo(String codigoAcesso) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('usuarioId');

    if (userId == null) return false;

    //final url = Uri.parse('https://192.168.3.6:7050/api/quizz/entrar');
    final url = Uri.parse('http://192.168.3.6:5267/api/quizz/entrar');

    final payload = {
      'codigoAcesso': codigoAcesso,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print('✅ Entrou no grupo: ${response.body}');
        return true;
      } else {
        print('❌ Erro ao entrar no grupo: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro ao entrar no grupo: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> buscarGrupoPorId(int grupoId) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.3.6:5267/api/quizz/Grupo/$grupoId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Normalização para o front (importante!)
        return {
          "id": data["id"],
          "nome": data["nome"],
          "icone": data["icone"],
          "descricao": data["descricao"],
          "cores": [
            _parseCor(data["cor"] ?? "#9333EA"),
            _parseCor(data["cor"] ?? "#9333EA"),
          ],

          // Estes campos podem vir do back com nomes diferentes
          "numeroMembros": data["numeroMembros"] ??
              data["NumeroMembros"] ??
              data["membros"] ??
              0,

          "numeroQuizzes": data["numeroQuizzes"] ??
              data["NumeroQuizzes"] ??
              data["quizzesCount"] ??
              0,

          // Lista de quizzes
          "quizzes": data["quizzes"] ?? data["Quizzes"] ?? [],
        };
      }

      print("Erro ao carregar grupo: ${response.body}");
      return null;
    } catch (e) {
      print("Erro na requisição buscarGrupoPorId: $e");
      return null;
    }
  }

  /// Converte a cor HEX em Color
  static Color _parseCor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }


  // ==========================================================
//   GET: DADOS DO USUÁRIO (TOKEN OBRIGATÓRIO)
// ==========================================================
  static Future<Map<String, dynamic>> obterDadosUsuario() async {
    final client = await _createHttpClient();
    final token = await _getToken();
    final prefs = await SharedPreferences.getInstance();

    // 1. Obtém o ID do usuário logado
    final usuarioId = prefs.getInt("usuarioId");

    if (usuarioId == null) {
      throw Exception("ID do usuário não encontrado no armazenamento local. Faça login novamente.");
    }

    // 2. Monta a URL com o ID do usuário (http://192.168.3.6:5267/api/quizz/usuario/{usuarioId})
    final url = Uri.parse("http://192.168.3.6:5267/api/quizz/usuario/$usuarioId");

    print('===== [API] obterDadosUsuario =====');
    print('URL: $url');

    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Retorna o objeto JSON contendo Nome, Email, PontosTotais, QuizzesGerados, etc.
      return jsonDecode(response.body);
    } else {
      throw HttpException(
          'Erro ${response.statusCode}: ${response.body}', uri: url);
    }
  }

  // ... outras funções (login, gerarQuizz, etc.)

// ==========================================================
//   LOGOUT ➝ LIMPA O TOKEN E ID DO USUÁRIO
// ==========================================================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    // Remove as chaves de autenticação e dados do usuário
    await prefs.remove("token");
    await prefs.remove("usuarioId");
    await prefs.remove("nomeUsuario");

    print('✅ Dados de autenticação limpos com sucesso.');
  }
}
