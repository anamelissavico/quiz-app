namespace quizzAPI.Models
{
    public class UsuarioResposta
    {
        public int Id { get; set; }

        public int UsuarioQuizzId { get; set; }
        public UsuarioQuizz UsuarioQuizz { get; set; }

        public int PerguntaId { get; set; }
        public Pergunta Pergunta { get; set; }

        public string RespostaSelecionada { get; set; }
        public string RespostaCorreta { get; set; }
        public bool Correta { get; set; }
    }
}
