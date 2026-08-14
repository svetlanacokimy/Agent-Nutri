# =====================================================================
# scripts/close_session55.ps1
# Session 55 закрытие: STATUS.md + SOURCES_INDEX.md
# female_hormones.md PARTIAL_EBM -> FULL_EBM, 500 EBM-тегов (+8)
# =====================================================================

$ErrorActionPreference = "Stop"
$statusPath  = "project/STATUS.md"
$sourcesPath = "v2/SOURCES_INDEX.md"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"

# ---------------------------------------------------------------------
# 0. Idempotency guard
# ---------------------------------------------------------------------
$statusCheck = [System.IO.File]::ReadAllText((Resolve-Path $statusPath), [System.Text.Encoding]::UTF8)
if ($statusCheck.Contains('<!-- STATUS_SESSION55_APPLIED -->')) {
    Write-Host "⊙ Маркер STATUS_SESSION55_APPLIED уже присутствует — Session 55 закрыта ранее." -ForegroundColor Yellow
    return
}

# ---------------------------------------------------------------------
# 1. Backup
# ---------------------------------------------------------------------
Write-Host "=== 1. BACKUP ===" -ForegroundColor Cyan
Copy-Item $statusPath  "$statusPath.bak.$stamp"
Copy-Item $sourcesPath "$sourcesPath.bak.$stamp"
Write-Host "✓ $statusPath.bak.$stamp" -ForegroundColor Green
Write-Host "✓ $sourcesPath.bak.$stamp" -ForegroundColor Green

# ---------------------------------------------------------------------
# 2. Apply-Patch
# ---------------------------------------------------------------------
function Apply-Patch {
    param([string]$text, [string]$id, [string]$old, [string]$new)
    if ($text.Contains($new) -and -not $text.Contains($old)) {
        Write-Host "  ⊙ $id : уже применён" -ForegroundColor DarkGray
        return $text
    }
    if (-not $text.Contains($old)) {
        Write-Host "  ✗ $id : OLD NOT FOUND" -ForegroundColor Red
        throw "Patch $id failed"
    }
    Write-Host "  ✓ $id" -ForegroundColor Green
    return $text.Replace($old, $new)
}

# ---------------------------------------------------------------------
# 3. STATUS.md — 10 патчей
# ---------------------------------------------------------------------
Write-Host "`n=== 2. STATUS.md ===" -ForegroundColor Cyan
$s = [System.IO.File]::ReadAllText((Resolve-Path $statusPath), [System.Text.Encoding]::UTF8)
$sOrig = $s.Length

$s = Apply-Patch $s "S1" `
    '**Последнее событие:** Session 54, Этап F.2 — структурная нормализация `nervous_system.md` (PARTIAL → FULL_EBM, 36 EBM-тегов подтверждено, v1.1 → v1.2, только маркер+метаданные). Прогресс: 7 → **8 FULL_EBM** файлов (15.1 %), 6 → 5 PARTIAL, 492 EBM-тега (без изменений).' `
    '**Последнее событие:** Session 55, Этап F.2 — EBM-обогащение `female_hormones.md` (PARTIAL → FULL_EBM, 29 → 37 EBM-тегов, +8 inline, v2.1 → v2.2). Прогресс: 8 → **9 FULL_EBM** файлов (17.0 %), 5 → 4 PARTIAL, 492 → **500 EBM-тегов** (+8). 🎉 Полтысячи EBM-тегов в методологии.'

$s = Apply-Patch $s "S2" `
    '**Тема:** структурная нормализация `nervous_system.md` — PARTIAL_EBM → FULL_EBM (метаданные + маркер идемпотентности)' `
    '**Тема:** EBM-обогащение `female_hormones.md` — PARTIAL_EBM → FULL_EBM (+8 inline тегов в §5/§8/§12/§13/§18/§19/§21/§23)'

$s = Apply-Patch $s "S3" `
    '- **FULL_EBM: 8/53 файлов (15.1%)** — было 7, +1 (`nervous_system.md`)' `
    '- **FULL_EBM: 9/53 файлов (17.0%)** — было 8, +1 (`female_hormones.md`)'

$s = Apply-Patch $s "S4" `
    '- **PARTIAL_EBM: 5/53 файлов (9.4%)** — было 6, -1' `
    '- **PARTIAL_EBM: 4/53 файлов (7.5%)** — было 5, -1'

$s = Apply-Patch $s "S5" `
    '- Всего EBM-тегов: **492** (без изменений — Session 54 была структурной нормализацией)' `
    '- Всего EBM-тегов: **500** (было 492, +8 — 🎉 полтысячи EBM-тегов в методологии)'

