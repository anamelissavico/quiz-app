using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace quizzAPI.Models
{
    public class Quizz
    {
        [Key]
        public int Id { get; set; }

        public string? Titulo { get; set; }

        [Required]
        public string NivelEscolar { get; set; }

        [Required]
        public int NumeroPerguntas { get; set; }

        public string? Objetivo { get; set; }

        public List<string> Dificuldade { get; set; } = new();

        public List<string> Temas { get; set; } = new();

        public List<Pergunta> Perguntas { get; set; } = new();

        public string Referencia { get; set; } = string.Empty;

        // 🔹 Associação opcional a grupo
        public int? GrupoId { get; set; }
        public Grupo? Grupo { get; set; }

        // 🔹 Datas opcionais — agora podem ficar nulas se não forem definidas
        public DateTime? DataInicio { get; set; }
        public DateTime? DataFim { get; set; }


        public int? CriadorId { get; set; }
        public User? Criador { get; set; }
    }
}
