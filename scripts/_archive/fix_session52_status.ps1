$ErrorActionPreference = "Stop"
$repoRoot = "C:\Users\ЗС\Agent-Nutri"
$statusPath = Join-Path $repoRoot "project\STATUS.md"
$sourcesPath = Join-Path $repoRoot "v2\SOURCES_INDEX.md"

Write-Host "=== fix_session52_status.ps1 ===" -ForegroundColor Cyan

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$utf8Bom = New-Object System.Text.UTF8Encoding($true)

# ============================================================
# ЧАСТЬ 1: STATUS.md
# ============================================================
Write-Host ""
Write-Host "--- ЧАСТЬ 1: STATUS.md ---" -ForegroundColor Yellow

Copy-Item $statusPath "$statusPath.fix.bak.$stamp" -Force
Write-Host "Backup: $statusPath.fix.bak.$stamp"

$s = [System.IO.File]::ReadAllText($statusPath, [System.Text.Encoding]::UTF8)
$sOrig = $s.Length
$s = $s -replace "`r`n", "`n"

# --- FIX 1: Заголовок Блока 1 «Текущее состояние» (строка 3) ---
$b1old = "## 📌 Текущее состояние (на 2026-07-31)"
$b1new = "## 📌 Текущее состояние (на 2026-07-31, Session 52)"
if ($s.Contains($b1old) -and -not $s.Contains($b1new)) {
    $s = $s.Replace($b1old, $b1new)
    Write-Host "  ✓ FIX 1: Заголовок Блока 1 обновлён"
} else {
    Write-Host "  ⊙ FIX 1: skip (уже обновлён или не найден)"
}

# --- FIX 2: «Последнее событие» (строка 6) ---
$b1eventOld = "**Последнее событие:** Session 51, Этап F.2 — EBM-обогащение ``joints_osteoporosis.md`` (PARTIAL → FULL_EBM, 0 → 33 EBM-тега, v1.0 → v1.2). Прогресс: 4 → **5 FULL_EBM** файлов (9.4 %), 9 → 8 PARTIAL, 468 EBM-тегов всего."
$b1eventNew = "**Последнее событие:** Session 52, Этап F.2 — EBM-обогащение ``hashimoto.md`` (PARTIAL → FULL_EBM, 24 → 34 EBM-тега, v1.1 → v1.2). Прогресс: 5 → **6 FULL_EBM** файлов (11.3 %), 8 → 7 PARTIAL, 478 EBM-тегов всего."
if ($s.Contains($b1eventOld)) {
    $s = $s.Replace($b1eventOld, $b1eventNew)
    Write-Host "  ✓ FIX 2: Последнее событие обновлено"
} else {
    Write-Host "  ⊙ FIX 2: skip (уже обновлён или не найден)"
}

# --- FIX 3: Блок «Следующая сессия» (строка 100) ---
# Реальный формат: ## ➡️ Следующая сессия — Session 52 (Этап F.2 продолжение)
$b3Pattern = '(?s)## ➡️ Следующая сессия — Session 52 \(Этап F\.2 продолжение\).*?(?=\n## 📜 История сессий)'
$b3New = @"
## ➡️ Следующая сессия — Session 53 (Этап F.2 продолжение)

**Цель:** EBM-обогащение ``vitamins.md`` (PARTIAL_EBM → FULL_EBM)

### Исходное состояние

- ``references/methodology/vitamins.md``: 1777 строк, 171.6 KB (самая крупная методичка проекта)
- **29 EBM-тегов** (нужно ≥30 для FULL_EBM — на пороге, добавить минимум +5–10 для запаса)
- ``EBM Benchmark`` секция присутствует (yes), метаданные отсутствуют (no)
- Маркер обогащения ещё не установлен → v1.1 (новый)

### Ключевые источники для добавления

- **IOM DRI 2011** — референсные диапазоны витамина D
- **Manson 2019 VITAL** — витамин D 2000 МЕ РКИ (кардио/онко)
- **LeBoff 2022 VITAL bone** — витамин D и переломы
- **Endocrine Society 2024** — обновлённые рекомендации по D
- **Autier 2014 Lancet Diabetes Endocrinol** — мета-анализ D
- **Green 2017 Blood** — диагностика дефицита B12
- **MRC 1991 Lancet** — фолиевая кислота и NTD (Neural Tube Defects)
- **Knapen 2013** — витамин K2 (переиспользовать из joints)
- **WHO 2011** — витамин А и иммунитет
- **Klein 2011 SELECT** — витамин E (переиспользовать из hashimoto)