$s = Apply-Patch $s "S6" `
    '## ➡️ Следующая сессия — Session 55 (Этап F.2 продолжение)' `
    '## ➡️ Следующая сессия — Session 56 (Этап F.2 продолжение)'

$s = Apply-Patch $s "S7" `
    '### Оставшиеся PARTIAL_EBM после Session 55' `
    '### Оставшиеся PARTIAL_EBM после Session 56'

$s = Apply-Patch $s "S8" `
    '- Session 55: female_hormones.md (29 тегов → ~35, добавить 5-8 тегов до FULL_EBM)' `
    '- Session 56: covid_pregnancy.md (16 тегов → ~25, добавить 9-10 тегов до FULL_EBM — ACOG COVID pregnancy, RCOG, WHO, Cochrane)'

$s9old = '- **Session 54** (2026-07-31, Этап F.2): `nervous_system.md` PARTIAL'
$s9new = '- **Session 55** (2026-07-31, Этап F.2): `female_hormones.md` PARTIAL → FULL_EBM (+8 inline EBM-тегов: 29 → 37, v2.1 → v2.2). Теги в §5 Прогестерон (Stanczyk 2013 / Prior 2015), §8 Пролактин + §12 Гиперпролактинемия (Melmed 2011 Endocrine Society), §13 ПМС/ПМДР (ACOG 2023, Cochrane Whelan 2009 B6, Thys-Jacobs 1998 Ca RCT), §18 КОК (Palmery 2013, WHO MEC 2015), §19 Лабдиагностика (ESHRE Rotterdam 2003, Monash 2018, NICE NG73), §21 Питание и §23 Образ жизни (Monash 2018, NAMS 2022). Коммит `6013e29` (+13/-12). 🎉 **9/53 FULL_EBM (17.0 %), 500 EBM-тегов (+8) — полтысячи.**' + "`n" + '- **Session 54** (2026-07-31, Этап F.2): `nervous_system.md` PARTIAL'
$s = Apply-Patch $s "S9" $s9old $s9new

$s = Apply-Patch $s "S10" `
    '<!-- STATUS_SESSION54_APPLIED -->' `
    '<!-- STATUS_SESSION55_APPLIED -->'

# ---------------------------------------------------------------------
# 4. SOURCES_INDEX.md — 4 патча
# ---------------------------------------------------------------------
Write-Host "`n=== 3. SOURCES_INDEX.md ===" -ForegroundColor Cyan
$si = [System.IO.File]::ReadAllText((Resolve-Path $sourcesPath), [System.Text.Encoding]::UTF8)
$siOrig = $si.Length

$si = Apply-Patch $si "I1" `
    '- **FULL_EBM — 8 файлов (15.1 %):** `autoimmune_basics.md`, `hashimoto.md`, `joints_osteoporosis.md`, `minerals.md`, `nervous_system.md`,`nutraceuticals.md`, `thyroid_health.md`, `vitamins.md`.' `
    '- **FULL_EBM — 9 файлов (17.0 %):** `autoimmune_basics.md`, `female_hormones.md`, `hashimoto.md`, `joints_osteoporosis.md`, `minerals.md`, `nervous_system.md`, `nutraceuticals.md`, `thyroid_health.md`, `vitamins.md`.'

$si = Apply-Patch $si "I2" `
    '- **PARTIAL_EBM — 5 файлов (9.4 %):** `covid_pregnancy.md`, `female_hormones.md`, `gallbladder_health.md`, `pancreas_health.md`, `stress_adrenals.md`.' `
    '- **PARTIAL_EBM — 4 файла (7.5 %):** `covid_pregnancy.md`, `gallbladder_health.md`, `pancreas_health.md`, `stress_adrenals.md`.'

$si = Apply-Patch $si "I3" `
    '- **Всего:** 492 EBM-тега, 37 378 строк методологии (обновлено Session 54, 2026-07-31 — структурная нормализация nervous_system.md, +3 строки метаданных).' `
    '- **Всего:** 500 EBM-тега, 37 378 строк методологии (обновлено Session 55, 2026-07-31 — EBM-обогащение female_hormones.md, +8 inline тегов). 🎉 Полтысячи EBM-тегов.'

$si = Apply-Patch $si "I4" `
    '<!-- SOURCES_INDEX_EBM_APPLIED_v54 -->' `
    '<!-- SOURCES_INDEX_EBM_APPLIED_v55 -->'

# ---------------------------------------------------------------------
# 5. WRITE
# ---------------------------------------------------------------------
Write-Host "`n=== 4. WRITE ===" -ForegroundColor Cyan
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path $statusPath),  $s,  $utf8Bom)
[System.IO.File]::WriteAllText((Resolve-Path $sourcesPath), $si, $utf8Bom)
Write-Host "STATUS.md: $sOrig → $($s.Length) (Δ $($s.Length - $sOrig))"
Write-Host "SOURCES_INDEX.md: $siOrig → $($si.Length) (Δ $($si.Length - $siOrig))"

