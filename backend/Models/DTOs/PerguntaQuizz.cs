namespace quizzAPI.Models
{
    public class PerguntaQuizz
    {
        public int Index { get; set; } // Para controle ou validação da ordem das perguntas

        public string Tema { get; set; }           // Novo campo: tema da pergunta
        public string Dificuldade { get; set; }    // Novo campo: dificuldade da pergunta (Fácil|Médio|Difícil)

        public string PerguntaTexto { get; set; }

        public string AlternativaA { get; set; }
        public string AlternativaB { get; set; }
        public string AlternativaC { get; set; }
        public string AlternativaD { get; set; }
        public string RespostaCorreta { get; set; }

        public string Justificativa { get; set; }

    }
}
