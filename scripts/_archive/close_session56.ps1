# ============================================================
# close_session56.ps1
# Закрытие Session 56 — covid_pregnancy.md PARTIAL_EBM -> FULL_EBM
# Метрики: 9 -> 10 FULL_EBM (18.9 %), 4 -> 3 PARTIAL_EBM (5.7 %), 500 -> 514 tags
# Маркеры v55 -> v56
# Транзакционный: Read -> Apply -> Validate -> Write (L-053-01)
# ============================================================

$ErrorActionPreference = 'Stop'

# === GUARD ===
$statusInit = [System.IO.File]::ReadAllText((Resolve-Path 'project/STATUS.md'), [System.Text.Encoding]::UTF8)
$sourcesInit = [System.IO.File]::ReadAllText((Resolve-Path 'v2/SOURCES_INDEX.md'), [System.Text.Encoding]::UTF8)
if (($statusInit -match '<!-- STATUS_SESSION56_APPLIED -->') -or ($sourcesInit -match '<!-- SOURCES_INDEX_EBM_APPLIED_v56 -->')) {
    Write-Host "Session 56 уже закрыта. Выход." -ForegroundColor Yellow
    exit 0
}

# === BACKUP ===
$ts = Get-Date -Format 'yyyyMMdd-HHmmss'
Copy-Item 'project/STATUS.md' "project/STATUS.md.bak.$ts"
Copy-Item 'v2/SOURCES_INDEX.md' "v2/SOURCES_INDEX.md.bak.$ts"
Write-Host "Backups: project/STATUS.md.bak.$ts, v2/SOURCES_INDEX.md.bak.$ts" -ForegroundColor Green

# === READ ===
$status = $statusInit
$sources = $sourcesInit
$statusOrig = $status.Length
$sourcesOrig = $sources.Length

function Apply-Patch {
    param($id, $old, $new, [ref]$text)
    if ($text.Value -notmatch [regex]::Escape($old)) {
        Write-Host ("  {0}: FAIL - якорь не найден" -f $id) -ForegroundColor Red
        return $false
    }
    $text.Value = $text.Value.Replace($old, $new)
    Write-Host ("  {0}: OK" -f $id) -ForegroundColor Green
    return $true
}

Write-Host "`n=== STATUS.md patches ===" -ForegroundColor Cyan
$results = @()

# S1 — Последнее событие (L6)
$results += Apply-Patch 'S1' `
    '**Последнее событие:** Session 55, Этап F.2 — EBM-обогащение `female_hormones.md` (PARTIAL → FULL_EBM, 29 → 37 EBM-тегов, +8 inline, v2.1 → v2.2). Прогресс: 8 → **9 FULL_EBM** файлов (17.0 %), 5 → 4 PARTIAL, 492 → **500 EBM-тегов** (+8). 🎉 Полтысячи EBM-тегов в методологии.' `
    '**Последнее событие:** Session 56, Этап F.2 — EBM-обогащение `covid_pregnancy.md` (PARTIAL → FULL_EBM, 16 → 30 EBM-тегов, +14 inline двумя проходами, v1.1 → v1.3). Прогресс: 9 → **10 FULL_EBM** файлов (18.9 %), 4 → 3 PARTIAL, 500 → **514 EBM-тегов** (+14). Почти пятая часть методологии — FULL_EBM.' `
    ([ref]$status)

# S2 — FULL_EBM count (L87)
$results += Apply-Patch 'S2' `
    '- **FULL_EBM: 9/53 файлов (17.0%)** — было 8, +1 (`female_hormones.md`)' `
    '- **FULL_EBM: 10/53 файлов (18.9%)** — было 9, +1 (`covid_pregnancy.md`)' `
    ([ref]$status)

# S3 — PARTIAL_EBM count (L88)
$results += Apply-Patch 'S3' `
    '- **PARTIAL_EBM: 4/53 файлов (7.5%)** — было 5, -1' `
    '- **PARTIAL_EBM: 3/53 файлов (5.7%)** — было 4, -1' `
    ([ref]$status)

# S4 — Всего тегов (L90)
$results += Apply-Patch 'S4' `
    '- Всего EBM-тегов: **500** (было 492, +8 — 🎉 полтысячи EBM-тегов в методологии)' `
    '- Всего EBM-тегов: **514** (было 500, +14 — двухпроходное обогащение covid_pregnancy.md: v1 +9, v2 +5 до порога аудита 30)' `
    ([ref]$status)

