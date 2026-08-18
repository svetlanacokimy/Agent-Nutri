# === НАЧАЛО ===
<#
.SYNOPSIS
  Обновляет project/STATUS.md по итогам Session 48.
  Закрывает Этапы B3/C/D/E, добавляет Sessions 39-47, обновляет счётчики.

.DESCRIPTION
  Идемпотентный скрипт: повторный запуск не изменит уже обновлённый файл.
  Создаёт backup перед изменениями. Сохраняет UTF-8 BOM + CRLF.

.NOTES
  Session 48, 2026-07-27
#>

$ErrorActionPreference = 'Stop'
$targetFile = 'project/STATUS.md'
$marker = '<!-- STATUS_SESSION48_APPLIED -->'

# --- Проверка существования файла ---
if (-not (Test-Path $targetFile)) {
    Write-Host "ОШИБКА: файл $targetFile не найден" -ForegroundColor Red
    exit 1
}

# --- Чтение содержимого ---
$content = Get-Content $targetFile -Raw -Encoding UTF8
$originalLength = $content.Length
Write-Host "Прочитано символов: $originalLength" -ForegroundColor Cyan

# --- Idempotency guard ---
if ($content -match [regex]::Escape($marker)) {
    Write-Host "Файл уже обновлён (найден маркер $marker). Выход без изменений." -ForegroundColor Yellow
    exit 0
}

# --- Backup ---
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupFile = "$targetFile.bak.$timestamp"
Copy-Item $targetFile $backupFile -Force
Write-Host "Backup создан: $backupFile" -ForegroundColor Green

# ================================================================
# ПАТЧ 1: Дата в шапке
# ================================================================
$patch1Applied = $false
if ($content -match '2026-07-20') {
    $content = $content -replace '2026-07-20', '2026-07-27'
    $patch1Applied = $true
    Write-Host "[Патч 1] Дата обновлена: 2026-07-20 -> 2026-07-27" -ForegroundColor Green
} else {
    Write-Host "[Патч 1] Дата 2026-07-20 не найдена — пропуск" -ForegroundColor Yellow
}

# ================================================================
# ПАТЧ 2: Замена блока "Следующая сессия"
# ================================================================
$newNextSessionBlock = @'
## ➡️ Следующая сессия — Этап F (планирование)

**Все этапы миграции закрыты (A–E).** Проект в стабильном состоянии: 19 кластеров, 56 методичек, ~360 EBM-тегов, 16 безоткатных коммитов Этапа E.

**Приоритет 1 (финализация Session 48, ~40 мин):**

- Обновить `project/EBM_UPGRADE_PLAN.md` — итоговая таблица 8/8, timeline сессий 40–47, метрики (~8 200 строк enrich, ~360 тегов, 16 коммитов).
- Обновить `project/EBM_WORKFLOW.md` — уроки Этапа E: 3 формата метаданных (blockquote/plain list/отдельная секция), idempotency marker, структурные аномалии (nervous_system дубликаты, autoimmune_basics строка 153), паттерн SKIP-замен (10–50 %), 5 технических предохранителей, шаблон workflow из 5 команд.

**Приоритет 2 (Этап F — планирование):**

- Определить содержание Этапа F. Возможные направления:
  - CI-валидатор (проверка маркеров EBM_ENRICHED, таблиц, порядка секций, BOM во всех 8 методичках).
  - Расширение EBM-lite до EBM-full (уровень 2) для приоритетных методичек.
  - Merge ветки `copilot/build-v2-nutrition-agent-core` в `main` одним PR.
  - Автоматизация проверки ссылок между методичками (`audit_links.ps1` v2).

**Приоритет 3 (опционально):**

- Обзор `_archive/` — что оставить, что удалить окончательно.

---

'@

$patch2Regex = '(?s)## ➡️ Следующая сессия.*?(?=## 📜 История сессий)'
if ($content -match $patch2Regex) {
    $content = [regex]::Replace($content, $patch2Regex, $newNextSessionBlock)
    Write-Host "[Патч 2] Блок 'Следующая сессия' заменён" -ForegroundColor Green
} else {
    Write-Host "[Патч 2] Блок 'Следующая сессия' не найден — ОШИБКА" -ForegroundColor Red
    exit 1
}

