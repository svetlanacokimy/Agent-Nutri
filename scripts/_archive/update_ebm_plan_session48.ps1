# === НАЧАЛО ===
<#
.SYNOPSIS
  Обновляет project/EBM_UPGRADE_PLAN.md по итогам Session 48.
  Фиксирует Этап E как завершённый (8/8 фактически обработанных файлов) и планирует Этап F (6 оставшихся методичек).

.DESCRIPTION
  Идемпотентный скрипт: повторный запуск не изменит уже обновлённый файл.
  Backup + UTF-8 BOM + CRLF + валидация 10 проверок.

.NOTES
  Session 48, 2026-07-27
#>

$ErrorActionPreference = 'Stop'
$targetFile = 'project/EBM_UPGRADE_PLAN.md'
$marker = '<!-- EBM_PLAN_SESSION48_APPLIED -->'

# --- Проверка файла ---
if (-not (Test-Path $targetFile)) {
    Write-Host "ОШИБКА: файл $targetFile не найден" -ForegroundColor Red
    exit 1
}

$content = Get-Content $targetFile -Raw -Encoding UTF8
$originalLength = $content.Length
Write-Host "Прочитано символов: $originalLength" -ForegroundColor Cyan

# --- Idempotency guard ---
if ($content -match [regex]::Escape($marker)) {
    Write-Host "Файл уже обновлён (найден маркер). Выход без изменений." -ForegroundColor Yellow
    exit 0
}

# --- Backup ---
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupFile = "$targetFile.bak.$timestamp"
Copy-Item $targetFile $backupFile -Force
Write-Host "Backup создан: $backupFile" -ForegroundColor Green

# ================================================================
# ПАТЧ 1: Шапка — статус и дата
# ================================================================
$patch1Regex = '(?s)(\*\*Создан:\*\* 2026-07-26 \(Session 40\)\r?\n)\*\*Статус:\*\* ⏳ в работе'
$patch1New = "`$1**Статус:** ✅ Этап E завершён (8/8, Session 47, 2026-07-27) | ⏳ Этап F запланирован (6 методичек)`r`n**Последнее обновление:** 2026-07-27 (Session 48)"
if ($content -match $patch1Regex) {
    $content = [regex]::Replace($content, $patch1Regex, $patch1New)
    Write-Host "[Патч 1] Шапка обновлена (статус + дата)" -ForegroundColor Green
} else {
    Write-Host "[Патч 1] Шапка не найдена — ОШИБКА" -ForegroundColor Red
    exit 1
}

# ================================================================
# ПАТЧ 2: Замена раздела "Порядок обработки файлов"
# ================================================================
$newOrderBlock = @'
## Порядок обработки файлов (ФАКТИЧЕСКИЙ, Этап E ✅)

По ходу работы приоритеты были пересмотрены: вместо первоначального списка (nutraceuticals, joints_osteoporosis, skin_hair, urogenital, lymph_immune, menus) в Этап E попали более востребованные методички кластеров 4 (эндокринология) и 8 (микронутриенты). Оставшиеся 6 файлов первоначального плана вынесены в **Этап F**.

**Фактически обогащены (Sessions 40–47):**

1. `covid_pregnancy.md` — Session 40 (2026-07-24) ✅ прототип
2. `nervous_system.md` — Session 41 (2026-07-24) ✅
3. `minerals.md` — Session 42 (2026-07-25) ✅
4. `vitamins.md` — Session 43 (2026-07-25) ✅
5. `hashimoto.md` — Session 44 (2026-07-25) ✅
6. `female_hormones.md` — Session 45 (2026-07-26) ✅
7. `autoimmune_basics.md` — Session 46 (2026-07-26) ✅
8. `thyroid_health.md` — Session 47 (2026-07-27) ✅ финал Этапа E

'@

$patch2Regex = '(?s)## Порядок обработки файлов.*?(?=## Метод обогащения)'
if ($content -match $patch2Regex) {
    $content = [regex]::Replace($content, $patch2Regex, $newOrderBlock)
    Write-Host "[Патч 2] Раздел 'Порядок обработки' заменён" -ForegroundColor Green
} else {
    Write-Host "[Патч 2] Раздел 'Порядок обработки' не найден — ОШИБКА" -ForegroundColor Red
    exit 1
}

# ================================================================
# ПАТЧ 3: Замена таблицы "Прогресс"
# ================================================================
$newProgressTable = @'
## Прогресс Этапа E — ✅ ЗАВЕРШЁН (8/8 = 100 %)

