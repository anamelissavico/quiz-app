import 'dart:async'; // Adicionado para TimeoutException
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/login_request.dart';
import '../Models/register_request.dart';

const String _BASE_URL = "https://quiz-app-x3pi.onrender.com";
//const String _BASE_URL = "http://192.168.57.154:5267";

const Duration _API_TIMEOUT = Duration(seconds: 60);

class ApiService {

  static Future<Map<String, dynamic>> login(String email, String senha) async {
    final url = Uri.parse("$_BASE_URL/api/auth/login");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "senha": senha}),
      ).timeout(_API_TIMEOUT);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);
        await prefs.setInt("usuarioId", data["usuarioId"]);
        await prefs.setString("nomeUsuario", data["nome"]);

        return data;
      } else {
        print('❌ [API ERROR] LOGIN FAILED');
        print('Request URL: $url');
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw HttpException(
            'Erro ${response.statusCode}: ${response.body}', uri: url);
      }
    } on TimeoutException {
      print('❌ [API ERROR] Request timed out.');
      throw TimeoutException('A requisição de login excedeu o tempo limite de $_API_TIMEOUT.');
    } on SocketException catch (e) {
      print('❌ [API ERROR] Network error: ${e.message}');
      throw SocketException('Não foi possível conectar ao servidor. Verifique sua conexão com a internet.');
    } catch (e) {
      print('❌ [API ERROR] An unexpected error occurred: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> registrar(RegisterRequest request) async {
    final url = Uri.parse("$_BASE_URL/api/auth/register");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(_API_TIMEOUT);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          "sucesso": true,
          "mensagem": data["mensagem"] ?? "Registrado com sucesso",
          "usuarioId": data["usuarioId"],
        };
      } else {
        print('❌ [API ERROR] REGISTER FAILED');
        print('Status: ${response.statusCode}');
        print('Body: ${response.body}');

        return {
          "sucesso": false,
          "mensagem": response.body,
        };
      }
    } on TimeoutException {
      print('❌ [API ERROR] Timeout ao registrar');
      return {
        "sucesso": false,
        "mensagem": "Tempo limite excedido"
      };

    } on SocketException catch (e) {
      print('❌ [API ERROR] Network error: ${e.message}');
      return {
        "sucesso": false,
        "mensagem": "Erro de conexão com o servidor"
      };

    } catch (e) {
      print("❌ [API ERROR] Erro inesperado: $e");
      return {
        "sucesso": false,
        "mensagem": "Erro inesperado"
      };
    }
  }


  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }


  static Future<Map<String, dynamic>> gerarQuizz(
      Map<String, dynamic> payload) async {

    // 💡 NOVO TIMEOUT PARA O QUIZ: 30 segundos (ou mais)
    const Duration _QUIZ_TIMEOUT = Duration(seconds: 90);

    final token = await _getToken();
    final url = Uri.parse("$_BASE_URL/api/quizz/gerar");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(_QUIZ_TIMEOUT);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw HttpException(
            'Erro ${response.statusCode}: ${response.body}', uri: url);
      }
    } on TimeoutException {

      throw TimeoutException('A requisição de geração de quiz excedeu o limite de 30 segundos. O servidor pode estar ocupado.');
    } on SocketException {
      throw SocketException('Erro de conexão com o servidor.');
    }
  }

  static Future<List<dynamic>> obterPerguntas(int quizzId) async {
    final token = await _getToken();
    final url = Uri.parse("$_BASE_URL/api/quizz/$quizzId/perguntas");

    try {
      final response = await http.get(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(_API_TIMEOUT);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return data['perguntas'] ?? [];
      } else {
        throw HttpException(
            'Erro ${response.statusCode}: ${response.body}', uri: url);
      }
    } on TimeoutException {
      throw TimeoutException('A requisição excedeu o tempo limite.');
    } on SocketException {
      throw SocketException('Erro de conexão com o servidor.');
    }
  }


  static Future<Map<String, dynamic>> avaliarQuizz(
      Map<String, dynamic> payload) async {
    final token = await _getToken();
    final url = Uri.parse("$_BASE_URL/api/quizz/avaliar");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(_API_TIMEOUT);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw HttpException(
            'Erro ${response.statusCode}: ${response.body}', uri: url);
      }
    } on TimeoutException {
      throw TimeoutException('A requisição excedeu o tempo limite.');
    } on SocketException {
      throw SocketException('Erro de conexão com o servidor.');
    }
  }

  static Future<Map<String, dynamic>> criarGrupo(
      Map<String, dynamic> payload) async {
    final token = await _getToken();
    final url = Uri.parse('$_BASE_URL/api/quizz/grupos/criar');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(_API_TIMEOUT);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw HttpException(
          'Erro ${response.statusCode}: ${response.body}',
          uri: url,
        );
      }
    } on TimeoutException {
      throw TimeoutException('A requisição excedeu o tempo limite.');
    } on SocketException {
      throw SocketException('Erro de conexão com o servidor.');
    }
  }



  static Future<List<dynamic>> buscarGruposDoUsuario(int usuarioId) async {
    final token = await _getToken();
    final url = Uri.parse('$_BASE_URL/api/quizz/usuario/$usuarioId/grupos');

    print('===== [API] buscarGruposDoUsuario =====');
    print('URL: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(_API_TIMEOUT);

      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          final maybeList =
              data['Grupos'] ?? data['grupos'] ?? data['GruposList'] ?? data['data'];
          if (maybeList is List) return maybeList;
          return [];
        }

        if (data is List) return data;

        return [];
      } else {
        throw HttpException('Erro ${response.statusCode}: ${response.body}', uri: url);
      }
    } on TimeoutException {
      throw TimeoutException('A requisição excedeu o tempo limite.');
    } on SocketException {
      throw SocketException('Erro de conexão com o servidor.');
    }
  }


  static Future<bool> entrarNoGrupo(String codigoAcesso) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('usuarioId');

    if (userId == null) {
      print('❌ UsuarioId não encontrado no SharedPreferences');
      return false;
    }

    final url = Uri.parse('$_BASE_URL/api/quizz/entrar');

    final payload = {
      "usuarioId": userId,
      "codigoAcesso": codigoAcesso
    };

    print('📨 Enviando payload: $payload');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print('📩 StatusCode: ${response.statusCode}');
      print('📩 ResponseBody: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('❌ Erro ao enviar requisição: $e');
      return false;
    }
  }


  static Future<Map<String, dynamic>> sairDoGrupo(int grupoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioId = prefs.getInt('usuarioId');

      if (usuarioId == null) {
        throw Exception("Usuário não encontrado.");
      }

      final url = Uri.parse('$_BASE_URL/api/quizz/sair');
      final body = {
        "usuarioId": usuarioId,
        "grupoId": grupoId,
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("📩 StatusCode: ${response.statusCode}");
      print("📩 ResponseBody: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body));
      }
    } catch (e) {
      throw Exception("Erro ao sair do grupo: $e");
    }
  }



  static Future<Map<String, dynamic>?> buscarGrupoPorId(int grupoId) async {
    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('$_BASE_URL/api/quizz/grupos/$grupoId/detalhes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_API_TIMEOUT);

      print("Status Code: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return {
          "id": data["id"],
          "nome": data["nome"],
          "icone": data["icon"],
          "descricao": data["descricao"],

          "cores": [
            _parseCor(data["color"] ?? "#9333EA"),
            _parseCor(data["color"] ?? "#9333EA"),
          ],

          "numeroMembros": data["numeroMembros"] ?? 0,
          "numeroQuizzes": data["numeroQuizzes"] ?? 0,

          "quizzes": (data["quizzes"] as List<dynamic>).map((q) {
            return {
              "id": q["id"],
              "titulo": q["titulo"],
              "nivelEscolar": q["nivelEscolar"],
              "numeroPerguntas": q["numeroPerguntas"],
              "temas": q["temas"],
              "objetivo": q["objetivo"],
              "referencia": q["referencia"],
              "dataInicio": q["dataInicio"],
              "dataFim": q["dataFim"],

              "respondido": q["respondido"] ?? false,
              "finalizado": q["finalizado"] ?? false,
              "criadorId": q["criadorId"],
            };
          }).toList(),

          "membros": data["membros"] ?? [],
          "criador": data["criador"],
        };
      }

      print("Erro ao carregar grupo: ${response.body}");
      return null;

    } on TimeoutException {
      print('Erro na requisição buscarGrupoPorId: Tempo limite excedido.');
      return null;

    } on SocketException {
      print('Erro na requisição buscarGrupoPorId: Erro de conexão.');
      return null;

    } catch (e) {
      print("Erro na requisição buscarGrupoPorId: $e");
      return null;
    }
  }


  static Color _parseCor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }


  static Future<Map<String, dynamic>> obterDadosUsuario() async {
    final token = await _getToken();
    final prefs = await SharedPreferences.getInstance();


    final usuarioId = prefs.getInt("usuarioId");

    if (usuarioId == null) {
      throw Exception("ID do usuário não encontrado no armazenamento local. Faça login novamente.");
    }

    final url = Uri.parse("$_BASE_URL/api/quizz/usuario/$usuarioId");

    print('===== [API] obterDadosUsuario =====');
    print('URL: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(_API_TIMEOUT);

      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw HttpException(
            'Erro ${response.statusCode}: ${response.body}', uri: url);
      }
    } on TimeoutException {
      throw TimeoutException('A requisição excedeu o tempo limite.');
    } on SocketException {
      throw SocketException('Erro de conexão com o servidor.');
    }
  }


  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("token");
    await prefs.remove("usuarioId");
    await prefs.remove("nomeUsuario");

    print('✅ Dados de autenticação limpos com sucesso.');
  }

  static Future<Map<String, dynamic>> gerarQuizzParaGrupo(
      int grupoId, Map<String, dynamic> payload) async {

    final token = await _getToken();

    const Duration _QUIZ_TIMEOUT = Duration(seconds: 90);

    final url = Uri.parse("$_BASE_URL/api/quizz/grupos/$grupoId/gerar-quizz");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(_QUIZ_TIMEOUT);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw HttpException(
          'Erro ${response.statusCode}: ${response.body}',
          uri: url,
        );
      }
    } on TimeoutException {
      throw TimeoutException(
          'A geração do quiz para o grupo excedeu o tempo limite.');
    } on SocketException {
      throw SocketException('Erro de conexão com o servidor.');
    }
  }

  static Future<Map<String, dynamic>> buscarMembrosDoGrupo(int grupoId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("Usuário não autenticado: token não encontrado.");
    }

    final url = Uri.parse("$_BASE_URL/api/grupos/$grupoId/membros");

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_API_TIMEOUT);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw HttpException(
          "Erro ${response.statusCode}: ${response.body}",
          uri: url,
        );
      }
    } on TimeoutException {
      throw TimeoutException(
          "A requisição excedeu o tempo limite de $_API_TIMEOUT.");
    } on SocketException catch (e) {
      throw SocketException(
          "Falha de conexão: ${e.message}. Verifique sua internet.");
    } catch (e) {
      rethrow;
    }

  }

  static Future<bool> finalizarQuiz(int quizId) async {
    try {
      final token = await _getToken();

      final url = Uri.parse('$_BASE_URL/api/quizz/quizzes/$quizId/finalizar');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_API_TIMEOUT);

      print("📩 StatusCode: ${response.statusCode}");
      print("📩 ResponseBody: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Erro ao finalizar quiz: ${response.body}");
        return false;
      }
    } on TimeoutException {
      print('Erro: Tempo limite excedido ao finalizar quiz.');
      return false;
    } on SocketException {
      print('Erro: Falha na conexão ao finalizar quiz.');
      return false;
    } catch (e) {
      print("Erro inesperado ao finalizar quiz: $e");
      return false;
    }
  }

  static Future<List<dynamic>> obterRankingDoGrupo(int grupoId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("Usuário não autenticado: token não encontrado.");
    }

    final url = Uri.parse("$_BASE_URL/api/quizz/grupos/$grupoId/ranking");

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_API_TIMEOUT);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        print("DEBUG: Ranking raw JSON -> ${data['ranking']}");

        return data['ranking'] ?? [];
      } else {
        throw HttpException(
          'Erro ${response.statusCode}: ${response.body}',
          uri: url,
        );
      }
    } on TimeoutException {
      throw TimeoutException("A requisição de ranking excedeu o tempo limite.");
    } on SocketException catch (e) {
      throw SocketException(
          "Falha de conexão: ${e.message}. Verifique sua internet.");
    } catch (e) {
      throw Exception("Erro inesperado ao buscar ranking: $e");
    }
  }

  static Future<List<dynamic>> obterRankingPorQuizz(int quizzId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("Usuário não autenticado: token não encontrado.");
    }

    final url = Uri.parse("$_BASE_URL/api/quizz/quizzes/$quizzId/ranking");

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_API_TIMEOUT);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);


        return data['ranking'] ?? [];
      } else {
        String errorMessage = "Erro desconhecido.";
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? response.body;
        } catch (_) {
          errorMessage = response.body;
        }

        throw HttpException(
          'Erro ${response.statusCode}: $errorMessage',
          uri: url,
        );
      }
    } on TimeoutException {
      throw TimeoutException("A requisição de ranking excedeu o tempo limite.");
    } on SocketException catch (e) {
      throw SocketException(
          "Falha de conexão: ${e.message}. Verifique sua internet.");
    } catch (e) {
      throw Exception("Erro inesperado ao buscar ranking do quiz: $e");
    }
  }

  static Future<List<dynamic>> obterHistoricoUsuario(int usuarioId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("Usuário não autenticado: token não encontrado.");
    }

    final url = Uri.parse("$_BASE_URL/api/quizz/usuario/$usuarioId/historico");

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_API_TIMEOUT);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        return data['historico'] as List<dynamic>? ?? [];
      } else {
        String errorMessage = "Erro desconhecido.";
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? response.body;
        } catch (_) {
          errorMessage = response.body;
        }

        throw HttpException(
          'Erro ${response.statusCode}: $errorMessage',
          uri: url,
        );
      }
    } on TimeoutException {
      throw TimeoutException("A requisição excedeu o tempo limite.");
    } on SocketException catch (e) {
      throw SocketException(
          "Falha de conexão: ${e.message}. Verifique sua internet.");
    } catch (e) {
      throw Exception("Erro inesperado ao buscar histórico do usuário: $e");
    }
  }

}

