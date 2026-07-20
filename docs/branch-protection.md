# Branch protection для `main`

Цель: изменения в `main` попадают только через Pull Request, с обязательным
просмотром диффа в веб-интерфейсе — в том числе для владельца.

## Важная оговорка: нельзя заапрувить свой PR

GitHub не позволяет апрувить собственный Pull Request. В соло-репозитории
`required_approving_review_count: 1` = ты сам себя заблокируешь: PR будет требовать
апрув, который никто не может поставить.

Поэтому в конфиге ниже стоит **`required_approving_review_count: 0`**.
PR всё равно обязателен, дифф ты всё равно смотришь в вебе и жмёшь Merge сам —
просто без формального апрува.

Если нужен именно обязательный апрув — заведи отдельный аккаунт для агента
(Уровень 2 в [`agent-security.md`](./agent-security.md)) и тогда ставь `1`.

## Ограничение бесплатного плана

На **GitHub Free** branch protection и rulesets для **приватных** репозиториев
недоступны — попытка вернёт:

```
403: Upgrade to GitHub Pro or make this repository public
```

Три варианта:

1. **GitHub Pro** (~$4/мес) — приватная репа + защита работает;
2. **остаться на Free, репа приватная** — серверной защиты нет,
   остаётся `.husky/pre-push` + урезанный токен + ручной мёрж;
3. **сделать репу публичной** — защита работает бесплатно.

> Текущее состояние MN: репозиторий **публичный**, серверная защита включена.

## Настройка через `gh`

```bash
OWNER=Vadim-B52
REPO=MN

gh api --method PUT "repos/$OWNER/$REPO/branches/main/protection" \
  -H "Accept: application/vnd.github+json" --input - <<'JSON'
{
  "required_status_checks": null,
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "required_approving_review_count": 0
  },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true
}
JSON
```

Что включает:

- `enforce_admins: true` — правила действуют и на владельца (иначе смысла мало);
- `required_linear_history` — без merge-коммитов, история читаемая;
- `allow_force_pushes: false`, `allow_deletions: false` — `main` не переписать и не удалить;
- `required_conversation_resolution` — незакрытые комментарии блокируют мёрж.

**Проверить текущее состояние:**

```bash
gh api "repos/$OWNER/$REPO/branches/main/protection" | jq
```

## Рабочий процесс

```bash
git checkout main && git pull
git checkout -b feat/название
# ... правки ...
git add -A && git commit -m "feat: описание"
git push -u origin feat/название
gh pr create --fill --base main
```

Дальше — открыть PR в вебе, посмотреть дифф, нажать **Merge**.
Мёржит всегда владелец, не агент (см. `AGENTS.md`).
