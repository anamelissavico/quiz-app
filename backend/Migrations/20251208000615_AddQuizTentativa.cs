using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace quizzAPI.Migrations
{
    /// <inheritdoc />
    public partial class AddQuizTentativa : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Nome = table.Column<string>(type: "text", nullable: false),
                    Email = table.Column<string>(type: "text", nullable: false),
                    SenhaHash = table.Column<string>(type: "text", nullable: false),
                    Pontos = table.Column<int>(type: "integer", nullable: false),
                    DataCriacao = table.Column<DateTime>(type: "timestamp without time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Grupos",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Nome = table.Column<string>(type: "text", nullable: false),
                    Descricao = table.Column<string>(type: "text", nullable: false),
                    CodigoAcesso = table.Column<string>(type: "text", nullable: false),
                    CriadorId = table.Column<int>(type: "integer", nullable: false),
                    DataCriacao = table.Column<DateTime>(type: "timestamp without time zone", nullable: false),
                    Icon = table.Column<string>(type: "text", nullable: false),
                    Color = table.Column<string>(type: "text", nullable: false),
                    NumeroMembros = table.Column<int>(type: "integer", nullable: false),
                    NumeroQuizzes = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Grupos", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Grupos_Users_CriadorId",
                        column: x => x.CriadorId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Quizz",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Titulo = table.Column<string>(type: "text", nullable: true),
                    NivelEscolar = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    NumeroPerguntas = table.Column<int>(type: "integer", nullable: false),
                    Objetivo = table.Column<string>(type: "text", nullable: true),
                    Dificuldade = table.Column<List<string>>(type: "text[]", nullable: true),
                    Temas = table.Column<List<string>>(type: "text[]", nullable: false),
                    Referencia = table.Column<string>(type: "text", nullable: false),
                    GrupoId = table.Column<int>(type: "integer", nullable: true),
                    DataInicio = table.Column<DateTime>(type: "timestamp without time zone", nullable: true),
                    DataFim = table.Column<DateTime>(type: "timestamp without time zone", nullable: true),
                    CriadorId = table.Column<int>(type: "integer", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Quizz", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Quizz_Grupos_GrupoId",
                        column: x => x.GrupoId,
                        principalTable: "Grupos",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Quizz_Users_CriadorId",
                        column: x => x.CriadorId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "UsuariosGrupos",
                columns: table => new
                {
                    UsuarioId = table.Column<int>(type: "integer", nullable: false),
                    GrupoId = table.Column<int>(type: "integer", nullable: false),
                    DataEntrada = table.Column<DateTime>(type: "timestamp without time zone", nullable: false),
                    Pontos = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UsuariosGrupos", x => new { x.UsuarioId, x.GrupoId });
                    table.ForeignKey(
                        name: "FK_UsuariosGrupos_Grupos_GrupoId",
                        column: x => x.GrupoId,
                        principalTable: "Grupos",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_UsuariosGrupos_Users_UsuarioId",
                        column: x => x.UsuarioId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Perguntas",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    PerguntaTexto = table.Column<string>(type: "text", nullable: false),
                    AlternativaA = table.Column<string>(type: "text", nullable: false),
                    AlternativaB = table.Column<string>(type: "text", nullable: false),
                    AlternativaC = table.Column<string>(type: "text", nullable: false),
                    AlternativaD = table.Column<string>(type: "text", nullable: false),
                    RespostaCorreta = table.Column<string>(type: "character varying(1)", maxLength: 1, nullable: false),
                    Justificativa = table.Column<string>(type: "text", nullable: true),
                    NivelEscolar = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    Tema = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    Dificuldade = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    QuizzId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Perguntas", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Perguntas_Quizz_QuizzId",
                        column: x => x.QuizzId,
                        principalTable: "Quizz",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "QuizTentativas",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserId = table.Column<int>(type: "integer", nullable: false),
                    QuizzId = table.Column<int>(type: "integer", nullable: false),
                    Acertos = table.Column<int>(type: "integer", nullable: false),
                    TotalPerguntas = table.Column<int>(type: "integer", nullable: false),
                    PontosObtidos = table.Column<int>(type: "integer", nullable: false),
                    PontosTotal = table.Column<int>(type: "integer", nullable: false),
                    Percentual = table.Column<double>(type: "double precision", nullable: false),
                    DataResposta = table.Column<DateTime>(type: "timestamp", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_QuizTentativas", x => x.Id);
                    table.ForeignKey(
                        name: "FK_QuizTentativas_Quizz_QuizzId",
                        column: x => x.QuizzId,
                        principalTable: "Quizz",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_QuizTentativas_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "RespostasQuizz",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    QuizTentativaId = table.Column<int>(type: "integer", nullable: false),
                    PerguntaId = table.Column<int>(type: "integer", nullable: false),
                    AlternativaEscolhida = table.Column<string>(type: "character varying(1)", maxLength: 1, nullable: false),
                    Correta = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RespostasQuizz", x => x.Id);
                    table.ForeignKey(
                        name: "FK_RespostasQuizz_Perguntas_PerguntaId",
                        column: x => x.PerguntaId,
                        principalTable: "Perguntas",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_RespostasQuizz_QuizTentativas_QuizTentativaId",
                        column: x => x.QuizTentativaId,
                        principalTable: "QuizTentativas",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Grupos_CriadorId",
                table: "Grupos",
                column: "CriadorId");

            migrationBuilder.CreateIndex(
                name: "IX_Perguntas_QuizzId",
                table: "Perguntas",
                column: "QuizzId");

            migrationBuilder.CreateIndex(
                name: "IX_QuizTentativas_QuizzId",
                table: "QuizTentativas",
                column: "QuizzId");

            migrationBuilder.CreateIndex(
                name: "IX_QuizTentativas_UserId",
                table: "QuizTentativas",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Quizz_CriadorId",
                table: "Quizz",
                column: "CriadorId");

            migrationBuilder.CreateIndex(
                name: "IX_Quizz_GrupoId",
                table: "Quizz",
                column: "GrupoId");

            migrationBuilder.CreateIndex(
                name: "IX_RespostasQuizz_PerguntaId",
                table: "RespostasQuizz",
                column: "PerguntaId");

            migrationBuilder.CreateIndex(
                name: "IX_RespostasQuizz_QuizTentativaId",
                table: "RespostasQuizz",
                column: "QuizTentativaId");

            migrationBuilder.CreateIndex(
                name: "IX_Users_Email",
                table: "Users",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_UsuariosGrupos_GrupoId",
                table: "UsuariosGrupos",
                column: "GrupoId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "RespostasQuizz");

            migrationBuilder.DropTable(
                name: "UsuariosGrupos");

            migrationBuilder.DropTable(
                name: "Perguntas");

            migrationBuilder.DropTable(
                name: "QuizTentativas");

            migrationBuilder.DropTable(
                name: "Quizz");

            migrationBuilder.DropTable(
                name: "Grupos");

            migrationBuilder.DropTable(
                name: "Users");
        }
    }
}