# S5 — Следующая сессия заголовок (L100)
$results += Apply-Patch 'S5' `
    '## ➡️ Следующая сессия — Session 56 (Этап F.2 продолжение)' `
    '## ➡️ Следующая сессия — Session 57 (Этап F.2 продолжение)' `
    ([ref]$status)

# S6 — Оставшиеся PARTIAL заголовок (L130)
$results += Apply-Patch 'S6' `
    '### Оставшиеся PARTIAL_EBM после Session 56' `
    '### Оставшиеся PARTIAL_EBM после Session 57' `
    ([ref]$status)

# S7 — Устаревший список PARTIAL (L132)
$results += Apply-Patch 'S7' `
    'covid_pregnancy.md, female_hormones.md, gallbladder_health.md, nervous_system.md, pancreas_health.md, stress_adrenals.md — итого 6 файлов на Sessions 54–57.' `
    'gallbladder_health.md, pancreas_health.md, stress_adrenals.md — итого 3 файла на Sessions 57–59 (все с 0 тегов, требуют полного обогащения с нуля).' `
    ([ref]$status)

# S8 — устаревший план (L136) — заменяем на план Session 57
$results += Apply-Patch 'S8' `
    '- Session 56: covid_pregnancy.md (16 тегов → ~25, добавить 9-10 тегов до FULL_EBM — ACOG COVID pregnancy, RCOG, WHO, Cochrane)' `
    '- Session 57: gallbladder_health.md (0 тегов → ~30, полное обогащение с нуля — AASLD 2018, EASL 2016 gallstone guideline, Cochrane, WGO)' `
    ([ref]$status)

# S9 — вторая устаревшая строка (L138) — удаляем целиком (заменяем на пустую строку рамкой из соседних \r\n)
$results += Apply-Patch 'S9' `
    "`r`n- Session 56: covid_pregnancy.md (16 → ~32 тега, +§21 добавления)`r`n" `
    "`r`n" `
    ([ref]$status)

# S10 — маркер v55 -> v56
$results += Apply-Patch 'S10' `
    '<!-- STATUS_SESSION55_APPLIED -->' `
    '<!-- STATUS_SESSION56_APPLIED -->' `
    ([ref]$status)

Write-Host "`n=== SOURCES_INDEX.md patches ===" -ForegroundColor Cyan

# I1 — FULL_EBM list (L624) — полная строка, без Substring (L-055-01)
$results += Apply-Patch 'I1' `
    '- **FULL_EBM — 9 файлов (17.0 %):** `autoimmune_basics.md`, `female_hormones.md`, `hashimoto.md`, `joints_osteoporosis.md`, `minerals.md`, `nervous_system.md`, `nutraceuticals.md`, `thyroid_health.md`, `vitamins.md`.' `
    '- **FULL_EBM — 10 файлов (18.9 %):** `autoimmune_basics.md`, `covid_pregnancy.md`, `female_hormones.md`, `hashimoto.md`, `joints_osteoporosis.md`, `minerals.md`, `nervous_system.md`, `nutraceuticals.md`, `thyroid_health.md`, `vitamins.md`.' `
    ([ref]$sources)

# I2 — PARTIAL_EBM list (L626)
$results += Apply-Patch 'I2' `
    '- **PARTIAL_EBM — 4 файла (7.5 %):** `covid_pregnancy.md`, `gallbladder_health.md`, `pancreas_health.md`, `stress_adrenals.md`.' `
    '- **PARTIAL_EBM — 3 файла (5.7 %):** `gallbladder_health.md`, `pancreas_health.md`, `stress_adrenals.md`.' `
    ([ref]$sources)

# I3 — Итоги (L630)
$results += Apply-Patch 'I3' `
    '- **Всего:** 500 EBM-тега, 37 378 строк методологии (обновлено Session 55, 2026-07-31 — EBM-обогащение female_hormones.md, +8 inline тегов). 🎉 Полтысячи EBM-тегов.' `
    '- **Всего:** 514 EBM-тегов, ~37 400 строк методологии (обновлено Session 56, 2026-08-05 — EBM-обогащение covid_pregnancy.md двухпроходное, +14 inline тегов).' `
    ([ref]$sources)

# I4 — маркер v55 -> v56
$results += Apply-Patch 'I4' `
    '<!-- SOURCES_INDEX_EBM_APPLIED_v55 -->' `
    '<!-- SOURCES_INDEX_EBM_APPLIED_v56 -->' `
    ([ref]$sources)

if ($results -contains $false) {
    Write-Host "`nПатчи провалились. Файлы НЕ записаны." -ForegroundColor Red
    exit 1
}

# === VALIDATE ===
Write-Host "`n=== VALIDATE ===" -ForegroundColor Cyan

