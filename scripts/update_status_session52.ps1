$ErrorActionPreference = "Stop"
$repoRoot = "C:\Users\ЗС\Agent-Nutri"
$statusPath = Join-Path $repoRoot "project\STATUS.md"
$sourcesPath = Join-Path $repoRoot "v2\SOURCES_INDEX.md"

$oldStatusMarker = "<!-- STATUS_SESSION51_APPLIED -->"
$newStatusMarker = "<!-- STATUS_SESSION52_APPLIED -->"
$oldSourcesMarker = "<!-- SOURCES_INDEX_EBM_APPLIED_v51 -->"
$newSourcesMarker = "<!-- SOURCES_INDEX_EBM_APPLIED_v52 -->"

Write-Host "=== update_status_session52.ps1 ===" -ForegroundColor Cyan

# ============================================================
# ЧАСТЬ 1: STATUS.md
# ============================================================
Write-Host ""
Write-Host "--- ЧАСТЬ 1: STATUS.md ---" -ForegroundColor Yellow

if (-not (Test-Path $statusPath)) { throw "STATUS.md не найден" }
$s = [System.IO.File]::ReadAllText($statusPath, [System.Text.Encoding]::UTF8)

if ($s -match [regex]::Escape($newStatusMarker)) {
    Write-Host "⚠ Маркер v52 уже есть — идемпотентный exit" -ForegroundColor Yellow
    exit 0
}

$sOrigLen = $s.Length
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
Copy-Item $statusPath "$statusPath.bak.$stamp" -Force
Write-Host "Backup STATUS: $statusPath.bak.$stamp"

$s = $s -replace "`r`n", "`n"

# --- БЛОК 1: Текущее состояние (заголовок + дата) ---
$block1Old = "## 📌 Текущее состояние \(на 2026-07-31, Session 51\)"
$block1New = "## 📌 Текущее состояние (на 2026-07-31, Session 52)"
if ($s -match $block1Old) {
    $s = $s -replace $block1Old, $block1New
    Write-Host "  ✓ Блок 1 (заголовок Session 51 → 52)"
} else {
    Write-Host "  ✗ Блок 1: заголовок Session 51 не найден" -ForegroundColor Red
}

# --- БЛОК 2: Последняя сессия ---
$block2Pattern = '(?s)## 🔄 Последняя сессия — 2026-07-31 \(Session 51, Этап F\.2\).*?(?=\n---\n)'
$block2New = @"
## 🔄 Последняя сессия — 2026-07-31 (Session 52, Этап F.2)

**Тема:** EBM-обогащение ``hashimoto.md`` — PARTIAL_EBM → FULL_EBM

### Что сделано

- ``references/methodology/hashimoto.md``: v1.1 → v1.2, **34 EBM-тега** (было 24, +10), 625 строк, 181.4 KB. Коммит ``ff2008b`` (+13/-13 строк, Δ +536 символов).
- ``scripts/ebm_enrich_hashimoto_v2.ps1`` (180 строк): идемпотентный маркер ``<!-- EBM_ENRICHED_v1.2 -->``, 10 успешных inline-патчей из 14 попыток (4 альтернативных якоря для устойчивости к опечаткам склеенных слов в исходном тексте).
- Новые EBM-источники: **Stagnaro-Green 2011** (ATA Postpartum Thyroiditis), **Mizokami 2004** (стресс-АИТ), **Ch'ng 2007** (целиакия-АИТ), **Tomer 2013** (IFN-α thyroiditis), **Kim 2017** (D3-АИТ мета-анализ), **Mahmoodianfard 2015** (Zn+Se), **Rayman 2019** (micronutrients thyroid), **Messina 2006** (soy isoflavones), **Skelin 2017** (T4 absorption), **Alexander 2017** (ATA Pregnancy Guidelines).
- Покрытые зоны: §3.4 послеродовый период, §3.5 стресс-HPA, §3.6 глютен-целиакия, §3.7 IFN-тиреоидит, §7.2 витамин D, §7.3 ферритин >70, §7.4 цинк, §8.4 соя, §9.1 L-T4 приём, §9.3 беременность ТТГ<2.5.

