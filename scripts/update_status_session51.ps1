# ============================================================================
# scripts/update_status_session51.ps1
# Закрытие Session 51 по протоколу CLAUDE.md (6 пунктов):
#   - STATUS.md: блоки Текущее состояние / Последняя сессия / Следующая / История
#   - SOURCES_INDEX.md: обновить карту 4→5 FULL, 9→8 PARTIAL
# Идемпотентный: маркеры <!-- STATUS_SESSION51_APPLIED -->, <!-- SOURCES_INDEX_EBM_APPLIED_v51 -->
# ============================================================================

$ErrorActionPreference = "Stop"
$repoRoot = "C:\Users\ЗС\Agent-Nutri"
Set-Location $repoRoot

$statusPath = Join-Path $repoRoot "project\STATUS.md"
$sourcesPath = Join-Path $repoRoot "v2\SOURCES_INDEX.md"
$statusMarkerNew = "<!-- STATUS_SESSION51_APPLIED -->"
$statusMarkerOld = "<!-- STATUS_SESSION50_APPLIED -->"
$sourcesMarkerNew = "<!-- SOURCES_INDEX_EBM_APPLIED_v51 -->"
$sourcesMarkerOld = "<!-- SOURCES_INDEX_EBM_APPLIED_v50 -->"
$bt = [char]96

Write-Host "=== update_status_session51.ps1 ===" -ForegroundColor Cyan

# ============================================================================
# ЧАСТЬ 1. STATUS.md
# ============================================================================
Write-Host ""
Write-Host "--- ЧАСТЬ 1: STATUS.md ---" -ForegroundColor Cyan

if (-not (Test-Path $statusPath)) {
    Write-Host "ОШИБКА: $statusPath не найден" -ForegroundColor Red
    exit 1
}

$content = [System.IO.File]::ReadAllText($statusPath, [System.Text.Encoding]::UTF8)
$origLen = $content.Length

