# =============================================================================
# scripts/close_session60.ps1
# Session 60 close: STATUS.md + SOURCES_INDEX.md after insulin_resistance.md
#   NO_EBM -> FULL_EBM (14/53, 26.4%, 634 EBM tags, +30)
# Rules: L-057-01 single quotes, TD-006 no md-tables in body,
#        TD-008/L-059-02 UTF-8 BOM, TD-010/Invariant 8 byte-verified anchors,
#        L-059-03/Invariant 9 size thresholds by fact (Abs delta for meta files)
# =============================================================================

$ErrorActionPreference = 'Stop'
$statusPath  = 'project/STATUS.md'
$sourcesPath = 'v2/SOURCES_INDEX.md'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

Write-Host '=== Session 60 close: STATUS + SOURCES_INDEX ==='

# ---- Guard ----
$statusRaw0  = Get-Content $statusPath  -Raw -Encoding UTF8
$sourcesRaw0 = Get-Content $sourcesPath -Raw -Encoding UTF8
if ($statusRaw0  -match 'STATUS_SESSION60_APPLIED')       { Write-Host '[ABORT] STATUS.md уже содержит маркер STATUS_SESSION60_APPLIED.'; exit 1 }
if ($sourcesRaw0 -match 'SOURCES_INDEX_EBM_APPLIED_v60')  { Write-Host '[ABORT] SOURCES_INDEX.md уже содержит маркер v60.'; exit 1 }

# ---- Backup ----
$bakS = "$statusPath.bak.$stamp"
$bakI = "$sourcesPath.bak.$stamp"
Copy-Item $statusPath  $bakS -Force
Copy-Item $sourcesPath $bakI -Force
Write-Host "[OK] Backup STATUS:  $bakS"
Write-Host "[OK] Backup SOURCES: $bakI"

$sizeS0 = (Get-Item $statusPath).Length
$sizeI0 = (Get-Item $sourcesPath).Length
Write-Host "Before: STATUS $sizeS0 bytes, SOURCES $sizeI0 bytes"

$statusRaw  = $statusRaw0
$sourcesRaw = $sourcesRaw0
$patches = @()

function Apply-PatchS { param([string]$Name,[string]$Old,[string]$New)
  if ($script:statusRaw -notmatch [regex]::Escape($Old)) { throw "[FAIL] Patch '$Name' -- anchor not found in STATUS.md" }
  $script:statusRaw = $script:statusRaw.Replace($Old,$New); $script:patches += $Name; Write-Host "[OK] $Name"
}
function Apply-PatchI { param([string]$Name,[string]$Old,[string]$New)
  if ($script:sourcesRaw -notmatch [regex]::Escape($Old)) { throw "[FAIL] Patch '$Name' -- anchor not found in SOURCES_INDEX.md" }
  $script:sourcesRaw = $script:sourcesRaw.Replace($Old,$New); $script:patches += $Name; Write-Host "[OK] $Name"
}

# ============ STATUS.md patches ============

# S1: L6 главная сводка
$s1Old = '**Последнее событие:** Session 59, Этап F.2 — EBM-обогащение `stress_adrenals.md` (NO_EBM → FULL_EBM, 0 → 30 EBM-тегов, +30 inline с нуля, v2.0 → v2.1). Прогресс: 12 → **13 FULL_EBM** файлов (24.5 %), 0 PARTIAL, 574 → **604 EBM-тегов** (+30). 🎯 Первое NO_EBM → FULL_EBM с нуля после исчерпания PARTIAL — доказана масштабируемость методологии на оставшиеся 39 файлов.'
$s1New = '**Последнее событие:** Session 60, Этап F.2 — EBM-обогащение `insulin_resistance.md` (NO_EBM → FULL_EBM, 0 → 30 EBM-тегов, +30 inline с нуля, v2.0 → v2.1). Прогресс: 13 → **14 FULL_EBM** файлов (26.4 %), 0 PARTIAL, 604 → **634 EBM-тегов** (+30). 🎯 Второе NO_EBM → FULL_EBM подряд с нуля — playbook v1.2 (Invariants 8+9) обеспечил 35/35 патчей и 38/38 валидаций с первого прогона, 0 инцидентов. Методология стабильно масштабируется на оставшиеся 38 файлов.'
Apply-PatchS 'S1 L6 главная сводка' $s1Old $s1New

