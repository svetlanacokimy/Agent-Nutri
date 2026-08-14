# =====================================================================
# scripts/close_session53.ps1
# Session 53 закрытие: STATUS.md + SOURCES_INDEX.md
# Правило Session 52: Old-паттерны скопированы дословно из разведки
# =====================================================================

$ErrorActionPreference = "Stop"
$statusPath  = "project/STATUS.md"
$sourcesPath = "v2/SOURCES_INDEX.md"

foreach ($p in @($statusPath, $sourcesPath)) {
    if (-not (Test-Path $p)) { throw "Файл не найден: $p" }
}

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"

# ---------------------------------------------------------------------
# STATUS.md
# ---------------------------------------------------------------------
Write-Host "=== 1. STATUS.md ===" -ForegroundColor Cyan
Copy-Item $statusPath "$statusPath.bak.$stamp"
Write-Host "✓ Backup: $statusPath.bak.$stamp" -ForegroundColor Green

$s = [System.IO.File]::ReadAllText((Resolve-Path $statusPath), [System.Text.Encoding]::UTF8)
$sOrig = $s.Length

function Apply-Patch {
    param($text, $id, $old, $new)
    if ($text.Contains($new) -and -not $text.Contains($old)) {
        Write-Host "  ⊙ $id : уже применён" -ForegroundColor Yellow
        return $text
    }
    if ($text.Contains($old)) {
        Write-Host "  ✓ $id : применён" -ForegroundColor Green
        return $text.Replace($old, $new)
    }
    Write-Host "  ✗ $id : OLD не найден" -ForegroundColor Red
    return $text
}

# S1: заголовок Блок 1
$s = Apply-Patch $s "S1" `
    '## 📌 Текущее состояние (на 2026-07-31, Session 52)' `
    '## 📌 Текущее состояние (на 2026-07-31, Session 53)'

# S2: последнее событие
$s = Apply-Patch $s "S2" `
    '**Последнее событие:** Session 52, Этап F.2 — EBM-обогащение `hashimoto.md` (PARTIAL → FULL_EBM, 24 → 34 EBM-тега, v1.1 → v1.2). Прогресс: 5 → **6 FULL_EBM** файлов (11.3 %), 8 → 7 PARTIAL, 478 EBM-тегов всего.' `
    '**Последнее событие:** Session 53, Этап F.2 — EBM-обогащение `vitamins.md` (PARTIAL → FULL_EBM, 29 → 43 EBM-тега, v1.1 → v1.2). Прогресс: 6 → **7 FULL_EBM** файлов (13.2 %), 7 → 6 PARTIAL, 492 EBM-тега всего.'

# S3: заголовок Блок 2
$s = Apply-Patch $s "S3" `
    '## 🔄 Последняя сессия — 2026-07-31 (Session 52, Этап F.2)' `
    '## 🔄 Последняя сессия — 2026-07-31 (Session 53, Этап F.2)'

# S4: тема
$s = Apply-Patch $s "S4" `
    '**Тема:** EBM-обогащение `hashimoto.md` — PARTIAL_EBM → FULL_EBM' `
    '**Тема:** EBM-обогащение `vitamins.md` — PARTIAL_EBM → FULL_EBM'

# S5: FULL_EBM count
$s = Apply-Patch $s "S5" `
    '- **FULL_EBM: 6/53 файлов (11.3%)** — было 5, +1 (`hashimoto.md`)' `
    '- **FULL_EBM: 7/53 файлов (13.2%)** — было 6, +1 (`vitamins.md`)'

# S6: PARTIAL_EBM count
$s = Apply-Patch $s "S6" `
    '- **PARTIAL_EBM: 7/53 файлов (13.2%)** — было 8, -1' `
    '- **PARTIAL_EBM: 6/53 файлов (11.3%)** — было 7, -1'

# S7: всего тегов
$s = Apply-Patch $s "S7" `
    '- Всего EBM-тегов: **478** (было 468, +10)' `
    '- Всего EBM-тегов: **492** (было 478, +14)'

# S8: заголовок Блок 3
$s = Apply-Patch $s "S8" `
    '## ➡️ Следующая сессия — Session 53 (Этап F.2 продолжение)' `
    '## ➡️ Следующая сессия — Session 54 (Этап F.2 продолжение)'

# S9: цель Блок 3 (перезапись всего блока L102-142)
$oldBlock3 = @"
**Цель:** EBM-обогащение ``vitamins.md`` (PARTIAL_EBM → FULL_EBM)
"@
$newBlock3 = @"
**Цель:** структурная нормализация ``nervous_system.md`` (PARTIAL_EBM → FULL_EBM, быстрая доводка)
"@
$s = Apply-Patch $s "S9" $oldBlock3.Trim() $newBlock3.Trim()

# S10: исходное состояние Блок 3 (первый маркёр)
$s = Apply-Patch $s "S10" `
    '- **29 EBM-тегов** (нужно ≥30 для FULL_EBM — на пороге, добавить минимум +5–10 для запаса)' `
    '- **36 EBM-тегов уже есть** (порог FULL_EBM = 30 перекрыт), §19 EBM Benchmark на месте'

