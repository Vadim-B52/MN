-- MN AI memory store (PostgreSQL).
-- Требуется расширение pgvector для семантического поиска по памяти.

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS vector;

-- Сессия/чат/запуск агента
CREATE TABLE IF NOT EXISTS ai_sessions (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  agent       TEXT        NOT NULL,          -- какой агент/инструмент
  title       TEXT,
  started_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  ended_at    TIMESTAMPTZ,
  metadata    JSONB       NOT NULL DEFAULT '{}'
);

-- Сообщения/шаги внутри сессии — сырой дамп контекста
CREATE TABLE IF NOT EXISTS ai_messages (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id  UUID        NOT NULL REFERENCES ai_sessions(id) ON DELETE CASCADE,
  role        TEXT        NOT NULL,          -- user | assistant | tool | system
  content     TEXT        NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  metadata    JSONB       NOT NULL DEFAULT '{}'
);
CREATE INDEX IF NOT EXISTS idx_ai_messages_session ON ai_messages (session_id, created_at);

-- Долгая память: факты/решения/предпочтения, доступные любому агенту
CREATE TABLE IF NOT EXISTS ai_memory (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  kind        TEXT        NOT NULL DEFAULT 'note',  -- note | decision | fact | preference
  scope       TEXT,                                 -- 'api' | 'marketing' | 'global' | ...
  content     TEXT        NOT NULL,
  source      TEXT,                                 -- откуда (session id, файл, человек)
  embedding   vector(1536),                         -- подставь размерность своей модели
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_ai_memory_scope ON ai_memory (scope, kind);
-- Индекс для семантического поиска (косинусное расстояние)
CREATE INDEX IF NOT EXISTS idx_ai_memory_embedding
  ON ai_memory USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
