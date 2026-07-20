# pnpm и corepack — как это работает в MN

Конспект разбора от 2026-07-20. Пункт 3 из [`learning-agenda.md`](./learning-agenda.md).

## pnpm

Пакетный менеджер (альтернатива npm и yarn). Два отличия, ради которых он выбран:

**Раскладка файлов.** npm копирует каждый пакет в каждый проект. pnpm хранит один
экземпляр в глобальном сторе (`~/.pnpm-store`) и расставляет жёсткие ссылки —
меньше места, быстрее повторная установка.

**Строгость.** В плоском `node_modules` у npm можно импортировать пакет, который ты
не объявлял — он попал туда как зависимость зависимости. Всё работает, пока верхний
пакет не перестанет его тянуть, и тогда падает без очевидной причины. pnpm показывает
только явно объявленное.

## corepack

Встроен в Node с 16-й версии. Читает поле `packageManager` и подтягивает ровно ту
версию пакетного менеджера:

```json
"packageManager": "pnpm@9.12.0"
```

`corepack enable` создаёт шимы `pnpm`/`yarn` в PATH. После этого `pnpm install`
всегда работает нужной версией — у тебя, у CI, у любого клона.

> Ставить pnpm глобально (`npm i -g pnpm`) не нужно: будет конфликтовать с шимом.

## Конфигурация в репозитории

| Файл | Что задаёт |
|---|---|
| `.nvmrc` | версия Node (20) |
| `package.json` → `packageManager` | версия pnpm (9.12.0) — её фиксирует corepack |
| `package.json` → `engines` | минимальная версия Node |
| `.npmrc` → `engine-strict=true` | падать, если Node не совпадает с `engines` |
| `pnpm-workspace.yaml` | какие папки — части монорепы (`apps/*`, `packages/*`) |

> `engine-strict` проверяет только `engines`. От запуска `npm install` вместо
> `pnpm install` он не защищает — это делает `packageManager` + corepack.

Отсюда порядок установки: `corepack enable`, затем `pnpm install`.

## Workspaces

`pnpm-workspace.yaml` объявляет каждую папку в `apps/*` и `packages/*` отдельным
пакетом. Ссылаются они друг на друга через протокол `workspace:` —
например, `apps/web/package.json`:

```json
"dependencies": {
  "@mn/shared": "workspace:*",
  "@mn/api-client": "workspace:*"
}
```

`workspace:*` — «брать из этой же репы, не из реестра npm». pnpm ставит симлинк на
`packages/shared/`. Правка в `packages/shared/src/index.ts` сразу видна в web и
mobile, без публикации и пересборки. Ради этого и заводилась монорепа.

## Команды

```bash
pnpm install                      # поставить всё по всем workspace
pnpm add -D husky -w              # в корень репы (-w = workspace root)
pnpm add zod --filter @mn/api     # в конкретный пакет
pnpm --filter @mn/web dev         # запустить скрипт в одном пакете
pnpm -r typecheck                 # рекурсивно во всех пакетах
pnpm dlx create-next-app          # разово запустить пакет, не устанавливая
pnpm exec tsc --noEmit            # запустить бинарник из node_modules
```

`--filter` — основной флаг при работе с монорепой.

## Где здесь Turborepo

pnpm ставит зависимости и запускает скрипты, но не знает про порядок и кэш.
Turborepo — слой сверху: `pnpm build` в корне вызывает `turbo run build`, тот строит
граф (сначала `shared`, потом зависящие от него `web` и `mobile`) и кэширует
результаты. Поэтому корневые скрипты выглядят как `"build": "turbo run build"`.
