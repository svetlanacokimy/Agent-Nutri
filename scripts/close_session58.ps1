# =============================================================================
# close_session58.ps1
# Session 58 closure — STATUS.md + SOURCES_INDEX.md (v57 -> v58)
# Схема: Read -> Apply -> Validate -> Write (L-053-01)
# Все якоря в single quotes (L-057-01)
# =============================================================================

$ErrorActionPreference = 'Stop'

$statusFile  = 'project/STATUS.md'
$sourcesFile = 'v2/SOURCES_INDEX.md'

Write-Host "=== close_session58.ps1 ===" -ForegroundColor Cyan
Write-Host ""

# --- Read ---
$rawStatus  = [System.IO.File]::ReadAllText((Resolve-Path $statusFile),  [System.Text.Encoding]::UTF8)
$rawSources = [System.IO.File]::ReadAllText((Resolve-Path $sourcesFile), [System.Text.Encoding]::UTF8)

# --- Guard идемпотентности ---
if ($rawStatus -match '<!--\s*STATUS_SESSION58_APPLIED\s*-->') {
    Write-Host "[GUARD] Маркер STATUS_SESSION58_APPLIED уже присутствует — скрипт уже применён. Выход." -ForegroundColor Yellow
    exit 0
}

$statusSizeBefore  = $rawStatus.Length
$sourcesSizeBefore = $rawSources.Length
Write-Host "[INFO] STATUS.md:        $statusSizeBefore chars"
Write-Host "[INFO] SOURCES_INDEX.md: $sourcesSizeBefore chars"
Write-Host ""

# --- Backups ---
$ts = Get-Date -Format 'yyyyMMdd-HHmmss'
$statusBackup  = "$statusFile.bak.$ts"
$sourcesBackup = "$sourcesFile.bak.$ts"
Copy-Item -Path $statusFile  -Destination $statusBackup  -Force
Copy-Item -Path $sourcesFile -Destination $sourcesBackup -Force
Write-Host "[BACKUP] $statusBackup"
Write-Host "[BACKUP] $sourcesBackup"
Write-Host ""

$s = $rawStatus
$i = $rawSources
$applied = 0

function Apply-PatchS {
    param([string]$Name, [string]$Old, [string]$New)
    if ($script:s.IndexOf($Old) -lt 0) { throw "[$Name] ANCHOR NOT FOUND в STATUS.md" }
    $script:s = $script:s.Replace($Old, $New)
    $script:applied++
    Write-Host "[OK] $Name" -ForegroundColor Green
}

function Apply-PatchI {
    param([string]$Name, [string]$Old, [string]$New)
    if ($script:i.IndexOf($Old) -lt 0) { throw "[$Name] ANCHOR NOT FOUND в SOURCES_INDEX.md" }
    $script:i = $script:i.Replace($Old, $New)
    $script:applied++
    Write-Host "[OK] $Name" -ForegroundColor Green
}

# =============================================================================
# ПАТЧИ STATUS.md (S1..S11)
# =============================================================================
Write-Host "=== STATUS.md патчи ===" -ForegroundColor Cyan

# --- S1: Последнее событие (L6) ---
Apply-PatchS 'S1 Последнее событие -> Session 58' `
    '**Последнее событие:** Session 57, Этап F.2 — EBM-обогащение `gallbladder_health.md` (NO_EBM → FULL_EBM, 0 → 30 EBM-тегов, +30 inline с нуля, v2.0 → v2.1). Прогресс: 10 → **11 FULL_EBM** файлов (20.8 %), 3 → 2 PARTIAL, 514 → **544 EBM-тегов** (+30). 🎯 Впервые >= 20 % методологии — FULL_EBM.' `
    '**Последнее событие:** Session 58, Этап F.2 — EBM-обогащение `pancreas_health.md` (NO_EBM → FULL_EBM, 0 → 30 EBM-тегов, +30 inline с нуля, v2.0 → v2.1). Прогресс: 11 → **12 FULL_EBM** файлов (22.6 %), 2 → **0 PARTIAL**, 544 → **574 EBM-тегов** (+30). 🎯 PARTIAL_EBM исчерпан — все файлы с Benchmark-секцией переведены в FULL_EBM.'

# --- S2: FULL_EBM метрика (L87) ---
Apply-PatchS 'S2 FULL_EBM 11/53 -> 12/53' `
    '- **FULL_EBM: 11/53 файлов (20.8%)** — было 10, +1 (`gallbladder_health.md`)' `
    '- **FULL_EBM: 12/53 файлов (22.6%)** — было 11, +1 (`pancreas_health.md`)'

