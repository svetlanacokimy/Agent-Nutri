# ============================================================================
# close_session57.ps1 (v2 - fixed backticks)
# Session 57 (2026-08-05) — closing: update STATUS.md + SOURCES_INDEX.md
# L-057-01: markdown backticks в якорях — только через '...' single quotes
# ============================================================================

$ErrorActionPreference = "Stop"
Write-Host "=== close_session57 ===" -ForegroundColor Cyan

$sPath = Resolve-Path "project/STATUS.md"
$iPath = Resolve-Path "v2/SOURCES_INDEX.md"
$s = [System.IO.File]::ReadAllText($sPath, [System.Text.Encoding]::UTF8)
$i = [System.IO.File]::ReadAllText($iPath, [System.Text.Encoding]::UTF8)

if ($s -match '<!--\s*STATUS_SESSION57_APPLIED\s*-->') {
    Write-Host "[GUARD] Session 57 already closed." -ForegroundColor Yellow
    exit 0
}
$sOrig = $s.Length
$iOrig = $i.Length

$ts = Get-Date -Format "yyyyMMdd-HHmmss"
Copy-Item $sPath "project/STATUS.md.bak.$ts" -Force
Copy-Item $iPath "v2/SOURCES_INDEX.md.bak.$ts" -Force
Write-Host "[BACKUP] project/STATUS.md.bak.$ts + v2/SOURCES_INDEX.md.bak.$ts" -ForegroundColor Green

function Apply($id, $old, $new, [ref]$text) {
    if ($text.Value.Contains($old)) {
        $text.Value = $text.Value.Replace($old, $new)
        Write-Host "  [$id] OK" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  [$id] ANCHOR NOT FOUND" -ForegroundColor Red
        Write-Host "    first 100: $($old.Substring(0, [Math]::Min(100, $old.Length)))" -ForegroundColor DarkRed
        return $false
    }
}

# ============================================================================
# STATUS.md
# ============================================================================

$ok = $true

# S1
$s1old = '**Последнее событие:** Session 56, Этап F.2 — EBM-обогащение `covid_pregnancy.md` (PARTIAL → FULL_EBM, 16 → 30 EBM-тегов, +14 inline двумя проходами, v1.1 → v1.3). Прогресс: 9 → **10 FULL_EBM** файлов (18.9 %), 4 → 3 PARTIAL, 500 → **514 EBM-тегов** (+14). Почти пятая часть методологии — FULL_EBM.'
$s1new = '**Последнее событие:** Session 57, Этап F.2 — EBM-обогащение `gallbladder_health.md` (NO_EBM → FULL_EBM, 0 → 30 EBM-тегов, +30 inline с нуля, v2.0 → v2.1). Прогресс: 10 → **11 FULL_EBM** файлов (20.8 %), 3 → 2 PARTIAL, 514 → **544 EBM-тегов** (+30). 🎯 Впервые >= 20 % методологии — FULL_EBM.'
$ok = (Apply "S1" $s1old $s1new ([ref]$s)) -and $ok

# S2
$s2old = '- **FULL_EBM: 10/53 файлов (18.9%)** — было 9, +1 (`covid_pregnancy.md`)'
$s2new = '- **FULL_EBM: 11/53 файлов (20.8%)** — было 10, +1 (`gallbladder_health.md`)'
$ok = (Apply "S2" $s2old $s2new ([ref]$s)) -and $ok

# S3
$s3old = '- **PARTIAL_EBM: 3/53 файлов (5.7%)** — было 4, -1'
$s3new = '- **PARTIAL_EBM: 2/53 файлов (3.8%)** — было 3, -1 (gallbladder ушёл в FULL_EBM; классификация аудита: pancreas_health.md и stress_adrenals.md имеют Benchmark-секцию без тегов)'
$ok = (Apply "S3" $s3old $s3new ([ref]$s)) -and $ok

# S4
$s4old = '- Всего EBM-тегов: **514** (было 500, +14 — двухпроходное обогащение covid_pregnancy.md: v1 +9, v2 +5 до порога аудита 30)'
$s4new = '- Всего EBM-тегов: **544** (было 514, +30 — полное EBM-обогащение gallbladder_health.md с нуля в 22 из 27 H2-секций)'
$ok = (Apply "S4" $s4old $s4new ([ref]$s)) -and $ok

# S5
$s5old = '## ➡️ Следующая сессия — Session 57 (Этап F.2 продолжение)'
$s5new = '## ➡️ Следующая сессия — Session 58 (Этап F.2 продолжение)'
$ok = (Apply "S5" $s5old $s5new ([ref]$s)) -and $ok

