using OpenAI.Chat;
using quizzAPI.Models;
using quizzAPI.Models.DTOs;
using System.ClientModel;
using System.Text.Json;

namespace quizzAPI.Services
{
    public class OpenAIService
    {
        private readonly ChatClient _client;

        public OpenAIService(IConfiguration configuration)
        {
            var apiKey = Environment.GetEnvironmentVariable("OPENAI_API_KEY")
                         ?? configuration["OpenAI:ApiKey"];

            if (string.IsNullOrEmpty(apiKey))
                throw new ArgumentException("API Key do OpenAI não encontrada.");

            _client = new ChatClient("gpt-4o-mini", new ApiKeyCredential(apiKey));
        }

        /// <summary>
        /// Gera um quiz com base nos parâmetros informados, incluindo justificativas breves e coerentes.
        /// </summary>
        public async Task<string> GerarQuizzAsync(string nivelEscolar, String objetivo, List<string> temas, int numeroPerguntas, List<string> dificuldade, String referencia)
        {
            string temasTexto = string.Join(", ", temas);
            string dificuldadeTexto = string.Join(", ", dificuldade);
            string prompt = $@"
Objetivos do estudante: {objetivo}
Nível escolar: {nivelEscolar}
Temas: {temasTexto}
Número total de perguntas: {numeroPerguntas}
Dificuldades selecionadas: {dificuldadeTexto}
Referência: {referencia}

Por favor:
- Crie exatamente {{numeroPerguntas}} perguntas de múltipla escolha.
- Para cada pergunta:
  1) Se o campo Referência estiver preenchido (ex.: 'ENEM', 'Concursos'), baseie a pergunta em questões dessas fontes. 
     - Sempre indique o ano e o nome da edição da fonte. O anoe o nome devem aparecer no início da pergunta entre parênteses, antes do texto da pergunta.
     - Se houver texto motivador, coloque-o antes da pergunta.
     - As alternativas devem ser as mesmas apresentadas na fonte.
  2) Se o campo Referência estiver vazio, crie a pergunta totalmente do zero e não precisa ano nem nome da fonte, original, com dificuldade apropriada.
- Distribua as perguntas proporcionalmente entre as dificuldades listadas (Fácil, Médio, Difícil). 
  Se houver resto, atribua as perguntas extras na ordem: Difícil, Médio, Fácil.
- Distribua as perguntas entre os temas fornecidos de forma balanceada.
- Cada pergunta deve conter:
  tema, dificuldade (Fácil|Médio|Difícil), perguntaTexto (com ano no início se houver referência), alternativaA..D, respostaCorreta (A|B|C|D), justificativa curta e campo 'referencia'.
- Evite ambiguidade e não gere perguntas repetidas.
- Para perguntas baseadas em referência, inclua a fonte e o ano ou edição no final da justificativa entre colchetes.
- Responda SOMENTE com um array JSON válido EXACTAMENTE no formato abaixo (sem texto adicional):

[
  {{
    ""tema"":""string"",
    ""dificuldade"":""Fácil|Médio|Difícil"",
    ""perguntaTexto"":""string"",
    ""alternativaA"":""string"",
    ""alternativaB"":""string"",
    ""alternativaC"":""string"",
    ""alternativaD"":""string"",
    ""respostaCorreta"":""A|B|C|D"",
    ""justificativa"":""string"",
    ""referencia"":""string ou vazio""
  }}
]

Exemplo de 1 item:
[
  {{
    ""tema"":""Biologia"",
    ""dificuldade"":""Fácil"",
    ""perguntaTexto"":""Qual organela é responsável pela produção de energia na célula?"",
    ""alternativaA"":""Mitocôndria"",
    ""alternativaB"":""Ribossomo"",
    ""alternativaC"":""Lisossomo"",
    ""alternativaD"":""Retículo endoplasmático"",
    ""respostaCorreta"":""A"",
    ""justificativa"":""A mitocôndria é onde ocorre a respiração celular e produção de ATP."",
    ""referencia"":""""
  }}
]
";

            var messages = new List<ChatMessage>
            {
                new SystemChatMessage("Você é um gerador de quizzes educacionais. Gere perguntas coerentes com o tema e o nível informado. Responda somente em JSON válido, sem comentários, explicações ou texto extra."),
                new UserChatMessage(prompt)
            };

            var response = await _client.CompleteChatAsync(messages);

            return response.Value.Content[0].Text?.Trim() ?? "[]";
        }

        /// <summary>
        /// Gera o quiz e retorna uma lista de PerguntaQuizz já desserializada.
        /// </summary>
        public async Task<List<PerguntaQuizz>> GerarQuizzDTOAsync(string nivelEscolar, String objetivo, List<string> temas, int numeroPerguntas, List<string> dificuldade, String referencia)
        {
            string json = await GerarQuizzAsync(nivelEscolar, objetivo, temas, numeroPerguntas, dificuldade, referencia);
            var jsonArray = ExtractJsonArray(json);
            if (jsonArray == null)
                throw new Exception("O serviço OpenAI não retornou JSON válido.");

            var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
            var perguntas = JsonSerializer.Deserialize<List<PerguntaQuizz>>(jsonArray, options) ?? new();

            // Garante que todas as perguntas tenham justificativa
            foreach (var p in perguntas)
            {
                if (string.IsNullOrWhiteSpace(p.Justificativa))
                    p.Justificativa = "Justificativa não gerada corretamente.";
            }

            return perguntas;
        }

        /// <summary>
        /// Valida perguntas geradas, revisando consistência e correção sem reescrever o conteúdo.
        /// </summary>
        public async Task<List<PerguntaValidacaoDTO>> ValidarQuizzAsync(string tema, string nivelEscolar, string dificuldade, string perguntasJson)
        {
            string prompt = $@"
Você é um revisor pedagógico.
Analise as perguntas abaixo e valide a qualidade e coerência das mesmas.

Critérios de validação:
1. Verifique se todos os campos existem (perguntaTexto, alternativaA–D, respostaCorreta, justificativa).
2. Confirme se a respostaCorreta corresponde à alternativa correta e é realmente a certa.
3. Cheque se não há ambiguidade (apenas uma resposta possível).
4. Verifique adequação ao tema '{tema}', ao nível '{nivelEscolar}' e à dificuldade '{dificuldade}'.
5. Corrija ortografia apenas se houver erro evidente.
6. Retorne SOMENTE em JSON no formato:

[
  {{
    ""index"": number,
    ""valid"": true|false,
    ""issues"": [""string"", ...],
    ""correctAnswerVerified"": true|false
  }}
]

Aqui estão as perguntas para validação:
{perguntasJson}
";

            var messages = new List<ChatMessage>
            {
                new SystemChatMessage("Você é um revisor pedagógico e linguístico. Responda exclusivamente em JSON válido, sem texto fora do formato."),
                new UserChatMessage(prompt)
            };

            var options = new ChatCompletionOptions
            {
                Temperature = 0.0f,
                TopP = 1.0f
            };

            var response = await _client.CompleteChatAsync(messages, options);
            var raw = response.Value.Content[0].Text?.Trim();

            var json = ExtractJsonArray(raw);
            if (json == null)
                throw new Exception("Resposta da IA não continha JSON válido.");

            var opts = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
            var results = JsonSerializer.Deserialize<List<ValidationResult>>(json, opts) ?? new();

            // Mapeamento para DTO
            return results.Select(r => new PerguntaValidacaoDTO
            {
                Index = r.Index,
                Valid = r.Valid,
                Issues = r.Issues,
                CorrectAnswerVerified = r.CorrectAnswerVerified
            }).ToList();
        }

        /// <summary>
        /// Extrai apenas o conteúdo JSON de uma resposta textual do modelo.
        /// </summary>
        private string? ExtractJsonArray(string raw)
        {
            if (string.IsNullOrWhiteSpace(raw)) return null;
            var start = raw.IndexOf('[');
            var end = raw.LastIndexOf(']');
            if (start >= 0 && end > start)
                return raw.Substring(start, end - start + 1);
            return null;
        }

        /// <summary>
        /// Classe interna auxiliar para mapear resultados de validação.
        /// </summary>
        internal class ValidationResult
        {
            public int Index { get; set; }
            public bool Valid { get; set; }
            public List<string> Issues { get; set; } = new();
            public bool CorrectAnswerVerified { get; set; }
        }
    }
}