$checks = @(
    # STATUS.md
    @{Name='STATUS: Session 56 в Последнем событии'; Ok=($status -match 'Session 56, Этап F\.2 — EBM-обогащение `covid_pregnancy\.md`')}
    @{Name='STATUS: 10 FULL_EBM (18.9%)'; Ok=($status -match 'FULL_EBM: 10/53 файлов \(18\.9%\)')}
    @{Name='STATUS: 3 PARTIAL (5.7%)'; Ok=($status -match 'PARTIAL_EBM: 3/53 файлов \(5\.7%\)')}
    @{Name='STATUS: 514 EBM-тегов'; Ok=($status -match '\*\*514\*\*')}
    @{Name='STATUS: Session 57 заголовок'; Ok=($status -match '## ➡️ Следующая сессия — Session 57')}
    @{Name='STATUS: план Session 57 gallbladder'; Ok=($status -match 'Session 57: gallbladder_health\.md')}
    @{Name='STATUS: старый план Session 56 covid удалён (~32 тега)'; Ok=($status -notmatch 'Session 56: covid_pregnancy\.md \(16 → ~32 тега')}
    @{Name='STATUS: старый список PARTIAL 6 файлов удалён'; Ok=($status -notmatch 'covid_pregnancy\.md, female_hormones\.md, gallbladder_health\.md, nervous_system\.md')}
    @{Name='STATUS: маркер v56 присутствует'; Ok=($status -match '<!-- STATUS_SESSION56_APPLIED -->')}
    @{Name='STATUS: маркер v55 удалён'; Ok=($status -notmatch '<!-- STATUS_SESSION55_APPLIED -->')}
    # SOURCES_INDEX.md
    @{Name='SOURCES: FULL 10 файлов'; Ok=($sources -match 'FULL_EBM — 10 файлов \(18\.9 %\)')}
    @{Name='SOURCES: PARTIAL 3 файла'; Ok=($sources -match 'PARTIAL_EBM — 3 файла \(5\.7 %\)')}
    @{Name='SOURCES: covid_pregnancy в FULL списке'; Ok=($sources -match 'FULL_EBM — 10 файлов.*covid_pregnancy\.md.*female_hormones')}
    @{Name='SOURCES: 514 тегов'; Ok=($sources -match '514 EBM-тегов')}
    @{Name='SOURCES: Session 56 метаданные'; Ok=($sources -match 'обновлено Session 56')}
    @{Name='SOURCES: маркер v56'; Ok=($sources -match '<!-- SOURCES_INDEX_EBM_APPLIED_v56 -->')}
    @{Name='SOURCES: маркер v55 удалён'; Ok=($sources -notmatch '<!-- SOURCES_INDEX_EBM_APPLIED_v55 -->')}
    @{Name='Оба файла выросли или не сжались'; Ok=(($status.Length -ge $statusOrig - 100) -and ($sources.Length -ge $sourcesOrig - 50))}
)

$failed = @()
foreach ($c in $checks) {
    if ($c.Ok) {
        Write-Host ("  [OK]  {0}" -f $c.Name) -ForegroundColor Green
    } else {
        Write-Host ("  [FAIL] {0}" -f $c.Name) -ForegroundColor Red
        $failed += $c.Name
    }
}

if ($failed.Count -gt 0) {
    Write-Host "`nВалидация провалена ($($failed.Count) проверок). Файлы НЕ записаны." -ForegroundColor Red
    exit 1
}

# === WRITE ===
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path 'project/STATUS.md'), $status, $utf8Bom)
[System.IO.File]::WriteAllText((Resolve-Path 'v2/SOURCES_INDEX.md'), $sources, $utf8Bom)

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host ("  STATUS.md:        {0} -> {1} chars (delta {2:+#;-#;0})" -f $statusOrig, $status.Length, ($status.Length - $statusOrig)) -ForegroundColor Green
Write-Host ("  SOURCES_INDEX.md: {0} -> {1} chars (delta {2:+#;-#;0})" -f $sourcesOrig, $sources.Length, ($sources.Length - $sourcesOrig)) -ForegroundColor Green
Write-Host ("  FULL_EBM:         9 -> 10 (18.9 %)") -ForegroundColor Green
Write-Host ("  PARTIAL_EBM:      4 -> 3 (5.7 %)") -ForegroundColor Green
Write-Host ("  EBM tags total:   500 -> 514 (+14)") -ForegroundColor Green
Write-Host ("  Next session:     Session 57 — gallbladder_health.md (0 -> ~30 tags)") -ForegroundColor Cyan
Write-Host "`n[OK] Session 56 закрыта" -ForegroundColor Green
