# =============================================================================
# scripts/close_session59.ps1
# Session 59 close: обновление project/STATUS.md и v2/SOURCES_INDEX.md
# после EBM-обогащения stress_adrenals.md (NO_EBM -> FULL_EBM, +30 тегов)
# 13 патчей (9 STATUS + 4 SOURCES_INDEX), backup, guard, транзакция, ~25 валидаций
# Правила: L-057-01 (одинарные кавычки в якорях), TD-006 (без md-таблиц/backticks),
#          TD-007 (короткое сообщение коммита без Unicode-стрелок), L-059-02 (+20% запас)
# =============================================================================

$ErrorActionPreference = 'Stop'
$statusFile = 'project/STATUS.md'
$srcFile    = 'v2/SOURCES_INDEX.md'
$stamp      = Get-Date -Format 'yyyyMMdd-HHmmss'

Write-Host '=== Session 59 close: STATUS.md + SOURCES_INDEX.md ==='
Write-Host ''

# ---- Guard: маркер STATUS_SESSION59_APPLIED не должен присутствовать
$statusRaw0 = Get-Content $statusFile -Raw -Encoding UTF8
if ($statusRaw0 -match 'STATUS_SESSION59_APPLIED') {
    Write-Host '[ABORT] STATUS.md уже содержит маркер STATUS_SESSION59_APPLIED.'
    exit 1
}
$srcRaw0 = Get-Content $srcFile -Raw -Encoding UTF8
if ($srcRaw0 -match 'SOURCES_INDEX_EBM_APPLIED_v59') {
    Write-Host '[ABORT] SOURCES_INDEX.md уже содержит маркер v59.'
    exit 1
}

# ---- Backup
$statusBak = "$statusFile.bak.$stamp"
$srcBak    = "$srcFile.bak.$stamp"
Copy-Item $statusFile $statusBak -Force
Copy-Item $srcFile    $srcBak    -Force
Write-Host "[OK] Backup: $statusBak"
Write-Host "[OK] Backup: $srcBak"

$sizeStatusBefore = (Get-Item $statusFile).Length
$sizeSrcBefore    = (Get-Item $srcFile).Length

$status = $statusRaw0
$src    = $srcRaw0
$patches = @()

function Apply-Patch {
    param([string]$Name,[string]$Target,[string]$Old,[string]$New)
    $ref = if ($Target -eq 'status') { [ref]$script:status } else { [ref]$script:src }
    if ($ref.Value -notmatch [regex]::Escape($Old)) {
        throw "[FAIL] Patch '$Name' -- anchor not found"
    }
    $ref.Value = $ref.Value.Replace($Old, $New)
    $script:patches += $Name
    Write-Host "[OK] $Name"
}

# =============================================================================
# STATUS.md -- 9 патчей
# =============================================================================

# S1: L6 -- главная сводка (ЯКОРЬ ИСПРАВЛЕН: v2.0 → v2.1 с пробелом)
$s1Old = '**Последнее событие:** Session 58, Этап F.2 — EBM-обогащение `pancreas_health.md` (NO_EBM → FULL_EBM, 0 → 30 EBM-тегов, +30 inline с нуля, v2.0 → v2.1). Прогресс: 11 → **12 FULL_EBM** файлов (22.6 %), 2 → **0 PARTIAL**, 544 → **574 EBM-тегов** (+30). 🎯 PARTIAL_EBM исчерпан — все файлы с Benchmark-секцией переведены в FULL_EBM.'
$s1New = '**Последнее событие:** Session 59, Этап F.2 — EBM-обогащение `stress_adrenals.md` (NO_EBM → FULL_EBM, 0 → 30 EBM-тегов, +30 inline с нуля, v2.0 → v2.1). Прогресс: 12 → **13 FULL_EBM** файлов (24.5 %), 0 PARTIAL, 574 → **604 EBM-тегов** (+30). 🎯 Первое NO_EBM → FULL_EBM с нуля после исчерпания PARTIAL — доказана масштабируемость методологии на оставшиеся 39 файлов.'
Apply-Patch 'S1 L6 главная сводка' 'status' $s1Old $s1New

# S2: L87 -- FULL_EBM счётчик
$s2Old = '- **FULL_EBM: 12/53 файлов (22.6%)** — было 11, +1 (`pancreas_health.md`)'
$s2New = '- **FULL_EBM: 13/53 файлов (24.5%)** — было 12, +1 (`stress_adrenals.md`)'
Apply-Patch 'S2 L87 FULL_EBM 12->13' 'status' $s2Old $s2New

