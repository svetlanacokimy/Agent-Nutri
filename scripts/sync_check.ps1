# sync_check.ps1 — автоматическая проверка синхронизации с GitHub
# Запускается автоматически при открытии PowerShell в папке Agent-Nutri
# Определяет состояние (up-to-date / ahead / behind / diverged) и предлагает действия

# 1. Проверка, что мы в git-репозитории
$gitDir = git rev-parse --git-dir 2>$null
if (-not $gitDir) { return }  # не в git-репо — тихо выйти

# 2. Заголовок
Write-Host ""
Write-Host "=== Agent-Nutri: проверка синхронизации ===" -ForegroundColor Cyan

# 3. Текущая ветка
$branch = git branch --show-current
$expectedBranch = "main"
if ($branch -eq $expectedBranch) {
    Write-Host "Ветка: $branch ✅" -ForegroundColor Green
} else {
    Write-Host "Ветка: $branch ⚠️ (ожидается: $expectedBranch)" -ForegroundColor Yellow
    Write-Host "  Переключиться: git checkout $expectedBranch" -ForegroundColor DarkYellow
}

# 4. Fetch (тихо — только читаем состояние origin)
Write-Host "Проверка GitHub..." -ForegroundColor DarkGray
git fetch --quiet origin 2>$null

# 5. Определить состояние относительно origin
$local = git rev-parse "@" 2>$null
$remote = git rev-parse "@{u}" 2>$null
$base = git merge-base "@" "@{u}" 2>$null

if (-not $remote) {
    Write-Host "⚠️ У ветки нет upstream. Настройте: git branch --set-upstream-to=origin/$branch" -ForegroundColor Yellow
    Write-Host ""
    return
}

# 6. Незакоммиченные изменения
$dirty = git status --porcelain
$dirtyCount = if ($dirty) { ($dirty -split "`n").Count } else { 0 }

# 7. Анализ состояния
if ($local -eq $remote) {
    # Up to date
    Write-Host "GitHub: синхронизировано ✅" -ForegroundColor Green
} elseif ($local -eq $base) {
    # Behind — на GitHub есть новее, локально чисто
    $behindCount = (git rev-list --count "HEAD..@{u}").Trim()
    Write-Host "GitHub: локальная ветка отстаёт на $behindCount коммит(ов) ⬇️" -ForegroundColor Yellow
    if ($dirtyCount -eq 0) {
        Write-Host "Безопасно подтянуть изменения (git pull)." -ForegroundColor Cyan
        $answer = Read-Host "Выполнить git pull сейчас? [Y/N]"
        if ($answer -match '^[YyДд]') {
            git pull
            Write-Host "✅ Синхронизировано с GitHub" -ForegroundColor Green
        } else {
            Write-Host "Пропущено. Команда: git pull" -ForegroundColor DarkGray
        }
    } else {
        Write-Host "⚠️ Есть незакоммиченные изменения ($dirtyCount файлов) — сначала закоммитьте." -ForegroundColor Yellow
    }
} elseif ($remote -eq $base) {
    # Ahead — у нас есть локальные коммиты, не запушенные
    $aheadCount = (git rev-list --count "@{u}..HEAD").Trim()
    Write-Host "GitHub: локальная ветка впереди на $aheadCount коммит(ов) ⬆️" -ForegroundColor Yellow
    Write-Host "Не забудьте: git push origin $branch" -ForegroundColor Cyan
} else {
    # Diverged — и локально есть коммиты, и на GitHub есть новее
    $aheadCount = (git rev-list --count "@{u}..HEAD").Trim()
    $behindCount = (git rev-list --count "HEAD..@{u}").Trim()
    Write-Host "GitHub: РАСХОЖДЕНИЕ ⚠️" -ForegroundColor Red
    Write-Host "  Локально впереди на: $aheadCount коммит(ов)" -ForegroundColor Yellow
    Write-Host "  Отстаёт на:          $behindCount коммит(ов)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Обычно это происходит после force push с другого ноута." -ForegroundColor DarkGray
    Write-Host "Если вы уверены, что GitHub-версия — актуальная," -ForegroundColor DarkGray
    Write-Host "локальные коммиты можно СБРОСИТЬ через git reset --hard." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "⚠️ ВНИМАНИЕ: reset --hard удалит ВСЕ локальные незакоммиченные изменения" -ForegroundColor Red
    if ($dirtyCount -gt 0) {
        Write-Host "  У вас $dirtyCount файлов с несохранёнными изменениями!" -ForegroundColor Red
    }
    $answer = Read-Host "Синхронизировать с GitHub через git reset --hard? [Y/N]"
    if ($answer -match '^[YyДд]') {
        git fetch origin
        git reset --hard "origin/$branch"
        Write-Host "✅ Локальная ветка синхронизирована с origin/$branch" -ForegroundColor Green
    } else {
        Write-Host "Пропущено. Команды для ручной синхронизации:" -ForegroundColor DarkGray
        Write-Host "  git fetch origin" -ForegroundColor DarkYellow
        Write-Host "  git reset --hard origin/$branch" -ForegroundColor DarkYellow
    }
}

# 8. Информация о незакоммиченных изменениях (если есть)
if ($dirtyCount -gt 0) {
    Write-Host ""
    Write-Host "📝 Незакоммиченные изменения: $dirtyCount файл(ов)" -ForegroundColor Yellow
    Write-Host "   Посмотреть: git status" -ForegroundColor DarkGray
}

Write-Host ""