# --- S3: PARTIAL_EBM метрика (L88) ---
Apply-PatchS 'S3 PARTIAL_EBM 2/53 -> 0/53' `
    '- **PARTIAL_EBM: 2/53 файлов (3.8%)** — было 3, -1 (gallbladder ушёл в FULL_EBM; классификация аудита: pancreas_health.md и stress_adrenals.md имеют Benchmark-секцию без тегов)' `
    '- **PARTIAL_EBM: 0/53 файлов (0%)** — было 2, -2 (pancreas ушёл в FULL_EBM; stress_adrenals переклассифицирован в NO_EBM аудитом — Benchmark-секция отсутствует)'

# --- S4: Всего EBM-тегов (L90) ---
Apply-PatchS 'S4 Всего EBM-тегов 544 -> 574' `
    '- Всего EBM-тегов: **544** (было 514, +30 — полное EBM-обогащение gallbladder_health.md с нуля в 22 из 27 H2-секций)' `
    '- Всего EBM-тегов: **574** (было 544, +30 — полное EBM-обогащение pancreas_health.md с нуля в 22 из 27 H2-секций)'

# --- S5: Заголовок следующей сессии (L100) ---
Apply-PatchS 'S5 Следующая сессия 58 -> 59' `
    '## ➡️ Следующая сессия — Session 58 (Этап F.2 продолжение)' `
    '## ➡️ Следующая сессия — Session 59 (Этап F.2 продолжение)'

# --- S6: Цель Session 59 (L102) ---
Apply-PatchS 'S6 Цель Session 59 -> stress_adrenals.md' `
    '**Цель:** EBM-обогащение `pancreas_health.md` (PARTIAL_EBM → FULL_EBM, 0 → ~30 EBM-тегов, полное обогащение с нуля — UEG 2017, ACG guidelines, TIGAR-O, Atlanta 2012, Hardt/Ewald для СД 3c, Hamano 2001 для АИП)' `
    '**Цель:** EBM-обогащение `stress_adrenals.md` (NO_EBM → FULL_EBM, 0 → ~30 EBM-тегов, полное обогащение с нуля — Endocrine Society 2016 (Cushing), NICE, ATA, Cochrane, обзоры по кортизолу/HPA-оси, адаптогенам)'

# --- S7: Характеристика цели (L107) ---
Apply-PatchS 'S7 Характеристика цели Session 59' `
    '- **0 EBM-тегов сейчас** (порог FULL_EBM = 30), Benchmark-секция уже присутствует (аудит: HasBenchmark=yes), 907 строк, кластер 3 (гепато-билиарно-панкреатический)' `
    '- **0 EBM-тегов сейчас** (порог FULL_EBM = 30), Benchmark-секция отсутствует (аудит после Session 58: HasBenchmark=no → NO_EBM), 1031 строка, кластер 4 (эндокринная система, ось HPA)'

# --- S8: Блок "Оставшиеся PARTIAL_EBM" (L130-132) ---
Apply-PatchS 'S8 Блок PARTIAL_EBM -> исчерпан' `
    '### Оставшиеся PARTIAL_EBM после Session 58' `
    '### Оставшиеся PARTIAL_EBM после Session 58 — ✅ ИСЧЕРПАНЫ'

Apply-PatchS 'S8b Список PARTIAL -> обнулён' `
    'pancreas_health.md, stress_adrenals.md — итого 2 файла на Sessions 58–59 (оба с 0 тегов, Benchmark-секции уже есть, требуется inline-обогащение до >=30 тегов).' `
    'PARTIAL_EBM = 0/53 после Session 58. Все файлы с Benchmark-секцией переведены в FULL_EBM. Дальнейшие сессии F.2 работают с NO_EBM (40 файлов): создание Benchmark-секции с нуля + inline-теги. Первый кандидат — stress_adrenals.md (Session 59).'

# --- S9: Long-term plan (L136-141) ---
Apply-PatchS 'S9a Long-term Session 58' `
    '- Session 58: pancreas_health.md (0 → ~30 тегов, полное обогащение с нуля — UEG 2017 PERT, ACG, Atlanta 2012, Hardt/Ewald СД 3c, Hamano 2001 АИП, Cochrane)' `
    '- ✅ Session 58 (закрыта, 2026-08-06): pancreas_health.md 0 → 30 тегов (Whitcomb 2019 NEJM, Banks 2013 Atlanta, Tenner 2013 ACG, UEG Löhr 2017 HaPanEU, IAP/APA 2013, Yadav 2013, DiMagno 1973, Hardt 2008, Ewald 2012, Wagner 2020, Hamano 2001, ICDC 2011, ACG 2018, Lowenfels 1993, Uden 1990, Siriwardena 2007, Frank 1999, Opie 1901). Density 83.8 %.'