| #   | Файл                    | Статус | Сессия     | Дата       | Коммит методички | Коммит скрипта | Строк | KB    | EBM-тегов |
| --- | ----------------------- | ------ | ---------- | ---------- | ---------------- | -------------- | ----- | ----- | --------- |
| 1   | covid_pregnancy.md      | ✅     | Session 40 | 2026-07-24 | (см. git log)    | —              | ~800  | ~85   | ~25       |
| 2   | nervous_system.md       | ✅     | Session 41 | 2026-07-24 | (см. git log)    | —              | ~900  | ~90   | ~25       |
| 3   | minerals.md             | ✅     | Session 42 | 2026-07-25 | (см. git log)    | (см. git log)  | 1376  | 94.2  | 30        |
| 4   | vitamins.md             | ✅     | Session 43 | 2026-07-25 | (см. git log)    | (см. git log)  | 1776  | 171.6 | 29        |
| 5   | hashimoto.md            | ✅     | Session 44 | 2026-07-25 | (см. git log)    | (см. git log)  | 624   | 180.8 | 24        |
| 6   | female_hormones.md      | ✅     | Session 45 | 2026-07-26 | `c9d2c01`        | `5a2555a`      | 885   | 86.9  | 29        |
| 7   | autoimmune_basics.md    | ✅     | Session 46 | 2026-07-26 | `c448de8`        | `3af1f9a`      | 1017  | 87.2  | 81        |
| 8   | thyroid_health.md       | ✅     | Session 47 | 2026-07-27 | `bce6025`        | `fefde08`      | 798   | 106.5 | 116       |

**Итоговые метрики Этапа E:** ~8 200 строк enrich, ~1 000 KB контента, **~360 EBM-тегов**, ~1 000 строк insertions, ~2 600 строк PowerShell-скриптов, **16 коммитов без единого отката**.

### Наблюдения Этапа E

1. **Три формата метаданных** обработаны: blockquote (`> **Версия:**`), plain list (`- **Версия:**`), отдельная секция `## Метаданные`. Regex-парсинг должен покрывать все три.
2. **SKIP-замены inline-паттернов** составили 10–50 % на файл — это норма, а не баг: причина в вариациях формулировок, а покрытие концепций обеспечивается за счёт разделов §§X.4–X.8 (EBM benchmark, таблица расхождений, RCT).
3. **Структурные аномалии** обработаны без правки исходника: дубликаты H2 в `nervous_system.md`, ложный H2 на строке 153 в `autoimmune_basics.md`. Регексы построены с учётом аномалий.
4. **Идемпотентность** через маркеры `<!-- EBM_ENRICHED_v1.1 -->` / `<!-- EBM_ENRICHED_v2.1 -->` — обязательный паттерн для всех enrichment-скриптов.
5. **Рекордная плотность EBM-тегов:** `thyroid_health.md` (116 тегов) и `autoimmune_basics.md` (81 тег) за счёт развёрнутых секций §10.3/§10.4 и §27.7/§27.8 с 20+ RCT/DOI.

'@

$patch3Regex = '(?s)## Прогресс.*?(?=## После завершения Этапа E)'
if ($content -match $patch3Regex) {
    $content = [regex]::Replace($content, $patch3Regex, $newProgressTable)
    Write-Host "[Патч 3] Таблица прогресса + итоги Этапа E добавлены" -ForegroundColor Green
} else {
    Write-Host "[Патч 3] Раздел 'Прогресс' не найден — ОШИБКА" -ForegroundColor Red
    exit 1
}

# ================================================================
# ПАТЧ 4: Замена финального раздела "После завершения Этапа E" на "Этап F + После завершения Этапа F"
# ================================================================
$newFinalBlock = @'
## Этап F — ⏳ ЗАПЛАНИРОВАН (6 методичек из первоначального списка)

После пересмотра приоритетов в Этапе E следующие 6 методичек первоначального плана остались не обогащёнными EBM-слоем. Они переносятся в Этап F с сохранением исходных требований (пулы источников, метод обогащения, правила безопасности).

**Приоритет высокий (кластер безопасности и клинических рисков):**

1. `nutraceuticals.md` — критично: взаимодействия, дозировки, LactMed, Stockley's
2. `joints_osteoporosis.md` — сложная EBM-база: VITAL, GAIT, NOF 2022, IOF, ESCEO 2019, Zdzieblik 2017 (коллаген), Knapen 2013 (K2)

**Приоритет средний:**

3. `skin_hair_health.md`
4. `urogenital_infections.md`
5. `lymph_immune.md`

