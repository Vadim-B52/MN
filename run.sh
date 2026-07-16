cd ~/Personal/Projects/MN
git checkout main && git pull          # если PR с guardrails уже смёржен
git checkout -b chore/husky-hooks

# 1) поставить husky и включить авто-активацию хуков на install
pnpm add -D husky -w
pnpm exec husky init                    # добавит "prepare": "husky" и создаст .husky/

# 2) наш pre-push хук (блок push в main)
cat > .husky/pre-push <<'HOOK'
# Блокирует прямой push в main. Изменения в main — только через Pull Request.
protected_branch="main"
while read -r local_ref local_sha remote_ref remote_sha; do
  if [ "$remote_ref" = "refs/heads/$protected_branch" ]; then
    echo "" >&2
    echo "✋ Прямой push в '$protected_branch' запрещён." >&2
    echo "   Сделай ветку и открой PR:" >&2
    echo "     git checkout -b feat/название" >&2
    echo "     git push -u origin feat/название" >&2
    echo "     gh pr create --fill --base $protected_branch" >&2
    echo "" >&2
    exit 1
  fi
done
exit 0
HOOK

rm -f .husky/pre-commit                 # пример, созданный husky init — не нужен

# 3) если раньше добавлял .githooks — убираем, чтобы не было двух механизмов
git rm -r --cached .githooks 2>/dev/null || true
rm -rf .githooks

# 4) коммит + PR
git add -A
git commit -m "chore: switch pre-push hook to husky (auto-activates on install)"
git push -u origin chore/husky-hooks
gh pr create --fill --base main
