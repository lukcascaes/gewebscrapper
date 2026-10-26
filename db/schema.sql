-- =====================================================================
-- gewebscrapper — schema inicial (etapa 2)
-- Duas tabelas: "times" (quem é) e "classificacao" (como estava a tabela
-- num dado momento). Rodar uma vez para criar o banco.
-- =====================================================================

-- No SQLite as chaves estrangeiras vêm DESLIGADAS por padrão.
-- Esse PRAGMA vale só para a conexão atual, então o código Node também
-- precisa rodar isso toda vez que abrir o banco.
PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------------
-- times: um registro por clube. O nome do time aparece aqui UMA vez só.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS times (
    -- INTEGER PRIMARY KEY vira apelido do "rowid": o SQLite gera o número
    -- sozinho (1, 2, 3...) quando você não informa.
    id    INTEGER PRIMARY KEY,
    -- NOT NULL: time sem nome não faz sentido.
    -- UNIQUE: impede cadastrar "Flamengo" duas vezes a cada raspagem.
    nome  TEXT    NOT NULL UNIQUE
) STRICT;  -- STRICT: recusa um TEXT numa coluna INTEGER (SQLite 3.37+)

-- ---------------------------------------------------------------------
-- classificacao: uma "foto" da tabela do ge. Cada raspagem grava 20
-- linhas (uma por time) com o mesmo coletado_em.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS classificacao (
    id           INTEGER PRIMARY KEY,
    -- Chave estrangeira: aponta para times.id em vez de repetir o nome.
    -- Se o ge mudar a grafia do time, você corrige em um lugar só.
    time_id      INTEGER NOT NULL REFERENCES times(id),
    -- CHECK: regra de negócio dentro do banco. Posição 0 ou pontos
    -- negativos indicam bug no scraper, então o banco recusa.
    posicao      INTEGER NOT NULL CHECK (posicao >= 1),
    pontos       INTEGER NOT NULL CHECK (pontos >= 0),
    -- SQLite não tem tipo DATE: guardamos texto ISO-8601
    -- ('2026-10-26T23:00:00Z'), que ordena certo com ORDER BY.
    coletado_em  TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')),
    -- Na mesma raspagem, um time aparece uma vez só.
    UNIQUE (time_id, coletado_em)
) STRICT;

-- Índice para a consulta mais comum do bot: "me dá a raspagem mais recente".
CREATE INDEX IF NOT EXISTS idx_classificacao_coletado_em
    ON classificacao (coletado_em);
