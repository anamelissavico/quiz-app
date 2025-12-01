namespace quizzAPI.Models.DTOs
{
    public class CriarGrupoDTO
    {

        public string Nome { get; set; } = string.Empty;

        public string Descricao { get; set; } = string.Empty;

        public int CriadorId { get; set; }

        public string Icon { get; set; } // Ex: "groups_rounded"
        public string Color { get; set; } // Ex: "#FFBB00"
    }
}