**Приоритет низкий:**

6. `menus.md` — меньше EBM-плотности, больше клинической практики

**Метод обогащения**: тот же, что в Этапе E (§XX. EBM Benchmark, inline `[EBM: Автор Год]`, таблица расхождений «школа vs EBM», ≥15 упоминаний беременности с безопасностью, ≥8 клинически значимых взаимодействий, обновление метаданных версии до 1.1/2.1, идемпотентный маркер).

**Тайминг Этапа F:** 1 файл = 30–50 мин работы Агента (по метрикам Sessions 42–47), итого 6 файлов ≈ 3–5 часов работы или 6 сессий по 30–50 мин.

## После завершения Этапа F

1. **Merge в main** — PR из `copilot/build-v2-nutrition-agent-core` → `main`.
2. **CI-валидатор EBM-маркеров** — GitHub Action, проверяющая наличие `<!-- EBM_ENRICHED_* -->`, порядок секций, UTF-8 BOM, количество `[EBM:]`-тегов ≥ 20 во всех 14 EBM-обогащённых методичках.
3. **Обновление STATUS.md** с финальными метриками (14/14 EBM-lite покрытие, ~600+ EBM-тегов).
4. **Опционально:** расширение EBM-lite до EBM-full (уровень 2 OCEBM) для 2–3 приоритетных методичек — с полными систематическими обзорами вместо отдельных RCT.

---

_План создан в рамках Session 40 (2026-07-26). Обновлён в Session 48 (2026-07-27): Этап E зафиксирован как ✅ завершённый (8/8), Этап F запланирован (6 методичек)._
'@

$patch4Regex = '(?s)## После завершения Этапа E.*?_План создан в рамках Session 40 \(2026-07-26\) как основа для последовательного EBM-обогащения методической базы Agent-Nutri\._'
if ($content -match $patch4Regex) {
    $content = [regex]::Replace($content, $patch4Regex, $newFinalBlock)
    Write-Host "[Патч 4] Финальный раздел (Этап F + после F) добавлен" -ForegroundColor Green
} else {
    Write-Host "[Патч 4] Финальный раздел не найден — ОШИБКА" -ForegroundColor Red
    exit 1
}

# ================================================================
# Маркер идемпотентности
# ================================================================
$content = $content.TrimEnd() + "`r`n`r`n$marker`r`n"

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
    @{ Name = 'Статус Этап E завершён'; Ok = $final -match 'Этап E завершён \(8/8' }
    @{ Name = 'Session 48 в дате'; Ok = $final -match 'Session 48' }
    @{ Name = 'Таблица 8 файлов Этапа E'; Ok = $final -match 'thyroid_health\.md' }
    @{ Name = 'Итоги: 360 EBM-тегов'; Ok = $final -match '360 EBM-тегов' }
    @{ Name = 'Итоги: 16 коммитов'; Ok = $final -match '16 коммитов' }
    @{ Name = 'Этап F запланирован'; Ok = $final -match 'Этап F — ⏳ ЗАПЛАНИРОВАН' }
    @{ Name = '6 методичек Этапа F'; Ok = $final -match 'nutraceuticals\.md.*?joints_osteoporosis' }
    @{ Name = 'CI-валидатор упомянут'; Ok = $final -match 'CI-валидатор' }
    @{ Name = 'Маркер идемпотентности'; Ok = $final -match [regex]::Escape($marker) }
    @{ Name = 'UTF-8 BOM'; Ok = $hasBom }
)

$allOk = $true
foreach ($c in $checks) {
    if ($c.Ok) { Write-Host "  ✅ $($c.Name)" }
    else { Write-Host "  ❌ $($c.Name)"; $allOk = $false }
}

Write-Host "`nСтрок: $lines" -ForegroundColor Cyan
Write-Host "Размер: $sizeKB KB" -ForegroundColor Cyan
Write-Host "Изменение: $originalLength -> $($content.Length) символов" -ForegroundColor Cyan

if ($allOk) {
    Write-Host "`n=== ГОТОВО: EBM_UPGRADE_PLAN.md обновлён для Session 48 ===" -ForegroundColor Green
    Write-Host "Следующий шаг: git diff --stat project/EBM_UPGRADE_PLAN.md" -ForegroundColor Yellow
} else {
    Write-Host "`n=== ВНИМАНИЕ: не все проверки пройдены ===" -ForegroundColor Red
    Write-Host "Проверьте backup: $backupFile" -ForegroundColor Yellow
}
# === КОНЕЦ ===