# S11: оставшиеся PARTIAL после сессии
$s = Apply-Patch $s "S11" `
    '### Оставшиеся PARTIAL_EBM после Session 53' `
    '### Оставшиеся PARTIAL_EBM после Session 54'

# S12-S16: долгосрочный план (roll-forward Session 53→54, 54→55 и т.д.)
$s = Apply-Patch $s "S12" `
    '- Session 53: vitamins.md (29 → ~40 тегов)' `
    '- Session 54: nervous_system.md (36 тегов + §19 — только структурная нормализация, добавить маркер+метаданные)'

$s = Apply-Patch $s "S13" `
    '- Session 54: female_hormones.md (29 → ~35, добавить 5–8)' `
    '- Session 55: female_hormones.md (29 → ~35, добавить 5–8 тегов)'

$s = Apply-Patch $s "S14" `
    '- Session 55: nervous_system.md (36 тегов + §19 — только структурная нормализация)' `
    '- Session 56: covid_pregnancy.md (16 → ~32 тега, +§21 добавления)'

$s = Apply-Patch $s "S15" `
    '- Session 56: covid_pregnancy.md (16 тегов + §21)' `
    '- Session 57: stress_adrenals.md (0 тегов, полный §Benchmark + inline-теги)'

$s = Apply-Patch $s "S16" `
    '- Session 57: stress_adrenals.md, gallbladder_health.md, pancreas_health.md (0 тегов, +Benchmark)' `
    '- Session 58: gallbladder_health.md + pancreas_health.md (0 тегов каждый, +Benchmark)'

# S17: прогноз
$s = Apply-Patch $s "S17" `
    '**Прогноз к концу Session 57:** 12/53 FULL_EBM (22.6 %), 1 PARTIAL, 40 NO_EBM.' `
    '**Прогноз к концу Session 58:** 12/53 FULL_EBM (22.6 %), 0 PARTIAL, 41 NO_EBM.'

# S18: добавить запись Session 53 в историю ПЕРЕД строкой Session 52
$historyOld = '- **Session 52** (2026-07-31, Этап F.2): `hashimoto.md`'
$historyNew = @"
- **Session 53** (2026-07-31, Этап F.2): ``vitamins.md`` PARTIAL → FULL_EBM (29 → 43 EBM-тега, v1.1 → v1.2). Скрипт ``ebm_enrich_vitamins_v2.ps1`` (168 строк, 13 патчей). Источники: Smith 2018 B12 neurology, Hemilä 2013 Cochrane Vit C, ATBC 1994 NEJM, Omenn 1996 CARET, Klein 2011 SELECT, Lonn 2005 HOPE-TOO, AIM-HIGH 2011, HPS2-THRIVE 2014, Schaumburg 1983, Caudill 2018, Wang 2011 TMAO, Koeth 2013, Unfer 2017 PCOS, D'Anna 2013 GDM. Коммит ``1fb26fe`` (+185/−17). 🎉 **7/53 FULL_EBM (13.2 %), 492 тега.**
- **Session 52** (2026-07-31, Этап F.2): ``hashimoto.md``
"@
$s = Apply-Patch $s "S18" $historyOld.Trim() $historyNew.Trim()

# S19: маркер идемпотентности v52 → v53 (в самом конце, только после успеха)
$s = Apply-Patch $s "S19" `
    '<!-- STATUS_SESSION52_APPLIED -->' `
    '<!-- STATUS_SESSION53_APPLIED -->'

# Запись STATUS.md
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path $statusPath), $s, $utf8Bom)
Write-Host "STATUS.md: $sOrig → $($s.Length) символов (Δ $($s.Length - $sOrig))" -ForegroundColor Cyan

# ---------------------------------------------------------------------
# SOURCES_INDEX.md
# ---------------------------------------------------------------------
Write-Host "`n=== 2. SOURCES_INDEX.md ===" -ForegroundColor Cyan
Copy-Item $sourcesPath "$sourcesPath.bak.$stamp"
Write-Host "✓ Backup: $sourcesPath.bak.$stamp" -ForegroundColor Green

$si = [System.IO.File]::ReadAllText((Resolve-Path $sourcesPath), [System.Text.Encoding]::UTF8)
$siOrig = $si.Length

# I1: FULL_EBM 6 → 7 файлов + добавить vitamins.md
$si = Apply-Patch $si "I1" `
    '- **FULL_EBM — 6 файлов (11.3 %):** `autoimmune_basics.md`, `hashimoto.md`, `joints_osteoporosis.md`, `minerals.md`, `nutraceuticals.md`, `thyroid_health.md`.' `
    '- **FULL_EBM — 7 файлов (13.2 %):** `autoimmune_basics.md`, `hashimoto.md`, `joints_osteoporosis.md`, `minerals.md`, `nutraceuticals.md`, `thyroid_health.md`, `vitamins.md`.'

