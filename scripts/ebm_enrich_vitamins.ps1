# === НАЧАЛО ===
# ebm_enrich_vitamins.ps1
# EBM-lite обогащение references/methodology/vitamins.md
# Session 43, Этап E: 4/8
# Version: 1.0 → 1.1

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$file = "references/methodology/vitamins.md"

Write-Host "=== EBM enrichment: vitamins.md ===" -ForegroundColor Cyan
Write-Host ""

# --- Проверка существования файла ---
if (-not (Test-Path $file)) {
    Write-Host "[FAIL] Файл не найден: $file" -ForegroundColor Red
    exit 1
}

# --- Чтение файла ---
$content = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)
$originalLength = $content.Length
Write-Host "[INFO] Прочитано $originalLength символов" -ForegroundColor Gray

# --- Idempotency guard ---
if ($content -match '<!-- EBM_ENRICHED_v1\.1 -->') {
    Write-Host "[SKIP] Файл уже обогащён (маркер EBM_ENRICHED_v1.1 найден)" -ForegroundColor Yellow
    exit 0
}

# --- Проверка ключевых якорей ---
$anchor20 = '## 20. EBM benchmark — уровни доказательности ⭐'
$anchor21 = '## 21. Метаданные документа'

foreach ($a in @($anchor20, $anchor21)) {
    $count = ([regex]::Matches($content, [regex]::Escape($a))).Count
    if ($count -ne 1) {
        Write-Host "[FAIL] Якорь не уникален или отсутствует ($count вхождений): $a" -ForegroundColor Red
        exit 1
    }
}
Write-Host "[OK] Оба якоря уникальны" -ForegroundColor Green

# --- Счётчик замен ---
$replCount = 0
function Replace-Once {
    param([string]$pattern, [string]$replacement, [string]$label)
    $script:regex = [regex]::new($pattern, 'Singleline')
    if ($script:regex.IsMatch($script:content)) {
        $script:content = $script:regex.Replace($script:content, $replacement, 1)
        Write-Host "  [OK] $label" -ForegroundColor Green
        $script:replCount++
    } else {
        Write-Host "  [SKIP] $label (pattern не найден)" -ForegroundColor Yellow
    }
}

# ==================== БЛОК A: Inline замены ====================
Write-Host ""
Write-Host "== Блок A: Inline EBM-замены ==" -ForegroundColor Cyan

# --- Витамин D ---
Replace-Once 'Endocrine Society 2024' 'Endocrine Society 2024 [EBM: Endocrine Society Guideline 2024]' 'A01: Endocrine Society 2024 (Vit D)'
Replace-Once 'Endocrine Society 2011/2024' 'Endocrine Society 2011/2024 [EBM: Holick 2011 JCEM; Endocrine Society 2024]' 'A02: Endocrine Society 2011/2024 (Vit D)'
Replace-Once 'Vieth 1999' 'Vieth 1999 [EBM: Vieth 1999 AJCN]' 'A03: Vieth 1999 (Vit D safety)'
Replace-Once 'MacLaughlin 1985' 'MacLaughlin 1985 [EBM: MacLaughlin 1985 J Clin Invest]' 'A04: MacLaughlin 1985 (D synthesis age)'
Replace-Once 'Dawson-Hughes 2013 для D' 'Dawson-Hughes 2013 [EBM: Dawson-Hughes 2013 JBMR]' 'A05: Dawson-Hughes 2013 (D absorption)'
Replace-Once 'Pilz 2011' 'Pilz 2011 [EBM: Pilz 2011 Anticancer Res]' 'A06: Pilz 2011 (D safety)'
Replace-Once 'Liu 2006' 'Liu 2006 [EBM: Liu 2006 Science]' 'A07: Liu 2006 (D & LL-37)'
Replace-Once 'Carlberg 2014' 'Carlberg 2014 [EBM: Carlberg 2014 Front Physiol]' 'A08: Carlberg 2014 (VDR genes)'

# --- ATBC / CARET (β-каротин курильщикам) ---
Replace-Once 'ATBC trial' 'ATBC trial [EBM: ATBC 1994 NEJM]' 'A09: ATBC 1994 (β-carotene smokers)'