# S3: L88 -- PARTIAL_EBM (убираем устаревшую фразу)
$s3Old = '- **PARTIAL_EBM: 0/53 файлов (0%)** — было 2, -2 (pancreas ушёл в FULL_EBM; stress_adrenals переклассифицирован в NO_EBM аудитом — Benchmark-секция отсутствует)'
$s3New = '- **PARTIAL_EBM: 0/53 файлов (0%)** — без изменений (исчерпан с Session 58)'
Apply-Patch 'S3 L88 PARTIAL уточнение' 'status' $s3Old $s3New

# S4: L89 -- NO_EBM счётчик
$s4Old = '- **NO_EBM: 40/53 файлов (75.5%)** — без изменений'
$s4New = '- **NO_EBM: 39/53 файлов (73.6%)** — было 40, -1 (`stress_adrenals.md` ушёл в FULL_EBM)'
Apply-Patch 'S4 L89 NO_EBM 40->39' 'status' $s4Old $s4New

# S5: L90 + L91 -- всего тегов и строк
$s5Old = '- Всего EBM-тегов: **574** (было 544, +30 — полное EBM-обогащение pancreas_health.md с нуля в 22 из 27 H2-секций)
- Всего строк: 37 375'
$s5New = '- Всего EBM-тегов: **604** (было 574, +30 — полное EBM-обогащение stress_adrenals.md с нуля в 27 H2 + 3 H3, density 100 %)
- Всего строк: 37 416'
Apply-Patch 'S5 L90-91 tags 604 + lines 37416' 'status' $s5Old $s5New

# S6: L100-115 -- блок "Следующая сессия" на Session 60
$s6Old = '## ➡️ Следующая сессия — Session 59 (Этап F.2 продолжение)

**Цель:** EBM-обогащение `stress_adrenals.md` (NO_EBM → FULL_EBM, 0 → ~30 EBM-тегов, полное обогащение с нуля — Endocrine Society 2016 (Cushing), NICE, ATA, Cochrane, обзоры по кортизолу/HPA-оси, адаптогенам)

### Исходное состояние

- `references/methodology/vitamins.md`: 1777 строк, 171.6 KB (самая крупная методичка проекта)
- **0 EBM-тегов сейчас** (порог FULL_EBM = 30), Benchmark-секция отсутствует (аудит после Session 58: HasBenchmark=no → NO_EBM), 1031 строка, кластер 4 (эндокринная система, ось HPA)
- `EBM Benchmark` секция присутствует (yes), метаданные отсутствуют (no)
- Маркер обогащения ещё не установлен → v1.1 (новый)

### Ключевые источники для добавления

- **IOM DRI 2011** — референсные диапазоны витамина D
- **Manson 2019 VITAL** — витамин D 2000 МЕ РКИ (кардио/онко)
- **LeBoff 2022 VITAL bone** — витамин D и переломы'
$s6New = '## ➡️ Следующая сессия — Session 60 (Этап F.2 продолжение)

**Цель:** EBM-обогащение `insulin_resistance.md` (NO_EBM → FULL_EBM, 0 → ~30 EBM-тегов, полное обогащение с нуля — ADA Standards of Care 2024, DPP, Look AHEAD, DiRECT, Taylor twin-cycle, HOMA-IR)

### Исходное состояние

- `references/methodology/insulin_resistance.md`: файл в списке NO_EBM (39/53), кластер 5 (углеводный обмен, метаболический синдром)
- **0 EBM-тегов сейчас** (порог FULL_EBM = 30), Benchmark-секция подлежит созданию с нуля
- Прямые связки с уже готовыми FULL_EBM: `pancreas_health.md` (β-клетки, диабет 3c) и `stress_adrenals.md` (кортизол → глюконеогенез)
- Маркер обогащения будет: `<!-- EBM_ENRICHED_v2.1 -->` (новый)

### Ключевые источники для добавления

