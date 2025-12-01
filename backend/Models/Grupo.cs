namespace quizzAPI.Models
{
    public class Grupo
    {
        public int Id { get; set; }
        public string Nome { get; set; } = string.Empty;

        public string Descricao { get; set; } = string.Empty;

        public string CodigoAcesso { get; set; } = Guid.NewGuid()
            .ToString()
            .Substring(0, 8);

        public int CriadorId { get; set; }
        public User Criador { get; set; } = null!;

        public ICollection<UsuarioGrupo> Membros { get; set; } = new List<UsuarioGrupo>();
        public ICollection<Quizz> Quizzes { get; set; } = new List<Quizz>();

        public DateTime DataCriacao { get; set; } = DateTime.UtcNow;

        public string Icon { get; set; } = string.Empty;
        public string Color { get; set; } = string.Empty;

        public int NumeroMembros { get; set; }    // ⬅️ Faltava fechar!
        public int NumeroQuizzes { get; set; }
    }
}