if ($content.Contains($statusMarkerNew)) {
    Write-Host "SKIP STATUS.md: маркер v51 уже присутствует." -ForegroundColor Yellow
} else {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    Copy-Item $statusPath "$statusPath.bak.$timestamp" -Force
    Write-Host "Backup STATUS: $statusPath.bak.$timestamp" -ForegroundColor Green

    $content = $content -replace "`r`n", "`n"

    # --- Блок 1: Текущее состояние ---
    $oldHeader = "## 📌 Текущее состояние (на 2026-07-31)`n`n" +
                 "**Ветка:** ${bt}main${bt} (ветка ${bt}copilot/build-v2-nutrition-agent-core${bt} замёржена через PR #2 и удалена в Session 49).`n" +
                 "**Последнее событие:** Этап F.1 — EBM-обогащение ${bt}nutraceuticals.md${bt} (0 → 74 EBM-тега, §13 EBM Benchmark). Создана спецификация ${bt}project/EBM_STANDARD.md${bt} v1.0 и аудит-инструмент ${bt}scripts/audit_ebm_compliance.ps1${bt}."
    $newHeader = "## 📌 Текущее состояние (на 2026-07-31)`n`n" +
                 "**Ветка:** ${bt}main${bt}`n" +
                 "**Последнее событие:** Session 51, Этап F.2 — EBM-обогащение ${bt}joints_osteoporosis.md${bt} (PARTIAL → FULL_EBM, 0 → 33 EBM-тега, v1.0 → v1.2). Прогресс: 4 → **5 FULL_EBM** файлов (9.4 %), 9 → 8 PARTIAL, 468 EBM-тегов всего."
    if ($content.Contains($oldHeader)) {
        $content = $content.Replace($oldHeader, $newHeader)
        Write-Host "✓ Блок 1 (Текущее состояние)" -ForegroundColor Green
    } else {
        Write-Host "⚠ Блок 1 не найден дословно" -ForegroundColor Yellow
    }

    # --- Блок 2: Последняя сессия — заменить весь блок ---
    $pattern2 = '(?s)## 🔄 Последняя сессия — 2026-07-31 \(Session 50, Этап F\.1\).*?(?=\n---\n\n## ➡️)'
    $newBlock2 = @"
## 🔄 Последняя сессия — 2026-07-31 (Session 51, Этап F.2)

**Тема:** EBM-обогащение ${bt}joints_osteoporosis.md${bt} — PARTIAL_EBM → FULL_EBM.

**Сделано:**

- **${bt}references/methodology/joints_osteoporosis.md${bt}**: v1.0 → v1.2, 561 → 563 строки, 66.8 → 66.4 KB (после нормализации), **33 EBM-тега** (было 0). Аудит: FULL_EBM ✅ (5 критериев из 5). §16 «EBM benchmark: школа vs доказательная медицина» уже существовал — не пересоздавался, добавлены inline-теги. Idempotency marker ${bt}<!-- EBM_ENRICHED_v1.2 -->${bt}. Ключевые источники в тегах: WHO 1994, NOF 2022, VITAL/Manson 2019, LeBoff 2022, GAIT 2006, Kanis 2008 FRAX, Knapen 2013, Kuptniratsaikul 2014, Bolland 2010, Rizzoli 2018 ESCEO, Zdzieblik 2017, König 2018, Chilibeck 2017, Kellgren-Lawrence 1957, ACR 2017 GIOP, Messier 2013 IDEA, ISCD 2019, Simopoulos 2016, Zhang 2010/2012, IOF/Kanis 2019.

- **${bt}scripts/ebm_enrich_joints_osteoporosis.ps1${bt}**: v1 — 14 патчей inline-тегов + метаданные v1.0 → v1.1 + маркер v1.1. Применено 11, NOT_FOUND 3 (Kellgren-Lawrence — с en-dash в файле, T-score/K2 — иные формулировки).

- **${bt}scripts/ebm_enrich_joints_osteoporosis_v2.ps1${bt}**: v2 — 20 доп-патчей (после разведки точных строк) + метаданные v1.1 → v1.2 + маркер v1.2. Применено 20/20 (100 % попаданий). Итог: 11 + 22 (доп-упоминания в теговых заголовках) = 33 EBM-тега.

- **Обновление аудита** ${bt}scripts/audit_ebm_compliance.ps1${bt}: FULL 4 → 5 (7.5 % → 9.4 %), PARTIAL 9 → 8, Total EBM tags 446 → 468.

**Технические уроки Session 51:**

- **PARTIAL → FULL через два скрипта = норма.** Первый (v1) — черновой прогон по типовым терминам. Второй (v2) — точечная разведка + гарантированные попадания через ${bt}IndexOf/Substring${bt} по уникальным подстрокам. Так получается 100 % applied в v2.
- **En-dash vs hyphen.** ${bt}Kellgren–Lawrence${bt} (en-dash, U+2013) в файле — regex на ${bt}Kellgren-Lawrence${bt} (hyphen) не сработает. Проверять оба варианта или использовать regex-класс.
- **Первое вхождение достаточно.** Тегать все вхождения термина смысла нет — стандарт требует ≥30 тегов на файл, а не тег на каждое упоминание. Стратегия «первое вхождение + заголовок раздела» экономична и достаточна.
- **Разведка перед v2 обязательна.** ${bt}Select-String -Pattern <term>${bt} по 7-8 ключевым терминам за 30 секунд даёт точные строки — без неё v2 промахивается на 30-50 %.

**Итого коммитов Session 51:** 1 (${bt}59447a5${bt}), +442 / −30 строк.

"@
    if ($content -match $pattern2) {
        $m = [regex]::Match($content, $pattern2).Value
        $content = $content.Replace($m, $newBlock2)
        Write-Host "✓ Блок 2 (Последняя сессия)" -ForegroundColor Green
    } else {
        Write-Host "⚠ Блок 2 не найден regex" -ForegroundColor Yellow
    }

    # --- Блок 3: Следующая сессия ---
    $pattern3 = '(?s)## ➡️ Следующая сессия — Session 51 \(Этап F\.2\).*?(?=\n---\n## 📜)'
    $newBlock3 = @"
## ➡️ Следующая сессия — Session 52 (Этап F.2 продолжение)

**Контекст:** Session 51 закрыла ${bt}joints_osteoporosis.md${bt} (PARTIAL → FULL). Осталось 8 PARTIAL_EBM файлов и 40 NO_EBM.

**PARTIAL_EBM (осталось 8/53):** covid_pregnancy, female_hormones, gallbladder_health, hashimoto, nervous_system, pancreas_health, stress_adrenals, vitamins.

**Приоритет 1 (Session 52, ~60–90 мин):** EBM-обогащение ${bt}hashimoto.md${bt} (сейчас 24 тега PARTIAL, порог 30).
- Аудит: ${bt}audit_ebm_compliance.ps1 | Select-String hashimoto${bt} — знать актуальное состояние.
- Ключевые источники: ATA/ETA 2013, Chaker 2017, Rayman 2019 (селен), Toulis 2010, Wichman 2016 (селен и АТ-ТПО), NICE Thyroid 2019, LactMed.
- Стратегия: v1 (типовые термины: селен, TSH, T4, АТ-ТПО, антитела, левотироксин, аутоиммунный тиреоидит) → аудит → v2 (доп-теги по разведке).
- Целевые метрики: 24 → 30+ тегов, marker EBM_ENRICHED_v1.1, метаданные v2.0 → v2.1.

**Приоритет 2 (опционально после hashimoto):** Session 53 — ${bt}vitamins.md${bt} (29 тегов, максимально близко к порогу).

**После закрытия PARTIAL (Sessions 52-57, ~5-6 сессий):**
- Обзор NO_EBM файлов — какие из 40 реально нуждаются в EBM-обогащении (клинические: menopause, mastopathy, ibs, ibd, insulin_resistance, liver_health, stomach_health, gluten_celiac, skin_hair_health, urogenital_infections), а какие корректно остаются NO_EBM (методологические: client_intake, motivational_interviewing, ethics_scope, goal_setting, nutrition_basics).
- Обсудить с пользователем целевое покрытие Этапа F: 100 % FULL для клинических методичек = ещё ~15-20 сессий.

"@
    if ($content -match $pattern3) {
        $m = [regex]::Match($content, $pattern3).Value
        $content = $content.Replace($m, $newBlock3)
        Write-Host "✓ Блок 3 (Следующая сессия)" -ForegroundColor Green
    } else {
        Write-Host "⚠ Блок 3 не найден" -ForegroundColor Yellow
    }

    # --- Блок 4: История сессий — добавить Session 51 перед Session 50 ---
    $historyAnchor = "- **Session 50** (Этап F.1, 2026-07-31):"
    $newHistoryLine = "- **Session 51** (Этап F.2, 2026-07-31): ${bt}joints_osteoporosis.md${bt} PARTIAL → **FULL_EBM** (0 → 33 EBM-тега, v1.0 → v1.2), §16 EBM benchmark сохранён. Два скрипта: v1 (11/14 патчей) + v2 (20/20 патчей после точечной разведки). Источники: WHO 1994, NOF 2022, VITAL, GAIT, Knapen 2013, Kuptniratsaikul, Bolland, Rizzoli ESCEO. Коммит ${bt}59447a5${bt} (+442/−30). 🎉 **5/53 FULL_EBM (9.4 %).**`n$historyAnchor"
    if ($content.Contains($historyAnchor)) {
        $content = $content.Replace($historyAnchor, $newHistoryLine)
        Write-Host "✓ История: Session 51 добавлена" -ForegroundColor Green
    }

    # --- Маркер ---
    if ($content.Contains($statusMarkerOld)) {
        $content = $content.Replace($statusMarkerOld, $statusMarkerNew)
        Write-Host "✓ Маркер STATUS: v50 → v51" -ForegroundColor Green
    }

    $content = $content -replace "`n", "`r`n"
    $utf8Bom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($statusPath, $content, $utf8Bom)

    $newLen = $content.Length
    Write-Host "STATUS: $origLen → $newLen (Δ $($newLen - $origLen))" -ForegroundColor Cyan
}