# S2: L87 FULL_EBM 13 -> 14
Apply-PatchS 'S2 L87 FULL_EBM 13->14' `
  '- **FULL_EBM: 13/53 файлов (24.5%)** — было 12, +1 (`stress_adrenals.md`)' `
  '- **FULL_EBM: 14/53 файлов (26.4%)** — было 13, +1 (`insulin_resistance.md`)'

# S3: L88 PARTIAL уточнение
Apply-PatchS 'S3 L88 PARTIAL уточнение' `
  '- **PARTIAL_EBM: 0/53 файлов (0%)** — без изменений (исчерпан с Session 58)' `
  '- **PARTIAL_EBM: 0/53 файлов (0%)** — без изменений с Session 58 (исчерпан)'

# S4: L89 NO_EBM 39 -> 38
Apply-PatchS 'S4 L89 NO_EBM 39->38' `
  '- **NO_EBM: 39/53 файлов (73.6%)** — было 40, -1 (`stress_adrenals.md` ушёл в FULL_EBM)' `
  '- **NO_EBM: 38/53 файлов (71.7%)** — было 39, -1 (`insulin_resistance.md` ушёл в FULL_EBM)'

# S5: L90 tags 604 -> 634
Apply-PatchS 'S5 L90 tags 604->634' `
  '- Всего EBM-тегов: **604** (было 574, +30 — полное EBM-обогащение stress_adrenals.md с нуля в 27 H2 + 3 H3, density 100 %)' `
  '- Всего EBM-тегов: **634** (было 604, +30 — полное EBM-обогащение insulin_resistance.md с нуля в 23 H2 + 7 H3, density 100 %)'

# S6: L91 lines 37 416 -> 37 457
Apply-PatchS 'S6 L91 lines 37416->37457' `
  '- Всего строк: 37 416' `
  '- Всего строк: 37 457'

# S7: L100-115 блок "Следующая сессия" - Session 60 -> Session 61
$s7Old = @'
## ➡️ Следующая сессия — Session 60 (Этап F.2 продолжение)

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
'@
$s7New = @'
## ➡️ Следующая сессия — Session 61 (Этап F.2 продолжение)

**Цель:** EBM-обогащение `liver_health.md` (NO_EBM → FULL_EBM, 0 → ~30 EBM-тегов, полное обогащение с нуля — EASL 2024, AASLD 2023, Younossi 2016, PIVENS 2010, Chalasani 2018, Sanyal 2021 resmetirom, Romero-Gómez 2017 lifestyle meta)

### Исходное состояние

- `references/methodology/liver_health.md`: файл в списке NO_EBM (38/53), кластер 5 (гепатология, NAFLD/MASLD)
- **0 EBM-тегов сейчас** (порог FULL_EBM = 30), Benchmark-секция подлежит созданию с нуля
- Прямые связки с уже готовыми FULL_EBM: `pancreas_health.md` (β-клетки, метаболизм) и `insulin_resistance.md` (ИР → NAFLD ключевая ось) — логическое замыкание кластера 5: ИР → NAFLD → цирроз
- Маркер обогащения будет: `<!-- EBM_ENRICHED_v2.1 -->` (новый)

### Ключевые источники для добавления