### Оценка усилий

- 90–120 минут (файл в 3× больше hashimoto)
- Стратегия: разведка H2-структуры → 12–15 inline-патчей → расширение §EBM Benchmark если требуется
- Целевой маркер: ``<!-- EBM_ENRICHED_v1.1 -->``

### Оставшиеся PARTIAL_EBM после Session 53

covid_pregnancy.md, female_hormones.md, gallbladder_health.md, nervous_system.md, pancreas_health.md, stress_adrenals.md — итого 6 файлов на Sessions 54–57.

### Долгосрочный план Этапа F.2

- Session 53: vitamins.md (29 → ~40 тегов)
- Session 54: female_hormones.md (29 → ~35, добавить 5–8)
- Session 55: nervous_system.md (36 тегов + §19 — только структурная нормализация)
- Session 56: covid_pregnancy.md (16 тегов + §21)
- Session 57: stress_adrenals.md, gallbladder_health.md, pancreas_health.md (0 тегов, +Benchmark)

**Прогноз к концу Session 57:** 12/53 FULL_EBM (22.6 %), 1 PARTIAL, 40 NO_EBM.

"@

if ($s -match $b3Pattern) {
    $s = [regex]::Replace($s, $b3Pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $b3New }, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    Write-Host "  ✓ FIX 3: Блок 'Следующая сессия' → Session 53"
} else {
    Write-Host "  ✗ FIX 3: паттерн не найден" -ForegroundColor Red
}

# --- FIX 4: Добавить Session 52 в Историю (строка 136) ---
$histAnchor = "## 📜 История сессий (краткая хронология)"
$histNew = @"
## 📜 История сессий (краткая хронология)

- **Session 52** (2026-07-31, Этап F.2): ``hashimoto.md`` PARTIAL → FULL_EBM (24 → 34 EBM-тега, v1.1 → v1.2). Скрипт ``ebm_enrich_hashimoto_v2.ps1`` (180 строк, 10 патчей, стратегия парных якорей). Источники: Stagnaro-Green 2011, Mizokami 2004, Ch'ng 2007, Tomer 2013, Kim 2017, Mahmoodianfard 2015, Rayman 2019, Messina 2006, Skelin 2017, Alexander 2017 ATA Pregnancy. Коммиты: ``ff2008b`` (обогащение), ``e55b583`` (частичное закрытие), fix-коммит (ремонт). Прогресс: FULL 5→6, PARTIAL 8→7, тегов 468→478.
"@

if ($s.Contains($histAnchor) -and -not ($s -match "Session 52.*hashimoto\.md PARTIAL → FULL_EBM \(24")) {
    $s = $s.Replace($histAnchor, $histNew)
    Write-Host "  ✓ FIX 4: Session 52 добавлена в Историю"
} else {
    Write-Host "  ⊙ FIX 4: skip (уже есть или якорь не найден)"
}

$s = $s -replace "`n", "`r`n"
[System.IO.File]::WriteAllText($statusPath, $s, $utf8Bom)
$sFinal = ([System.IO.File]::ReadAllText($statusPath, [System.Text.Encoding]::UTF8)).Length
Write-Host "STATUS: $sOrig → $sFinal (Δ $($sFinal - $sOrig))"

# ============================================================
# ЧАСТЬ 2: SOURCES_INDEX.md
# ============================================================
Write-Host ""
Write-Host "--- ЧАСТЬ 2: SOURCES_INDEX.md ---" -ForegroundColor Yellow

Copy-Item $sourcesPath "$sourcesPath.fix.bak.$stamp" -Force
Write-Host "Backup: $sourcesPath.fix.bak.$stamp"

$si = [System.IO.File]::ReadAllText($sourcesPath, [System.Text.Encoding]::UTF8)
$siOrig = $si.Length
$si = $si -replace "`r`n", "`n"

# --- FIX 5: FULL_EBM 5 → 6 файлов (em-dash `—`) ---
$fullOld = "**FULL_EBM — 5 файлов (9.4 %):** ``autoimmune_basics.md``, ``joints_osteoporosis.md``, ``minerals.md``, ``nutraceuticals.md``, ``thyroid_health.md``."
$fullNew = "**FULL_EBM — 6 файлов (11.3 %):** ``autoimmune_basics.md``, ``hashimoto.md``, ``joints_osteoporosis.md``, ``minerals.md``, ``nutraceuticals.md``, ``thyroid_health.md``."
if ($si.Contains($fullOld)) {
    $si = $si.Replace($fullOld, $fullNew)
    Write-Host "  ✓ FIX 5: FULL_EBM 5 → 6 файлов (+hashimoto.md)"
} else {
    Write-Host "  ⊙ FIX 5: skip (уже обновлён)"
}