# ============================================================================
# ЧАСТЬ 2. SOURCES_INDEX.md
# ============================================================================
Write-Host ""
Write-Host "--- ЧАСТЬ 2: SOURCES_INDEX.md ---" -ForegroundColor Cyan

if (-not (Test-Path $sourcesPath)) {
    Write-Host "ОШИБКА: $sourcesPath не найден" -ForegroundColor Red
    exit 1
}

$src = [System.IO.File]::ReadAllText($sourcesPath, [System.Text.Encoding]::UTF8)
$srcOrigLen = $src.Length

if ($src.Contains($sourcesMarkerNew)) {
    Write-Host "SKIP SOURCES_INDEX.md: маркер v51 уже присутствует." -ForegroundColor Yellow
} else {
    $timestamp2 = Get-Date -Format "yyyyMMdd-HHmmss"
    Copy-Item $sourcesPath "$sourcesPath.bak.$timestamp2" -Force
    Write-Host "Backup SOURCES: $sourcesPath.bak.$timestamp2" -ForegroundColor Green

    $src = $src -replace "`r`n", "`n"

    # --- Обновление FULL_EBM списка: 4 → 5 (добавить joints_osteoporosis.md) ---
    $oldFull = "- **FULL_EBM — 4 файла (7.5 %):** ${bt}autoimmune_basics.md${bt}, ${bt}minerals.md${bt}, ${bt}nutraceuticals.md${bt}, ${bt}thyroid_health.md${bt}."
    $newFull = "- **FULL_EBM — 5 файлов (9.4 %):** ${bt}autoimmune_basics.md${bt}, ${bt}joints_osteoporosis.md${bt}, ${bt}minerals.md${bt}, ${bt}nutraceuticals.md${bt}, ${bt}thyroid_health.md${bt}."
    if ($src.Contains($oldFull)) {
        $src = $src.Replace($oldFull, $newFull)
        Write-Host "✓ FULL_EBM: 4 → 5 файлов" -ForegroundColor Green
    } else {
        Write-Host "⚠ FULL_EBM строка не найдена дословно" -ForegroundColor Yellow
    }

    # --- Обновление PARTIAL_EBM: 9 → 8 (убрать joints_osteoporosis.md) ---
    $oldPartial = "- **PARTIAL_EBM — 9 файлов (17 %):** ${bt}covid_pregnancy.md${bt}, ${bt}female_hormones.md${bt}, ${bt}gallbladder_health.md${bt}, ${bt}hashimoto.md${bt}, ${bt}joints_osteoporosis.md${bt}, ${bt}nervous_system.md${bt}, ${bt}pancreas_health.md${bt}, ${bt}stress_adrenals.md${bt}, ${bt}vitamins.md${bt}."
    $newPartial = "- **PARTIAL_EBM — 8 файлов (15.1 %):** ${bt}covid_pregnancy.md${bt}, ${bt}female_hormones.md${bt}, ${bt}gallbladder_health.md${bt}, ${bt}hashimoto.md${bt}, ${bt}nervous_system.md${bt}, ${bt}pancreas_health.md${bt}, ${bt}stress_adrenals.md${bt}, ${bt}vitamins.md${bt}."
    if ($src.Contains($oldPartial)) {
        $src = $src.Replace($oldPartial, $newPartial)
        Write-Host "✓ PARTIAL_EBM: 9 → 8 файлов" -ForegroundColor Green
    } else {
        Write-Host "⚠ PARTIAL_EBM строка не найдена дословно" -ForegroundColor Yellow
    }

    # --- Всего тегов: 435 → 468 ---
    $oldTotal = "**Всего:** 435 EBM-тегов, 37 373 строки методологии."
    $newTotal = "**Всего:** 468 EBM-тегов, 37 375 строк методологии (обновлено Session 51, 2026-07-31)."
    if ($src.Contains($oldTotal)) {
        $src = $src.Replace($oldTotal, $newTotal)
        Write-Host "✓ Всего тегов: 435 → 468" -ForegroundColor Green
    }

    # --- Планы скриптов ---
    $oldPlan = "- ${bt}scripts/ebm_enrich_joints_osteoporosis.ps1${bt} ⏳ (Session 51)."
    $newPlan = "- ${bt}scripts/ebm_enrich_joints_osteoporosis.ps1${bt} + ${bt}scripts/ebm_enrich_joints_osteoporosis_v2.ps1${bt} ✅ (Session 51, 33 тега).`n- ${bt}scripts/ebm_enrich_hashimoto.ps1${bt} ⏳ (Session 52)."
    if ($src.Contains($oldPlan)) {
        $src = $src.Replace($oldPlan, $newPlan)
        Write-Host "✓ План скриптов обновлён" -ForegroundColor Green
    }
    # Убираем дублирующуюся строку "hashimoto.md ⏳ (Session 52)"
    $dupPlan = "- ${bt}scripts/ebm_enrich_hashimoto.ps1${bt} ⏳ (Session 52).`n- ${bt}scripts/ebm_enrich_hashimoto.ps1${bt} ⏳ (Session 52)."
    if ($src.Contains($dupPlan)) {
        $src = $src.Replace($dupPlan, "- ${bt}scripts/ebm_enrich_hashimoto.ps1${bt} ⏳ (Session 52).")
    }

    # --- Маркер ---
    if ($src.Contains($sourcesMarkerOld)) {
        $src = $src.Replace($sourcesMarkerOld, $sourcesMarkerNew)
        Write-Host "✓ Маркер SOURCES: v50 → v51" -ForegroundColor Green
    }

    $src = $src -replace "`n", "`r`n"
    [System.IO.File]::WriteAllText($sourcesPath, $src, $utf8Bom)

    $srcNewLen = $src.Length
    Write-Host "SOURCES: $srcOrigLen → $srcNewLen (Δ $($srcNewLen - $srcOrigLen))" -ForegroundColor Cyan
}