# I2: PARTIAL_EBM 7 → 6 файлов, убрать vitamins.md
$si = Apply-Patch $si "I2" `
    '- **PARTIAL_EBM — 7 файлов (13.2 %):** `covid_pregnancy.md`, `female_hormones.md`, `gallbladder_health.md`, `nervous_system.md`, `pancreas_health.md`, `stress_adrenals.md`, `vitamins.md`.' `
    '- **PARTIAL_EBM — 6 файлов (11.3 %):** `covid_pregnancy.md`, `female_hormones.md`, `gallbladder_health.md`, `nervous_system.md`, `pancreas_health.md`, `stress_adrenals.md`.'

# I3: всего 478 → 492
$si = Apply-Patch $si "I3" `
    '- **Всего:** 478 EBM-тегов, 37 375 строк методологии (обновлено Session 52, 2026-07-31).' `
    '- **Всего:** 492 EBM-тега, 37 375 строк методологии (обновлено Session 53, 2026-07-31).'

# I4: маркер v52 → v53
$si = Apply-Patch $si "I4" `
    '<!-- SOURCES_INDEX_EBM_APPLIED_v52 -->' `
    '<!-- SOURCES_INDEX_EBM_APPLIED_v53 -->'

# Запись SOURCES_INDEX.md
[System.IO.File]::WriteAllText((Resolve-Path $sourcesPath), $si, $utf8Bom)
Write-Host "SOURCES_INDEX.md: $siOrig → $($si.Length) символов (Δ $($si.Length - $siOrig))" -ForegroundColor Cyan

# ---------------------------------------------------------------------
# ВАЛИДАЦИЯ — правило Session 52: контентные маркеры, а не только идемпотентность
# ---------------------------------------------------------------------
Write-Host "`n=== 3. ВАЛИДАЦИЯ ===" -ForegroundColor Cyan

$sFinal  = [System.IO.File]::ReadAllText((Resolve-Path $statusPath),  [System.Text.Encoding]::UTF8)
$siFinal = [System.IO.File]::ReadAllText((Resolve-Path $sourcesPath), [System.Text.Encoding]::UTF8)

$checks = @(
    @{ Name="STATUS: Session 53 в Блок 1";      Ok=$sFinal.Contains('на 2026-07-31, Session 53') },
    @{ Name="STATUS: 7 FULL_EBM (13.2%)";       Ok=$sFinal.Contains('FULL_EBM: 7/53 файлов (13.2%)') },
    @{ Name="STATUS: 6 PARTIAL (11.3%)";        Ok=$sFinal.Contains('PARTIAL_EBM: 6/53 файлов (11.3%)') },
    @{ Name="STATUS: 492 тега";                 Ok=$sFinal.Contains('Всего EBM-тегов: **492**') },
    @{ Name="STATUS: Session 54 Блок 3";        Ok=$sFinal.Contains('Session 54 (Этап F.2') },
    @{ Name="STATUS: nervous_system цель";      Ok=$sFinal.Contains('nervous_system.md') -and $sFinal.Contains('быстрая доводка') },
    @{ Name="STATUS: Session 53 в истории";     Ok=$sFinal.Contains('Session 53** (2026-07-31, Этап F.2): `vitamins.md`') },
    @{ Name="STATUS: маркер v53";               Ok=$sFinal.Contains('<!-- STATUS_SESSION53_APPLIED -->') },
    @{ Name="STATUS: старый маркер v52 удалён"; Ok=(-not $sFinal.Contains('STATUS_SESSION52_APPLIED')) },
    @{ Name="SOURCES: FULL 7 файлов";           Ok=$siFinal.Contains('FULL_EBM — 7 файлов (13.2 %)') },
    @{ Name="SOURCES: PARTIAL 6 файлов";        Ok=$siFinal.Contains('PARTIAL_EBM — 6 файлов (11.3 %)') },
    @{ Name="SOURCES: 492 тега";                Ok=$siFinal.Contains('492 EBM-тега') },
    @{ Name="SOURCES: vitamins в FULL";         Ok=$siFinal.Contains('`thyroid_health.md`, `vitamins.md`') },
    @{ Name="SOURCES: маркер v53";              Ok=$siFinal.Contains('<!-- SOURCES_INDEX_EBM_APPLIED_v53 -->') },
    @{ Name="SOURCES: старый маркер v52 удалён"; Ok=(-not $siFinal.Contains('SOURCES_INDEX_EBM_APPLIED_v52')) }
)

$fails = 0
foreach ($c in $checks) {
    if ($c.Ok) { Write-Host ("  ✓ {0}" -f $c.Name) -ForegroundColor Green }
    else       { Write-Host ("  ✗ {0}" -f $c.Name) -ForegroundColor Red; $fails++ }
}

Write-Host "`n=== ИТОГ ===" -ForegroundColor Magenta
if ($fails -eq 0) {
    Write-Host "✅ Session 53 закрыта: 15/15 валидаций green" -ForegroundColor Green
} else {
    Write-Host "⚠️ Провалено проверок: $fails / $($checks.Count)" -ForegroundColor Yellow
    Write-Host "   Backup файлы: $statusPath.bak.$stamp, $sourcesPath.bak.$stamp"
}