Apply-PatchS 'S9b Long-term Session 59' `
    '- Session 59: stress_adrenals.md (0 → ~30 тегов, полное обогащение — ES 2016 CS guideline, NICE, ATA, Cochrane; закроет весь список PARTIAL_EBM)' `
    '- Session 59: stress_adrenals.md (0 → ~30 тегов, NO_EBM → FULL_EBM — Endocrine Society 2016 (Cushing), Fries 2005 (HPA-ось), Panossian 2010 (адаптогены), NICE addisonian, Cochrane; создание Benchmark-секции с нуля + inline-теги)'

Apply-PatchS 'S9c Long-term прогноз -> Session 59' `
    '- Прогноз к концу Session 59: **13/53 FULL_EBM (24.5 %), 0 PARTIAL, 40 NO_EBM**, ~604 EBM-тегов.' `
    '- Прогноз к концу Session 59: **13/53 FULL_EBM (24.5 %), 0 PARTIAL, 39 NO_EBM**, ~604 EBM-тегов.'

Apply-PatchS 'S9d Промежуточный прогноз -> факт Session 58' `
    '**Session 58 промежуточный прогноз:** 12/53 FULL_EBM (22.6 %), 1 PARTIAL (stress_adrenals), 40 NO_EBM, ~574 EBM-тегов.' `
    '**Session 58 факт:** 12/53 FULL_EBM (22.6 %), **0 PARTIAL** (stress_adrenals оказался без Benchmark → переклассифицирован в NO_EBM), 40 NO_EBM, 574 EBM-тегов. 🎯 Milestone: PARTIAL_EBM полностью исчерпан.'

# --- S10: Запись Session 58 в лог (перед L145 Session 57) ---
Apply-PatchS 'S10 Запись Session 58 в лог' `
    '- **Session 57** (2026-08-05, Этап F.2): `gallbladder_health.md` NO_EBM → FULL_EBM' `
    '- **Session 58** (2026-08-06, Этап F.2): `pancreas_health.md` NO_EBM → FULL_EBM (0 → 30 EBM-тегов, полное обогащение с нуля, v2.0 → v2.1). Скрипт `normalize_pancreas_health_v1.ps1` v2 (30 патчей контента + 5 метаданных, 29/29 валидаций OK со второго прохода). Инцидент v1: P6 упал из-за неверной логики корректировочных патчей (искал якорь с уже вставленным тегом Tenner 2013, которого там не было — тег ушёл в inline-блок перед §5); файл остался нетронут благодаря транзакционности. Фикс v2: убраны P10 и P17 для точного попадания в 30 тегов, P6 использует чистый якорь. Теги в 22 из 27 H2-секций: анатомия/физиология (Whitcomb 2019 NEJM), 10 ферментов (DiMagno 1973), карта ЖКТ (Whitcomb 2019), связки ПЖ (Opie 1901 common-channel, Tenner 2013 ACG), правила приёма ферментов (UEG Löhr 2017 HaPanEU), сладкое+жирное (Yadav 2013), животные vs растительные (UEG 2017), дозировки (UEG 2017), патогенез ОП (Banks 2013 Atlanta, Tenner 2013 критерии), причины ОП (Yadav 2013, Tenner 2013 ЖКБ+алкоголь), симптомы (IAP/APA 2013), лаб.диагностика (Tenner 2013 липаза >3× ВГН), лекарства (Frank 1999 макроамилаземия), ПЖ↔ИР (Wagner 2020 Nat Med), диета (IAP/APA 2013 раннее энтеральное), нутрицевтики (Uden 1990 селен, Siriwardena 2007 АО в ХП), EPI (UEG Löhr 2017, DiMagno 1973 порог 10 %), PERT (UEG 2017 дозы, Whitcomb 2019), СД 3c (Hardt 2008, Ewald 2012 недооценка ~9 %), кисты/IPMN (ACG 2018 + European 2018), AIP (Hamano 2001 IgG4 NEJM, ICDC 2011 критерии), рак ПЖ (Lowenfels 1993 NEJM). Коммит `f50ea34` (+336/-25). 🎯 **12/53 FULL_EBM (22.6 %), 574 EBM-тегов, PARTIAL_EBM = 0 (исчерпан).**