# --- FIX 6: PARTIAL_EBM 8 → 7 файлов (убрать hashimoto.md) ---
$partOld = "**PARTIAL_EBM — 8 файлов (15.1 %):** ``covid_pregnancy.md``, ``female_hormones.md``, ``gallbladder_health.md``, ``nervous_system.md``, ``pancreas_health.md``, ``stress_adrenals.md``, ``vitamins.md``."
$partNew = "**PARTIAL_EBM — 7 файлов (13.2 %):** ``covid_pregnancy.md``, ``female_hormones.md``, ``gallbladder_health.md``, ``nervous_system.md``, ``pancreas_health.md``, ``stress_adrenals.md``, ``vitamins.md``."
if ($si.Contains($partOld)) {
    $si = $si.Replace($partOld, $partNew)
    Write-Host "  ✓ FIX 6: PARTIAL_EBM 8 → 7 (13.2 %)"
} else {
    # Пробуем вариант где hashimoto ещё есть в списке
    $partOldAlt = "**PARTIAL_EBM — 8 файлов (15.1 %):**"
    if ($si.Contains($partOldAlt)) {
        $si = $si.Replace("**PARTIAL_EBM — 8 файлов (15.1 %):**", "**PARTIAL_EBM — 7 файлов (13.2 %):**")
        $si = $si -replace "``hashimoto\.md``, ", ""
        Write-Host "  ✓ FIX 6 (alt): PARTIAL 8 → 7 + удаление hashimoto"
    } else {
        Write-Host "  ⊙ FIX 6: skip"
    }
}

# --- FIX 7: Всего тегов 468 → 478 ---
$totalOld = "- **Всего:** 468 EBM-тегов, 37 375 строк методологии (обновлено Session 51, 2026-07-31)."
$totalNew = "- **Всего:** 478 EBM-тегов, 37 375 строк методологии (обновлено Session 52, 2026-07-31)."
if ($si.Contains($totalOld)) {
    $si = $si.Replace($totalOld, $totalNew)
    Write-Host "  ✓ FIX 7: Всего 468 → 478 тегов, Session 51 → 52"
} else {
    Write-Host "  ⊙ FIX 7: skip"
}

# --- FIX 8: Убрать дубликат hashimoto.ps1, обновить статус на ✅ ---
# Реальные строки 641 и 643 — дублирующая запись:
#   - `scripts/ebm_enrich_hashimoto.ps1` ⏳ (Session 52).
$dupPattern = "(?s)- ``scripts/ebm_enrich_hashimoto\.ps1`` ⏳ \(Session 52\)\.\n\n\n\n- ``scripts/ebm_enrich_hashimoto\.ps1`` ⏳ \(Session 52\)\.`n"
# Более безопасный подход: заменить обе строки одной корректной
$hashimotoOld1 = "- ``scripts/ebm_enrich_hashimoto.ps1`` ⏳ (Session 52)."
$hashimotoNew = "- ``scripts/ebm_enrich_hashimoto_v2.ps1`` ✅ (Session 52, 34 тега)."

# Считаем, сколько вхождений
$matches = [regex]::Matches($si, [regex]::Escape($hashimotoOld1))
Write-Host "  ⓘ Найдено вхождений hashimoto.ps1 ⏳: $($matches.Count)"

if ($matches.Count -ge 2) {
    # Заменить ПЕРВОЕ вхождение на корректную запись, второе удалить
    $idx1 = $si.IndexOf($hashimotoOld1)
    $si = $si.Remove($idx1, $hashimotoOld1.Length).Insert($idx1, $hashimotoNew)
    # Теперь удалить второе (оставшееся) вхождение вместе с окружающими пустыми строками
    $idx2 = $si.IndexOf($hashimotoOld1)
    if ($idx2 -gt 0) {
        # Удаляем строку целиком (включая \n\n\n\n перед и после)
        $lineStart = $si.LastIndexOf("`n", $idx2) + 1
        $lineEnd = $si.IndexOf("`n", $idx2) + 1
        # Также схлопнуть множественные пустые строки
        $si = $si.Remove($lineStart, $lineEnd - $lineStart)
        $si = $si -replace "`n{4,}", "`n`n`n"
        Write-Host "  ✓ FIX 8: убран дубликат, статус ⏳ → ✅"
    }
} elseif ($matches.Count -eq 1) {
    $si = $si.Replace($hashimotoOld1, $hashimotoNew)
    Write-Host "  ✓ FIX 8: один экземпляр — обновлён статус на ✅"
} else {
    Write-Host "  ⊙ FIX 8: skip (уже обновлено или не найдено)"
}

