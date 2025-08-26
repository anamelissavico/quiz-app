using Microsoft.AspNetCore.Mvc;
using QuizzAPI.Services;
using System.Threading.Tasks;
using quizzAPI.Models.DTOs;

namespace QuizzAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class QuizzController : ControllerBase
    {
        private readonly OpenAIService _openAIService;

        public QuizzController(OpenAIService openAIService)
        {
            _openAIService = openAIService;
        }

        [HttpPost("gerar")]
        public async Task<IActionResult> GerarQuizz([FromBody] QuizRequest request)
        {
            if (request == null)
                return BadRequest("Requisição inválida.");

            try
            {
                var resultado = await _openAIService.GerarQuizzAsync(
                    request.NivelEscolar,
                    request.Tema,
                    request.NumeroPerguntas,
                    request.Dificuldade
                );

                return Ok(resultado);
            }
            catch (System.Exception ex)
            {
                return StatusCode(500, $"Erro ao gerar quiz: {ex.Message}");
            }
        }
    }
}

