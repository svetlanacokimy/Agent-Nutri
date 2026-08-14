# =====================================================================
# scripts/close_session54.ps1
# Session 54 закрытие: STATUS.md + SOURCES_INDEX.md
# Правило Session 52+54: транзакционность (Read → Patch → Validate → Write)
# =====================================================================

$ErrorActionPreference = "Stop"
$statusPath  = "project/STATUS.md"
$sourcesPath = "v2/SOURCES_INDEX.md"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"

# ---------------------------------------------------------------------
# 0. Idempotency guard
# ---------------------------------------------------------------------
$statusCheck = [System.IO.File]::ReadAllText((Resolve-Path $statusPath), [System.Text.Encoding]::UTF8)
if ($statusCheck.Contains('<!-- STATUS_SESSION54_APPLIED -->')) {
    Write-Host "⊙ Маркер STATUS_SESSION54_APPLIED уже присутствует — Session 54 закрыта ранее." -ForegroundColor Yellow
    Write-Host "  Ничего не делаю (idempotent)." -ForegroundColor Yellow
    return
}

# ---------------------------------------------------------------------
# 1. Backup обоих файлов
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
    '**Последнее событие:** Session 53, Этап F.2 — EBM-обогащение `vitamins.md` (PARTIAL → FULL_EBM, 29 → 43 EBM-тега, v1.1 → v1.2). Прогресс: 6 → **7 FULL_EBM** файлов (13.2 %), 7 → 6 PARTIAL, 492 EBM-тега всего.' `
    '**Последнее событие:** Session 54, Этап F.2 — структурная нормализация `nervous_system.md` (PARTIAL → FULL_EBM, 36 EBM-тегов подтверждено, v1.1 → v1.2, только маркер+метаданные). Прогресс: 7 → **8 FULL_EBM** файлов (15.1 %), 6 → 5 PARTIAL, 492 EBM-тега (без изменений).'

$s = Apply-Patch $s "S2" `
    '**Тема:** EBM-обогащение `vitamins.md` — PARTIAL_EBM → FULL_EBM' `
    '**Тема:** структурная нормализация `nervous_system.md` — PARTIAL_EBM → FULL_EBM (метаданные + маркер идемпотентности)'

$s = Apply-Patch $s "S3" `
    '- **FULL_EBM: 7/53 файлов (13.2%)** — было 6, +1 (`vitamins.md`)' `
    '- **FULL_EBM: 8/53 файлов (15.1%)** — было 7, +1 (`nervous_system.md`)'

$s = Apply-Patch $s "S4" `
    '- **PARTIAL_EBM: 6/53 файлов (11.3%)** — было 7, -1' `
    '- **PARTIAL_EBM: 5/53 файлов (9.4%)** — было 6, -1'

$s = Apply-Patch $s "S5" `
    '- Всего EBM-тегов: **492** (было 478, +14)' `
    '- Всего EBM-тегов: **492** (без изменений — Session 54 была структурной нормализацией)'

$s = Apply-Patch $s "S6" `
    '## ➡️ Следующая сессия — Session 54 (Этап F.2 продолжение)' `
    '## ➡️ Следующая сессия — Session 55 (Этап F.2 продолжение)'

$s = Apply-Patch $s "S7" `
    '### Оставшиеся PARTIAL_EBM после Session 54' `
    '### Оставшиеся PARTIAL_EBM после Session 55'

$s = Apply-Patch $s "S8" `
    '- Session 54: nervous_system.md (36 тегов + §19 — только структурная нормализация, добавить маркер+метаданные)' `
    '- Session 55: female_hormones.md (29 тегов → ~35, добавить 5-8 тегов до FULL_EBM)'

$s9old = '- **Session 53** (2026-07-31, Этап F.2): `vitamins.md` PARTIAL'
$s9new = '- **Session 54** (2026-07-31, Этап F.2): `nervous_system.md` PARTIAL → FULL_EBM (36 EBM-тегов подтверждено, v1.1 → v1.2). Структурная нормализация без правки контента: маркер `<!-- EBM_ENRICHED_v1.2 -->`, статус EBM-lite → FULL_EBM, история версий v1.0 → v1.1 → v1.2. Атомарные патчи вместо multiline-скрипта (правило Session 52 + урок Session 54: multiline @-strings в PS 5.x → возврат к формату Session 50-53). Коммит `46fc173` (+6/-3). 🎉 **8/53 FULL_EBM (15.1 %), 492 тега (без изменений).**' + "`n" + '- **Session 53** (2026-07-31, Этап F.2): `vitamins.md` PARTIAL'
$s = Apply-Patch $s "S9" $s9old $s9new

$s = Apply-Patch $s "S10" `
    '<!-- STATUS_SESSION53_APPLIED -->' `
    '<!-- STATUS_SESSION54_APPLIED -->'

# ---------------------------------------------------------------------
# 4. SOURCES_INDEX.md — 4 патча
# ---------------------------------------------------------------------
Write-Host "`n=== 3. SOURCES_INDEX.md ===" -ForegroundColor Cyan
$si = [System.IO.File]::ReadAllText((Resolve-Path $sourcesPath), [System.Text.Encoding]::UTF8)
$siOrig = $si.Length

$si = Apply-Patch $si "I1" `
    '- **FULL_EBM — 7 файлов (13.2 %):** `autoimmune_basics.md`, `hashimoto.md`, `joints_osteoporosis.md`, `minerals.md`, `nutraceuticals.md`, `thyroid_health.md`, `vitamins.md`.' `
    '- **FULL_EBM — 8 файлов (15.1 %):** `autoimmune_basics.md`, `hashimoto.md`, `joints_osteoporosis.md`, `minerals.md`, `nervous_system.md`, `nutraceuticals.md`, `thyroid_health.md`, `vitamins.md`.'