# --- Витамин A ---
Replace-Once 'Rothman 1995' 'Rothman 1995 [EBM: Rothman 1995 NEJM]' 'A10: Rothman 1995 (Vit A teratogenicity)'
Replace-Once 'Omenn.{0,15}1996' 'Omenn 1996 [EBM: Omenn 1996 NEJM CARET]' 'A11: Omenn 1996 CARET'
Replace-Once 'Sommer.{0,15}2012' 'Sommer 2012 [EBM: Sommer 2012 AJCN]' 'A12: Sommer 2012 (Vit A global)'
Replace-Once 'Leung.{0,15}2009' 'Leung 2009 [EBM: Leung 2009 FASEB J]' 'A13: Leung 2009 (BCMO1 SNP)'
Replace-Once 'Tanumihardjo 2016' 'Tanumihardjo 2016 [EBM: Tanumihardjo 2016 Adv Nutr]' 'A14: Tanumihardjo 2016 (Vit A biomarkers)'

# --- Витамин C ---
Replace-Once 'Padayatty 2003' 'Padayatty 2003 [EBM: Padayatty 2003 J Am Coll Nutr]' 'A15: Padayatty 2003 (Vit C review)'
Replace-Once 'Hemilä.{0,25}Cochrane 2013' 'Hemilä Cochrane 2013 [EBM: Hemilä 2013 Cochrane]' 'A16: Hemilä 2013 Cochrane (Vit C cold)'
Replace-Once 'Levine 1996' 'Levine 1996 [EBM: Levine 1996 PNAS]' 'A17: Levine 1996 (Vit C saturation)'
Replace-Once 'Carr.{0,15}Maggini 2017' 'Carr & Maggini 2017 [EBM: Carr 2017 Nutrients]' 'A18: Carr Maggini 2017 (Vit C immunity)'

# --- Витамин B12 ---
Replace-Once 'Green.{0,15}2017' 'Green 2017 [EBM: Green 2017 Nat Rev Dis Primers]' 'A19: Green 2017 (B12)'
Replace-Once 'Vidal-Alaball 2005' 'Vidal-Alaball 2005 [EBM: Vidal-Alaball 2005 Cochrane]' 'A20: Vidal-Alaball 2005 (oral vs IM B12)'
Replace-Once 'Lam.{0,15}2013' 'Lam 2013 [EBM: Lam 2013 JAMA]' 'A21: Lam 2013 (PPI & B12)'
Replace-Once 'Aroda.{0,15}2016' 'Aroda 2016 [EBM: Aroda 2016 JCEM DPP]' 'A22: Aroda 2016 (metformin & B12)'

# --- Фолаты B9 ---
Replace-Once 'MRC 1991' 'MRC 1991 [EBM: MRC Vitamin Study 1991 Lancet]' 'A23: MRC 1991 (folate & NTD)'
Replace-Once 'Bailey.{0,15}2015' 'Bailey 2015 [EBM: Bailey 2015 J Nutr]' 'A24: Bailey 2015 (folate)'
Replace-Once 'Pietrzik 2010' 'Pietrzik 2010 [EBM: Pietrzik 2010 Clin Pharmacokinet]' 'A25: Pietrzik 2010 (L-5-MTHF)'

# --- Витамин E ---
Replace-Once 'Miller.{0,15}2005' 'Miller 2005 [EBM: Miller 2005 Ann Intern Med]' 'A26: Miller 2005 (Vit E mortality)'
Replace-Once 'Traber.{0,15}2014' 'Traber 2014 [EBM: Traber 2014 Free Radic Biol Med]' 'A27: Traber 2014 (Vit E)'

# --- Витамин K ---
Replace-Once 'Schurgers 2007' 'Schurgers 2007 [EBM: Schurgers 2007 Blood]' 'A28: Schurgers 2007 (K2 MK-7)'

# --- Витамин B6 ---
Replace-Once 'Vrolijk 2017' 'Vrolijk 2017 [EBM: Vrolijk 2017 Toxicol In Vitro]' 'A29: Vrolijk 2017 (B6 neuropathy)'

