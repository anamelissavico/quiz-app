using System.Text.RegularExpressions;

namespace quizzAPI.Models
{
    public class UsuarioGrupo
    {
        public int UsuarioId { get; set; }
        public User User { get; set; } = null!;

        public int GrupoId { get; set; }
        public Grupo Grupo { get; set; } = null!;

        public DateTime DataEntrada { get; set; } = DateTime.UtcNow;

        public int Pontos { get; set; } = 0;
    }
}