# ================================================================
# ПАТЧ 3: Вставка Sessions 39-47 в начало Истории
# ================================================================
$newSessions = @'
- **Сессия 47** (EBM Этап E 8/8, 2026-07-27): `thyroid_health.md` v2.0→2.1, 798 строк, 106.5 KB, **116 EBM-тегов** (рекорд), 11 inline-замен, §§27.4–27.8 (OCEBM, таблица 10 расхождений, гайдлайны ATA/ETA/NICE, 20 RCT с DOI). Коммиты `bce6025` (+172/−81), `fefde08` (+326, script). 🎉 **Этап E закрыт 8/8 = 100 %.**
- **Сессия 46** (EBM 7/8, 2026-07-26): `autoimmune_basics.md` v1.0→1.1, 1017 строк, 87.2 KB, **81 EBM-тег**, 15 inline-замен, §10 EBM benchmark (иерархия, 10 расхождений, EULAR/ACR/ECCO, 20 RCT). Коммиты `c448de8` (+151/−61), `3af1f9a` (+316, script).
- **Сессия 45** (EBM 6/8, 2026-07-26): `female_hormones.md` v2.0→2.1, 885 строк, 86.9 KB, 29 EBM-тегов, 21 inline-замен, §§27.4–27.8 (Monash/AE-PCOS 2023, NICE NG73, NAMS 2022, 25 RCT). Коммиты `c9d2c01` (+113/−14), `5a2555a` (+350, script).
- **Сессия 44** (EBM 5/8, 2026-07-25): `hashimoto.md`, 624 строки, 180.8 KB, 24 EBM-тега. Diff +101/−18.
- **Сессия 43** (EBM 4/8, 2026-07-25): `vitamins.md`, 1776 строк, 171.6 KB, 29 EBM-тегов. Diff +107/−23.
- **Сессия 42** (EBM 3/8, 2026-07-25): `minerals.md`, 1376 строк, 94.2 KB, 30 EBM-тегов. Diff +105/−22.
- **Сессия 41** (EBM 2/8, 2026-07-24): `nervous_system.md`, ~900 строк, ~90 KB, ~25 EBM-тегов. Обработана структурная аномалия (дубликаты H2).
- **Сессия 40** (EBM 1/8, 2026-07-24): `covid_pregnancy.md`, ~800 строк, ~85 KB, ~25 EBM-тегов. Старт Этапа E — идемпотентный EBM-lite enrichment (уровень 1 OCEBM).
- **Сессия 39** (Этап C, 2026-07-21): создан `joints_osteoporosis.md` — суставы, остеоартроз, РА, остеопороз, DEXA, T/Z-score, кальций/D/K2/магний, бисфосфонаты. Открыт **Кластер 19**. Коммиты `a5243c6`, `0cd159f`, `f4c309a`. 🎉 **Этап C закрыт 9/9.**

'@

$patch3Regex = '(## 📜 История сессий \(краткая хронология\)\s*\r?\n\r?\n)'
if ($content -match $patch3Regex) {
    $content = [regex]::Replace($content, $patch3Regex, "`$1$newSessions")
    Write-Host "[Патч 3] Sessions 39-47 добавлены в историю" -ForegroundColor Green
} else {
    Write-Host "[Патч 3] Заголовок 'История сессий' не найден — ОШИБКА" -ForegroundColor Red
    exit 1
}

# ================================================================
# ПАТЧ 4: Финальная строка-сводка
# ================================================================
$patch4Regex = '\*\*Активных кластеров:\*\* 18 из 18\..*?\*\*Этапы миграции:\*\* A ✅ / B1 ✅ / B2 ✅ / B3 ⏳ / C ⏳ / D ⏳\.'
$newSummary = '**Активных кластеров:** 19 из 19. **Контентных файлов:** 56/56 подключены (100 %). **EBM-lite покрытие:** 8/8 приоритетных методичек (~360 EBM-тегов). **Этапы миграции:** A ✅ / B1 ✅ / B2 ✅ / B3 ✅ / C ✅ / D ✅ N/A / **E ✅**. **Примечание по Этапу D:** задача «DEPRECATED-заголовки в 14 файлах `references/NN_*.md`» признана фантомной (Session 48, 2026-07-27) — файлы не существуют ни в текущем состоянии репозитория, ни в истории git (`--diff-filter=D --all` дал пустой результат). Реальная миграция контента завершена в Этапах A–C.'

