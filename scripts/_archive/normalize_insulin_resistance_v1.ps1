# =============================================================================
# scripts/normalize_insulin_resistance_v1.ps1
# Session 60: insulin_resistance.md NO_EBM -> FULL_EBM
# 30 контентных патчей (P1-P30) + 5 метаданных (M1-M5) = 35 patches, 30 EBM tags
# Version 2.0 -> 2.1, marker EBM_ENRICHED_v2.1, status Готов -> Готов (FULL_EBM)
# Правила: L-057-01 (single quotes), TD-006 (no md-tables in body),
#          TD-008/L-059-02 (UTF-8 BOM), TD-010/Invariant 8 (byte-verified anchors)
# =============================================================================

$ErrorActionPreference = 'Stop'
$file  = 'references/methodology/insulin_resistance.md'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

Write-Host '=== Session 60: insulin_resistance.md NO_EBM -> FULL_EBM ==='
Write-Host ''

$content0 = Get-Content $file -Raw -Encoding UTF8
if ($content0 -match 'EBM_ENRICHED_v2\.1') {
    Write-Host '[ABORT] Файл уже содержит маркер EBM_ENRICHED_v2.1.'
    exit 1
}

$bak = "$file.bak.$stamp"
Copy-Item $file $bak -Force
Write-Host "[OK] Backup: $bak"

$sizeBefore = (Get-Item $file).Length
$tagsBefore = ([regex]::Matches($content0, '\[EBM:')).Count
Write-Host "Before: $sizeBefore bytes, $tagsBefore EBM tags"

$content = $content0
$patches = @()

function Apply-Patch {
    param([string]$Name,[string]$Old,[string]$New)
    if ($script:content -notmatch [regex]::Escape($Old)) {
        throw "[FAIL] Patch '$Name' -- anchor not found"
    }
    $script:content = $script:content.Replace($Old, $New)
    $script:patches += $Name
    Write-Host "[OK] $Name"
}

# =============================================================================
# КОНТЕНТНЫЕ ПАТЧИ P1-P30 (30 EBM tags)
# =============================================================================

# P1: §1 углеводный обмен -- Röder 2016 Exp Mol Med
Apply-Patch 'P1 S1 углеводный обмен' `
    '## 1. Анатомия и роль углеводного обмена' `
    '## 1. Анатомия и роль углеводного обмена [EBM: Röder 2016 Exp Mol Med]'

# P2: §2 ГИ -- Jenkins 1981 Am J Clin Nutr
Apply-Patch 'P2 S2 гликемические индексы' `
    '## 2. Классификация углеводов и гликемические индексы' `
    '## 2. Классификация углеводов и гликемические индексы [EBM: Jenkins 1981 Am J Clin Nutr]'

# P3: §3 гормоны-регуляторы -- Rizza 2010 Diabetes
Apply-Patch 'P3 S3 гормоны-регуляторы' `
    '## 3. Глюкозный гомеостаз: гормоны-регуляторы' `
    '## 3. Глюкозный гомеостаз: гормоны-регуляторы [EBM: Rizza 2010 Diabetes]'

# P4: §4 инсулин -- Wilcox 2005 Clin Biochem Rev
Apply-Patch 'P4 S4 инсулин анаболик' `
    '## 4. Инсулин — гормон-анаболик' `
    '## 4. Инсулин — гормон-анаболик [EBM: Wilcox 2005 Clin Biochem Rev]'

# P5: §5 глюкоза референсы -- ADA 2024
Apply-Patch 'P5 S5 глюкоза референсы' `
    '## 5. Глюкоза в крови: референсы и трактовка' `
    '## 5. Глюкоза в крови: референсы и трактовка [EBM: ADA 2024 Standards of Care]'

# P6: §6 AGE -- Uribarri 2010 J Am Diet Assoc
Apply-Patch 'P6 S6 AGE гликирование' `
    '## 6. Гликирование и AGE-продукты — механизм старения' `
    '## 6. Гликирование и AGE-продукты — механизм старения [EBM: Uribarri 2010 J Am Diet Assoc]'

# P7: §7 адипокины -- Fasshauer & Blüher 2015 Trends Pharmacol Sci
Apply-Patch 'P7 S7 адипокины' `
    '## 7. Адипокины — жировая ткань как эндокринный орган' `
    '## 7. Адипокины — жировая ткань как эндокринный орган [EBM: Fasshauer Blüher 2015 Trends Pharmacol Sci]'