- **EASL–EASD–EASO Clinical Practice Guidelines 2024** — MASLD (обновлённая номенклатура NAFLD), диагностика, стратификация
- **AASLD 2023 Practice Guidance** (Rinella et al., Hepatology) — многодисциплинарное ведение MASLD/MASH
- **Younossi 2016 Hepatology** — глобальная эпидемиология NAFLD (мета-анализ, 8.5 млн пациентов, 86 исследований)
- **PIVENS 2010 NEJM** (Sanyal) — витамин E 800 МЕ/сут vs пиоглитазон vs плацебо при NASH без диабета
- **Sanyal 2021/2024 NEJM (MAESTRO-NASH)** — resmetirom, первый одобренный препарат для MASH (2024)
'@
Apply-PatchS 'S7 L100-115 Session 61 план' $s7Old $s7New

# S8: L137 хвост
Apply-PatchS 'S8 L137 хвост' `
  'PARTIAL_EBM = 0/53 после Session 58. Все файлы с Benchmark-секцией переведены в FULL_EBM. Дальнейшие сессии F.2 работают с NO_EBM (39 файлов после Session 59): создание Benchmark-секции с нуля + inline-теги. Session 59 закрыта (stress_adrenals.md → FULL_EBM). Следующий кандидат — insulin_resistance.md (Session 60).' `
  'PARTIAL_EBM = 0/53 после Session 58. Все файлы с Benchmark-секцией переведены в FULL_EBM. Дальнейшие сессии F.2 работают с NO_EBM (38 файлов после Session 60): создание Benchmark-секции с нуля + inline-теги. Session 60 закрыта (insulin_resistance.md → FULL_EBM). Следующий кандидат — liver_health.md (Session 61) — логическая связка кластера 5: ИР → NAFLD → цирроз.'

# S9: L144-145 план -> факт + новый план
$s9Old = @'
- Session 60: insulin_resistance.md (0 → ~30 тегов, NO_EBM → FULL_EBM — ADA 2024, DPP, Look AHEAD, DiRECT, Taylor twin-cycle, Finnish DPS, HOMA-IR, Reaven; создание Benchmark-секции с нуля + inline-теги)
- Прогноз к концу Session 60: **14/53 FULL_EBM (26.4 %), 0 PARTIAL, 38 NO_EBM**, ~634 EBM-тегов.
'@
$s9New = @'
- Session 60: insulin_resistance.md ✅ выполнено (0 → 30 тегов, NO_EBM → FULL_EBM — Röder 2016, Jenkins 1981, Rizza 2010, Wilcox 2005, ADA 2024, Uribarri 2010, Fasshauer & Blüher 2015, Petersen & Shulman 2018, Tabák 2012, Alberti 2009, Reaven 1988, DiMeglio 2018, DeFronzo 2015, UKPDS 33 1998, Matthews 1985, Evert 2019, de Cabo & Mattson 2019, Colberg 2016, Costello 2016, Knowler 2002 DPP, Lean 2018 DiRECT, Schauer 2017 STAMPEDE, Estruch 2018 PREDIMED, Athinarayanan 2019, Jelleyman 2015; 23 H2 + 7 H3, density 100 %)
- Session 61: liver_health.md (0 → ~30 тегов, NO_EBM → FULL_EBM — EASL 2024, AASLD 2023, Younossi 2016, PIVENS 2010, Chalasani 2018, Sanyal 2021, Romero-Gómez 2017; создание Benchmark-секции с нуля + inline-теги)
- Прогноз к концу Session 61: **15/53 FULL_EBM (28.3 %), 0 PARTIAL, 37 NO_EBM**, ~664 EBM-тегов.
'@
Apply-PatchS 'S9 L144-145 план -> факт + Session 61' $s9Old $s9New

