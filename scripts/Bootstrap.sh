#!/usr/bin/env bash
#
# bootstrap-mn.sh — создаёт скелет монорепы MN (pnpm workspaces + Turborepo).
# Стек: TypeScript everywhere — backend (NestJS), web (Next.js), mobile (Expo/React Native).
#
# Использование:
#   ./bootstrap-mn.sh                       # создаст в ~/Personal/Projects/MN
#   ./bootstrap-mn.sh /path/to/dir          # создаст в указанной папке
#
# Скрипт идемпотентен для структуры: существующие файлы НЕ перезаписываются.

set -euo pipefail

TARGET_DIR="${1:-$HOME/Personal/Projects/MN}"

say()  { printf '\033[1;36m▸ %s\033[0m\n' "$*"; }
skip() { printf '  \033[2m· %s (уже есть, пропускаю)\033[0m\n' "$*"; }
made() { printf '  \033[0;32m+ %s\033[0m\n' "$*"; }

# writef PATH <<'EOF' ... EOF  — пишет файл только если его ещё нет
writef() {
  local path="$1"
  mkdir -p "$(dirname "$path")"
  if [ -e "$path" ]; then
    skip "$path"
    cat >/dev/null   # проглотить heredoc из stdin
  else
    cat > "$path"
    made "$path"
  fi
}

say "Целевая папка: $TARGET_DIR"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

# ── Каталоги ────────────────────────────────────────────────────────────────
say "Создаю структуру каталогов"
mkdir -p \
  apps/api/src \
  apps/web/src \
  apps/mobile/src \
  packages/shared/src \
  packages/api-client/src \
  packages/config \
  docs/adr \
  .github/workflows \
  .github/ISSUE_TEMPLATE

# ── Корневые конфиги ─────────────────────────────────────────────────────────
say "Корневые конфиги"

writef package.json <<'EOF'
{
  "name": "mn",
  "version": "0.0.0",
  "private": true,
  "packageManager": "pnpm@9.12.0",
  "engines": { "node": ">=20" },
  "scripts": {
    "build": "turbo run build",
    "dev": "turbo run dev",
    "lint": "turbo run lint",
    "test": "turbo run test",
    "typecheck": "turbo run typecheck",
    "format": "prettier --write \"**/*.{ts,tsx,js,jsx,json,md}\""
  },
  "devDependencies": {
    "prettier": "^3.3.3",
    "turbo": "^2.1.0",
    "typescript": "^5.6.2"
  }
}
EOF

writef pnpm-workspace.yaml <<'EOF'
packages:
  - "apps/*"
  - "packages/*"
EOF

writef turbo.json <<'EOF'
{
  "$schema": "https://turbo.build/schema.json",
  "ui": "tui",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "!.next/cache/**"]
    },
    "dev": { "cache": false, "persistent": true },
    "lint": {},
    "typecheck": { "dependsOn": ["^build"] },
    "test": { "dependsOn": ["^build"] }
  }
}
EOF

writef tsconfig.base.json <<'EOF'
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "lib": ["ES2022"],
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "composite": false,
    "noUncheckedIndexedAccess": true,
    "baseUrl": ".",
    "paths": {
      "@mn/shared": ["packages/shared/src/index.ts"],
      "@mn/api-client": ["packages/api-client/src/index.ts"]
    }
  }
}
EOF

writef .gitignore <<'EOF'
# deps
node_modules/
.pnpm-store/

# build
dist/
build/
.next/
out/
*.tsbuildinfo

# turbo
.turbo/

# env / secrets
.env
.env.*
!.env.example

# mobile / expo
.expo/
apps/mobile/ios/
apps/mobile/android/

