using Microsoft.EntityFrameworkCore;
using quizzAPI.Models;

namespace quizzAPI.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<Quizz> Quizzes { get; set; }
        public DbSet<Pergunta> Perguntas { get; set; }
        public DbSet<Grupo> Grupos { get; set; }
        public DbSet<UsuarioGrupo> UsuariosGrupos { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // User
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            // Quizz
            modelBuilder.Entity<Quizz>(entity =>
            {
                entity.ToTable("Quizz");

                entity.Property(e => e.Temas)
                      .HasColumnType("text[]")
                      .IsRequired();

                entity.Property(e => e.NivelEscolar)
                      .HasMaxLength(100)
                      .IsRequired(false);

                entity.Property(e => e.Dificuldade)
                      .HasColumnType("text[]")
                      .IsRequired(false);

                entity.HasMany(q => q.Perguntas)
                      .WithOne(p => p.Quizz)
                      .HasForeignKey(p => p.QuizzId)
                      .OnDelete(DeleteBehavior.Cascade);
            });

            // Pergunta
            modelBuilder.Entity<Pergunta>(entity =>
            {
                entity.ToTable("Perguntas");

                entity.Property(e => e.PerguntaTexto)
                      .HasColumnType("text")
                      .IsRequired();

                entity.Property(e => e.AlternativaA)
                      .HasColumnType("text")
                      .IsRequired();

                entity.Property(e => e.AlternativaB)
                      .HasColumnType("text")
                      .IsRequired();

                entity.Property(e => e.AlternativaC)
                      .HasColumnType("text")
                      .IsRequired();

                entity.Property(e => e.AlternativaD)
                      .HasColumnType("text")
                      .IsRequired();

                entity.Property(e => e.RespostaCorreta)
                      .HasMaxLength(1)
                      .IsRequired();

                entity.Property(e => e.Justificativa)
                      .HasColumnType("text")
                      .IsRequired(false);

                entity.Property(e => e.NivelEscolar)
                      .HasMaxLength(50)
                      .IsRequired(false);

                entity.Property(e => e.Tema)
                      .HasMaxLength(100)
                      .IsRequired(false);

                entity.Property(e => e.Dificuldade)
                      .HasMaxLength(50)
                      .IsRequired(false);
            });

            // UsuarioGrupo
            modelBuilder.Entity<UsuarioGrupo>()
                .HasKey(ug => new { ug.UsuarioId, ug.GrupoId });

            modelBuilder.Entity<UsuarioGrupo>()
                .HasOne(ug => ug.User)
                .WithMany(u => u.Grupos)
                .HasForeignKey(ug => ug.UsuarioId);

            modelBuilder.Entity<UsuarioGrupo>()
                .HasOne(ug => ug.Grupo)
                .WithMany(g => g.Membros)
                .HasForeignKey(ug => ug.GrupoId);

            base.OnModelCreating(modelBuilder);
        }
    }
}