# S10: L149 вставить Session 60 факт ПЕРЕД строкой Session 59
$s10Old = '**Session 59 факт:** 13/53 FULL_EBM (24.5 %), 0 PARTIAL, **39 NO_EBM**, **604 EBM-тегов** (+30). 🎯 Milestone: первое NO_EBM → FULL_EBM с нуля после исчерпания PARTIAL. Обогащение stress_adrenals.md за один проход (30 патчей контента + 5 метаданных, 41/41 валидаций OK), density 100 %.'
$s10New = @'
**Session 60 факт:** 14/53 FULL_EBM (26.4 %), 0 PARTIAL, **38 NO_EBM**, **634 EBM-тегов** (+30). 🎯 Milestone: второе NO_EBM → FULL_EBM подряд с нуля; playbook v1.2 (Invariants 8+9 — байтовая валидация якорей + UTF-8 BOM + пороги по факту) обеспечил 35/35 патчей и 38/38 валидаций с первого прогона (0 инцидентов, впервые за F.2). Обогащение insulin_resistance.md: 23/23 H2 + 7 H3 глубоких (DPP, DiRECT, STAMPEDE, HOMA-IR, PREDIMED, low-carb, HIIT), +4 440 байт, density 100 %.

**Session 59 факт:** 13/53 FULL_EBM (24.5 %), 0 PARTIAL, **39 NO_EBM**, **604 EBM-тегов** (+30). 🎯 Milestone: первое NO_EBM → FULL_EBM с нуля после исчерпания PARTIAL. Обогащение stress_adrenals.md за один проход (30 патчей контента + 5 метаданных, 41/41 валидаций OK), density 100 %.
'@
Apply-PatchS 'S10 L149 Session 60 факт (insert перед Session 59)' $s10Old $s10New

# S11: Хронология - вставить пункт Session 60 перед строкой SESSION56 маркера
$s11Old = '<!-- STATUS_SESSION59_APPLIED -->'
$s11New = @'
<!-- STATUS_SESSION59_APPLIED -->
<!-- STATUS_SESSION60_APPLIED -->
'@
Apply-PatchS 'S11 L206 маркер STATUS_SESSION60_APPLIED' $s11Old $s11New

# ============ SOURCES_INDEX.md patches ============

# I1: L620 дата и сессия
Apply-PatchI 'I1 L620 дата -> 2026-08-13, Session 60' `
  '**Текущая карта состояний (2026-08-10, Session 59):**' `
  '**Текущая карта состояний (2026-08-13, Session 60):**'

# I2: L624 FULL_EBM 13 -> 14 + insulin_resistance.md алфавитно
Apply-PatchI 'I2 L624 FULL_EBM 14 файлов + insulin_resistance.md' `
  '- **FULL_EBM — 13 файлов (24.5 %):** `autoimmune_basics.md`, `covid_pregnancy.md`, `female_hormones.md`, `gallbladder_health.md`, `hashimoto.md`, `joints_osteoporosis.md`, `minerals.md`, `nervous_system.md`, `nutraceuticals.md`, `pancreas_health.md`, `stress_adrenals.md`, `thyroid_health.md`, `vitamins.md`.' `
  '- **FULL_EBM — 14 файлов (26.4 %):** `autoimmune_basics.md`, `covid_pregnancy.md`, `female_hormones.md`, `gallbladder_health.md`, `hashimoto.md`, `insulin_resistance.md`, `joints_osteoporosis.md`, `minerals.md`, `nervous_system.md`, `nutraceuticals.md`, `pancreas_health.md`, `stress_adrenals.md`, `thyroid_health.md`, `vitamins.md`.'

# I3: L626 PARTIAL - добавить упоминание Session 60
Apply-PatchI 'I3 L626 PARTIAL + Session 60 note' `
  '- **PARTIAL_EBM — 0 файлов (0 %):** ✅ исчерпан с Session 58. После Session 59 `stress_adrenals.md` переведён из NO_EBM в FULL_EBM (Benchmark §14 присутствовал, +30 inline тегов добавлено с нуля).' `
  '- **PARTIAL_EBM — 0 файлов (0 %):** ✅ исчерпан с Session 58. После Session 59 `stress_adrenals.md` переведён из NO_EBM в FULL_EBM (Benchmark §14 присутствовал, +30 inline тегов добавлено с нуля). После Session 60 `insulin_resistance.md` переведён из NO_EBM в FULL_EBM (Benchmark создан с нуля, +30 inline тегов, 23 H2 + 7 H3).'