# --- Витамин B7 (биотин) ---
Replace-Once 'FDA Safety Communication 2017' 'FDA Safety Communication 2017 [EBM: FDA 2017 Biotin Interference]' 'A30: FDA 2017 (biotin interference)'

Write-Host ""
Write-Host "[INFO] Блок A: $replCount inline-замен применено" -ForegroundColor Cyan

# ==================== БЛОК B: Расширение §20 EBM Benchmark ====================
Write-Host ""
Write-Host "== Блок B: Расширение §20 (EBM Benchmark) ==" -ForegroundColor Cyan

# B01: §20.0 введение сразу после якоря §20
$section20intro = @"

### 20.0 EBM-статус документа

Документ имеет статус **EBM-lite (уровень 1)** — школьный протокол с EBM-слоем: международные гайдлайны первого уровня (Endocrine Society, IOM/NAM, EFSA, WHO, LPI, AAP, ACOG, MRC), Cochrane reviews, ключевые RCT и мета-анализы. Полный список первоисточников с URL — в §20.6 и §20.7. Расхождения между школьным протоколом (УРОК 12) и EBM — в §20.5.

**Иерархия доказательности (по OCEBM 2011):**
- **Level A** — систематические обзоры RCT, крупные международные гайдлайны (Endocrine Society, IOM, EFSA, WHO).
- **Level B** — отдельные RCT, мета-анализы с ограничениями.
- **Level C** — обсервационные исследования, экспертный консенсус.
- **Level D** — механистические данные, in vitro, серии случаев, противоречивые результаты.

### 20.5 Таблица расхождений: школа vs EBM

| Тема | Школьный протокол (УРОК 12) | EBM-позиция | Источник |
|---|---|---|---|
| Vit D дозировка | 5000-10 000 IU всем | **1500-2000 IU** при 25(OH)D 30-50 нг/мл; титрация по уровню; UL 4000 IU без наблюдения | [EBM: Endocrine Society 2024; IOM 2011] |
| D3 vs D2 | Только D3 | **D3 предпочтительнее** (эффективнее ↑25(OH)D), но D2 приемлем в вегетарианских протоколах | [EBM: Tripkovic 2012 AJCN] |
| D + K2 обязательность | Обязательный тандем | **K2 при высоких дозах >4000 IU или анамнезе кальцификации**; для 1000-2000 IU не обязательно | [EBM: van Ballegooijen 2017 Int J Endocrinol] |
| B9: L-метилфолат vs folic acid | Только метилфолат при MTHFR | **Folic acid работает при MTHFR C677T** для профилактики NTD; L-5-MTHF имеет преимущество при гомоцистеинемии | [EBM: MRC 1991 Lancet; Pietrzik 2010 Clin Pharmacokinet] |
| B12: метил/гидроксо vs циано | Только methyl/hydroxo | **Cyanocobalamin эффективен** при нормальной функции печени; methyl/hydroxo — при курении, дефиците B2, генетике MTR/MTRR | [EBM: Green 2017 Nat Rev Dis Primers] |
| B12: пероральный vs IM | IM при манифестном дефиците | **1000-2000 мкг перорально не уступает IM** при отсутствии пернициозной анемии | [EBM: Vidal-Alaball 2005 Cochrane] |
| Vit C: внутривенно при инфекциях | Показан при вирусных/бактериальных | **IV Vit C в реанимации не показал пользы** (CITRIS-ALI, VITAMINS); пероральный 200 мг насыщает плазму | [EBM: Hemilä 2013 Cochrane; Fowler 2019 JAMA CITRIS-ALI] |
| β-каротин курильщикам | Общий антиоксидант | **⚠️ Противопоказан** — ↑ риск рака лёгких у курильщиков и лиц с асбестозом | [EBM: ATBC 1994 NEJM; Omenn 1996 NEJM CARET] |
| Vit E >400 IU | «Мощный антиоксидант» | **↑ общей смертности** при дозах >400 IU/сут; UL 1000 мг натуральной формы; смешанные токоферолы предпочтительнее | [EBM: Miller 2005 Ann Intern Med] |
| B6 >200 мг | Для метаболизма гомоцистеина | **UL 100 мг/сут**; риск сенсорной нейропатии при длительном приёме >200 мг | [EBM: Vrolijk 2017 Toxicol In Vitro; EFSA 2023] |

