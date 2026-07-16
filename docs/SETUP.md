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
