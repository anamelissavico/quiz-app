namespace quizzAPI.Models.DTOs
{
    public class QuizRequest
    {
        public string NivelEscolar { get; set; } = string.Empty;   
        public int NumeroPerguntas { get; set; }                    
        public string Objetivo { get; set; } = string.Empty;       
        public List<string> Temas { get; set; } = new List<string>();         
        public List<string> Dificuldades { get; set; } = new List<string>();  
    }
}