# --- FIX 9: Добавить vitamins.ps1 если ещё нет ---
$vitOld = "- ``scripts/ebm_enrich_vitamins.ps1`` ⏳ (Session 53)."
if (-not $si.Contains($vitOld)) {
    Write-Host "  ⊙ FIX 9: vitamins.ps1 запись отсутствует (без изменений)"
} else {
    Write-Host "  ⊙ FIX 9: vitamins.ps1 запись уже есть"
}

$si = $si -replace "`n", "`r`n"
[System.IO.File]::WriteAllText($sourcesPath, $si, $utf8Bom)
$siFinal = ([System.IO.File]::ReadAllText($sourcesPath, [System.Text.Encoding]::UTF8)).Length
Write-Host "SOURCES: $siOrig → $siFinal (Δ $($siFinal - $siOrig))"

# ============================================================
# ВАЛИДАЦИЯ
# ============================================================
Write-Host ""
Write-Host "=== ВАЛИДАЦИЯ ===" -ForegroundColor Cyan

$sFinalContent = [System.IO.File]::ReadAllText($statusPath, [System.Text.Encoding]::UTF8)
$siFinalContent = [System.IO.File]::ReadAllText($sourcesPath, [System.Text.Encoding]::UTF8)
$sBytes = [System.IO.File]::ReadAllBytes($statusPath)
$siBytes = [System.IO.File]::ReadAllBytes($sourcesPath)

$checks = @(
    @{ Name = "STATUS BOM";                    Test = ($sBytes[0] -eq 0xEF -and $sBytes[1] -eq 0xBB -and $sBytes[2] -eq 0xBF) }
    @{ Name = "STATUS заголовок 'Session 52'"; Test = $sFinalContent.Contains("## 📌 Текущее состояние (на 2026-07-31, Session 52)") }
    @{ Name = "STATUS 'Последнее событие' → 52";  Test = $sFinalContent -match "Последнее событие:.+Session 52.+hashimoto" }
    @{ Name = "STATUS Блок 3 → Session 53";    Test = $sFinalContent -match "## ➡️ Следующая сессия — Session 53" }
    @{ Name = "STATUS История содержит 24 → 34"; Test = $sFinalContent -match "Session 52.*24 → 34" }
    @{ Name = "STATUS маркер v52";             Test = $sFinalContent.Contains("<!-- STATUS_SESSION52_APPLIED -->") }
    @{ Name = "SOURCES BOM";                   Test = ($siBytes[0] -eq 0xEF -and $siBytes[1] -eq 0xBB -and $siBytes[2] -eq 0xBF) }
    @{ Name = "SOURCES FULL_EBM 6 файлов";     Test = $siFinalContent.Contains("**FULL_EBM — 6 файлов (11.3 %):**") }
    @{ Name = "SOURCES hashimoto в FULL";      Test = $siFinalContent -match "FULL_EBM — 6 файлов.*hashimoto\.md" }
    @{ Name = "SOURCES PARTIAL_EBM 7 файлов";  Test = $siFinalContent.Contains("**PARTIAL_EBM — 7 файлов (13.2 %):**") }
    @{ Name = "SOURCES Всего 478 тегов";       Test = $siFinalContent.Contains("**Всего:** 478 EBM-тегов") }
    @{ Name = "SOURCES hashimoto ✅ (Session 52)"; Test = $siFinalContent.Contains("ebm_enrich_hashimoto_v2.ps1`` ✅ (Session 52") }
    @{ Name = "SOURCES маркер v52";            Test = $siFinalContent.Contains("<!-- SOURCES_INDEX_EBM_APPLIED_v52 -->") }
)

$green = 0; $red = 0
foreach ($c in $checks) {
    if ($c.Test) { Write-Host "  ✓ $($c.Name)" -ForegroundColor Green; $green++ }
    else { Write-Host "  ✗ $($c.Name)" -ForegroundColor Red; $red++ }
}
Write-Host ""
Write-Host "Итого: $green зелёных, $red красных" -ForegroundColor $(if ($red -eq 0) { "Green" } else { "Yellow" })

Write-Host ""
Write-Host "=== ГОТОВО ===" -ForegroundColor Green
Write-Host "Diff: git --no-pager diff --stat project/STATUS.md v2/SOURCES_INDEX.md"