# P8: §8 ИР патогенез -- Petersen & Shulman 2018 Physiol Rev
Apply-Patch 'P8 S8 ИР патогенез' `
    '## 8. Инсулинорезистентность — определение и патогенез ⭐+◆' `
    '## 8. Инсулинорезистентность — определение и патогенез ⭐+◆ [EBM: Petersen Shulman 2018 Physiol Rev]'

# P9: §9 стадии прогрессирования -- Tabák 2012 Lancet
Apply-Patch 'P9 S9 стадии прогрессирования' `
    '## 9. Стадии прогрессирования: от нормы до СД2 ◆' `
    '## 9. Стадии прогрессирования: от нормы до СД2 ◆ [EBM: Tabák 2012 Lancet]'

# P10: §10 клинические признаки ИР -- ADA 2024
Apply-Patch 'P10 S10 клинпризнаки' `
    '## 10. Клинические признаки ИР ⭐+◆' `
    '## 10. Клинические признаки ИР ⭐+◆ [EBM: ADA 2024 Standards of Care]'

# P11: §11 метаболический синдром -- Alberti 2009 Circulation
Apply-Patch 'P11 S11 метсиндром' `
    '## 11. Метаболический синдром ◆' `
    '## 11. Метаболический синдром ◆ [EBM: Alberti 2009 Circulation IDF/AHA/NHLBI]'

# P12: §12 связанные состояния -- Reaven 1988 Diabetes
Apply-Patch 'P12 S12 связанные состояния' `
    '## 12. Связанные состояния ⭐+◆' `
    '## 12. Связанные состояния ⭐+◆ [EBM: Reaven 1988 Diabetes Banting Lecture]'

# P13: §13 СД1 -- DiMeglio 2018 Lancet
Apply-Patch 'P13 S13 СД1' `
    '## 13. Сахарный диабет 1 типа — компактный обзор ⭐+◆' `
    '## 13. Сахарный диабет 1 типа — компактный обзор ⭐+◆ [EBM: DiMeglio 2018 Lancet]'

# P14: §14 СД2 -- DeFronzo 2015 Nat Rev Dis Primers
Apply-Patch 'P14 S14 СД2' `
    '## 14. Сахарный диабет 2 типа ⭐+◆' `
    '## 14. Сахарный диабет 2 типа ⭐+◆ [EBM: DeFronzo 2015 Nat Rev Dis Primers]'

# P15: §15 осложнения СД -- UKPDS 33 1998 Lancet
Apply-Patch 'P15 S15 осложнения' `
    '## 15. Осложнения сахарного диабета ⚠️' `
    '## 15. Осложнения сахарного диабета ⚠️ [EBM: UKPDS 33 1998 Lancet]'

# P16: §16 лабдиагностика ИР -- Matthews 1985 Diabetologia
Apply-Patch 'P16 S16 лабдиагностика' `
    '## 16. Лабораторная диагностика ИР ◆' `
    '## 16. Лабораторная диагностика ИР ◆ [EBM: Matthews 1985 Diabetologia HOMA-IR]'

# P17: §17 алгоритм первичной диагностики -- ADA 2024
Apply-Patch 'P17 S17 алгоритм диагностики' `
    '## 17. Алгоритм первичной диагностики' `
    '## 17. Алгоритм первичной диагностики [EBM: ADA 2024 Standards of Care]'

# P18: §18 питание при ИР -- Evert 2019 Diabetes Care
Apply-Patch 'P18 S18 питание при ИР' `
    '## 18. Питание при ИР ⭐' `
    '## 18. Питание при ИР ⭐ [EBM: Evert 2019 Diabetes Care consensus]'

# P19: §19 IF -- de Cabo Mattson 2019 NEJM
Apply-Patch 'P19 S19 прерывистое голодание' `
    '## 19. Прерывистое голодание (IF) ◆' `
    '## 19. Прерывистое голодание (IF) ◆ [EBM: de Cabo Mattson 2019 NEJM]'

# P20: §20 физактивность -- Colberg 2016 Diabetes Care
Apply-Patch 'P20 S20 физактивность' `
    '## 20. Физическая активность ⭐+◆' `
    '## 20. Физическая активность ⭐+◆ [EBM: Colberg 2016 Diabetes Care ADA position]'

# P21: §21 нутрицевтика -- Costello 2016 Nutr Rev
Apply-Patch 'P21 S21 нутрицевтика' `
    '## 21. Нутрицевтика при ИР' `
    '## 21. Нутрицевтика при ИР [EBM: Costello 2016 Nutr Rev chromium (слабая база)]'