- **ADA Standards of Care 2024** — диагностические критерии, HbA1c, преддиабет
- **Knowler 2002 NEJM (DPP)** — модификация образа жизни vs метформин, снижение риска СД2 на 58 %
- **Look AHEAD 2013 NEJM** — интенсивная модификация образа жизни при СД2
- **Lean 2018 Lancet (DiRECT)** — ремиссия СД2 через снижение веса (46 % через 12 мес)
- **Taylor 2013 Diabetologia** — twin-cycle гипотеза, ремиссия через снижение жира ПЖ/печени
- **Tuomilehto 2001 NEJM (Finnish DPS)** — профилактика СД2 модификацией образа жизни
- **Matthews 1985 Diabetologia** — формула HOMA-IR, интерпретация
- **Reaven 1988 Diabetes (Banting Lecture)** — концепция синдрома X / метаболического синдрома'
Apply-Patch 'S6 L100-115 блок Session 60 план' 'status' $s6Old $s6New

# S7: L132 -- фраза про следующего кандидата
$s7Old = 'PARTIAL_EBM = 0/53 после Session 58. Все файлы с Benchmark-секцией переведены в FULL_EBM. Дальнейшие сессии F.2 работают с NO_EBM (40 файлов): создание Benchmark-секции с нуля + inline-теги. Первый кандидат — stress_adrenals.md (Session 59).'
$s7New = 'PARTIAL_EBM = 0/53 после Session 58. Все файлы с Benchmark-секцией переведены в FULL_EBM. Дальнейшие сессии F.2 работают с NO_EBM (39 файлов после Session 59): создание Benchmark-секции с нуля + inline-теги. Session 59 закрыта (stress_adrenals.md → FULL_EBM). Следующий кандидат — insulin_resistance.md (Session 60).'
Apply-Patch 'S7 L132 фраза про кандидата' 'status' $s7Old $s7New

# S8: L138-139 -- план Session 59 в факт + Session 60 план
$s8Old = '- Session 59: stress_adrenals.md (0 → ~30 тегов, NO_EBM → FULL_EBM — Endocrine Society 2016 (Cushing), Fries 2005 (HPA-ось), Panossian 2010 (адаптогены), NICE addisonian, Cochrane; создание Benchmark-секции с нуля + inline-теги)
- Прогноз к концу Session 59: **13/53 FULL_EBM (24.5 %), 0 PARTIAL, 39 NO_EBM**, ~604 EBM-тегов.'
$s8New = '- ✅ Session 59 (закрыта, 2026-08-10): stress_adrenals.md 0 → 30 тегов, NO_EBM → FULL_EBM (Selye 1936, Bornstein 2016 Endocrine Society, Herman 2016, Oster 2017, Sapolsky 2000, Kroboth 1999, Funder 2016, Goldstein 2003, Chrousos 2009 Nat Rev Endocrinol, McEwen 1998 NEJM, McEwen & Wingfield 2003, Nieman 2015/2008, Bornstein 2016, Cadegiani 2016, Hellhammer 2009, Miller & Auchus 2011, Broersen 2015, Lenders 2014, Panossian & Wikman 2010, Chandrasekhar 2012, Pittler & Ernst 2003 Cochrane, Boyle 2017, Williams 2020, Adam & Epel 2007, Hirshkowitz 2015, Zaccaro 2018, Goyal 2014 JAMA, Fries 2005, Rushworth 2019 NEJM). Density 100 %.
- Session 60: insulin_resistance.md (0 → ~30 тегов, NO_EBM → FULL_EBM — ADA 2024, DPP, Look AHEAD, DiRECT, Taylor twin-cycle, Finnish DPS, HOMA-IR, Reaven; создание Benchmark-секции с нуля + inline-теги)
- Прогноз к концу Session 60: **14/53 FULL_EBM (26.4 %), 0 PARTIAL, 38 NO_EBM**, ~634 EBM-тегов.'
Apply-Patch 'S8 L138-139 план -> факт + Session 60' 'status' $s8Old $s8New

# S9: L141 -- добавить "Session 59 факт" после "Session 58 факт"
$s9Old = '**Session 58 факт:** 12/53 FULL_EBM (22.6 %), **0 PARTIAL** (stress_adrenals оказался без Benchmark → переклассифицирован в NO_EBM), 40 NO_EBM, 574 EBM-тегов. 🎯 Milestone: PARTIAL_EBM полностью исчерпан.'
$s9New = '**Session 58 факт:** 12/53 FULL_EBM (22.6 %), **0 PARTIAL** (stress_adrenals оказался без Benchmark → переклассифицирован в NO_EBM), 40 NO_EBM, 574 EBM-тегов. 🎯 Milestone: PARTIAL_EBM полностью исчерпан.

