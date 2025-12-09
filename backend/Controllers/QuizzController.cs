using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using quizzAPI.Data;
using quizzAPI.Models;
using quizzAPI.Models.DTOs;
using quizzAPI.Services;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

namespace YourNamespace.Controllers

{
    [ApiController]
    [Route("api/[controller]")]
    public class QuizzController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly OpenAIService _openAIService;

        public QuizzController(ApplicationDbContext context, OpenAIService openAIService)
        {
            _context = context;
            _openAIService = openAIService;
        }


        [HttpPost("gerar")]
        [Authorize]
        public async Task<IActionResult> GerarQuizz([FromBody] Quizz request)
        {
            if (request == null)
                return BadRequest("Requisição inválida.");


            var titulo = string.IsNullOrWhiteSpace(request.Titulo)
       ? $"Quiz sobre {string.Join(", ", request.Temas ?? new List<string>())}"
       : request.Titulo.Trim();

            var userIdClaim = User.FindFirst("id")?.Value
                  ?? User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim))
                return Unauthorized("Usuário não autenticado.");

            int criadorId = int.Parse(userIdClaim);

            var quizz = new Quizz
            {
                Titulo = titulo,
                NivelEscolar = request.NivelEscolar,
                NumeroPerguntas = request.NumeroPerguntas,
                Temas = request.Temas,
                Objetivo = request.Objetivo,
                Referencia = request.Referencia,
                CriadorId = criadorId, // 🔹 Atribui automaticamente
                DataInicio = null,
                DataFim = null
            };

            Console.WriteLine($"DataInicio: {request.DataInicio}");
            Console.WriteLine($"DataFim: {request.DataFim}");
            Console.WriteLine($"Titulo: {request.Titulo}");

            _context.Quizzes.Add(quizz);
            await _context.SaveChangesAsync();

            // 2️⃣ Gerar perguntas via IA (dificuldade e tema virão no JSON de retorno)
            List<PerguntaQuizz> perguntasGeradas = await _openAIService.GerarQuizzDTOAsync(
                request.NivelEscolar,
                request.Objetivo,
                request.Temas,
                request.NumeroPerguntas,
                request.Dificuldade,
                request.Referencia
            );

            if (perguntasGeradas == null || !perguntasGeradas.Any())
                return BadRequest("Não foi possível gerar perguntas do quiz.");

            // 3️⃣ Serializar perguntas para validação (sem dificuldade fixa)
            string perguntasJson = JsonSerializer.Serialize(perguntasGeradas);

            await _openAIService.ValidarQuizzAsync(
                string.Join(", ", request.Temas),
                request.NivelEscolar,
                "",
                perguntasJson
            );

            // 4️⃣ Salvar perguntas no banco
            foreach (var p in perguntasGeradas)
            {
                var pergunta = new Pergunta
                {
                    PerguntaTexto = p.PerguntaTexto,
                    AlternativaA = p.AlternativaA,
                    AlternativaB = p.AlternativaB,
                    AlternativaC = p.AlternativaC,
                    AlternativaD = p.AlternativaD,
                    RespostaCorreta = p.RespostaCorreta,
                    Justificativa = p.Justificativa,
                    NivelEscolar = request.NivelEscolar,
                    Tema = p.Tema,
                    Dificuldade = p.Dificuldade,
                    QuizzId = quizz.Id
                };

                _context.Perguntas.Add(pergunta);
            }

            await _context.SaveChangesAsync();

            // 5️⃣ Retornar quizz completo com perguntas
            return Ok(new
            {
                Mensagem = "Quiz gerado com sucesso!",
                QuizzId = quizz.Id,
                Titulo = quizz.Titulo,
                NivelEscolar = quizz.NivelEscolar,
                Temas = quizz.Temas,
                Objetivo = quizz.Objetivo,
                CriadorId = quizz.CriadorId,
                GrupoId = quizz.GrupoId,
                DataInicio = quizz.DataInicio,
                DataFim = quizz.DataFim,
                Perguntas = perguntasGeradas.Select(p => new
                {
                    p.Tema,
                    p.Dificuldade,
                    p.PerguntaTexto,
                    p.AlternativaA,
                    p.AlternativaB,
                    p.AlternativaC,
                    p.AlternativaD,
                    p.RespostaCorreta,
                    p.Justificativa
                })
            });
        }

        [HttpGet("{quizzId}/perguntas")]
        public async Task<IActionResult> ObterPerguntasPorQuizz(int quizzId)
        {
            var perguntas = await _context.Perguntas
                .Where(p => p.QuizzId == quizzId)
                .Select(p => new
                {
                    p.Id,
                    p.Tema,
                    p.Dificuldade,
                    p.PerguntaTexto,
                    p.AlternativaA,
                    p.AlternativaB,
                    p.AlternativaC,
                    p.AlternativaD,
                    p.RespostaCorreta,
                    p.Justificativa
                })
                .ToListAsync();

            if (!perguntas.Any())
                return NotFound($"Nenhuma pergunta encontrada para o QuizzId {quizzId}.");

            return Ok(new { perguntas });
        }

        [HttpPost("avaliar")]
        public async Task<IActionResult> AvaliarQuizz([FromBody] AvaliacaoQuizzRequest dto)
        {

            Console.WriteLine("➡️ Entrou no método SalvarTentativa!");
            if (dto == null || dto.Respostas == null || !dto.Respostas.Any())
                return BadRequest("Nenhuma resposta enviada.");

            var user = await _context.Users.FindAsync(dto.UserId);
            if (user == null)
                return NotFound("Usuário não encontrado.");

            var perguntas = await _context.Perguntas
                .Where(p => p.QuizzId == dto.QuizzId)
                .ToDictionaryAsync(p => p.Id);

            int pontosTotalQuizz = perguntas.Values.Sum(p => p.Dificuldade switch
            {
                "Fácil" => 15,
                "Médio" => 20,
                "Difícil" => 30,
                _ => 0
            });

            int pontosObtidos = 0;
            int totalPerguntas = perguntas.Count;
            int acertosTotais = 0;

            var temasResumo = new Dictionary<string, (int respondidas, int acertos)>();

            var tentativa = new QuizTentativa
            {
                UserId = dto.UserId,
                QuizzId = dto.QuizzId,
                Acertos = 0,
                TotalPerguntas = totalPerguntas,
                PontosObtidos = 0,
                PontosTotal = pontosTotalQuizz,
                Percentual = 0,
                DataResposta = DateTime.Now
            };

            await _context.QuizTentativas.AddAsync(tentativa);
            await _context.SaveChangesAsync();

            var respostasSalvar = new List<RespostaQuizz>();

            foreach (var resposta in dto.Respostas)
            {
                if (perguntas.TryGetValue(resposta.PerguntaId, out var pergunta))
                {
                    if (!temasResumo.ContainsKey(pergunta.Tema))
                        temasResumo[pergunta.Tema] = (0, 0);

                    var (respondidas, acertos) = temasResumo[pergunta.Tema];
                    respondidas++;

                    bool correto = pergunta.RespostaCorreta == resposta.AlternativaEscolhida;

                    if (correto)
                    {
                        acertos++;
                        acertosTotais++;

                        pontosObtidos += pergunta.Dificuldade switch
                        {
                            "Fácil" => 15,
                            "Médio" => 20,
                            "Difícil" => 30,
                            _ => 0
                        };
                    }

                    temasResumo[pergunta.Tema] = (respondidas, acertos);

                    respostasSalvar.Add(new RespostaQuizz
                    {
                        QuizTentativaId = tentativa.Id,
                        PerguntaId = resposta.PerguntaId,
                        AlternativaEscolhida = resposta.AlternativaEscolhida,
                        Correta = correto
                    });
                }
            }

            await _context.RespostasQuizz.AddRangeAsync(respostasSalvar);

            tentativa.Acertos = acertosTotais;
            tentativa.PontosObtidos = pontosObtidos;
            tentativa.Percentual = totalPerguntas > 0
                ? (acertosTotais * 100.0 / totalPerguntas)
                : 0;

            await _context.SaveChangesAsync();

            user.Pontos += pontosObtidos;
            await _context.SaveChangesAsync();

            string mensagemMotivadora = tentativa.Percentual <= 60
                ? "Você está indo bem, mas pode melhorar. Vamos!"
                : tentativa.Percentual <= 85
                    ? "Você tá indo muito bem, continue assim!"
                    : "Temos um expert na área, parabéns!";

            return Ok(new
            {
                pontosTotalQuizz = pontosTotalQuizz,
                pontosRecebidosQuizz = pontosObtidos,
                pontosTotaisUsuario = user.Pontos,
                percentualAcertos = tentativa.Percentual,
                mensagemMotivadora = mensagemMotivadora,
                tentativaId = tentativa.Id,
                resumoPorTema = temasResumo.Select(kvp => new
                {
                    tema = kvp.Key,
                    perguntasRespondidas = kvp.Value.respondidas,
                    acertos = kvp.Value.acertos
                })
            });
        }

        [HttpPost("grupos/criar")]
        public async Task<IActionResult> CriarGrupo([FromBody] CriarGrupoDTO dto)
        {
            var user = await _context.Users.FindAsync(dto.CriadorId);
            if (user == null) return NotFound("Usuário não encontrado.");

            var grupo = new Grupo
            {
                Nome = dto.Nome,
                CriadorId = user.Id,
                Icon = dto.Icon,    // 🔹 Novo campo
                Color = dto.Color   // 🔹 Novo campo
            };


            _context.Grupos.Add(grupo);
            _context.UsuariosGrupos.Add(new UsuarioGrupo { UsuarioId = user.Id, Grupo = grupo });
            await _context.SaveChangesAsync();

            return Ok(new { grupo.Id, grupo.Nome, grupo.CodigoAcesso, grupo.Icon, grupo.Color });
        }


        [HttpPost("entrar")]
        public async Task<IActionResult> EntrarGrupo([FromBody] EntrarGrupoDTO dto)
        {
            var user = await _context.Users.FindAsync(dto.UsuarioId);
            if (user == null) return NotFound("Usuário não encontrado.");

            var grupo = await _context.Grupos.FirstOrDefaultAsync(g => g.CodigoAcesso == dto.CodigoAcesso);
            if (grupo == null) return NotFound("Código inválido.");

            bool jaEsta = await _context.UsuariosGrupos.AnyAsync(ug => ug.UsuarioId == dto.UsuarioId && ug.GrupoId == grupo.Id);
            if (jaEsta) return BadRequest("Usuário já faz parte do grupo.");

            _context.UsuariosGrupos.Add(new UsuarioGrupo { UsuarioId = dto.UsuarioId, GrupoId = grupo.Id });
            await _context.SaveChangesAsync();

            return Ok(new { grupo.Id, grupo.Nome });
        }

        [HttpPost("sair")]
        public async Task<IActionResult> SairGrupo([FromBody] SairGrupoDTO dto)
        {
            var user = await _context.Users.FindAsync(dto.UsuarioId);
            if (user == null)
                return NotFound("Usuário não encontrado.");

            var grupo = await _context.Grupos.FindAsync(dto.GrupoId);
            if (grupo == null)
                return NotFound("Grupo não encontrado.");

            var usuarioGrupo = await _context.UsuariosGrupos
                .FirstOrDefaultAsync(ug => ug.UsuarioId == dto.UsuarioId && ug.GrupoId == dto.GrupoId);

            if (usuarioGrupo == null)
                return BadRequest("Usuário não faz parte deste grupo.");

            _context.UsuariosGrupos.Remove(usuarioGrupo);
            await _context.SaveChangesAsync();

            return Ok(new { mensagem = "Usuário removido do grupo com sucesso." });
        }

        [HttpGet("grupos/{id}/membros")]

        public async Task<IActionResult> ObterMembrosDoGrupo(int id)
        {
            var grupo = await _context.Grupos
                .Include(g => g.Membros)
                    .ThenInclude(ug => ug.User)
                .FirstOrDefaultAsync(g => g.Id == id);

            if (grupo == null)
                return NotFound("Grupo não encontrado.");

            var membros = grupo.Membros.Select(m => new
            {
                m.User.Id,
                m.User.Nome,
                m.User.Email,
                DataEntrada = m.DataEntrada
            });

            return Ok(new
            {
                GrupoId = grupo.Id,
                NomeGrupo = grupo.Nome,
                TotalMembros = membros.Count(),
                Membros = membros
            });
        }

        [HttpPost("grupos/{grupoId}/gerar-quizz")]
        public async Task<IActionResult> GerarQuizzParaGrupo(int grupoId, [FromBody] Quizz request)
        {
            // 1️⃣ Verifica se o grupo existe
            var grupo = await _context.Grupos
                .Include(g => g.Membros)
                .FirstOrDefaultAsync(g => g.Id == grupoId);

            if (grupo == null)
                return NotFound("Grupo não encontrado.");

            if (!grupo.Membros.Any())
                return BadRequest("Não é possível gerar um quiz para um grupo sem membros.");

            // 2️⃣ Define o título (caso não tenha vindo na requisição)
            var titulo = string.IsNullOrWhiteSpace(request.Titulo)
    ? $"Quiz sobre {string.Join(", ", request.Temas ?? new List<string>())}"
    : request.Titulo.Trim();

            var userIdClaim = User.FindFirst("id")?.Value
                  ?? User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim))
                return Unauthorized("Usuário não autenticado.");

            int criadorId = int.Parse(userIdClaim);


            var quizz = new Quizz
            {
                Titulo = titulo,
                NivelEscolar = request.NivelEscolar,
                NumeroPerguntas = request.NumeroPerguntas,
                Temas = request.Temas,
                Objetivo = request.Objetivo,
                Referencia = request.Referencia,
                GrupoId = grupo.Id,
                CriadorId = criadorId, // 🔹 Adicionado
                DataInicio = request.DataInicio,
                DataFim = request.DataFim
            };

            _context.Quizzes.Add(quizz);
            await _context.SaveChangesAsync();

            var perguntasGeradas = await _openAIService.GerarQuizzDTOAsync(
                request.NivelEscolar,
                request.Objetivo,
                request.Temas,
                request.NumeroPerguntas,
                request.Dificuldade,
                request.Referencia
            );

            if (perguntasGeradas == null || !perguntasGeradas.Any())
                return BadRequest("Não foi possível gerar perguntas para o quiz do grupo.");

            foreach (var p in perguntasGeradas)
            {
                _context.Perguntas.Add(new Pergunta
                {
                    PerguntaTexto = p.PerguntaTexto,
                    AlternativaA = p.AlternativaA,
                    AlternativaB = p.AlternativaB,
                    AlternativaC = p.AlternativaC,
                    AlternativaD = p.AlternativaD,
                    RespostaCorreta = p.RespostaCorreta,
                    Justificativa = p.Justificativa,
                    NivelEscolar = request.NivelEscolar,
                    Tema = p.Tema,
                    Dificuldade = p.Dificuldade,
                    QuizzId = quizz.Id
                });
            }

            await _context.SaveChangesAsync();

            return Ok(new
            {
                Mensagem = $"Quiz gerado com sucesso para o grupo {grupo.Nome}.",
                GrupoId = grupo.Id,
                QuizzId = quizz.Id,
                Titulo = quizz.Titulo,
                Temas = request.Temas,
                NumeroPerguntas = perguntasGeradas.Count,
                Perguntas = perguntasGeradas.Select(p => new
                {
                    p.Tema,
                    p.Dificuldade,
                    p.PerguntaTexto,
                    p.AlternativaA,
                    p.AlternativaB,
                    p.AlternativaC,
                    p.AlternativaD,
                    p.RespostaCorreta
                })
            });
        }



        [HttpGet("usuario/{usuarioId}/grupos")]
        public async Task<IActionResult> ObterGruposDoUsuario(int usuarioId)
        {
            var user = await _context.Users.FindAsync(usuarioId);
            if (user == null)
                return NotFound("Usuário não encontrado.");

            var grupos = await _context.UsuariosGrupos
                .Where(ug => ug.UsuarioId == usuarioId)
                .Include(ug => ug.Grupo) // Inclui dados do grupo
                .Select(ug => new
                {
                    ug.Grupo.Id,
                    ug.Grupo.Nome,
                    ug.Grupo.CodigoAcesso,
                    DataEntrada = ug.DataEntrada,
                    Cor = ug.Grupo.Color,
                    Icon = ug.Grupo.Icon,

                    NumeroMembros = _context.UsuariosGrupos
                        .Count(x => x.GrupoId == ug.Grupo.Id),

                    NumeroQuizzes = _context.Quizzes
                        .Count(q => q.GrupoId == ug.Grupo.Id)
                })
                .ToListAsync();

            return Ok(new
            {
                UsuarioId = usuarioId,
                NomeUsuario = user.Nome,
                TotalGrupos = grupos.Count,
                Grupos = grupos
            });
        }



        [HttpGet("grupos/{grupoId}/detalhes")]
        [Authorize]
        public async Task<IActionResult> ObterDetalhesDoGrupo(int grupoId)
        {
            var userIdClaim = User.FindFirst("id")?.Value
                ?? User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim))
                return Unauthorized("Usuário não autenticado.");

            int userId = int.Parse(userIdClaim);

            var grupo = await _context.Grupos
                .Include(g => g.Criador)
                .Include(g => g.Membros)
                    .ThenInclude(ug => ug.User)
                .Include(g => g.Quizzes)
                .FirstOrDefaultAsync(g => g.Id == grupoId);

            if (grupo == null)
                return NotFound("Grupo não encontrado.");

            grupo.NumeroMembros = grupo.Membros.Count;
            grupo.NumeroQuizzes = grupo.Quizzes.Count;

            var tentativasUsuario = await _context.QuizTentativas
                .Where(t => t.UserId == userId)
                .Select(t => t.QuizzId)
                .ToListAsync();

            var resultado = new
            {
                grupo.Id,
                grupo.Nome,
                grupo.Descricao,
                grupo.CodigoAcesso,
                grupo.Icon,
                grupo.Color,
                grupo.DataCriacao,
                grupo.NumeroMembros,
                grupo.NumeroQuizzes,

                Criador = new
                {
                    grupo.Criador.Id,
                    grupo.Criador.Nome,
                    grupo.Criador.Email
                },

                Quizzes = grupo.Quizzes.Select(q => new
                {
                    q.Id,
                    q.Titulo,
                    q.NivelEscolar,
                    q.NumeroPerguntas,
                    q.Temas,
                    q.Objetivo,
                    q.Referencia,
                    q.DataInicio,
                    q.DataFim,
                    Respondido = tentativasUsuario.Contains(q.Id),
                    Finalizado = q.Finalizado,
                    CriadorId = q.CriadorId
                }),

                Membros = grupo.Membros.Select(m => new
                {
                    m.User.Id,
                    m.User.Nome,
                    m.User.Email
                })
            };


            return Ok(resultado);
        }


        [HttpGet("usuario/{usuarioId}")]
        public async Task<IActionResult> ObterDadosUsuario(int usuarioId)
        {

            var user = await _context.Users.FindAsync(usuarioId);

            if (user == null)
                return NotFound($"Usuário com ID {usuarioId} não encontrado.");


            int quizzesGerados = await _context.Quizzes
                .CountAsync(q => q.CriadorId == usuarioId);


            var dadosUsuario = new
            {
                Id = user.Id,
                Nome = user.Nome,
                Email = user.Email,
                PontosTotais = user.Pontos,
                QuizzesGerados = quizzesGerados
            };

            return Ok(dadosUsuario);
        }

        [HttpPut("quizzes/{quizId}/finalizar")]
        [Authorize]
        public async Task<IActionResult> FinalizarQuiz(int quizId)
        {
            var userIdClaim = User.FindFirst("id")?.Value
                ?? User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim))
                return Unauthorized("Usuário não autenticado.");

            int userId = int.Parse(userIdClaim);

            var quiz = await _context.Quizzes
                .Include(q => q.Criador)
                .FirstOrDefaultAsync(q => q.Id == quizId);

            if (quiz == null)
                return NotFound("Quiz não encontrado.");

            if (quiz.Criador.Id != userId)
                return Forbid("Apenas o criador do quiz pode finalizá-lo.");

            quiz.Finalizado = true;

            await _context.SaveChangesAsync();

            return Ok(new { message = "Quiz finalizado com sucesso.", quizId = quiz.Id });
        }

        [HttpGet("grupos/{grupoId}/ranking")]

        public async Task<IActionResult> ObterRankingPorGrupo(int grupoId)
        {
            var grupo = await _context.Grupos.FindAsync(grupoId);
            if (grupo == null)
                return NotFound("Grupo não encontrado.");

            var rankingQuery = await _context.QuizTentativas
                .Where(qt => _context.Quizzes.Any(q => q.Id == qt.QuizzId && q.GrupoId == grupoId))
                .GroupBy(qt => qt.UserId)
                .Select(g => new
                {
                    UsuarioId = g.Key,
                    PontosTotais = g.Sum(qt => qt.PontosObtidos)
                })
                .OrderByDescending(x => x.PontosTotais)
                .ToListAsync();

            var rankingComNome = rankingQuery.Select((r, index) => new
            {
                Posicao = index + 1,
                r.UsuarioId,
                Nome = _context.Users.Where(u => u.Id == r.UsuarioId).Select(u => u.Nome).FirstOrDefault() ?? "Desconhecido",
                r.PontosTotais
            }).ToList();

            return Ok(new
            {
                GrupoId = grupo.Id,
                GrupoNome = grupo.Nome,
                Ranking = rankingComNome
            });
        }

        [HttpGet("quizzes/{quizzId}/ranking")]
        public async Task<IActionResult> ObterRankingPorQuizz(int quizzId)
        {
            var quiz = await _context.Quizzes.FindAsync(quizzId);
            if (quiz == null)
                return NotFound("Quiz não encontrado.");

            var rankingQuery = await _context.QuizTentativas
                .Where(qt => qt.QuizzId == quizzId)
                .GroupBy(qt => qt.UserId)
                .Select(g => new
                {
                    UsuarioId = g.Key,
                    PontosTotais = g.Sum(qt => qt.PontosObtidos)
                })
                .OrderByDescending(x => x.PontosTotais)
                .ToListAsync();

            var rankingComNome = rankingQuery.Select((r, index) => new
            {
                Posicao = index + 1,
                r.UsuarioId,
                Nome = _context.Users
                    .Where(u => u.Id == r.UsuarioId)
                    .Select(u => u.Nome)
                    .FirstOrDefault() ?? "Desconhecido",
                r.PontosTotais
            }).ToList();

            return Ok(new
            {
                QuizzId = quiz.Id,
                QuizzTitulo = quiz.Titulo,
                Ranking = rankingComNome
            });
        }

        [HttpGet("usuario/{usuarioId}/historico")]
        
        public async Task<IActionResult> ObterHistoricoUsuario(int usuarioId)
        {
            var user = await _context.Users.FindAsync(usuarioId);
            if (user == null)
                return NotFound("Usuário não encontrado.");

            var tentativas = await _context.QuizTentativas
                .Where(t => t.UserId == usuarioId)
                .Include(t => t.Respostas) 
                .ToListAsync();

            var historico = new List<object>();

            foreach (var tentativa in tentativas)
            {
                var quiz = await _context.Quizzes.FindAsync(tentativa.QuizzId);
                if (quiz == null) continue; 

                historico.Add(new
                {
                    TentativaId = tentativa.Id,
                    QuizzId = quiz.Id,
                    QuizzTitulo = quiz.Titulo,
                    DataResposta = tentativa.DataResposta,
                    Acertos = tentativa.Acertos,
                    TotalPerguntas = tentativa.TotalPerguntas,
                    PontosObtidos = tentativa.PontosObtidos,
                    PontosTotal = tentativa.PontosTotal,
                    Percentual = tentativa.Percentual,
                    Respostas = tentativa.Respostas.Select(r => new
                    {
                        r.PerguntaId,
                        PerguntaTexto = _context.Perguntas
                            .Where(p => p.Id == r.PerguntaId)
                            .Select(p => p.PerguntaTexto)
                            .FirstOrDefault() ?? "Pergunta removida",
                        r.AlternativaEscolhida,
                        r.Correta
                    })
                });
            }

            return Ok(new
            {
                UsuarioId = user.Id,
                NomeUsuario = user.Nome,
                Historico = historico
            });
        }

    }


}
//teste