# S6
$s6old = '**Цель:** структурная нормализация `nervous_system.md` (PARTIAL_EBM → FULL_EBM, быстрая доводка)'
$s6new = '**Цель:** EBM-обогащение `pancreas_health.md` (PARTIAL_EBM → FULL_EBM, 0 → ~30 EBM-тегов, полное обогащение с нуля — UEG 2017, ACG guidelines, TIGAR-O, Atlanta 2012, Hardt/Ewald для СД 3c, Hamano 2001 для АИП)'
$ok = (Apply "S6" $s6old $s6new ([ref]$s)) -and $ok

# S7
$s7old = '- **36 EBM-тегов уже есть** (порог FULL_EBM = 30 перекрыт), §19 EBM Benchmark на месте'
$s7new = '- **0 EBM-тегов сейчас** (порог FULL_EBM = 30), Benchmark-секция уже присутствует (аудит: HasBenchmark=yes), 907 строк, кластер 3 (гепато-билиарно-панкреатический)'
$ok = (Apply "S7" $s7old $s7new ([ref]$s)) -and $ok

# S8a
$s8aold = '### Оставшиеся PARTIAL_EBM после Session 57'
$s8anew = '### Оставшиеся PARTIAL_EBM после Session 58'
$ok = (Apply "S8a" $s8aold $s8anew ([ref]$s)) -and $ok

# S8b
$s8bold = 'gallbladder_health.md, pancreas_health.md, stress_adrenals.md — итого 3 файла на Sessions 57–59 (все с 0 тегов, требуют полного обогащения с нуля).'
$s8bnew = 'pancreas_health.md, stress_adrenals.md — итого 2 файла на Sessions 58–59 (оба с 0 тегов, Benchmark-секции уже есть, требуется inline-обогащение до >=30 тегов).'
$ok = (Apply "S8b" $s8bold $s8bnew ([ref]$s)) -and $ok

# S9a
$s9aold = '- Session 57: gallbladder_health.md (0 тегов → ~30, полное обогащение с нуля — AASLD 2018, EASL 2016 gallstone guideline, Cochrane, WGO)'
$s9anew = '- Session 58: pancreas_health.md (0 → ~30 тегов, полное обогащение с нуля — UEG 2017 PERT, ACG, Atlanta 2012, Hardt/Ewald СД 3c, Hamano 2001 АИП, Cochrane)'
$ok = (Apply "S9a" $s9aold $s9anew ([ref]$s)) -and $ok

# S9b
$s9bold = '- Session 57: stress_adrenals.md (0 тегов, полный §Benchmark + inline-теги)'
$s9bnew = '- Session 59: stress_adrenals.md (0 → ~30 тегов, полное обогащение — ES 2016 CS guideline, NICE, ATA, Cochrane; закроет весь список PARTIAL_EBM)'
$ok = (Apply "S9b" $s9bold $s9bnew ([ref]$s)) -and $ok

# S9c
$s9cold = '- Session 58: gallbladder_health.md + pancreas_health.md (0 тегов каждый, +Benchmark)'
$s9cnew = '- Прогноз к концу Session 59: **13/53 FULL_EBM (24.5 %), 0 PARTIAL, 40 NO_EBM**, ~604 EBM-тегов.'
$ok = (Apply "S9c" $s9cold $s9cnew ([ref]$s)) -and $ok

# S9d
$s9dold = '**Прогноз к концу Session 58:** 12/53 FULL_EBM (22.6 %), 0 PARTIAL, 41 NO_EBM.'
$s9dnew = '**Session 58 промежуточный прогноз:** 12/53 FULL_EBM (22.6 %), 1 PARTIAL (stress_adrenals), 40 NO_EBM, ~574 EBM-тегов.'
$ok = (Apply "S9d" $s9dold $s9dnew ([ref]$s)) -and $ok

