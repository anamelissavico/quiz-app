using System.ComponentModel.DataAnnotations.Schema;

namespace quizzAPI.Models
{
    [Table("quiztentativa")]
    public class RespostaQuizz
    {
        public int Id { get; set; }

        public int QuizTentativaId { get; set; }
        public QuizTentativa QuizTentativa { get; set; }

        public int PerguntaId { get; set; }
        public Pergunta Pergunta { get; set; }
        public string AlternativaEscolhida { get; set; }
        public bool Correta { get; set; }
    }
}