if ($content -match $patch4Regex) {
    $content = [regex]::Replace($content, $patch4Regex, $newSummary)
    Write-Host "[Патч 4] Финальная сводка обновлена" -ForegroundColor Green
} else {
    Write-Host "[Патч 4] Финальная сводка не найдена — пробуем упрощённый паттерн" -ForegroundColor Yellow
    $patch4Fallback = '\*\*Активных кластеров:\*\* 18 из 18.*?D ⏳\.'
    if ($content -match $patch4Fallback) {
        $content = [regex]::Replace($content, $patch4Fallback, $newSummary, [System.Text.RegularExpressions.RegexOptions]::Singleline)
        Write-Host "[Патч 4] Финальная сводка обновлена (fallback)" -ForegroundColor Green
    } else {
        Write-Host "[Патч 4] Финальная сводка не найдена — ОШИБКА" -ForegroundColor Red
        exit 1
    }
}

# ================================================================
# Добавление маркера идемпотентности
# ================================================================
if ($content -notmatch [regex]::Escape($marker)) {
    $content = $content.TrimEnd() + "`r`n`r`n$marker`r`n"
    Write-Host "Маркер идемпотентности добавлен" -ForegroundColor Green
}

# ================================================================
# Нормализация CRLF
# ================================================================
$content = $content -replace "`r`n", "`n"
$content = $content -replace "`n", "`r`n"

# ================================================================
# Сохранение UTF-8 with BOM
# ================================================================
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path $targetFile).Path, $content, $utf8Bom)
Write-Host "Файл сохранён: $targetFile (UTF-8 BOM, CRLF)" -ForegroundColor Green

# ================================================================
# ВАЛИДАЦИЯ
# ================================================================
Write-Host "`n=== ВАЛИДАЦИЯ ===" -ForegroundColor Cyan
$final = Get-Content $targetFile -Raw -Encoding UTF8
$bytes = [System.IO.File]::ReadAllBytes((Resolve-Path $targetFile).Path)
$hasBom = ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
$lines = ($final -split "`r`n").Count
$sizeKB = [math]::Round($bytes.Length / 1KB, 1)

$checks = @(
    @{ Name = 'Дата 2026-07-27'; Ok = $final -match '2026-07-27' }
    @{ Name = 'Сессия 47'; Ok = $final -match 'Сессия 47' }
    @{ Name = 'Сессия 39'; Ok = $final -match 'Сессия 39' }
    @{ Name = '19 из 19 кластеров'; Ok = $final -match '19 из 19' }
    @{ Name = '56/56 файлов'; Ok = $final -match '56/56' }
    @{ Name = 'Этап E закрыт'; Ok = $final -match 'E ✅' }
    @{ Name = 'Этап D N/A'; Ok = $final -match 'D ✅ N/A' }
    @{ Name = 'Этап F в плане'; Ok = $final -match 'Этап F' }
    @{ Name = 'Маркер идемпотентности'; Ok = $final -match [regex]::Escape($marker) }
    @{ Name = 'UTF-8 BOM'; Ok = $hasBom }
)

$allOk = $true
foreach ($c in $checks) {
    $status = if ($c.Ok) { '✅' } else { '❌'; $allOk = $false }
    Write-Host "  $status $($c.Name)"
}

Write-Host "`nСтрок: $lines" -ForegroundColor Cyan
Write-Host "Размер: $sizeKB KB" -ForegroundColor Cyan
Write-Host "Изменение размера: $($originalLength) -> $($content.Length) символов" -ForegroundColor Cyan

if ($allOk) {
    Write-Host "`n=== ГОТОВО: STATUS.md обновлён для Session 48 ===" -ForegroundColor Green
    Write-Host "Следующий шаг: git diff --stat project/STATUS.md" -ForegroundColor Yellow
} else {
    Write-Host "`n=== ВНИМАНИЕ: не все проверки пройдены ===" -ForegroundColor Red
    Write-Host "Проверьте backup: $backupFile" -ForegroundColor Yellow
}
# === КОНЕЦ ===