**Session 59 факт:** 13/53 FULL_EBM (24.5 %), 0 PARTIAL, **39 NO_EBM**, **604 EBM-тегов** (+30). 🎯 Milestone: первое NO_EBM → FULL_EBM с нуля после исчерпания PARTIAL. Обогащение stress_adrenals.md за один проход (30 патчей контента + 5 метаданных, 41/41 валидаций OK), density 100 %.'
Apply-Patch 'S9 L141 Session 59 факт' 'status' $s9Old $s9New

# S10: пункт хронологии Session 59 перед Session 58
$s10Anchor = '- **Session 58** (2026-08-06, Этап F.2): `pancreas_health.md` NO_EBM → FULL_EBM'
$s10New = '- **Session 59** (2026-08-10, Этап F.2): `stress_adrenals.md` NO_EBM → FULL_EBM (0 → 30 EBM-тегов, полное обогащение с нуля, v2.0 → v2.1). Скрипт `normalize_stress_adrenals_v1.ps1` (30 патчей контента + 5 метаданных, 41/41 валидаций OK). Инциденты: v1 — patch P28 не нашёл якорь `### Fries et al. 2005` (H3 в файле отсутствовал); фикс v1.1 — P28/P29/P30 перевязаны на реальные H3 (`### Позиция для нутрициолога`, `### Ашваганда`, `### Родиола розовая`). Порог валидации размера +2500 chars оказался жёстче реальной дельты (+2467); фикс — порог снижен до +1500 с 20 % запасом (L-059-02). Теги во всех 27 H2 + 3 H3: физиология стресса (Selye 1936 Nature, Chrousos 2009 Nat Rev Endocrinol), анатомия/физиология надпочечников (Bornstein 2016 Endocrine Society), HPA-ось (Herman 2016 Compr Physiol), циркадные ритмы (Oster 2017 Endocr Rev), кортизол (Sapolsky 2000 Endocr Rev), DHEA (Kroboth 1999), альдостерон (Funder 2016 Endocrine Society), катехоламины (Goldstein 2003 Endocr Regul), allostatic load (McEwen 1998 NEJM, McEwen & Wingfield 2003 Horm Behav), Cushing (Nieman 2008/2015 Endocrine Society), Addison (Bornstein 2016, Rushworth 2019 NEJM), adrenal fatigue vs HPA dysfunction (Cadegiani 2016 BMC), гипокортизолизм (Fries 2005 Psychoneuroendocrinology), кортизоловая кривая (Hellhammer 2009), pregnenolone steal (Miller & Auchus 2011 Endocr Rev), гиперкортизолизм у полных (Broersen 2015 JCEM), феохромоцитома (Lenders 2014 Endocrine Society), адаптогены обзор (Panossian & Wikman 2010 Pharmaceuticals), ашваганда РКИ (Chandrasekhar 2012 Indian J Psychol Med), кава (Pittler & Ernst 2003 Cochrane), магний и тревожность (Boyle 2017 Nutrients SR), L-теанин (Williams 2020 Plant Foods Hum Nutr), стресс и питание (Adam & Epel 2007 Physiol Behav), сон (Hirshkowitz 2015 Sleep Health NSF), дыхательные практики (Zaccaro 2018 Front Hum Neurosci), медитация (Goyal 2014 JAMA Intern Med). Коммит `814246f` (+280/-33 в 2 файлах). 🎯 **13/53 FULL_EBM (24.5 %), 604 EBM-тегов, 39 NO_EBM.**
' + $s10Anchor
Apply-Patch 'S10 пункт хронологии Session 59' 'status' $s10Anchor $s10New

# S11: маркер SESSION59
if ($status -match 'STATUS_SESSION58_APPLIED') {
    $status = $status -replace 'STATUS_SESSION58_APPLIED', 'STATUS_SESSION58_APPLIED -->
<!-- STATUS_SESSION59_APPLIED'
    $patches += 'S11 маркер SESSION59'
    Write-Host '[OK] S11 маркер SESSION59 добавлен после SESSION58'
} else {
    $status = $status.TrimEnd() + "`r`n`r`n<!-- STATUS_SESSION59_APPLIED -->`r`n"
    $patches += 'S11 маркер SESSION59 (append)'
    Write-Host '[OK] S11 маркер SESSION59 добавлен в конец файла'
}

# =============================================================================
# SOURCES_INDEX.md -- 4 патча
# =============================================================================

# I0: L619 -- дата шапки
$i0Old = '**Текущая карта состояний (2026-07-31, Session 50):**'
$i0New = '**Текущая карта состояний (2026-08-10, Session 59):**'
Apply-Patch 'I0 L619 дата шапки' 'src' $i0Old $i0New