$si = Apply-Patch $si "I2" `
    '- **PARTIAL_EBM — 6 файлов (11.3 %):** `covid_pregnancy.md`, `female_hormones.md`, `gallbladder_health.md`, `nervous_system.md`, `pancreas_health.md`, `stress_adrenals.md`.' `
    '- **PARTIAL_EBM — 5 файлов (9.4 %):** `covid_pregnancy.md`, `female_hormones.md`, `gallbladder_health.md`, `pancreas_health.md`, `stress_adrenals.md`.'

$si = Apply-Patch $si "I3" `
    '- **Всего:** 492 EBM-тега, 37 375 строк методологии (обновлено Session 53, 2026-07-31).' `
    '- **Всего:** 492 EBM-тега, 37 378 строк методологии (обновлено Session 54, 2026-07-31 — структурная нормализация nervous_system.md, +3 строки метаданных).'

$si = Apply-Patch $si "I4" `
    '<!-- SOURCES_INDEX_EBM_APPLIED_v53 -->' `
    '<!-- SOURCES_INDEX_EBM_APPLIED_v54 -->'

# ---------------------------------------------------------------------
# 5. Запись файлов
# ---------------------------------------------------------------------
Write-Host "`n=== 4. WRITE ===" -ForegroundColor Cyan
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path $statusPath),  $s,  $utf8Bom)
[System.IO.File]::WriteAllText((Resolve-Path $sourcesPath), $si, $utf8Bom)
Write-Host "STATUS.md: $sOrig → $($s.Length) символов (Δ $($s.Length - $sOrig))"
Write-Host "SOURCES_INDEX.md: $siOrig → $($si.Length) символов (Δ $($si.Length - $siOrig))"

# ---------------------------------------------------------------------
# 6. Валидация (15 проверок)
# ---------------------------------------------------------------------
Write-Host "`n=== 5. ВАЛИДАЦИЯ ===" -ForegroundColor Cyan
$sFinal  = [System.IO.File]::ReadAllText((Resolve-Path $statusPath),  [System.Text.Encoding]::UTF8)
$siFinal = [System.IO.File]::ReadAllText((Resolve-Path $sourcesPath), [System.Text.Encoding]::UTF8)

$checks = @(
    @{ Name="STATUS: Session 54 в Блок 1";           Ok=$sFinal.Contains('Session 54, Этап F.2 — структурная нормализация') },
    @{ Name="STATUS: 8 FULL_EBM (15.1%)";            Ok=$sFinal.Contains('FULL_EBM: 8/53 файлов (15.1%)') },
    @{ Name="STATUS: 5 PARTIAL (9.4%)";              Ok=$sFinal.Contains('PARTIAL_EBM: 5/53 файлов (9.4%)') },
    @{ Name="STATUS: 492 тега (без изменений)";      Ok=$sFinal.Contains('(без изменений — Session 54 была структурной') },
    @{ Name="STATUS: Session 55 Блок 3";             Ok=$sFinal.Contains('Session 55 (Этап F.2') },
    @{ Name="STATUS: female_hormones цель";          Ok=$sFinal.Contains('Session 55: female_hormones.md') },
    @{ Name="STATUS: Session 54 в истории";          Ok=$sFinal.Contains('**Session 54** (2026-07-31, Этап F.2): `nervous_system.md`') },
    @{ Name="STATUS: маркер v54";                    Ok=$sFinal.Contains('<!-- STATUS_SESSION54_APPLIED -->') },
    @{ Name="STATUS: старый маркер v53 удалён";      Ok=(-not $sFinal.Contains('STATUS_SESSION53_APPLIED')) },
    @{ Name="SOURCES: FULL 8 файлов";                Ok=$siFinal.Contains('FULL_EBM — 8 файлов (15.1 %)') },
    @{ Name="SOURCES: PARTIAL 5 файлов";             Ok=$siFinal.Contains('PARTIAL_EBM — 5 файлов (9.4 %)') },
    @{ Name="SOURCES: nervous_system в FULL";        Ok=$siFinal.Contains('`nervous_system.md`, `nutraceuticals.md`') },
    @{ Name="SOURCES: Session 54 в метаданных";      Ok=$siFinal.Contains('обновлено Session 54') },
    @{ Name="SOURCES: маркер v54";                   Ok=$siFinal.Contains('<!-- SOURCES_INDEX_EBM_APPLIED_v54 -->') },
    @{ Name="SOURCES: старый маркер v53 удалён";     Ok=(-not $siFinal.Contains('SOURCES_INDEX_EBM_APPLIED_v53')) }
)

$fails = 0
foreach ($c in $checks) {
    if ($c.Ok) { Write-Host ("  ✓ {0}" -f $c.Name) -ForegroundColor Green }
    else       { Write-Host ("  ✗ {0}" -f $c.Name) -ForegroundColor Red; $fails++ }
}

Write-Host "`n=== ИТОГ ===" -ForegroundColor Magenta
if ($fails -eq 0) {
    Write-Host "✅ Session 54 закрыта: 15/15 валидаций green" -ForegroundColor Green
    Write-Host "   FULL_EBM: 7 → 8 файлов (13.2% → 15.1%)" -ForegroundColor Green
    Write-Host "   PARTIAL_EBM: 6 → 5 файлов (11.3% → 9.4%)" -ForegroundColor Green
    Write-Host "   Тегов: 492 (без изменений)" -ForegroundColor Green
} else {
    Write-Host "⚠️ Провалено проверок: $fails / $($checks.Count)" -ForegroundColor Yellow
    Write-Host "   Восстановление: Copy-Item $statusPath.bak.$stamp $statusPath -Force"
    Write-Host "                    Copy-Item $sourcesPath.bak.$stamp $sourcesPath -Force"
}