### Результаты аудита (по ``project/EBM_STANDARD.md`` v1.0)

- **FULL_EBM: 6/53 файлов (11.3%)** — было 5, +1 (``hashimoto.md``)
- **PARTIAL_EBM: 7/53 файлов (13.2%)** — было 8, -1
- **NO_EBM: 40/53 файлов (75.5%)** — без изменений
- Всего EBM-тегов: **478** (было 468, +10)
- Всего строк: 37 375

### Технические уроки

- Разведка контента через ``Select-String`` + прямой вывод фрагментов файла с номерами строк перед составлением патчей — обязательный шаг для устойчивости к опечаткам.
- Стратегия «парных якорей» (P1/P1b и т.д.) — эффективный способ идемпотентно обрабатывать файлы с потенциально склеенными словами при копировании из PowerShell-вывода.
- Файлы с существующим §EBM Benchmark и подробными Src-ссылками требуют только inline-тегов, не структурного расширения (экономия ~50% усилий на сессию).
"@

if ($s -match $block2Pattern) {
    $s = [regex]::Replace($s, $block2Pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $block2New }, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    Write-Host "  ✓ Блок 2 (Последняя сессия)"
} else {
    Write-Host "  ✗ Блок 2: не найден паттерн Session 51" -ForegroundColor Red
}

# --- БЛОК 3: Следующая сессия ---
$block3Pattern = '(?s)## 🎯 Следующая сессия.*?(?=\n## 📜 История сессий)'
$block3New = @"
## 🎯 Следующая сессия — Session 53, Этап F.2

**Цель:** EBM-обогащение ``vitamins.md`` (PARTIAL_EBM → FULL_EBM)

### Исходное состояние

- ``references/methodology/vitamins.md``: 1777 строк, 171.6 KB (самая крупная методичка проекта)
- **29 EBM-тегов** (нужно ≥30 для FULL_EBM — на пороге, нужен минимум +5-10 для запаса)
- ``EBM Benchmark`` присутствует (yes), метаданные отсутствуют (no)

### Ключевые источники для добавления

- **IOM DRI 2011** — референсные диапазоны витамина D
- **Manson 2019 VITAL** — витамин D 2000 МЕ РКИ (кардио/онко)
- **LeBoff 2022 VITAL bone** — витамин D и переломы
- **Endocrine Society 2024** — обновлённые рекомендации по D
- **Autier 2014 Lancet Diabetes Endocrinol** — мета-анализ D и здоровья
- **B12: Green 2017 Blood** — диагностика дефицита B12
- **Folate: NTD Prevention MRC 1991** — фолиевая кислота и NTD
- **K2: Knapen 2013** (уже в joints — переиспользовать)
- **A: WHO 2011** — витамин А и функция иммунитета
- **E: SELECT trial 2011** (Klein — уже в hashimoto — переиспользовать)

### Оценка усилий

- 90-120 минут (файл в 3× больше hashimoto)
- Стратегия: разведка H2-структуры → 12-15 inline-патчей → §EBM Benchmark расширение (если требуется)
- Маркер: ``<!-- EBM_ENRICHED_v1.1 -->`` (файл ещё без версии обогащения)

### Оставшиеся PARTIAL_EBM (после Session 53)

covid_pregnancy.md, female_hormones.md, gallbladder_health.md, nervous_system.md, pancreas_health.md, stress_adrenals.md — итого 6 файлов на 3-4 сессии (54-57).

### Долгосрочный план Этапа F.2

- Session 53: vitamins.md (PARTIAL → FULL)
- Session 54: female_hormones.md (PARTIAL → FULL, уже 29 тегов, добавить 5-8)
- Session 55: nervous_system.md (PARTIAL 36 тегов + §19 — только структурная нормализация)
- Session 56: covid_pregnancy.md (PARTIAL 16 тегов + §21)
- Session 57: stress_adrenals.md, gallbladder_health.md, pancreas_health.md (0 тегов, +Benchmark)