# I1: L624 -- FULL_EBM 12->13 + stress_adrenals
$i1Old = '- **FULL_EBM — 12 файлов (22.6 %):** `autoimmune_basics.md`, `covid_pregnancy.md`, `female_hormones.md`, `gallbladder_health.md`, `hashimoto.md`, `joints_osteoporosis.md`, `minerals.md`, `nervous_system.md`, `nutraceuticals.md`, `pancreas_health.md`, `thyroid_health.md`, `vitamins.md`.'
$i1New = '- **FULL_EBM — 13 файлов (24.5 %):** `autoimmune_basics.md`, `covid_pregnancy.md`, `female_hormones.md`, `gallbladder_health.md`, `hashimoto.md`, `joints_osteoporosis.md`, `minerals.md`, `nervous_system.md`, `nutraceuticals.md`, `pancreas_health.md`, `stress_adrenals.md`, `thyroid_health.md`, `vitamins.md`.'
Apply-Patch 'I1 L624 FULL_EBM 12->13 + stress_adrenals' 'src' $i1Old $i1New

# I2: L626 -- PARTIAL переформулировка
$i2Old = '- **PARTIAL_EBM — 0 файлов (0 %):** ✅ исчерпан (Session 58, pancreas_health.md переведён в FULL_EBM; stress_adrenals.md переклассифицирован аудитом в NO_EBM — отсутствует Benchmark-секция).'
$i2New = '- **PARTIAL_EBM — 0 файлов (0 %):** ✅ исчерпан с Session 58. После Session 59 `stress_adrenals.md` переведён из NO_EBM в FULL_EBM (Benchmark §14 присутствовал, +30 inline тегов добавлено с нуля).'
Apply-Patch 'I2 L626 PARTIAL переформулировка' 'src' $i2Old $i2New

# I3a: L628 -- NO_EBM 40->39
$i3Old = '- **NO_EBM — 40 файлов (75.5 %):** в основном методологические и клиентские файлы, где EBM в форме RCT неприменима (интервью с клиентом, мотивационное интервью, этика, шаблоны меню, антипаразитарные протоколы без RCT-базы).'
$i3New = '- **NO_EBM — 39 файлов (73.6 %):** в основном методологические и клиентские файлы, где EBM в форме RCT неприменима (интервью с клиентом, мотивационное интервью, этика, шаблоны меню, антипаразитарные протоколы без RCT-базы). Приоритетные кандидаты на FULL_EBM: `insulin_resistance.md` (Session 60), `liver_health.md`, `menopause.md`.'
Apply-Patch 'I3a L628 NO_EBM 40->39' 'src' $i3Old $i3New

# I3b: L630 -- всего тегов 574->604
$i3bOld = '- **Всего:** 574 EBM-тегов, ~37 500 строк методологии (обновлено Session 58, 2026-08-06 — полное EBM-обогащение pancreas_health.md с нуля, +30 inline тегов; PARTIAL_EBM исчерпан).'
$i3bNew = '- **Всего:** 604 EBM-тегов, ~37 500 строк методологии (обновлено Session 59, 2026-08-10 — полное EBM-обогащение stress_adrenals.md с нуля, +30 inline тегов; density 100 %).'
Apply-Patch 'I3b L630 всего тегов 574->604' 'src' $i3bOld $i3bNew

# I4: маркер v58 -> v59
$i4Old = '<!-- SOURCES_INDEX_EBM_APPLIED_v58 -->'
$i4New = '<!-- SOURCES_INDEX_EBM_APPLIED_v59 -->'
Apply-Patch 'I4 маркер v58 -> v59' 'src' $i4Old $i4New

# =============================================================================
# ВАЛИДАЦИЯ
# =============================================================================

Write-Host ''
Write-Host '=== Валидация ==='

$sizeStatusAfter = [System.Text.Encoding]::UTF8.GetByteCount($status)
$sizeSrcAfter    = [System.Text.Encoding]::UTF8.GetByteCount($src)
$deltaStatus = $sizeStatusAfter - $sizeStatusBefore
$deltaSrc    = $sizeSrcAfter    - $sizeSrcBefore

