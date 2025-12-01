namespace quizzAPI.Models
{
    public class Resultado
    {
            public int Id { get; set; }
            public int QuizzId { get; set; }
            public Quizz Quizz { get; set; }

            public int UsuarioId { get; set; }
            public User Usuario { get; set; }  // ← precisa existir
            public int Pontuacao { get; set; }
            public DateTime DataFinalizacao { get; set; }
        

    }
}