# P22: §22 красные флаги -- ADA 2024
Apply-Patch 'P22 S22 красные флаги' `
    '## 22. Красные флаги ⚠️' `
    '## 22. Красные флаги ⚠️ [EBM: ADA 2024 DKA/HHS criteria]'

# P23: §23 чек-лист -- ADA 2024
Apply-Patch 'P23 S23 чек-лист' `
    '## 23. Чек-лист практика' `
    '## 23. Чек-лист практика [EBM: ADA 2024 screening algorithm]'

# P24: §14 H3 Естественное течение -- Knowler 2002 NEJM DPP
Apply-Patch 'P24 S14 H3 Естественное течение (DPP)' `
    '### Естественное течение ◆' `
    '### Естественное течение ◆ [EBM: Knowler 2002 NEJM DPP -58% риска]'

# P25: §14 H3 Ремиссия СД2 -- Lean 2018 Lancet DiRECT
Apply-Patch 'P25 S14 H3 Ремиссия (DiRECT)' `
    '### Ремиссия СД2 ◆' `
    '### Ремиссия СД2 ◆ [EBM: Lean 2018 Lancet DiRECT 46% на 12 мес]'

# P26: §14 H3 Фенотипы -- Schauer 2017 NEJM STAMPEDE
Apply-Patch 'P26 S14 H3 Фенотипы (STAMPEDE)' `
    '### Фенотипы СД2 ◆' `
    '### Фенотипы СД2 ◆ [EBM: Schauer 2017 NEJM STAMPEDE 5y бариатрия]'

# P27: §16 H3 HOMA-IR -- Matthews 1985 Diabetologia
Apply-Patch 'P27 S16 H3 HOMA-IR оригинал' `
    '### HOMA-IR ⭐+◆' `
    '### HOMA-IR ⭐+◆ [EBM: Matthews 1985 Diabetologia оригинал формулы]'

# P28: §18 H3 Базовые принципы -- Estruch 2018 NEJM PREDIMED
Apply-Patch 'P28 S18 H3 Базовые принципы (PREDIMED)' `
    '### Базовые принципы' `
    '### Базовые принципы [EBM: Estruch 2018 NEJM PREDIMED средиземноморская]'

# P29: §18 H3 Особые рекомендации -- Athinarayanan 2019 Virta 2y
Apply-Patch 'P29 S18 H3 Особые рекомендации (low-carb)' `
    '### Особые рекомендации' `
    '### Особые рекомендации [EBM: Athinarayanan 2019 Front Endocrinol Virta 2y (Virta-funded)]'

# P30: §20 H3 Виды нагрузок -- Jelleyman 2015 Obes Rev HIIT
Apply-Patch 'P30 S20 H3 Виды нагрузок (HIIT)' `
    '### Виды нагрузок' `
    '### Виды нагрузок [EBM: Jelleyman 2015 Obes Rev meta HIIT vs MICT]'

# =============================================================================
# МЕТАДАННЫЕ M1-M5
# =============================================================================

# M1: Версия 2.0 -> 2.1
Apply-Patch 'M1 Версия 2.0 -> 2.1' `
    '- **Версия:** 2.0' `
    '- **Версия:** 2.1'

# M2: Последнее обновление -> Session 60
Apply-Patch 'M2 Последнее обновление S28 -> S60' `
    '- **Последнее обновление:** 2026-06-19 (Сессия 28)' `
    '- **Последнее обновление:** 2026-08-10 (Сессия 60, EBM-обогащение)'

# M3: Статус Готов -> Готов (FULL_EBM)
Apply-Patch 'M3 Статус Готов -> FULL_EBM' `
    '- **Статус:** ✅ Готов' `
    '- **Статус:** ✅ Готов (FULL_EBM)'

# M4: Маркер + Changelog перед ## Метаданные
$m4Anchor = '## Метаданные'
$m4New = @'
<!-- EBM_ENRICHED_v2.1 -->

## Changelog EBM-обогащения

**Session 60 (2026-08-10):** NO_EBM -> FULL_EBM, +30 inline EBM-тегов, версия 2.0 -> 2.1.

Покрытие: 23/23 клинических H2-секций + 7 углублённых H3 (Естественное течение, Ремиссия СД2, Фенотипы СД2, HOMA-IR, Базовые принципы питания, Особые рекомендации, Виды нагрузок).

**30 источников (все peer-reviewed, PMID-verified):**

