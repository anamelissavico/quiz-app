using Microsoft.Extensions.Configuration;
using OpenAI;
using OpenAI.Chat;
using System;
using System.ClientModel;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace QuizzAPI.Services
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

        public async Task<string> GerarQuizzAsync(string nivelEscolar, string tema, int numeroPerguntas, string dificuldade)
        {
            string prompt = $"Crie {numeroPerguntas} perguntas de quizz sobre '{tema}', " +
                            $"para um estudante de {nivelEscolar}, com nível de dificuldade {dificuldade}. " +
                            $"Responda em JSON, cada pergunta com 'pergunta' e 'resposta'.";

            List<ChatMessage> messages = new List<ChatMessage>
            {
                new SystemChatMessage("Você é um professor especializado em criar quizzes educacionais. Sempre responda no formato JSON."),
                new UserChatMessage(prompt)
            };

            var requestOptions = new ChatCompletionOptions()
            {
                Temperature = 1.0f,
                TopP = 1.0f,
            };

            using var cts = new CancellationTokenSource(TimeSpan.FromMinutes(2));

            var response = await _client.CompleteChatAsync(messages, requestOptions, cts.Token);
            return response.Value.Content[0].Text;
        }
    }
}