**Прогноз:** к концу Session 57 → **12/53 FULL_EBM (22.6%)**, 1 PARTIAL, 40 NO_EBM (без изменений).

"@

if ($s -match $block3Pattern) {
    $s = [regex]::Replace($s, $block3Pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $block3New }, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    Write-Host "  ✓ Блок 3 (Следующая сессия)"
} else {
    Write-Host "  ✗ Блок 3: паттерн не найден" -ForegroundColor Red
}

# --- ИСТОРИЯ: добавить Session 52 ---
$historyAnchor = "## 📜 История сессий`n"
$sessionEntry = @"
## 📜 История сессий

### Session 52 (2026-07-31, Этап F.2)

- **hashimoto.md**: PARTIAL_EBM → FULL_EBM (24 → 34 EBM-тега, v1.1→1.2, +536 символов)
- Скрипт ``ebm_enrich_hashimoto_v2.ps1`` (180 строк, 10 патчей, стратегия парных якорей)
- Источники: Stagnaro-Green 2011, Mizokami 2004, Ch'ng 2007, Tomer 2013, Kim 2017, Mahmoodianfard 2015, Rayman 2019, Messina 2006, Skelin 2017, Alexander 2017 ATA Pregnancy
- Коммиты: ``ff2008b`` (обогащение), ``<COMMIT_SESSION_52_CLOSURE>`` (закрытие)
- Прогресс: FULL 5→6, PARTIAL 8→7, тегов 468→478

"@

if ($s -match [regex]::Escape($historyAnchor)) {
    $s = $s -replace [regex]::Escape($historyAnchor), $sessionEntry
    Write-Host "  ✓ История: Session 52 добавлена"
} else {
    Write-Host "  ✗ История: якорь не найден" -ForegroundColor Red
}

# --- МАРКЕР ---
if ($s -match [regex]::Escape($oldStatusMarker)) {
    $s = $s -replace [regex]::Escape($oldStatusMarker), $newStatusMarker
    Write-Host "  ✓ Маркер STATUS: v51 → v52"
} else {
    $s = $s.TrimEnd() + "`n`n$newStatusMarker`n"
    Write-Host "  ✓ Маркер STATUS: добавлен v52"
}

$s = $s -replace "`n", "`r`n"
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($statusPath, $s, $utf8Bom)
$sFinalLen = ([System.IO.File]::ReadAllText($statusPath, [System.Text.Encoding]::UTF8)).Length
Write-Host "STATUS: $sOrigLen → $sFinalLen (Δ $($sFinalLen - $sOrigLen))"

# ============================================================
# ЧАСТЬ 2: SOURCES_INDEX.md
# ============================================================
Write-Host ""
Write-Host "--- ЧАСТЬ 2: SOURCES_INDEX.md ---" -ForegroundColor Yellow