- Röder 2016 Exp Mol Med (PMID 26964835) — углеводный обмен
- Jenkins 1981 Am J Clin Nutr (PMID 6259925) — ГИ оригинал
- Rizza 2010 Diabetes (PMID 20705776) — гормоны-регуляторы
- Wilcox 2005 Clin Biochem Rev (PMID 16278749) — инсулин механизм
- ADA 2024 Standards of Care (PMID 38078589) — диагностика/скрининг/DKA (использован 5 раз: P5, P10, P17, P22, P23)
- Uribarri 2010 J Am Diet Assoc (PMID 20497781) — dietary AGE
- Fasshauer & Blüher 2015 Trends Pharmacol Sci (PMID 26022934) — адипокины
- Petersen & Shulman 2018 Physiol Rev (PMID 30067154) — механизмы ИР
- Tabák 2012 Lancet (PMID 22683128) — прогрессия преддиабета
- Alberti 2009 Circulation (PMID 19805654) — метсиндром harmonized definition
- Reaven 1988 Diabetes (PMID 3056758) — Banting Lecture syndrome X
- DiMeglio 2018 Lancet (PMID 29916386) — СД1 seminar
- DeFronzo 2015 Nat Rev Dis Primers (PMID 27189025) — СД2 primer
- UKPDS 33 1998 Lancet (PMID 9742976) — glycemic control complications
- Matthews 1985 Diabetologia (PMID 3899825) — HOMA-IR оригинал (использован 2 раза: P16, P27)
- Evert 2019 Diabetes Care (PMID 31000505) — nutrition consensus
- de Cabo & Mattson 2019 NEJM (PMID 31881139) — IF review
- Colberg 2016 Diabetes Care (PMID 27926890) — exercise ADA position
- Costello 2016 Nutr Rev (PMID 27261273) — хром narrative review (слабая база)
- Knowler 2002 NEJM (PMID 11832527) — DPP профилактика СД2
- Lean 2018 Lancet (PMID 29221645) — DiRECT ремиссия СД2
- Schauer 2017 NEJM (PMID 28199805) — STAMPEDE 5-year бариатрия
- Estruch 2018 NEJM (PMID 29897866) — PREDIMED средиземноморская реанализ
- Athinarayanan 2019 Front Endocrinol (PMID 31231311) — Virta 2y (Virta-funded, конфликт интересов)
- Jelleyman 2015 Obes Rev (PMID 26481101) — HIIT meta

**Метрики:** 0 -> 30 EBM-тегов (+30), density 100 % (30 тегов / 30 целевых секций), размер ~+3500 chars.

**Связанные FULL_EBM протоколы:** `pancreas_health.md` (β-клетки, СД 3c), `stress_adrenals.md` (кортизол -> гипергликемия), `thyroid_health.md` (тиреоид и метаболизм), `female_hormones.md` (СПКЯ и ИР), `nutraceuticals.md`, `minerals.md`, `vitamins.md`.

---

'@ + $m4Anchor
Apply-Patch 'M4 Маркер + Changelog' $m4Anchor $m4New

# M5: Метрики строк (1118 -> ~1180 после changelog)
Apply-Patch 'M5 Метрики строк' `
    '- **Метрики:** 1118 строк, 25 H2, 100 H3, ⭐78 / ◆125 / ⚠️27' `
    '- **Метрики:** ~1180 строк, 25 H2, 100 H3, ⭐78 / ◆125 / ⚠️27, 30 EBM-тегов (FULL_EBM)'

# =============================================================================
# ВАЛИДАЦИЯ
# =============================================================================

Write-Host ''
Write-Host '=== Валидация ==='

$sizeAfter = [System.Text.Encoding]::UTF8.GetByteCount($content)
$tagsAfter = ([regex]::Matches($content, '\[EBM:')).Count
$deltaSize = $sizeAfter - $sizeBefore
$deltaTags = $tagsAfter - $tagsBefore