# os / editor
.DS_Store
.idea/
.vscode/*
!.vscode/extensions.json
*.log
EOF

writef .nvmrc <<'EOF'
20
EOF

writef .npmrc <<'EOF'
# гарантированно нужен pnpm (Corepack)
engine-strict=true
EOF

writef .prettierrc <<'EOF'
{
  "semi": true,
  "singleQuote": true,
  "printWidth": 100,
  "trailingComma": "all"
}
EOF

writef .env.example <<'EOF'
# Скопируй в .env и заполни. Реальный .env в git НЕ коммитим.
NODE_ENV=development

# api
API_PORT=3001
DATABASE_URL=postgres://user:pass@localhost:5432/mn

# web
NEXT_PUBLIC_API_URL=http://localhost:3001
EOF

writef LICENSE <<'EOF'
MIT License

Copyright (c) 2026 Vadim B.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

writef README.md <<'EOF'
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

> ⚠️ Не коммить в `legal/` подписанные договоры с персональными данными и любые
> секреты. Держи там только шаблоны и публичные документы.
EOF

# ── docs ─────────────────────────────────────────────────────────────────────
say "Документы (планы / роадмап / архитектура)"

writef docs/roadmap.md <<'EOF'
# Роадмап MN

> Живой документ. Обновляй по мере движения. Статусы: 🔜 план · 🚧 в работе · ✅ готово

## Видение

_Одним абзацем: что за продукт, для кого, какую боль решает._

## Milestones

### M0 — Скелет и инфраструктура 🚧
- [x] Монорепа, тулинг, CI
- [ ] Базовый бэкенд (health-check, конфиг, БД)
- [ ] Заглушки web и mobile, которые ходят в api

### M1 — MVP
- [ ] _Ключевая фича 1_
- [ ] _Ключевая фича 2_
- [ ] Авторизация

### M2 — Публичная бета
- [ ] _..._

## Идеи / потом (icebox)
- _..._
EOF

writef docs/backlog.md <<'EOF'
# Бэклог

> Крупные задачи и эпики. Мелкие оперативные — в GitHub Issues.
> Формат: `[ ] #<issue> Название — короткий контекст`

## Now (делаем сейчас)
- [ ] Настроить БД и миграции в apps/api

## Next (ближайшее)
- [ ] _..._

## Later (потом)
- [ ] _..._
EOF

writef docs/architecture.md <<'EOF'
# Архитектура

## Обзор

```
mobile ─┐
        ├─▶ api (NestJS) ─▶ PostgreSQL
web  ───┘
        packages/shared      — общие типы/модели
        packages/api-client  — типизированный доступ к api
```

## Принципы
- Общие типы и контракты живут в `packages/shared` — единственный источник правды.
- Клиенты (web, mobile) не дублируют модели, а импортируют из `@mn/shared`.
- Бэкенд отдаёт API, клиент к нему — в `@mn/api-client`.

## Данные
_Схема БД, ключевые сущности — по мере появления._
EOF

writef docs/SETUP.md <<'EOF'
# Настройка и работа

## 0. Требования
- Node.js 20+ (`.nvmrc` = 20)
- pnpm через Corepack: `corepack enable`
- git

## 1. Первая настройка репозитория
```bash
cd ~/Personal/Projects/MN
git init -b main
git add .
git commit -m "chore: bootstrap monorepo skeleton"
git remote add origin git@github.com:Vadim-B52/MN.git   # или https://github.com/Vadim-B52/MN.git
git push -u origin main
```

## 2. Установка зависимостей
```bash
corepack enable
pnpm install
```

## 3. Добавление реальных приложений
Скелет содержит заглушки. Заменить их настоящими генераторами:

**Backend (NestJS):**
```bash
pnpm dlx @nestjs/cli new apps/api --skip-git --package-manager pnpm
```

**Web (Next.js):**
```bash
pnpm create next-app@latest apps/web --ts --eslint --app --no-src-dir --import-alias "@/*"
```

**Mobile (Expo):**
```bash
pnpm create expo-app apps/mobile
```

> После генерации проверь, что имена пакетов — `@mn/api`, `@mn/web`, `@mn/mobile`,
> и что они видят `@mn/shared` через workspace.

## 4. Ежедневная работа
```bash
pnpm dev                     # всё сразу
pnpm --filter web dev        # только web
pnpm lint && pnpm typecheck  # перед коммитом
```

## 5. Ведение задач
- Роадмап — `docs/roadmap.md`
- Крупные задачи — `docs/backlog.md`
- Оперативные задачи — GitHub Issues (шаблоны в `.github/ISSUE_TEMPLATE`)
- Доска — GitHub Projects (см. раздел в основном ответе)

## 6. Ветки и коммиты
- Ветки: `feat/…`, `fix/…`, `chore/…`
- Коммиты: Conventional Commits (`feat: …`, `fix: …`, `docs: …`)
- В `main` — только через PR (когда будешь готов включить branch protection).
EOF

writef docs/adr/0001-record-architecture-decisions.md <<'EOF'
# ADR 0001: Ведём Architecture Decision Records

- Статус: принято
- Дата: 2026-07-16

## Контекст
Нужен способ фиксировать важные технические решения и причины их принятия.

## Решение
Каждое значимое решение оформляем отдельным файлом `docs/adr/NNNN-title.md`
по шаблону: контекст → решение → последствия.

## Последствия
История решений видна в репозитории; новым участникам проще войти в контекст.
EOF

# ── packages ─────────────────────────────────────────────────────────────────
say "Общие пакеты"

writef packages/shared/package.json <<'EOF'
{
  "name": "@mn/shared",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "main": "src/index.ts",
  "types": "src/index.ts",
  "scripts": {
    "lint": "echo \"(shared) add eslint\"",
    "typecheck": "tsc --noEmit",
    "build": "echo \"(shared) source-only package\""
  },
  "devDependencies": { "typescript": "^5.6.2" }
}
EOF

writef packages/shared/tsconfig.json <<'EOF'
{
  "extends": "../../tsconfig.base.json",
  "include": ["src"]
}
EOF

writef packages/shared/src/index.ts <<'EOF'
// Общие типы и модели — единственный источник правды для web/mobile/api.
export interface HealthStatus {
  ok: boolean;
  version: string;
}

export const APP_NAME = 'MN' as const;
EOF

writef packages/api-client/package.json <<'EOF'
{
  "name": "@mn/api-client",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "main": "src/index.ts",
  "types": "src/index.ts",
  "scripts": {
    "lint": "echo \"(api-client) add eslint\"",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": { "@mn/shared": "workspace:*" },
  "devDependencies": { "typescript": "^5.6.2" }
}
EOF

writef packages/api-client/tsconfig.json <<'EOF'
{
  "extends": "../../tsconfig.base.json",
  "include": ["src"]
}
EOF

writef packages/api-client/src/index.ts <<'EOF'
import type { HealthStatus } from '@mn/shared';

export async function getHealth(baseUrl: string): Promise<HealthStatus> {
  const res = await fetch(`${baseUrl}/health`);
  return (await res.json()) as HealthStatus;
}
EOF

writef packages/config/package.json <<'EOF'
{
  "name": "@mn/config",
  "version": "0.0.0",
  "private": true,
  "main": "index.js"
}
EOF

writef packages/config/index.js <<'EOF'
// Место для общих конфигов (eslint/prettier/tsconfig presets).
module.exports = {};
EOF

# ── apps (заглушки) ──────────────────────────────────────────────────────────
say "Приложения (заглушки — заменяются генераторами, см. docs/SETUP.md)"

writef apps/api/package.json <<'EOF'
{
  "name": "@mn/api",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "echo \"(api) заглушка. Замени на NestJS — см. docs/SETUP.md\"",
    "build": "echo \"(api) заглушка\"",
    "lint": "echo \"(api) заглушка\"",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": { "@mn/shared": "workspace:*" },
  "devDependencies": { "typescript": "^5.6.2" }
}
EOF

writef apps/api/tsconfig.json <<'EOF'
{ "extends": "../../tsconfig.base.json", "include": ["src"] }
EOF

writef apps/api/src/main.ts <<'EOF'
import { APP_NAME } from '@mn/shared';
console.log(`${APP_NAME} api — заглушка. См. docs/SETUP.md, чтобы поставить NestJS.`);
EOF

writef apps/web/package.json <<'EOF'
{
  "name": "@mn/web",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "echo \"(web) заглушка. Замени на Next.js — см. docs/SETUP.md\"",
    "build": "echo \"(web) заглушка\"",
    "lint": "echo \"(web) заглушка\"",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": { "@mn/shared": "workspace:*", "@mn/api-client": "workspace:*" },
  "devDependencies": { "typescript": "^5.6.2" }
}
EOF

writef apps/web/tsconfig.json <<'EOF'
{ "extends": "../../tsconfig.base.json", "include": ["src"] }
EOF

writef apps/web/src/index.ts <<'EOF'
import { APP_NAME } from '@mn/shared';
console.log(`${APP_NAME} web — заглушка. См. docs/SETUP.md.`);
EOF

writef apps/mobile/package.json <<'EOF'
{
  "name": "@mn/mobile",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "start": "echo \"(mobile) заглушка. Замени на Expo — см. docs/SETUP.md\"",
    "lint": "echo \"(mobile) заглушка\"",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": { "@mn/shared": "workspace:*", "@mn/api-client": "workspace:*" },
  "devDependencies": { "typescript": "^5.6.2" }
}
EOF

writef apps/mobile/tsconfig.json <<'EOF'
{ "extends": "../../tsconfig.base.json", "include": ["src"] }
EOF

writef apps/mobile/src/index.ts <<'EOF'
import { APP_NAME } from '@mn/shared';
console.log(`${APP_NAME} mobile — заглушка. См. docs/SETUP.md.`);
EOF

# ── GitHub: CI + шаблоны ─────────────────────────────────────────────────────
say "GitHub: CI и шаблоны"

writef .github/workflows/ci.yml <<'EOF'
name: CI
on:
  push:
    branches: [main]
  pull_request:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm lint
      - run: pnpm typecheck
      - run: pnpm test
EOF

writef .github/ISSUE_TEMPLATE/feature.md <<'EOF'
---
name: Feature / задача
about: Новая фича или задача
labels: enhancement
---

## Что нужно
_Кратко и по делу._

## Зачем / критерии готовности
- [ ] ...

## Заметки
EOF

writef .github/ISSUE_TEMPLATE/bug.md <<'EOF'
---
name: Bug / баг
about: Что-то сломалось
labels: bug
---

## Что происходит
## Как воспроизвести
## Ожидаемое поведение
## Окружение (web/mobile/api, версия)
EOF

writef .github/pull_request_template.md <<'EOF'
## Что меняем
## Как проверить
## Чеклист
- [ ] `pnpm lint` и `pnpm typecheck` зелёные
- [ ] Обновил docs/roadmap.md или docs/backlog.md при необходимости
EOF

writef .vscode/extensions.json <<'EOF'
{
  "recommendations": [
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint"
  ]
}
EOF

# ── Бизнес-разделы: strategy / design / legal / marketing ────────────────────
say "Бизнес-разделы (strategy / design / legal / marketing)"
mkdir -p strategy design/assets design/ux legal/contracts marketing

# strategy ------------------------------------------------------------------
writef strategy/README.md <<'EOF'
# Strategy

Бизнес-сторона проекта: зачем он существует, как зарабатывает и куда движется.

- `business-model.md` — модель (lean canvas): для кого, ценность, монетизация.
- `market.md` — рынок, сегменты, конкуренты, отличие.
- `exit-strategy.md` — сценарии выхода и что к ним ведёт.
- `metrics.md` — north star и ключевые метрики.
EOF

writef strategy/business-model.md <<'EOF'
# Бизнес-модель (Lean Canvas)

| Блок | Заметки |
|---|---|
| **Проблема** | 1–3 главные боли |
| **Сегменты клиентов** | Кто именно (и кто early adopters) |
| **Уникальное предложение** | Одной фразой, почему вы |
| **Решение** | Топ-3 фичи |
| **Каналы** | Как доходим до людей |
| **Потоки доходов** | Как берём деньги (подписка / комиссия / …) |
| **Структура затрат** | Основные расходы |
| **Ключевые метрики** | Что меряем |
| **Нечестное преимущество** | Что не скопировать |
EOF

writef strategy/market.md <<'EOF'
# Рынок и конкуренты

## Размер рынка
- TAM / SAM / SOM — оценки и источники.

## Сегменты
- ...

## Конкуренты
| Кто | Что делает | В чём мы лучше/иначе |
|---|---|---|
| ... | ... | ... |
EOF

writef strategy/exit-strategy.md <<'EOF'
# Exit strategy

> Как проект может «завершиться» успехом. Полезно держать в голове с ранних дней:
> это влияет на то, чей продукт строим, какие метрики важны и с кем дружить.

## Возможные сценарии
- **Стратегическое поглощение (acquisition)** — кого продукт усилит; список
  потенциальных покупателей и почему им это интересно.
- **Acqui-hire** — покупка ради команды/технологии.
- **Слияние (merger)** — с кем синергия.
- **IPO** — при большом масштабе; какие показатели нужны.
- **Lifestyle / cash-cow** — не продаём, живём на прибыль. Тоже валидный выход.
- **Закрытие / sunset** — как аккуратно свернуть (данные, обязательства).

## Потенциальные покупатели / партнёры
| Компания | Почему им интересно | Что нужно, чтобы стать интересными |
|---|---|---|
| ... | ... | ... |

## Триггеры и вехи
- Что должно произойти (выручка, аудитория, доля рынка), чтобы выход стал реальным.

## Чистота для сделки (важно с самого начала)
- Понятная структура владения (cap table), закрытые права на ИС (см. `legal/ip.md`),
  чистые лицензии зависимостей (`legal/licenses.md`), порядок в договорах.
EOF

writef strategy/metrics.md <<'EOF'
# Метрики

## North Star Metric
- _Одна метрика, отражающая ценность для пользователя._

## Ключевые (по воронке AARRR)
- Acquisition · Activation · Retention · Revenue · Referral — что и как меряем.
EOF

# design --------------------------------------------------------------------
writef design/README.md <<'EOF'
# Design

Бренд, продуктовый дизайн и UX.

- `brand.md` — имя, логотип, цвета, tone of voice.
- `design-system.md` — токены, компоненты, правила.
- `ux/` — пользовательские сценарии, вайрфреймы, заметки исследований.
- `assets/` — исходники и экспорт (логотипы, иконки, изображения).

> Тяжёлые бинарные ассеты (Figma-экспорт, PSD, видео) лучше хранить через **Git LFS**
> или ссылками на Figma/Drive, чтобы не раздувать репозиторий.
EOF

writef design/brand.md <<'EOF'
# Бренд

- **Название:** MN
- **Суть одной фразой:** ...
- **Tone of voice:** ...
- **Логотип:** файл в `assets/`
- **Палитра:** primary `#`, secondary `#`, ...
- **Шрифты:** ...
EOF

writef design/design-system.md <<'EOF'
# Дизайн-система

## Токены
- Цвета, типографика, отступы, радиусы, тени.

## Компоненты
- Кнопки, поля, карточки — состояния и правила использования.

> Код общих UI-компонентов может жить в `packages/ui` (создать при необходимости),
> чтобы web и mobile использовали одну систему.
EOF

writef design/ux/README.md <<'EOF'
# UX

Сюда: карты пользовательских сценариев (user flows), вайрфреймы,
результаты интервью и юзабилити-тестов, ключевые решения по UX.
EOF

writef design/assets/.gitkeep <<'EOF'
EOF

# legal ---------------------------------------------------------------------
writef legal/README.md <<'EOF'
# Legal

Юридические документы и артефакты.

- `terms-of-service.md` — условия использования (черновик).
- `privacy-policy.md` — политика конфиденциальности (черновик).
- `licenses.md` — лицензии сторонних зависимостей.
- `ip.md` — интеллектуальная собственность, товарные знаки.
- `compliance.md` — GDPR / 152-ФЗ и прочее.
- `contracts/` — шаблоны договоров (NDA, подрядчики).

> ⚠️ **Дисклеймер:** это шаблоны и заметки, а не юридическая консультация.
> Перед публикацией ToS/Privacy покажи их юристу.
> ⚠️ Не коммить подписанные договоры с персональными данными и любые секреты.
EOF

writef legal/terms-of-service.md <<'EOF'
# Terms of Service (черновик)

_Черновик. Проверить у юриста перед публикацией._

1. Общие положения
2. Аккаунт и доступ
3. Допустимое использование
4. Оплата и возвраты (если применимо)
5. Ответственность и отказ от гарантий
6. Прекращение
7. Изменения условий
8. Контакты
EOF

writef legal/privacy-policy.md <<'EOF'
# Privacy Policy (черновик)

_Черновик. Проверить у юриста; учесть GDPR и 152-ФЗ, если применимо._

- Какие данные собираем и зачем
- Правовые основания обработки
- Хранение и сроки
- Передача третьим лицам (аналитика, хостинг)
- Права пользователя (доступ, удаление)
- Cookies
- Контакт ответственного за данные
EOF

writef legal/licenses.md <<'EOF'
# Лицензии

## Лицензия проекта
- См. `LICENSE` в корне (по умолчанию MIT).

## Сторонние зависимости
- Периодически проверять совместимость лицензий (например, `pnpm licenses list`).
- Избегать копилефт-лицензий (GPL) в проприетарных частях, если это проблема.
EOF

writef legal/ip.md <<'EOF'
# Интеллектуальная собственность

- **Владелец кода/ИС:** ...
- **Товарный знак «MN»:** статус регистрации, классы, юрисдикции.
- **Домены:** список и даты продления.
- **Вклад подрядчиков:** права передаются проекту (см. договоры в `contracts/`).
EOF

writef legal/compliance.md <<'EOF'
# Compliance

- GDPR (EU), 152-ФЗ (РФ), CCPA (US) — что применимо и что нужно сделать.
- Обработка ПДн: где хранится, кто имеет доступ.
- Возрастные ограничения / согласия.
EOF

writef legal/contracts/README.md <<'EOF'
# Contracts

Только шаблоны (NDA, договор подряда, оферта). Подписанные документы с
персональными данными сюда НЕ коммитим — храни их вне репозитория.
EOF

# marketing -----------------------------------------------------------------
writef marketing/README.md <<'EOF'
# Marketing

- `positioning.md` — позиционирование и месседжинг.
- `go-to-market.md` — план вывода на рынок и каналы.
- `content-plan.md` — контент и календарь.
- `launch-checklist.md` — чеклист запуска.
EOF

writef marketing/positioning.md <<'EOF'
# Позиционирование

- **Для кого (ICP):** идеальный клиент.
- **Категория:** к чему относимся в голове пользователя.
- **Ценностное предложение:** «Для [кого], которые [боль], MN — это [что], которое [ценность], в отличие от [альтернативы]».
- **Ключевые сообщения:** 3 тезиса.
EOF

writef marketing/go-to-market.md <<'EOF'
# Go-to-Market

## Каналы
- Органика (SEO, контент), сообщества, партнёрства, платный трафик, сарафан.

## Гипотезы каналов
| Канал | Гипотеза | Как проверяем | Бюджет/усилия |
|---|---|---|---|
| ... | ... | ... | ... |

## Первые 100 пользователей
- Где именно их взять руками.
EOF

writef marketing/content-plan.md <<'EOF'
# Контент-план

| Дата | Формат | Тема | Канал | Статус |
|---|---|---|---|---|
| ... | пост/видео/статья | ... | ... | 🔜 |
EOF

writef marketing/launch-checklist.md <<'EOF'
# Чеклист запуска

- [ ] Лендинг готов и собирает лиды
- [ ] Аналитика подключена
- [ ] ToS и Privacy опубликованы (`legal/`)
- [ ] Онбординг в продукте работает
- [ ] Материалы для соцсетей / Product Hunt готовы
- [ ] Поддержка / канал обратной связи есть
EOF

# ── AI: скиллы, контекст, память для агентов ─────────────────────────────────
say "AI-инфраструктура (скиллы / контекст / память)"
mkdir -p ai/skills/_template ai/agents ai/context ai/prompts ai/memory/dumps

# Корневые точки входа для агентов ------------------------------------------
writef AGENTS.md <<'EOF'
# AGENTS.md — как AI-агенты работают с этой репой

Этот файл читает любой AI-агент (Claude, Cursor, Copilot и т.п.) в начале работы.
Цель — чтобы контекст жил в репозитории и базе, а не только в одном чате.

## С чего начать (порядок чтения)
1. `README.md` — что за проект и структура.
2. `ai/context/overview.md` — суть продукта и текущее состояние.
3. `ai/context/conventions.md` — правила кода и коммитов.
4. `ai/context/glossary.md` — термины предметной области.
5. `ai/context/decisions-log.md` + `docs/adr/` — принятые решения.

## Где что
- **Скиллы** (переиспользуемые инструкции) → `ai/skills/`. Шаблон: `ai/skills/_template/`.
- **Роли агентов** → `ai/agents/`.
- **Системные промпты** → `ai/prompts/`.
- **Долгая память**:
  - версионируемая (в git) → `ai/context/`;
  - queryable / для дампа контекста → БД по схеме `ai/memory/schema.sql`.

## Правила для агента
- Значимые решения фиксируй в `docs/adr/` и/или `ai/context/decisions-log.md`.
- Новые устойчивые факты о проекте клади в память (`ai/context/` или таблицу `ai_memory`).
- Не коммить секреты; используй `.env` (см. `.env.example`).
- Перед PR прогоняй `pnpm lint && pnpm typecheck`.
EOF

writef CLAUDE.md <<'EOF'
# CLAUDE.md

Инструкции для Claude Code — см. общий файл **[AGENTS.md](./AGENTS.md)**.
Всё, что описано там, применимо и здесь. Держим один источник правды в `AGENTS.md`,
а этот файл существует только потому, что некоторые инструменты ищут `CLAUDE.md`.
EOF

# ai/README ------------------------------------------------------------------
writef ai/README.md <<'EOF'
# ai/

AI-инфраструктура проекта: скиллы, контекст и память для агентов.

- `skills/` — переиспользуемые скиллы (папка + `SKILL.md` с фронтматтером).
- `agents/` — описания ролей агентов (что делает, чем пользуется).
- `context/` — долгая память, которая версионируется в git (читается агентами).
- `prompts/` — системные промпты и шаблоны.
- `memory/` — схема БД (`schema.sql`) и снапшоты (`dumps/`) для дампа контекста
  из чатов в базу, чтобы потом искать по нему (в т.ч. семантически).

Точка входа для агента — `../AGENTS.md`.
EOF

# skills ---------------------------------------------------------------------
writef ai/skills/README.md <<'EOF'
# Skills

Каждый скилл — папка с файлом `SKILL.md`. В начале файла — YAML-фронтматтер
с `name` и `description` (по нему инструмент решает, когда скилл применять).
Рядом можно класть вспомогательные файлы (скрипты, шаблоны, `references/`).

Как добавить: скопируй `_template/` в `ai/skills/<имя-скилла>/` и заполни.
EOF

writef ai/skills/_template/SKILL.md <<'EOF'
---
name: skill-template
description: Кратко — что делает скилл и КОГДА его применять (триггеры/ключевые слова). Именно по description агент решает, брать ли скилл.
---

# <Название скилла>

## Когда использовать
- Список ситуаций/триггеров.

## Шаги
1. ...
2. ...

## Примеры
- Вход → ожидаемый результат.

## Файлы (опционально)
- `references/…`, скрипты и т.п.
EOF

writef ai/skills/_template/references/.gitkeep <<'EOF'
EOF

# agents ---------------------------------------------------------------------
writef ai/agents/README.md <<'EOF'
# Agents

Описания ролей агентов — по одному файлу на роль. Пример полей:

```
# <Роль>
- Назначение: что делает.
- Инструменты: чем пользуется (репо, БД, внешние API).
- Вход/выход: что получает и что возвращает.
- Ограничения: чего не делает.
```
EOF

writef ai/agents/example-backend-agent.md <<'EOF'
# Backend Agent (пример)

- **Назначение:** помогает с кодом в `apps/api` (NestJS).
- **Инструменты:** файлы репозитория, миграции БД, тесты.
- **Вход/выход:** задача из GitHub Issue → PR с изменениями.
- **Ограничения:** не трогает `legal/` и секреты; не мёржит без ревью.
EOF

# prompts --------------------------------------------------------------------
writef ai/prompts/system.md <<'EOF'
# Системный промпт (базовый)

Ты — инженер-ассистент проекта MN. Работаешь в монорепе (см. AGENTS.md).
Принципы:
- Сначала читаешь `ai/context/`, потом действуешь.
- Пишешь на TypeScript, соблюдаешь `ai/context/conventions.md`.
- Значимые решения записываешь в `docs/adr/`.
- Не выдумываешь факты о проекте — сверяешься с контекстом и памятью.
EOF

# context (версионируемая долгая память) -------------------------------------
writef ai/context/overview.md <<'EOF'
# Overview

- **Продукт:** MN — _одно предложение о сути._
- **Стадия:** ранняя (скелет).
- **Клиенты:** web (Next.js), mobile (Expo/RN), backend (NestJS).
- **Текущий фокус:** _что делаем прямо сейчас._

_Держи этот файл коротким и актуальным — это первое, что читает агент._
EOF

writef ai/context/conventions.md <<'EOF'
# Conventions

## Код
- TypeScript, strict. Общие типы — только из `@mn/shared`.
- Форматирование — Prettier (`.prettierrc`), линт — eslint.

## Git
- Ветки: `feat/…`, `fix/…`, `chore/…`.
- Коммиты: Conventional Commits.
- В `main` — через PR; CI должен быть зелёным.

## Структура
- Приложения → `apps/*`, общий код → `packages/*`.
EOF

writef ai/context/glossary.md <<'EOF'
# Glossary

Термины предметной области — чтобы агенты и люди понимали слова одинаково.

| Термин | Значение |
|---|---|
| ... | ... |
EOF

writef ai/context/decisions-log.md <<'EOF'
# Decisions log

Короткий журнал решений (развёрнутые — в `docs/adr/`).

| Дата | Решение | Почему |
|---|---|---|
| 2026-07-16 | Монорепа на pnpm+Turborepo, TS everywhere | Шаринг кода между web/mobile/api |
EOF

# memory (БД для дампа контекста) --------------------------------------------
writef ai/memory/README.md <<'EOF'
# Memory (БД)

Долгая, queryable память: дампим контекст из чатов/сессий в базу, чтобы он не
терялся в одном чате и был доступен другим агентам, в т.ч. семантическим поиском.

- `schema.sql` — схема для PostgreSQL. Для эмбеддингов используется **pgvector**.
- `dumps/` — ручные снапшоты (JSON) на случай оффлайн-экспорта.

## Как применить схему
```bash
# нужен PostgreSQL с расширением pgvector
psql "$DATABASE_URL" -f ai/memory/schema.sql
```

## Модель данных (коротко)
- `ai_sessions` — сессия/чат/запуск агента.
- `ai_messages` — сообщения внутри сессии (сырой дамп контекста).
- `ai_memory` — атомарные факты/решения/предпочтения с эмбеддингом для поиска.

Размерность вектора (`vector(1536)`) подставь под свою модель эмбеддингов.
EOF

writef ai/memory/schema.sql <<'EOF'
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
EOF

writef ai/memory/dumps/.gitkeep <<'EOF'
EOF

say "Готово. Скелет создан в: $TARGET_DIR"
echo
echo "Дальше:"
echo "  cd \"$TARGET_DIR\""
echo "  git init -b main && git add . && git commit -m 'chore: bootstrap monorepo skeleton'"
echo "  git remote add origin https://github.com/Vadim-B52/MN.git"
echo "  git push -u origin main"
echo "  corepack enable && pnpm install"