# =====================================================================
# scripts/fix_status_session55.ps1
# Ремонт STATUS.md для Session 55 (SOURCES_INDEX.md уже обновлён вручную)
# 10 патчей S1–S10, транзакционно, с backup и idempotency guard
# =====================================================================

$ErrorActionPreference = "Stop"
$path = "project/STATUS.md"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"

# Idempotency guard
$check = [System.IO.File]::ReadAllText((Resolve-Path $path), [System.Text.Encoding]::UTF8)
if ($check.Contains('<!-- STATUS_SESSION55_APPLIED -->')) {
    Write-Host "⊙ STATUS_SESSION55_APPLIED уже присутствует. Ничего не делаю." -ForegroundColor Yellow
    return
}

# Backup
Write-Host "=== 1. BACKUP ===" -ForegroundColor Cyan
Copy-Item $path "$path.bak.$stamp"
Write-Host "✓ $path.bak.$stamp" -ForegroundColor Green

# Apply-Patch
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

Write-Host "`n=== 2. PATCHES ===" -ForegroundColor Cyan
$s = [System.IO.File]::ReadAllText((Resolve-Path $path), [System.Text.Encoding]::UTF8)
$orig = $s.Length

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

Write-Host "`n=== 3. WRITE ===" -ForegroundColor Cyan
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path $path), $s, $utf8Bom)
Write-Host "STATUS.md: $orig → $($s.Length) (Δ $($s.Length - $orig))"

Write-Host "`n=== 4. ВАЛИДАЦИЯ ===" -ForegroundColor Cyan
$f = [System.IO.File]::ReadAllText((Resolve-Path $path), [System.Text.Encoding]::UTF8)

$checks = @(
    @{ Name="Session 55 в Блок 1";        Ok=$f.Contains('Session 55, Этап F.2 — EBM-обогащение') },
    @{ Name="9 FULL_EBM (17.0%)";         Ok=$f.Contains('FULL_EBM: 9/53 файлов (17.0%)') },
    @{ Name="4 PARTIAL (7.5%)";           Ok=$f.Contains('PARTIAL_EBM: 4/53 файлов (7.5%)') },
    @{ Name="500 тегов";                  Ok=$f.Contains('Всего EBM-тегов: **500**') },
    @{ Name="полтысячи";                  Ok=$f.Contains('полтысячи') },
    @{ Name="Session 56 Блок 3";          Ok=$f.Contains('Session 56 (Этап F.2') },
    @{ Name="covid_pregnancy цель";       Ok=$f.Contains('Session 56: covid_pregnancy.md') },
    @{ Name="Session 55 в истории";       Ok=$f.Contains('**Session 55** (2026-07-31, Этап F.2): `female_hormones.md`') },
    @{ Name="коммит 6013e29";             Ok=$f.Contains('6013e29') },
    @{ Name="маркер v55";                 Ok=$f.Contains('<!-- STATUS_SESSION55_APPLIED -->') },
    @{ Name="маркер v54 удалён";          Ok=(-not $f.Contains('STATUS_SESSION54_APPLIED')) }
)

$fails = 0
foreach ($c in $checks) {
    if ($c.Ok) { Write-Host ("  ✓ {0}" -f $c.Name) -ForegroundColor Green }
    else       { Write-Host ("  ✗ {0}" -f $c.Name) -ForegroundColor Red; $fails++ }
}

Write-Host "`n=== ИТОГ ===" -ForegroundColor Magenta
if ($fails -eq 0) {
    Write-Host "✅ STATUS.md обновлён: 11/11 валидаций green" -ForegroundColor Green
    Write-Host "   9/53 FULL_EBM (17.0 %), 4 PARTIAL (7.5 %), 500 EBM-тегов" -ForegroundColor Green
} else {
    Write-Host "⚠️ Провалено: $fails / $($checks.Count)" -ForegroundColor Yellow
    Write-Host "   Восстановление: Copy-Item $path.bak.$stamp $path -Force"
}