$checks = @(
    @{Name='STATUS содержит 13/53 файлов (24.5%)';   Test={ $status -match '13/53 файлов \(24\.5%\)' }},
    @{Name='STATUS содержит 39/53 файлов (73.6%)';   Test={ $status -match '39/53 файлов \(73\.6%\)' }},
    @{Name='STATUS содержит 604 EBM-тегов';          Test={ $status -match '604' }},
    @{Name='STATUS содержит 37 416 строк';           Test={ $status -match '37 416' }},
    @{Name='STATUS блок Session 60 план';            Test={ $status -match 'Следующая сессия — Session 60' }},
    @{Name='STATUS упоминает insulin_resistance';    Test={ $status -match 'insulin_resistance\.md' }},
    @{Name='STATUS упоминает DiRECT';                Test={ $status -match 'DiRECT' }},
    @{Name='STATUS Session 59 факт';                 Test={ $status -match 'Session 59 факт' }},
    @{Name='STATUS пункт хронологии Session 59';     Test={ $status -match '\*\*Session 59\*\* \(2026-08-10' }},
    @{Name='STATUS упоминает коммит 814246f';        Test={ $status -match '814246f' }},
    @{Name='STATUS маркер SESSION59_APPLIED';        Test={ $status -match 'STATUS_SESSION59_APPLIED' }},
    @{Name='STATUS убран артефакт vitamins.md';      Test={ -not ($status -match 'vitamins\.md.*1777 строк') }},
    @{Name='STATUS убран старый блок Session 59 план'; Test={ -not ($status -match 'Следующая сессия — Session 59') }},
    @{Name='SOURCES дата шапки 2026-08-10';          Test={ $src -match '2026-08-10, Session 59' }},
    @{Name='SOURCES FULL_EBM 13 файлов';             Test={ $src -match 'FULL_EBM — 13 файлов' }},
    @{Name='SOURCES stress_adrenals в FULL списке';  Test={ $src -match 'pancreas_health\.md`, `stress_adrenals\.md`, `thyroid_health\.md' }},
    @{Name='SOURCES NO_EBM 39 файлов';               Test={ $src -match 'NO_EBM — 39 файлов' }},
    @{Name='SOURCES всего 604 EBM-тегов';            Test={ $src -match 'Всего:\*\* 604 EBM-тегов' }},
    @{Name='SOURCES маркер v59';                     Test={ $src -match 'SOURCES_INDEX_EBM_APPLIED_v59' }},
    @{Name='SOURCES маркер v58 удалён';              Test={ -not ($src -match 'SOURCES_INDEX_EBM_APPLIED_v58') }},
    @{Name='SOURCES убрано 12 файлов (22.6 %)';      Test={ -not ($src -match 'FULL_EBM — 12 файлов') }},
    @{Name='SOURCES убрано 574 EBM-тегов';           Test={ -not ($src -match 'Всего:\*\* 574') }},
    @{Name='STATUS размер +1200 chars (запас 20%)';  Test={ $deltaStatus -ge 1200 }},
    @{Name='SOURCES размер +50 chars';               Test={ $deltaSrc    -ge 50 }},
    @{Name='STATUS размер не раздут (< +8000)';      Test={ $deltaStatus -lt 8000 }}
)

$failCount = 0
foreach ($c in $checks) {
    $ok = & $c.Test
    if ($ok) { Write-Host ('[OK] '   + $c.Name) }
    else     { Write-Host ('[FAIL] ' + $c.Name); $failCount++ }
}

if ($failCount -gt 0) {
    Write-Host ''
    Write-Host "[ABORT] $failCount валидаций провалено -- файлы НЕ записаны."
    Write-Host "Backup STATUS:  $statusBak"
    Write-Host "Backup SOURCES: $srcBak"
    exit 1
}

Set-Content -Path $statusFile -Value $status -Encoding UTF8 -NoNewline
Set-Content -Path $srcFile    -Value $src    -Encoding UTF8 -NoNewline

Write-Host ''
Write-Host '=== ИТОГ ==='
Write-Host ("STATUS.md:        $sizeStatusBefore -> $sizeStatusAfter (delta $deltaStatus bytes)")
Write-Host ("SOURCES_INDEX.md: $sizeSrcBefore -> $sizeSrcAfter (delta $deltaSrc bytes)")
Write-Host ("Патчей применено: " + $patches.Count)
Write-Host ("Валидаций OK: " + $checks.Count)
Write-Host ''
Write-Host "Backup STATUS:  $statusBak"
Write-Host "Backup SOURCES: $srcBak"
Write-Host ''
Write-Host '[DONE] Session 59 close complete. Готово к git add + commit.'