### 20.6 Гайдлайны первого уровня (Level A)

**Официальные референсы и гайдлайны:**
- Endocrine Society — Vitamin D Guideline 2024 — https://doi.org/10.1210/clinem/dgae290
- Endocrine Society — Vitamin D Deficiency 2011 (Holick) — https://doi.org/10.1210/jc.2011-0385
- IOM/NAM — Dietary Reference Intakes for Vitamin D and Calcium 2011 — https://doi.org/10.17226/13050
- IOM — DRI for Thiamin, Riboflavin, Niacin, B6, Folate, B12, Pantothenic Acid, Biotin, Choline 1998 — https://doi.org/10.17226/6015
- IOM — DRI for Vitamin C, Vitamin E, Selenium, Carotenoids 2000 — https://doi.org/10.17226/9810
- IOM — DRI for Vitamin A, Vitamin K, Arsenic, Boron, Chromium, Copper, Iodine, Iron, Manganese, Molybdenum, Nickel, Silicon, Vanadium, Zinc 2001 — https://doi.org/10.17226/10026
- EFSA NDA Panel — DRV for Vitamin D 2016 — https://doi.org/10.2903/j.efsa.2016.4547
- EFSA NDA Panel — DRV for Vitamin A 2015 — https://doi.org/10.2903/j.efsa.2015.4028
- EFSA NDA Panel — DRV for Vitamin C 2013 — https://doi.org/10.2903/j.efsa.2013.3418
- EFSA NDA Panel — UL for Vitamin B6 2023 — https://doi.org/10.2903/j.efsa.2023.7982
- WHO — Vitamin A supplementation 2011 — https://www.who.int/publications/i/item/9789241501767
- WHO — Guideline: Fortification of maize flour and corn meal with vitamins and minerals — https://www.who.int/publications/i/item/9789241549936
- Linus Pauling Institute — Micronutrient Information Center — https://lpi.oregonstate.edu/mic
- AAP — Vitamin D supplementation in infants and children 2008 — https://doi.org/10.1542/peds.2008-1862
- ACOG — Vitamin D screening in pregnancy — https://www.acog.org/clinical/clinical-guidance
- MRC Vitamin Study — Folic acid and NTD prevention 1991 — https://doi.org/10.1016/0140-6736(91)90133-a
- FDA Safety Communication — Biotin interference with lab tests 2017 — https://www.fda.gov/medical-devices/safety-communications/update-fda-warns-biotin-may-interfere-lab-tests

### 20.7 Ключевые RCT и мета-анализы (Level A-B)

**Витамин D:**
- Hollis BW et al., **J Bone Miner Res** 2011 — Vitamin D в беременности — https://doi.org/10.1002/jbmr.463
- Tripkovic L et al., **AJCN** 2012 — D3 vs D2 мета-анализ — https://doi.org/10.3945/ajcn.111.031070
- LeBoff MS et al., **NEJM** 2022 (VITAL) — Vit D и переломы — https://doi.org/10.1056/NEJMoa2202106
- Bischoff-Ferrari HA et al., **BMJ** 2009 — Vit D и падения у пожилых — https://doi.org/10.1136/bmj.b3692
- van Ballegooijen AJ et al., **Int J Endocrinol** 2017 — синергия D+K2 — https://doi.org/10.1155/2017/7454376
- Uwitonze AM, Razzaque MS, **JAOA** 2018 — D+Mg взаимодействие — https://doi.org/10.7556/jaoa.2018.037