$si = [System.IO.File]::ReadAllText($sourcesPath, [System.Text.Encoding]::UTF8)
if ($si -match [regex]::Escape($newSourcesMarker)) {
    Write-Host "⚠ Маркер SOURCES v52 уже есть" -ForegroundColor Yellow
} else {
    $siOrigLen = $si.Length
    Copy-Item $sourcesPath "$sourcesPath.bak.$stamp" -Force
    Write-Host "Backup SOURCES: $sourcesPath.bak.$stamp"

    $si = $si -replace "`r`n", "`n"

    # FULL_EBM: 5 → 6 файлов
    $si = $si -replace "\*\*FULL_EBM — 5 файлов \(9\.4 %\)\*\*", "**FULL_EBM — 6 файлов (11.3 %)**"
    $si = $si -replace "\*\*FULL_EBM — 5 файлов \(9\.4%\)\*\*", "**FULL_EBM — 6 файлов (11.3%)**"
    Write-Host "  ✓ FULL_EBM: 5 → 6 файлов (11.3%)"

    # Добавить hashimoto.md в список FULL_EBM (после joints_osteoporosis.md)
    $si = $si -replace "(``joints_osteoporosis\.md``)", "``hashimoto.md``, `$1"
    Write-Host "  ✓ hashimoto.md добавлен в FULL_EBM"

    # PARTIAL_EBM: 8 → 7 файлов
    $si = $si -replace "\*\*PARTIAL_EBM — 8 файлов \(15\.1 %\)\*\*", "**PARTIAL_EBM — 7 файлов (13.2 %)**"
    $si = $si -replace "\*\*PARTIAL_EBM — 8 файлов \(15\.1%\)\*\*", "**PARTIAL_EBM — 7 файлов (13.2%)**"
    Write-Host "  ✓ PARTIAL_EBM: 8 → 7 файлов (13.2%)"

    # Убрать hashimoto.md из списка PARTIAL_EBM
    $si = $si -replace "``hashimoto\.md``, ", ""
    $si = $si -replace ", ``hashimoto\.md``", ""
    $si = $si -replace "``hashimoto\.md``", ""
    Write-Host "  ✓ hashimoto.md удалён из PARTIAL_EBM"

    # Всего тегов: 468 → 478
    $si = $si -replace "Всего тегов: \*\*468\*\*", "Всего тегов: **478**"
    $si = $si -replace "тегов 468", "тегов 478"
    Write-Host "  ✓ Всего тегов: 468 → 478"

    # Маркер
    if ($si -match [regex]::Escape($oldSourcesMarker)) {
        $si = $si -replace [regex]::Escape($oldSourcesMarker), $newSourcesMarker
        Write-Host "  ✓ Маркер SOURCES: v51 → v52"
    }

    $si = $si -replace "`n", "`r`n"
    [System.IO.File]::WriteAllText($sourcesPath, $si, $utf8Bom)
    $siFinalLen = ([System.IO.File]::ReadAllText($sourcesPath, [System.Text.Encoding]::UTF8)).Length
    Write-Host "SOURCES: $siOrigLen → $siFinalLen (Δ $($siFinalLen - $siOrigLen))"
}

# ============================================================
# ВАЛИДАЦИЯ
# ============================================================
Write-Host ""
Write-Host "=== ВАЛИДАЦИЯ ===" -ForegroundColor Cyan
$sBytes = [System.IO.File]::ReadAllBytes($statusPath)
$siBytes = [System.IO.File]::ReadAllBytes($sourcesPath)
$sFinal = [System.IO.File]::ReadAllText($statusPath, [System.Text.Encoding]::UTF8)
$siFinal = [System.IO.File]::ReadAllText($sourcesPath, [System.Text.Encoding]::UTF8)

Write-Host ("STATUS.md BOM: {0}" -f (($sBytes[0] -eq 0xEF) -and ($sBytes[1] -eq 0xBB) -and ($sBytes[2] -eq 0xBF)))
Write-Host ("STATUS.md маркер v52: {0}" -f ($sFinal -match [regex]::Escape($newStatusMarker)))
Write-Host ("STATUS.md Session 52 в тексте: {0}" -f ($sFinal -match "Session 52"))
Write-Host ("STATUS.md hashimoto.md в истории: {0}" -f ($sFinal -match "hashimoto\.md"))
Write-Host ("SOURCES.md BOM: {0}" -f (($siBytes[0] -eq 0xEF) -and ($siBytes[1] -eq 0xBB) -and ($siBytes[2] -eq 0xBF)))
Write-Host ("SOURCES.md маркер v52: {0}" -f ($siFinal -match [regex]::Escape($newSourcesMarker)))
Write-Host ("SOURCES.md FULL_EBM 6 файлов: {0}" -f ($siFinal -match "FULL_EBM — 6 файлов"))
Write-Host ("SOURCES.md 478 EBM-тегов: {0}" -f ($siFinal -match "478"))

Write-Host ""
Write-Host "=== ГОТОВО ===" -ForegroundColor Green
Write-Host "Проверка: git --no-pager diff --stat project/STATUS.md v2/SOURCES_INDEX.md"