# ============================================================================
# ФИНАЛЬНАЯ ВАЛИДАЦИЯ
# ============================================================================
Write-Host ""
Write-Host "=== ВАЛИДАЦИЯ ===" -ForegroundColor Cyan

$statusContent = [System.IO.File]::ReadAllText($statusPath, [System.Text.Encoding]::UTF8)
$statusBytes = [System.IO.File]::ReadAllBytes($statusPath)
$statusBom = $statusBytes[0] -eq 0xEF -and $statusBytes[1] -eq 0xBB -and $statusBytes[2] -eq 0xBF

$sourcesContent = [System.IO.File]::ReadAllText($sourcesPath, [System.Text.Encoding]::UTF8)
$sourcesBytes = [System.IO.File]::ReadAllBytes($sourcesPath)
$sourcesBom = $sourcesBytes[0] -eq 0xEF -and $sourcesBytes[1] -eq 0xBB -and $sourcesBytes[2] -eq 0xBF

Write-Host "STATUS.md BOM: $statusBom" -ForegroundColor $(if ($statusBom) { "Green" } else { "Red" })
Write-Host "STATUS.md маркер v51: $($statusContent.Contains($statusMarkerNew))" -ForegroundColor $(if ($statusContent.Contains($statusMarkerNew)) { "Green" } else { "Red" })
Write-Host "STATUS.md Session 51 в тексте: $($statusContent.Contains('Session 51'))" -ForegroundColor $(if ($statusContent.Contains('Session 51')) { "Green" } else { "Red" })
Write-Host "SOURCES.md BOM: $sourcesBom" -ForegroundColor $(if ($sourcesBom) { "Green" } else { "Red" })
Write-Host "SOURCES.md маркер v51: $($sourcesContent.Contains($sourcesMarkerNew))" -ForegroundColor $(if ($sourcesContent.Contains($sourcesMarkerNew)) { "Green" } else { "Red" })
Write-Host "SOURCES.md FULL_EBM 5 файлов: $($sourcesContent.Contains('FULL_EBM — 5 файлов'))" -ForegroundColor $(if ($sourcesContent.Contains('FULL_EBM — 5 файлов')) { "Green" } else { "Red" })
Write-Host "SOURCES.md 468 EBM-тегов: $($sourcesContent.Contains('468 EBM-тегов'))" -ForegroundColor $(if ($sourcesContent.Contains('468 EBM-тегов')) { "Green" } else { "Red" })

Write-Host ""
Write-Host "=== ГОТОВО ===" -ForegroundColor Cyan
Write-Host "Проверка: git --no-pager diff --stat project/STATUS.md v2/SOURCES_INDEX.md"