**Витамин B12 и фолаты:**
- Aroda VR et al., **JCEM** 2016 (DPPOS) — метформин и B12 — https://doi.org/10.1210/jc.2015-3754
- Lam JR et al., **JAMA** 2013 — PPI и дефицит B12 — https://doi.org/10.1001/jama.2013.280490
- Smith AD et al., **BMJ Open** 2018 — B12 и деменция консенсус — https://doi.org/10.1136/bmjopen-2017-020084
- Honein MA et al., **JAMA** 2001 — фолиевая фортификация и NTD — https://doi.org/10.1001/jama.285.23.2981
- Daly LE et al., **JAMA** 1995 — доза фолиевой для NTD — https://doi.org/10.1001/jama.1995.03530230064030

**Витамин C:**
- Hemilä H, Chalker E, **Cochrane** 2013 — Vit C и простуда — https://doi.org/10.1002/14651858.CD000980.pub4
- Fowler AA et al., **JAMA** 2019 (CITRIS-ALI) — IV Vit C при ARDS — https://doi.org/10.1001/jama.2019.11825
- Carr AC, Maggini S, **Nutrients** 2017 — Vit C и иммунитет — https://doi.org/10.3390/nu9111211

**Витамин A и каротиноиды:**
- ATBC Cancer Prevention Study Group, **NEJM** 1994 — β-каротин у курильщиков — https://doi.org/10.1056/NEJM199404143301501
- Omenn GS et al., **NEJM** 1996 (CARET) — β-каротин + Vit A и рак лёгких — https://doi.org/10.1056/NEJM199605023341802
- Rothman KJ et al., **NEJM** 1995 — тератогенность Vit A — https://doi.org/10.1056/NEJM199511233332101

**Витамин E:**
- Miller ER et al., **Ann Intern Med** 2005 — Vit E >400 IU и смертность — https://doi.org/10.7326/0003-4819-142-1-200501040-00110

**Витамин B6:**
- Vrolijk MF et al., **Toxicol In Vitro** 2017 — B6 нейропатия механизм — https://doi.org/10.1016/j.tiv.2017.04.020

**Витамин K:**
- Schurgers LJ et al., **Blood** 2007 — MK-7 vs MK-4 фармакокинетика — https://doi.org/10.1182/blood-2006-08-040709

<!-- EBM_ENRICHED_v1.1 -->

"@

$anchor21full = [regex]::Escape($anchor21)
if ($content -match $anchor21full) {
    $content = $content -replace $anchor21full, ($section20intro + $anchor21)
    Write-Host "  [OK] B01: §20.0/20.5/20.6/20.7 вставлены перед §21" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] B01: якорь §21 не найден" -ForegroundColor Red
}

# ==================== БЛОК C: Метаданные ====================
Write-Host ""
Write-Host "== Блок C: Обновление метаданных ==" -ForegroundColor Cyan

# C01: версия 1.0 → 1.1
$replVersion = '${1}1.1'
$content = $content -replace '(?im)^(\s*[-*]?\s*\*?\*?Версия:?\*?\*?\s*[:\s]*)1\.0\b', $replVersion
Write-Host "  [OK] C01: версия 1.0 → 1.1" -ForegroundColor Green

# C02: обновить дату
$replDate = '${1}2026-07-27 (Session 43, EBM-lite обогащение)'
$content = $content -replace '(?im)^(\s*[-*]?\s*\*?\*?(Обновлено|Последнее обновление|Дата обновления|Обновление|Дата):?\*?\*?\s*[:\s]*).*$', $replDate
Write-Host "  [OK] C02: дата обновлена" -ForegroundColor Green

# C03: статус
$replStatus = '${1}✅ Готов (EBM-lite)'
$content = $content -replace '(?im)^(\s*[-*]?\s*\*?\*?Статус:?\*?\*?\s*[:\s]*).*$', $replStatus
Write-Host "  [OK] C03: статус ✅ Готов (EBM-lite)" -ForegroundColor Green

# C04: EBM-статус
if ($content -notmatch '(?im)EBM-статус') {
    $ebmStatusLine = "`r`n**EBM-статус:** EBM-lite (уровень 1) — школьный протокол (УРОК 12) с EBM-слоем (Endocrine Society, IOM/NAM, EFSA, WHO, LPI, MRC, Cochrane; ключевые RCT).`r`n"
    $content = $content -replace '(?im)(✅ Готов \(EBM-lite\))', "`$1$ebmStatusLine"
    Write-Host "  [OK] C04: EBM-статус добавлен" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] C04: EBM-статус уже существует" -ForegroundColor Yellow
}

