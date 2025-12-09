using System.ComponentModel.DataAnnotations.Schema;

namespace quizzAPI.Models
{
    [Table("quiztentativa")]
    public class QuizTentativa
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int QuizzId { get; set; }
        public int Acertos { get; set; }
        public int TotalPerguntas { get; set; }
        public int PontosObtidos { get; set; }
        public int PontosTotal { get; set; }
        public double Percentual { get; set; }
        public DateTime DataResposta { get; set; } = DateTime.Now;
        public List<RespostaQuizz> Respostas { get; set; }
        public QuizTentativa()
        {
            Respostas = new List<RespostaQuizz>();
        }
    }
}
