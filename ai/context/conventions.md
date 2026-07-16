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