# I4: L628 NO_EBM 39 -> 38 + новые кандидаты
Apply-PatchI 'I4 L628 NO_EBM 38 файлов + кандидаты Session 61+' `
  '- **NO_EBM — 39 файлов (73.6 %):** в основном методологические и клиентские файлы, где EBM в форме RCT неприменима (интервью с клиентом, мотивационное интервью, этика, шаблоны меню, антипаразитарные протоколы без RCT-базы). Приоритетные кандидаты на FULL_EBM: `insulin_resistance.md` (Session 60), `liver_health.md`, `menopause.md`.' `
  '- **NO_EBM — 38 файлов (71.7 %):** в основном методологические и клиентские файлы, где EBM в форме RCT неприменима (интервью с клиентом, мотивационное интервью, этика, шаблоны меню, антипаразитарные протоколы без RCT-базы). Приоритетные кандидаты на FULL_EBM: `liver_health.md` (Session 61 — замыкание кластера 5: ИР → NAFLD → цирроз), `menopause.md`, `intestinal_health.md`.'

# I5: Всего EBM-тегов 604 -> 634 + Session 60
Apply-PatchI 'I5 Всего 634 EBM-тегов + Session 60' `
  '- **Всего:** 604 EBM-тегов, ~37 500 строк методологии (обновлено Session 59, 2026-08-10 — полное EBM-обогащение stress_adrenals.md с нуля, +30 inline тегов; density 100 %).' `
  '- **Всего:** 634 EBM-тегов, ~37 500 строк методологии (обновлено Session 60, 2026-08-13 — полное EBM-обогащение insulin_resistance.md с нуля, +30 inline тегов; density 100 %; playbook v1.2 первый прогон без инцидентов — 35/35 патчей, 38/38 валидаций).'

# I6: маркер v59 -> v60
Apply-PatchI 'I6 маркер v59 -> v60' `
  '<!-- SOURCES_INDEX_EBM_APPLIED_v59 -->' `
  '<!-- SOURCES_INDEX_EBM_APPLIED_v60 -->'

# ============ Validation ============

Write-Host ''
Write-Host '=== Validation ==='

$deltaS = $statusRaw.Length  - $statusRaw0.Length
$deltaI = $sourcesRaw.Length - $sourcesRaw0.Length
Write-Host "STATUS delta chars: $deltaS"
Write-Host "SOURCES delta chars: $deltaI"