- **Session 57** (2026-08-05, Этап F.2): `gallbladder_health.md` NO_EBM → FULL_EBM'

# --- S11: Маркер применения ---
Apply-PatchS 'S11 Маркер STATUS_SESSION58_APPLIED' `
    '<!-- STATUS_SESSION57_APPLIED -->' `
    '<!-- STATUS_SESSION57_APPLIED -->
<!-- STATUS_SESSION58_APPLIED -->'

Write-Host ""

# =============================================================================
# ПАТЧИ SOURCES_INDEX.md (I1..I4)
# =============================================================================
Write-Host "=== SOURCES_INDEX.md патчи ===" -ForegroundColor Cyan

# --- I1: FULL_EBM список ---
Apply-PatchI 'I1 FULL_EBM список 11 -> 12' `
    '- **FULL_EBM — 11 файлов (20.8 %):** `autoimmune_basics.md`, `covid_pregnancy.md`, `female_hormones.md`, `gallbladder_health.md`, `hashimoto.md`, `joints_osteoporosis.md`, `minerals.md`, `nervous_system.md`, `nutraceuticals.md`, `thyroid_health.md`, `vitamins.md`.' `
    '- **FULL_EBM — 12 файлов (22.6 %):** `autoimmune_basics.md`, `covid_pregnancy.md`, `female_hormones.md`, `gallbladder_health.md`, `hashimoto.md`, `joints_osteoporosis.md`, `minerals.md`, `nervous_system.md`, `nutraceuticals.md`, `pancreas_health.md`, `thyroid_health.md`, `vitamins.md`.'

# --- I2: PARTIAL_EBM исчерпан ---
Apply-PatchI 'I2 PARTIAL_EBM 2 -> 0 (исчерпан)' `
    '- **PARTIAL_EBM — 2 файла (3.8 %):** `pancreas_health.md`, `stress_adrenals.md`.' `
    '- **PARTIAL_EBM — 0 файлов (0 %):** ✅ исчерпан (Session 58, pancreas_health.md переведён в FULL_EBM; stress_adrenals.md переклассифицирован аудитом в NO_EBM — отсутствует Benchmark-секция).'

# --- I3: Всего тегов ---
Apply-PatchI 'I3 Всего 544 -> 574' `
    '- **Всего:** 544 EBM-тегов, ~37 500 строк методологии (обновлено Session 57, 2026-08-05 — полное EBM-обогащение gallbladder_health.md с нуля, +30 inline тегов).' `
    '- **Всего:** 574 EBM-тегов, ~37 500 строк методологии (обновлено Session 58, 2026-08-06 — полное EBM-обогащение pancreas_health.md с нуля, +30 inline тегов; PARTIAL_EBM исчерпан).'

# --- I4: Маркер версии v57 -> v58 ---
Apply-PatchI 'I4 Маркер v57 -> v58' `
    '<!-- SOURCES_INDEX_EBM_APPLIED_v57 -->' `
    '<!-- SOURCES_INDEX_EBM_APPLIED_v58 -->'

Write-Host ""

# =============================================================================
# ВАЛИДАЦИИ
# =============================================================================
Write-Host "=== ВАЛИДАЦИИ ===" -ForegroundColor Cyan