# ---------------------------------------------------------------------
# 6. Валидация
# ---------------------------------------------------------------------
Write-Host "`n=== 5. ВАЛИДАЦИЯ ===" -ForegroundColor Cyan
$sFinal  = [System.IO.File]::ReadAllText((Resolve-Path $statusPath),  [System.Text.Encoding]::UTF8)
$siFinal = [System.IO.File]::ReadAllText((Resolve-Path $sourcesPath), [System.Text.Encoding]::UTF8)

$checks = @(
    @{ Name="STATUS: Session 55 в Блок 1";          Ok=$sFinal.Contains('Session 55, Этап F.2 — EBM-обогащение') },
    @{ Name="STATUS: 9 FULL_EBM (17.0%)";           Ok=$sFinal.Contains('FULL_EBM: 9/53 файлов (17.0%)') },
    @{ Name="STATUS: 4 PARTIAL (7.5%)";             Ok=$sFinal.Contains('PARTIAL_EBM: 4/53 файлов (7.5%)') },
    @{ Name="STATUS: 500 тегов";                    Ok=$sFinal.Contains('Всего EBM-тегов: **500**') },
    @{ Name="STATUS: полтысячи упомянуто";          Ok=$sFinal.Contains('полтысячи') },
    @{ Name="STATUS: Session 56 Блок 3";            Ok=$sFinal.Contains('Session 56 (Этап F.2') },
    @{ Name="STATUS: covid_pregnancy цель";         Ok=$sFinal.Contains('Session 56: covid_pregnancy.md') },
    @{ Name="STATUS: Session 55 в истории";         Ok=$sFinal.Contains('**Session 55** (2026-07-31, Этап F.2): `female_hormones.md`') },
    @{ Name="STATUS: коммит 6013e29";               Ok=$sFinal.Contains('6013e29') },
    @{ Name="STATUS: маркер v55";                   Ok=$sFinal.Contains('<!-- STATUS_SESSION55_APPLIED -->') },
    @{ Name="STATUS: маркер v54 удалён";            Ok=(-not $sFinal.Contains('STATUS_SESSION54_APPLIED')) },
    @{ Name="SOURCES: FULL 9 файлов";               Ok=$siFinal.Contains('FULL_EBM — 9 файлов (17.0 %)') },
    @{ Name="SOURCES: PARTIAL 4 файла";             Ok=$siFinal.Contains('PARTIAL_EBM — 4 файла (7.5 %)') },
    @{ Name="SOURCES: female_hormones в FULL";      Ok=$siFinal.Contains('`autoimmune_basics.md`, `female_hormones.md`') },
    @{ Name="SOURCES: 500 тегов";                   Ok=$siFinal.Contains('500 EBM-тега') },
    @{ Name="SOURCES: Session 55 в метаданных";     Ok=$siFinal.Contains('обновлено Session 55') },
    @{ Name="SOURCES: маркер v55";                  Ok=$siFinal.Contains('<!-- SOURCES_INDEX_EBM_APPLIED_v55 -->') },
    @{ Name="SOURCES: маркер v54 удалён";           Ok=(-not $siFinal.Contains('SOURCES_INDEX_EBM_APPLIED_v54')) }
)

$fails = 0
foreach ($c in $checks) {
    if ($c.Ok) { Write-Host ("  ✓ {0}" -f $c.Name) -ForegroundColor Green }
    else       { Write-Host ("  ✗ {0}" -f $c.Name) -ForegroundColor Red; $fails++ }
}

Write-Host "`n=== ИТОГ ===" -ForegroundColor Magenta
if ($fails -eq 0) {
    Write-Host "✅ Session 55 закрыта: $($checks.Count)/$($checks.Count) валидаций green" -ForegroundColor Green
    Write-Host "   FULL_EBM: 8 → 9 файлов (15.1% → 17.0%)" -ForegroundColor Green
    Write-Host "   PARTIAL_EBM: 5 → 4 файла (9.4% → 7.5%)" -ForegroundColor Green
    Write-Host "   EBM-тегов: 492 → 500 (+8) 🎉 полтысячи" -ForegroundColor Green
} else {
    Write-Host "⚠️ Провалено проверок: $fails / $($checks.Count)" -ForegroundColor Yellow
    Write-Host "   Восстановление: Copy-Item $statusPath.bak.$stamp $statusPath -Force"
    Write-Host "                    Copy-Item $sourcesPath.bak.$stamp $sourcesPath -Force"
}