$validations = @(
  @{Name='STATUS содержит 14/53 файлов (26.4%)';           Test={ $statusRaw -match '14/53 файлов \(26\.4%\)' }},
  @{Name='STATUS содержит 38/53 файлов (71.7%)';           Test={ $statusRaw -match '38/53 файлов \(71\.7%\)' }},
  @{Name='STATUS содержит 634 EBM-тегов';                  Test={ $statusRaw -match '634 EBM-тегов' }},
  @{Name='STATUS содержит 37 457 строк';                   Test={ $statusRaw -match '37 457' }},
  @{Name='STATUS содержит Session 60 факт';                Test={ $statusRaw -match 'Session 60 факт' }},
  @{Name='STATUS содержит liver_health.md';                Test={ $statusRaw -match 'liver_health\.md' }},
  @{Name='STATUS содержит EASL 2024';                      Test={ $statusRaw -match 'EASL 2024' }},
  @{Name='STATUS содержит PIVENS';                         Test={ $statusRaw -match 'PIVENS' }},
  @{Name='STATUS содержит Session 61 план';                Test={ $statusRaw -match 'Session 61 \(Этап F\.2' }},
  @{Name='STATUS содержит маркер SESSION60_APPLIED';       Test={ $statusRaw -match 'STATUS_SESSION60_APPLIED' }},
  @{Name='STATUS сохранил маркер SESSION59_APPLIED';       Test={ $statusRaw -match 'STATUS_SESSION59_APPLIED' }},
  @{Name='STATUS сохранил Session 59 факт (архив)';        Test={ $statusRaw -match 'Session 59 факт' }},
  @{Name='STATUS убрал 13 FULL_EBM файлов из L87';         Test={ -not ($statusRaw -match '\*\*FULL_EBM: 13/53 файлов') }},
  @{Name='STATUS убрал 39 NO_EBM файлов из L89';           Test={ -not ($statusRaw -match '\*\*NO_EBM: 39/53 файлов') }},
  @{Name='STATUS убрал 604 EBM-тегов из L90';              Test={ -not ($statusRaw -match 'Всего EBM-тегов: \*\*604\*\*') }},
  @{Name='STATUS убрал старый блок Session 60 план';       Test={ -not ($statusRaw -match 'Следующая сессия — Session 60') }},
  @{Name='STATUS размер +1500 chars';                      Test={ $deltaS -ge 1500 }},
  @{Name='SOURCES содержит Session 60 в заголовке';        Test={ $sourcesRaw -match '2026-08-13, Session 60' }},
  @{Name='SOURCES содержит 14 файлов (26.4 %)';            Test={ $sourcesRaw -match '14 файлов \(26\.4 %\)' }},
  @{Name='SOURCES содержит insulin_resistance.md в FULL';  Test={ $sourcesRaw -match 'hashimoto\.md`, `insulin_resistance\.md`, `joints' }},
  @{Name='SOURCES содержит 38 файлов (71.7 %)';            Test={ $sourcesRaw -match '38 файлов \(71\.7 %\)' }},
  @{Name='SOURCES содержит 634 EBM-тегов';                 Test={ $sourcesRaw -match '634 EBM-тегов' }},
  @{Name='SOURCES содержит маркер v60';                    Test={ $sourcesRaw -match 'SOURCES_INDEX_EBM_APPLIED_v60' }},
  @{Name='SOURCES убрал маркер v59';                       Test={ -not ($sourcesRaw -match 'SOURCES_INDEX_EBM_APPLIED_v59') }},
  @{Name='SOURCES убрал 13 файлов (24.5 %) из FULL';       Test={ -not ($sourcesRaw -match '13 файлов \(24\.5 %\)') }},
  @{Name='SOURCES убрал 604 EBM-тегов';                    Test={ -not ($sourcesRaw -match '604 EBM-тегов') }},
  @{Name='SOURCES размер Abs delta >= 50 (L-059-03)';      Test={ [Math]::Abs($deltaI) -ge 50 }}
)

$okCount = 0
$failCount = 0
foreach ($v in $validations) {
  $result = & $v.Test
  if ($result) { Write-Host "[OK]   $($v.Name)"; $okCount++ }
  else         { Write-Host "[FAIL] $($v.Name)"; $failCount++ }
}

Write-Host ''
Write-Host "Validation summary: $okCount OK, $failCount FAIL"

if ($failCount -gt 0) {
  Write-Host '[ABORT] Файлы НЕ записаны. Backup сохранён:'
  Write-Host "  $bakS"
  Write-Host "  $bakI"
  exit 1
}

# ---- Write ----
$utf8bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path $statusPath),  $statusRaw,  $utf8bom)
[System.IO.File]::WriteAllText((Resolve-Path $sourcesPath), $sourcesRaw, $utf8bom)

$sizeS1 = (Get-Item $statusPath).Length
$sizeI1 = (Get-Item $sourcesPath).Length

Write-Host ''
Write-Host '=== SUCCESS ==='
Write-Host "STATUS:  $sizeS0 -> $sizeS1 bytes (delta $($sizeS1 - $sizeS0))"
Write-Host "SOURCES: $sizeI0 -> $sizeI1 bytes (delta $($sizeI1 - $sizeI0))"
Write-Host "Patches applied: $($patches.Count)"
Write-Host "Validations OK:  $okCount"
Write-Host "Backups: $bakS ; $bakI"
Write-Host ''
Write-Host 'Ready for git add + commit.'