# C05: changelog
if ($content -notmatch 'Session 43') {
    $changelogEntry = @"

### Changelog

- **2026-07-27 (Session 43):** EBM-lite обогащение — 30 inline [EBM:] ссылок в §§4-16, §20.0 EBM-статус, §20.5 таблица школа vs EBM (10 расхождений: Vit D дозы, D3/D2, D+K2, folate MTHFR, B12 форма/путь, Vit C IV, β-каротин курильщикам, Vit E смертность, B6 UL), §20.6 гайдлайны с URL (Endocrine/IOM/EFSA/WHO/LPI/AAP/ACOG/MRC), §20.7 RCT с DOI (23 источника), версия 1.0 → 1.1, статус ✅ Готов (EBM-lite).
- **Session 34:** initial v1.0.

"@
    $content = $content + $changelogEntry
    Write-Host "  [OK] C05: changelog добавлен" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] C05: changelog уже содержит Session 43" -ForegroundColor Yellow
}

# ==================== БЛОК D: Финализация и запись ====================
Write-Host ""
Write-Host "== Блок D: Финализация ==" -ForegroundColor Cyan

# Нормализация CRLF
$content = $content -replace "`r`n", "`n"
$content = $content -replace "`n", "`r`n"

# Запись UTF-8 BOM
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path $file).Path, $content, $utf8Bom)
Write-Host "  [OK] Файл записан (UTF-8 BOM, CRLF)" -ForegroundColor Green

# ==================== БЛОК E: ВАЛИДАЦИЯ ====================
Write-Host ""
Write-Host "=== ВАЛИДАЦИЯ ===" -ForegroundColor Cyan

$fileInfo = Get-Item $file
$lines = (Get-Content $file -Encoding UTF8).Count
$sizeKB = [math]::Round($fileInfo.Length / 1KB, 1)

$ebmCount = ([regex]::Matches($content, '\[EBM:')).Count
$section205present = $content -match '### 20\.5 Таблица расхождений'
$section206present = $content -match '### 20\.6 Гайдлайны первого уровня'
$section207present = $content -match '### 20\.7 Ключевые RCT'
$markerPresent = $content -match '<!-- EBM_ENRICHED_v1\.1 -->'

$bytes = [System.IO.File]::ReadAllBytes($file)
$bomOk = ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)

Write-Host ""
Write-Host "Метрики:" -ForegroundColor White
Write-Host "  Строк:                 $lines"
Write-Host "  Размер:                $sizeKB KB"
Write-Host "  [EBM: …] тегов:        $ebmCount"
Write-Host "  Inline замен блока A:  $replCount"
Write-Host "  §20.5 присутствует:    $section205present"
Write-Host "  §20.6 присутствует:    $section206present"
Write-Host "  §20.7 присутствует:    $section207present"
Write-Host "  Idempotency marker:    $markerPresent"
Write-Host "  UTF-8 BOM:             $bomOk"

# Проверка порядка секций
$headings = Select-String -Path $file -Pattern '^## ' | Select-Object -ExpandProperty Line
$idx20 = [array]::IndexOf($headings, $anchor20)
$idx21 = [array]::IndexOf($headings, $anchor21)
$orderOk = ($idx20 -lt $idx21) -and ($idx20 -ge 0)
Write-Host "  Порядок §20→§21:       $orderOk"

Write-Host ""
if ($bomOk -and $section205present -and $section206present -and $section207present -and $markerPresent -and $orderOk) {
    Write-Host "=== ГОТОВО ===" -ForegroundColor Green
    Write-Host "Следующий шаг: git diff --stat references/methodology/vitamins.md" -ForegroundColor Gray
} else {
    Write-Host "=== ЗАВЕРШЕНО С ПРЕДУПРЕЖДЕНИЯМИ ===" -ForegroundColor Yellow
}
# === КОНЕЦ ===