$checks = @(
    # STATUS.md
    @{ Name = 'STATUS: Session 58 в "Последнее событие"';       Test = { $s -match 'Последнее событие:\*\*\s*Session 58' } },
    @{ Name = 'STATUS: FULL_EBM 12/53 (22.6%)';                 Test = { $s -match 'FULL_EBM:\s*12/53\s*файлов\s*\(22\.6%\)' } },
    @{ Name = 'STATUS: старое FULL_EBM 11/53 удалено';          Test = { -not ($s -match 'FULL_EBM:\s*11/53\s*файлов\s*\(20\.8%\)') } },
    @{ Name = 'STATUS: PARTIAL_EBM 0/53 (0%)';                  Test = { $s -match 'PARTIAL_EBM:\s*0/53\s*файлов\s*\(0%\)' } },
    @{ Name = 'STATUS: старое PARTIAL 2/53 удалено';            Test = { -not ($s -match 'PARTIAL_EBM:\s*2/53\s*файлов\s*\(3\.8%\)') } },
    @{ Name = 'STATUS: всего 574 EBM-тегов';                    Test = { $s -match 'Всего EBM-тегов:\s*\*\*574\*\*' } },
    @{ Name = 'STATUS: старое "544" в метрике удалено';         Test = { -not ($s -match 'Всего EBM-тегов:\s*\*\*544\*\*') } },
    @{ Name = 'STATUS: заголовок Session 59';                   Test = { $s -match 'Следующая сессия\s*—\s*Session 59' } },
    @{ Name = 'STATUS: цель stress_adrenals.md';                Test = { $s -match 'Цель:\*\*\s*EBM-обогащение\s*`stress_adrenals\.md`' } },
    @{ Name = 'STATUS: Session 58 запись в лог';                Test = { $s -match '\*\*Session 58\*\*\s*\(2026-08-06' } },
    @{ Name = 'STATUS: маркер STATUS_SESSION58_APPLIED';        Test = { $s -match '<!--\s*STATUS_SESSION58_APPLIED\s*-->' } },
    @{ Name = 'STATUS: маркер STATUS_SESSION57_APPLIED сохранён'; Test = { $s -match '<!--\s*STATUS_SESSION57_APPLIED\s*-->' } },
    @{ Name = 'STATUS: PARTIAL исчерпан (текст)';               Test = { $s -match 'PARTIAL_EBM полностью исчерпан|исчерпан' } },
    @{ Name = 'STATUS: коммит f50ea34 упомянут';                Test = { $s -match 'f50ea34' } },

    # SOURCES_INDEX.md
    @{ Name = 'SOURCES: FULL_EBM 12 файлов (22.6 %)';           Test = { $i -match 'FULL_EBM\s*—\s*12\s*файлов\s*\(22\.6\s*%\)' } },
    @{ Name = 'SOURCES: pancreas_health.md в FULL_EBM';         Test = { $i -match 'FULL_EBM.*pancreas_health\.md' } },
    @{ Name = 'SOURCES: старое FULL_EBM 11 удалено';            Test = { -not ($i -match 'FULL_EBM\s*—\s*11\s*файлов') } },
    @{ Name = 'SOURCES: PARTIAL_EBM 0 файлов';                  Test = { $i -match 'PARTIAL_EBM\s*—\s*0\s*файлов' } },
    @{ Name = 'SOURCES: старое PARTIAL 2 файла удалено';        Test = { -not ($i -match 'PARTIAL_EBM\s*—\s*2\s*файла') } },
    @{ Name = 'SOURCES: 574 EBM-тегов';                         Test = { $i -match 'Всего:\*\*\s*574\s*EBM-тегов' } },
    @{ Name = 'SOURCES: старое 544 EBM-тегов удалено';          Test = { -not ($i -match 'Всего:\*\*\s*544\s*EBM-тегов') } },
    @{ Name = 'SOURCES: маркер v58';                            Test = { $i -match '<!--\s*SOURCES_INDEX_EBM_APPLIED_v58\s*-->' } },
    @{ Name = 'SOURCES: старый маркер v57 удалён';              Test = { -not ($i -match '<!--\s*SOURCES_INDEX_EBM_APPLIED_v57\s*-->') } },
    @{ Name = 'STATUS: размер вырос';                           Test = { ($s.Length - $statusSizeBefore) -gt 500 } },
    @{ Name = 'SOURCES: размер изменился';                      Test = { $i.Length -ne $sourcesSizeBefore } }
)

$failed = 0
foreach ($chk in $checks) {
    if (& $chk.Test) {
        Write-Host "  [OK] $($chk.Name)" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $($chk.Name)" -ForegroundColor Red
        $failed++
    }
}

if ($failed -gt 0) {
    Write-Host ""
    Write-Host "[ABORT] $failed валидаций провалено — файлы НЕ записаны." -ForegroundColor Red
    Write-Host "  Backups: $statusBackup, $sourcesBackup" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# =============================================================================
# ЗАПИСЬ (UTF-8 BOM)
# =============================================================================
$enc = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path $statusFile),  $s, $enc)
[System.IO.File]::WriteAllText((Resolve-Path $sourcesFile), $i, $enc)

Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "  STATUS.md:        $statusSizeBefore  -> $($s.Length)   (delta $($s.Length - $statusSizeBefore))"
Write-Host "  SOURCES_INDEX.md: $sourcesSizeBefore -> $($i.Length)   (delta $($i.Length - $sourcesSizeBefore))"
Write-Host "  Patches:          $applied applied (11 STATUS + 4 SOURCES)"
Write-Host "  Checks:           $($checks.Count)/$($checks.Count) OK"
Write-Host "  Next session:     Session 59 — stress_adrenals.md"
Write-Host "  Milestone:        🎯 PARTIAL_EBM исчерпан (0/53)"
Write-Host ""
Write-Host "=== DONE ===" -ForegroundColor Green
