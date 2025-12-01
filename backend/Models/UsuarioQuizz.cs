namespace quizzAPI.Models
{
    public class UsuarioQuizz
    {
        public int Id { get; set; }

        public int UserId { get; set; }
        public User User { get; set; }

        public int QuizzId { get; set; }
        public Quizz Quizz { get; set; }

        public int Tentativa { get; set; } = 1;

        public DateTime DataInicio { get; set; } = DateTime.UtcNow;
        public DateTime? DataConclusao { get; set; }

        public int Pontuacao { get; set; }

        public ICollection<UsuarioResposta> Respostas { get; set; } = new List<UsuarioResposta>();
    }
}