# S10: insert Session 57 record before Session 55 line
$s10anchor = '- **Session 55** (2026-07-31, Этап F.2)'
$s10newLine = '- **Session 57** (2026-08-05, Этап F.2): `gallbladder_health.md` NO_EBM → FULL_EBM (0 → 30 EBM-тегов, полное обогащение с нуля, v2.0 → v2.1). Скрипт `normalize_gallbladder_health_v1.ps1` (28 патчей + 6 метаданных, 21/21 валидаций OK с первого прохода). Теги в 22 из 27 H2-секций: анатомия (Boyer 2013), функции желчи (Hofmann 2009, Reboul 2013, Ridlon 2014), билиарный панкреатит (Tenner 2013 ACG), диагностика (EASL 2016), копрограмма (Fine 1999), Бристоль (Lewis-Heaton 1997), ДЖВП (Cotton 2016 Rome IV), причины застоя (Sichieri 1991, Weinsier 1995), лабмаркеры (Kwo 2017 ACG), нутрицевтики (Chiang 2013 таурин, Russell 2003 глицин, Guarino 2013 PC+УДХК, Tsai 2008 Mg), травы (Rambaldi Cochrane 2007, Holtmann 2003, Shoba 1998 куркумин+пиперин), полипы (Wiles 2017 EASL/ESGAR), камни (Lammert 2016 Nat Rev), холецистэктомия (Gurusamy Cochrane 2013), УДХК (May 1993), ПХЭС (Sauter 2002, Hofmann 1972). Коммит `239dbf0` (+261/-29). 🎯 **11/53 FULL_EBM (20.8 %), 544 EBM-тегов — впервые >= 20 % методологии.**' + "`n"
if ($s.Contains($s10anchor)) {
    $s = $s.Replace($s10anchor, $s10newLine + $s10anchor)
    Write-Host "  [S10] история Session 57 OK" -ForegroundColor Green
} else { Write-Host "  [S10] ANCHOR NOT FOUND" -ForegroundColor Red; $ok = $false }

# S11: marker
if (-not $s.Contains('<!-- STATUS_SESSION57_APPLIED -->')) {
    if ($s.EndsWith("`n")) { $s = $s + '<!-- STATUS_SESSION57_APPLIED -->' + "`n" }
    else { $s = $s + "`n" + '<!-- STATUS_SESSION57_APPLIED -->' + "`n" }
    Write-Host "  [S11] маркер STATUS_SESSION57_APPLIED добавлен OK" -ForegroundColor Green
}

# ============================================================================
# SOURCES_INDEX.md
# ============================================================================

# I1
$i1old = '- **FULL_EBM — 10 файлов (18.9 %):** `autoimmune_basics.md`, `covid_pregnancy.md`, `female_hormones.md`, `hashimoto.md`, `joints_osteoporosis.md`, `minerals.md`, `nervous_system.md`, `nutraceuticals.md`, `thyroid_health.md`, `vitamins.md`.'
$i1new = '- **FULL_EBM — 11 файлов (20.8 %):** `autoimmune_basics.md`, `covid_pregnancy.md`, `female_hormones.md`, `gallbladder_health.md`, `hashimoto.md`, `joints_osteoporosis.md`, `minerals.md`, `nervous_system.md`, `nutraceuticals.md`, `thyroid_health.md`, `vitamins.md`.'
$ok = (Apply "I1" $i1old $i1new ([ref]$i)) -and $ok

# I2
$i2old = '- **PARTIAL_EBM — 3 файла (5.7 %):** `gallbladder_health.md`, `pancreas_health.md`, `stress_adrenals.md`.'
$i2new = '- **PARTIAL_EBM — 2 файла (3.8 %):** `pancreas_health.md`, `stress_adrenals.md`.'
$ok = (Apply "I2" $i2old $i2new ([ref]$i)) -and $ok

# I3
$i3old = '- **Всего:** 514 EBM-тегов, ~37 400 строк методологии (обновлено Session 56, 2026-08-05 — EBM-обогащение covid_pregnancy.md двухпроходное, +14 inline тегов).'
$i3new = '- **Всего:** 544 EBM-тегов, ~37 500 строк методологии (обновлено Session 57, 2026-08-05 — полное EBM-обогащение gallbladder_health.md с нуля, +30 inline тегов).'
$ok = (Apply "I3" $i3old $i3new ([ref]$i)) -and $ok

# I4
$i4old = '<!-- SOURCES_INDEX_EBM_APPLIED_v56 -->'
$i4new = '<!-- SOURCES_INDEX_EBM_APPLIED_v57 -->'
$ok = (Apply "I4" $i4old $i4new ([ref]$i)) -and $ok

if (-not $ok) {
    Write-Host "`n[ABORT] Some patches failed. Files NOT written." -ForegroundColor Red
    exit 1
}

# ============================================================================
# VALIDATIONS
# ============================================================================
Write-Host "`n=== VALIDATIONS ===" -ForegroundColor Cyan
$errors = 0
function Check($name, $cond) {
    if ($cond) { Write-Host "  [OK] $name" -ForegroundColor Green }
    else { Write-Host "  [FAIL] $name" -ForegroundColor Red; $script:errors++ }
}