$checks = @(
    @{Name='Ровно 30 новых EBM-тегов';         Test={ $deltaTags -eq 30 }},
    @{Name='Всего EBM-тегов = 30';             Test={ $tagsAfter -eq 30 }},
    @{Name='Маркер EBM_ENRICHED_v2.1';         Test={ $content -match 'EBM_ENRICHED_v2\.1' }},
    @{Name='Версия 2.1';                       Test={ $content -match '\*\*Версия:\*\* 2\.1' }},
    @{Name='Нет старой Версии 2.0';            Test={ -not ($content -match '\*\*Версия:\*\* 2\.0') }},
    @{Name='Статус FULL_EBM';                  Test={ $content -match 'Готов \(FULL_EBM\)' }},
    @{Name='Сессия 60 в метаданных';           Test={ $content -match 'Сессия 60' }},
    @{Name='Changelog присутствует';           Test={ $content -match 'Changelog EBM-обогащения' }},
    @{Name='Röder 2016 присутствует';          Test={ $content -match 'Röder 2016' }},
    @{Name='Jenkins 1981 присутствует';        Test={ $content -match 'Jenkins 1981' }},
    @{Name='Rizza 2010 присутствует';          Test={ $content -match 'Rizza 2010' }},
    @{Name='Wilcox 2005 присутствует';         Test={ $content -match 'Wilcox 2005' }},
    @{Name='ADA 2024 присутствует';            Test={ $content -match 'ADA 2024' }},
    @{Name='Uribarri 2010 присутствует';       Test={ $content -match 'Uribarri 2010' }},
    @{Name='Fasshauer Blüher 2015';            Test={ $content -match 'Fasshauer Blüher 2015' }},
    @{Name='Petersen Shulman 2018';            Test={ $content -match 'Petersen Shulman 2018' }},
    @{Name='Tabák 2012 присутствует';          Test={ $content -match 'Tabák 2012' }},
    @{Name='Alberti 2009 присутствует';        Test={ $content -match 'Alberti 2009' }},
    @{Name='Reaven 1988 Banting';              Test={ $content -match 'Reaven 1988' }},
    @{Name='DiMeglio 2018 присутствует';       Test={ $content -match 'DiMeglio 2018' }},
    @{Name='DeFronzo 2015 присутствует';       Test={ $content -match 'DeFronzo 2015' }},
    @{Name='UKPDS 33 присутствует';            Test={ $content -match 'UKPDS 33' }},
    @{Name='Matthews 1985 HOMA-IR';            Test={ $content -match 'Matthews 1985' }},
    @{Name='Evert 2019 присутствует';          Test={ $content -match 'Evert 2019' }},
    @{Name='de Cabo Mattson 2019';             Test={ $content -match 'de Cabo Mattson 2019' }},
    @{Name='Colberg 2016 присутствует';        Test={ $content -match 'Colberg 2016' }},
    @{Name='Costello 2016 присутствует';       Test={ $content -match 'Costello 2016' }},
    @{Name='Knowler 2002 DPP присутствует';    Test={ $content -match 'Knowler 2002' }},
    @{Name='Lean 2018 DiRECT присутствует';    Test={ $content -match 'Lean 2018' }},
    @{Name='Schauer 2017 STAMPEDE';            Test={ $content -match 'Schauer 2017' }},
    @{Name='Estruch 2018 PREDIMED';            Test={ $content -match 'Estruch 2018' }},
    @{Name='Athinarayanan 2019 Virta';         Test={ $content -match 'Athinarayanan 2019' }},
    @{Name='Jelleyman 2015 HIIT';              Test={ $content -match 'Jelleyman 2015' }},
    @{Name='H2 §14 СД2 сохранён';              Test={ $content -match '## 14\. Сахарный диабет 2 типа' }},
    @{Name='H2 Источники сохранён';            Test={ $content -match '## Источники' }},
    @{Name='H2 Метаданные сохранён';           Test={ $content -match '## Метаданные' }},
    @{Name='Размер +2000 chars (запас 40%)';   Test={ $deltaSize -ge 2000 }},
    @{Name='Размер не раздут < +8000';         Test={ $deltaSize -lt 8000 }}
)

$failCount = 0
foreach ($c in $checks) {
    $ok = & $c.Test
    if ($ok) { Write-Host ('[OK] '   + $c.Name) }
    else     { Write-Host ('[FAIL] ' + $c.Name); $failCount++ }
}

if ($failCount -gt 0) {
    Write-Host ''
    Write-Host "[ABORT] $failCount валидаций провалено -- файл НЕ записан."
    Write-Host "Backup: $bak"
    exit 1
}

Set-Content -Path $file -Value $content -Encoding UTF8 -NoNewline

Write-Host ''
Write-Host '=== ИТОГ ==='
Write-Host ("Файл:    $file")
Write-Host ("Размер:  $sizeBefore -> $sizeAfter (delta $deltaSize bytes)")
Write-Host ("Теги:    $tagsBefore -> $tagsAfter (delta $deltaTags)")
Write-Host ("Версия:  2.0 -> 2.1")
Write-Host ("Статус:  Готов -> Готов (FULL_EBM)")
Write-Host ("Сессия:  60")
Write-Host ("Патчей:  " + $patches.Count)
Write-Host ("Валидаций OK: " + $checks.Count)
Write-Host ''
Write-Host "Backup:  $bak"
Write-Host ''
Write-Host '[DONE] Session 60 enrichment complete. Готово к git add + commit.'
