# MN

Монорепа проекта: планы, задачи, роадмап, клиенты (web + mobile) и бэкенд в одном месте.

## Стек

- **Тулинг монорепы:** pnpm workspaces + Turborepo
- **Backend:** `apps/api` — NestJS (TypeScript)
- **Web:** `apps/web` — Next.js (React, TypeScript)
- **Mobile:** `apps/mobile` — Expo / React Native (TypeScript)
- **Общий код:** `packages/*` — типы, API-клиент, конфиги

## Структура

```
MN/
├── apps/
│   ├── api/          # бэкенд (NestJS)
│   ├── web/          # веб-клиент (Next.js)
│   └── mobile/       # мобильный клиент (Expo / React Native)
├── packages/
│   ├── shared/       # общие типы, модели, утилиты (используются всеми)
│   ├── api-client/   # типизированный клиент к api (web + mobile)
│   └── config/       # базовые конфиги (tsconfig, eslint, prettier)
├── docs/             # планы, роадмап, архитектура, ADR (решения)
│   ├── roadmap.md
│   ├── architecture.md
│   ├── backlog.md
│   └── adr/          # Architecture Decision Records
├── strategy/         # видение, бизнес-модель, exit strategy, метрики
├── design/           # бренд, дизайн-система, UX, ассеты
├── legal/            # ToS, privacy, лицензии, ИС, compliance
├── marketing/        # позиционирование, go-to-market, контент, лаунч
├── ai/               # скиллы, контекст и память для агентов
│   ├── skills/       # переиспользуемые скиллы (SKILL.md)
│   ├── agents/       # роли и описания агентов
│   ├── context/      # версионируемая долгая память (в git)
│   ├── prompts/      # системные промпты и шаблоны
│   └── memory/       # схема БД для дампа контекста (schema.sql)
├── AGENTS.md         # точка входа для любого AI-агента
├── CLAUDE.md         # то же для Claude Code (симлинк-по-смыслу)
├── .github/          # CI + шаблоны issues/PR
├── package.json      # корень (pnpm workspaces)
├── pnpm-workspace.yaml
├── turbo.json
└── tsconfig.base.json
```

## Быстрый старт

```bash
corepack enable          # включает pnpm нужной версии
pnpm install
pnpm dev                 # запустит dev во всех apps через turbo
```

Отдельное приложение:

```bash
pnpm --filter web dev
pnpm --filter api dev
pnpm --filter mobile start
```

## Куда что писать

- **Планы и роадмап** → `docs/roadmap.md`
- **Бэклог задач** → `docs/backlog.md` (крупное) + GitHub Issues (оперативное)
- **Решения по архитектуре** → `docs/adr/` (по одному файлу на решение)
- **Стратегия, бизнес-модель, exit** → `strategy/`
- **Дизайн, бренд, UX** → `design/`
- **Юридическое (ToS, privacy, ИС)** → `legal/`
- **Маркетинг, go-to-market** → `marketing/`
- **Скиллы, контекст и память для AI-агентов** → `ai/` (входная точка — `AGENTS.md`)

Подробности по настройке — в `docs/SETUP.md`.

**Процесс и безопасность:**
- `docs/branch-protection.md` — защита `main`, работа через PR
- `docs/agent-security.md` — как ограничить AI-агента (токен, песочница)
- `AGENTS.md` — правила для самих агентов

> ⚠️ Не коммить в `legal/` подписанные договоры с персональными данными и любые
> секреты. Держи там только шаблоны и публичные документы.