Check "STATUS: Session 57 в последнем событии"                    ($s.Contains('Session 57, Этап F.2 — EBM-обогащение'))
Check "STATUS: gallbladder в последнем событии"                    ($s.Contains('`gallbladder_health.md` (NO_EBM → FULL_EBM'))
Check "STATUS: FULL 11/53 (20.8%)"                                 ($s.Contains('**FULL_EBM: 11/53 файлов (20.8%)**'))
Check "STATUS: PARTIAL 2/53 (3.8%)"                                ($s.Contains('**PARTIAL_EBM: 2/53 файлов (3.8%)**'))
Check "STATUS: тегов 544"                                          ($s.Contains('**544** (было 514, +30'))
Check "STATUS: Session 58 в заголовке следующей"                   ($s.Contains('Следующая сессия — Session 58'))
Check "STATUS: цель Session 58 = pancreas"                         ($s.Contains('EBM-обогащение `pancreas_health.md`'))
Check "STATUS: старая цель nervous_system удалена"                 (-not $s.Contains('структурная нормализация `nervous_system.md`'))
Check "STATUS: старый заголовок Session 57 удалён"                 (-not $s.Contains('Следующая сессия — Session 57'))
Check "STATUS: запись Session 57 в истории"                        ($s.Contains('**Session 57** (2026-08-05, Этап F.2): `gallbladder_health.md`'))
Check "STATUS: маркер STATUS_SESSION57_APPLIED"                    ($s.Contains('<!-- STATUS_SESSION57_APPLIED -->'))
Check "STATUS: фантом 'Session 57: gallbladder' удалён"            (-not $s.Contains('Session 57: gallbladder_health.md (0 тегов → ~30'))
Check "STATUS: фантом 'Session 57: stress_adrenals' удалён"        (-not $s.Contains('Session 57: stress_adrenals.md (0 тегов, полный'))
Check "STATUS: фантом 'Session 58: gallbladder + pancreas' удалён" (-not $s.Contains('Session 58: gallbladder_health.md + pancreas_health.md'))
Check "STATUS: старая метрика 10/53 (18.9%) удалена"               (-not $s.Contains('**FULL_EBM: 10/53 файлов (18.9%)**'))
Check "STATUS: старая метрика 3/53 (5.7%) удалена"                 (-not $s.Contains('**PARTIAL_EBM: 3/53 файлов (5.7%)**'))
Check "SOURCES: FULL_EBM 11 файлов (20.8 %)"                       ($i.Contains('FULL_EBM — 11 файлов (20.8 %)'))
Check "SOURCES: gallbladder_health.md в FULL списке"               ($i.Contains('`female_hormones.md`, `gallbladder_health.md`, `hashimoto.md`'))
Check "SOURCES: PARTIAL_EBM 2 файла (3.8 %)"                       ($i.Contains('PARTIAL_EBM — 2 файла (3.8 %)'))
Check "SOURCES: старый список PARTIAL из 3-х удалён"               (-not $i.Contains('PARTIAL_EBM — 3 файла (5.7 %)'))
Check "SOURCES: Всего 544 EBM-тегов"                               ($i.Contains('**Всего:** 544 EBM-тегов'))
Check "SOURCES: маркер v57"                                        ($i.Contains('<!-- SOURCES_INDEX_EBM_APPLIED_v57 -->'))
Check "SOURCES: старый маркер v56 удалён"                          (-not $i.Contains('<!-- SOURCES_INDEX_EBM_APPLIED_v56 -->'))

if ($errors -gt 0) {
    Write-Host "`n[ABORT] $errors validation(s) failed. Files NOT written." -ForegroundColor Red
    exit 1
}

$utf8bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($sPath, $s, $utf8bom)
[System.IO.File]::WriteAllText($iPath, $i, $utf8bom)

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "  STATUS.md:        $sOrig -> $($s.Length) chars (delta $($s.Length - $sOrig))"
Write-Host "  SOURCES_INDEX.md: $iOrig -> $($i.Length) chars (delta $($i.Length - $iOrig))"
Write-Host "  FULL_EBM:    10 -> 11 / 53 (20.8%)"
Write-Host "  PARTIAL_EBM: 3 -> 2 / 53 (3.8%)"
Write-Host "  EBM tags:    514 -> 544 (+30)"
Write-Host "  Next:        Session 58 = pancreas_health.md"
Write-Host "`n[OK] Session 57 закрыта" -ForegroundColor Green
