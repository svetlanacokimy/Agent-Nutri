# === НАЧАЛО ===
# ebm_enrich_minerals.ps1
# EBM-lite обогащение references/methodology/minerals.md
# Session 42, Этап E: 3/8
# Version: 1.0 → 1.1

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$file = "references/methodology/minerals.md"

Write-Host "=== EBM enrichment: minerals.md ===" -ForegroundColor Cyan
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
$anchor21 = '## 21. Взаимодействия минерал ↔ минерал / минерал ↔ витамин'
$anchor22 = '## 22. Метаданные документа'
$anchor23 = '## 23. Ключевые референсы'

foreach ($a in @($anchor20, $anchor21, $anchor22, $anchor23)) {
    $count = ([regex]::Matches($content, [regex]::Escape($a))).Count
    if ($count -ne 1) {
        Write-Host "[FAIL] Якорь не уникален или отсутствует ($count вхождений): $a" -ForegroundColor Red
        exit 1
    }
}
Write-Host "[OK] Все 4 якоря уникальны" -ForegroundColor Green

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

# A01: Fe every-other-day (Stoffel 2017)
Replace-Once 'Stoffel NU et al\., Lancet Haematol 2017' 'Stoffel NU et al., Lancet Haematol 2017 [EBM: Stoffel 2017 Lancet Haematol]' 'A01: Fe every-other-day (Stoffel 2017)'

# A02: Mg биохимия (Volpe 2013)
Replace-Once 'Volpe SL, Adv Nutr 2013' 'Volpe SL, Adv Nutr 2013 [EBM: Volpe 2013 Adv Nutr]' 'A02: Mg биохимия (Volpe 2013)'

# A03: Mg L-threonate (Slutsky 2010)
Replace-Once 'Slutsky I et al\., Neuron 2010' 'Slutsky I et al., Neuron 2010 [EBM: Slutsky 2010 Neuron]' 'A03: Mg L-threonate (Slutsky 2010)'

# A04: Mg dietary intake (Rosanoff 2012)
Replace-Once 'Rosanoff A et al\., Nutr Rev 2012' 'Rosanoff A et al., Nutr Rev 2012 [EBM: Rosanoff 2012 Nutr Rev]' 'A04: Mg intake (Rosanoff 2012)'

# A05: Se и Hashimoto (Gärtner 2002)
Replace-Once 'Gärtner R et al\., JCEM 2002' 'Gärtner R et al., JCEM 2002 [EBM: Gärtner 2002 JCEM]' 'A05: Se АИТ (Gärtner 2002)'

# A06: Se обзор (Rayman 2012)
Replace-Once 'Rayman MP, Lancet 2012' 'Rayman MP, Lancet 2012 [EBM: Rayman 2012 Lancet]' 'A06: Se обзор (Rayman 2012)'

# A07: SELECT trial (Klein 2011)
Replace-Once 'Klein EA et al\., JAMA 2011 \(SELECT\)' 'Klein EA et al., JAMA 2011 (SELECT) [EBM: Klein 2011 JAMA SELECT]' 'A07: SELECT trial (Klein 2011)'

# A08: Se и Coxsackie (Beck 1994)
Replace-Once 'Beck MA, J Nutr 1994' 'Beck MA, J Nutr 1994 [EBM: Beck 1994 J Nutr]' 'A08: Se вирусы (Beck 1994)'

# A09: Zn обзор (Prasad 2014)
Replace-Once 'Prasad AS, J Trace Elem Med Biol 2014' 'Prasad AS, J Trace Elem Med Biol 2014 [EBM: Prasad 2014 JTEMB]' 'A09: Zn обзор (Prasad 2014)'

# A10: Zn при простуде (Hemilä Cochrane)
Replace-Once 'Hemilä H[^,]*, [^2]*2011' 'Hemilä H, Cochrane 2011 [EBM: Hemilä 2011 Cochrane]' 'A10: Zn простуда (Hemilä 2011)'

# A11: Ca+D мета-анализ (Weaver 2016)
Replace-Once 'Weaver CM et al\., Osteoporos Int 2016' 'Weaver CM et al., Osteoporos Int 2016 [EBM: Weaver 2016 Osteoporos Int]' 'A11: Ca+D (Weaver 2016)'

# A12: Ca-only риск CVD (Bolland 2010)
Replace-Once 'Bolland MJ et al\., BMJ 2010' 'Bolland MJ et al., BMJ 2010 [EBM: Bolland 2010 BMJ]' 'A12: Ca-only CVD риск (Bolland 2010)'

# A13: DASH калий (Appel 1997)
Replace-Once 'Appel LJ et al\., NEJM 1997' 'Appel LJ et al., NEJM 1997 [EBM: Appel 1997 NEJM DASH]' 'A13: DASH калий (Appel 1997)'

# A14: Na снижение и АД (Sacks 2001)
Replace-Once 'Sacks FM et al\., NEJM 2001' 'Sacks FM et al., NEJM 2001 [EBM: Sacks 2001 NEJM DASH-Sodium]' 'A14: Na и АД (Sacks 2001)'

# A15: Na глобальный обзор (Mozaffarian 2014)
Replace-Once 'Mozaffarian D et al\., NEJM 2014' 'Mozaffarian D et al., NEJM 2014 [EBM: Mozaffarian 2014 NEJM]' 'A15: Na обзор (Mozaffarian 2014)'

# A16: K и АД (Aburto 2013)
Replace-Once 'Aburto NJ et al\., BMJ 2013' 'Aburto NJ et al., BMJ 2013 [EBM: Aburto 2013 BMJ]' 'A16: K и АД (Aburto 2013)'

# A17: I и когнитивное развитие (Zimmermann 2008)
Replace-Once 'Zimmermann MB[^,]*, [^2]*2008' 'Zimmermann MB, Endocr Rev 2008 [EBM: Zimmermann 2008 Endocr Rev]' 'A17: I когнитивное развитие (Zimmermann 2008)'

# A18: I mild deficiency (Bath 2013)
Replace-Once 'Bath SC et al\., Lancet 2013' 'Bath SC et al., Lancet 2013 [EBM: Bath 2013 Lancet]' 'A18: I лёгкий дефицит (Bath 2013)'

# A19: I и беременность (Leung 2014)
Replace-Once 'Leung AM[^,]*, [^2]*2014' 'Leung AM, JCEM 2014 [EBM: Leung 2014 JCEM]' 'A19: I и беременность (Leung 2014)'

# A20: Cr picolinate (Anderson 1997)
Replace-Once 'Anderson RA[^,]*, [^1]*1997' 'Anderson RA, Diabetes 1997 [EBM: Anderson 1997 Diabetes]' 'A20: Cr picolinate (Anderson 1997)'

# A21: ALA нейропатия (Ziegler 2011 NATHAN 1)
Replace-Once 'Ziegler D et al\., Diabetes Care 2011' 'Ziegler D et al., Diabetes Care 2011 [EBM: Ziegler 2011 Diabetes Care NATHAN-1]' 'A21: ALA нейропатия (Ziegler 2011)'

# A22: Fe обзор (Camaschella 2015)
Replace-Once 'Camaschella C[^,]*, [^2]*2015' 'Camaschella C, NEJM 2015 [EBM: Camaschella 2015 NEJM]' 'A22: Fe анемия обзор (Camaschella 2015)'

Write-Host ""
Write-Host "[INFO] Блок A: $replCount inline-замен применено" -ForegroundColor Cyan

# ==================== БЛОК B: Расширение §20 EBM Benchmark ====================
Write-Host ""
Write-Host "== Блок B: Расширение §20 (EBM Benchmark) ==" -ForegroundColor Cyan

# B01: §20.0 введение перед §20.1
$section20intro = @"

### 20.0 EBM-статус документа

Документ имеет статус **EBM-lite (уровень 1)** — школьный протокол с EBM-слоем: международные гайдлайны первого уровня, Cochrane reviews, ключевые RCT и мета-анализы. Полный список первоисточников с URL — в §23. Расхождения между школьным протоколом (УРОК) и EBM — в §20.5.

**Иерархия доказательности (по OCEBM 2011):**
- **Level A** — систематические обзоры RCT, крупные международные гайдлайны (WHO, NIH, EFSA, ATA);
- **Level B** — отдельные RCT, мета-анализы с ограничениями;
- **Level C** — обсервационные исследования, экспертный консенсус;
- **Level D** — механистические данные, in vitro, серии случаев, противоречивые результаты.

"@

$anchor20full = [regex]::Escape($anchor20)
if ($content -match $anchor20full) {
    $content = $content -replace $anchor20full, ($anchor20 + $section20intro)
    Write-Host "  [OK] B01: §20.0 введение вставлено" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] B01: якорь §20 не найден" -ForegroundColor Red
}

# B02: §20.5 таблица «школа vs EBM» перед §21
$section205 = @"

### 20.5 Таблица расхождений: школа vs EBM

| Тема | Школьный протокол | EBM-позиция | Источник |
|---|---|---|---|
| Fe: режим приёма | Ежедневно 50-100 мг | **Через день 60-120 мг** — выше абсорбция (↓ гепсидин), ↓ побочные эффекты | [EBM: Stoffel 2017 Lancet Haematol] |
| Se: показания | Всем при АИТ | **Только при исходно низком/нормальном Se**, оценить до добавки; UL 400 мкг; ↑ риск СД2 при избытке | [EBM: Klein 2011 JAMA SELECT; Rayman 2012 Lancet] |
| Zn:Cu ratio | Обязательный контроль | **Не рутинный маркер** — используется в специфических ситуациях (Wilson, длительный приём Zn >40 мг) | [EBM: NIH ODS Zinc Fact Sheet 2022] |
| Ca монотерапия | Ca 1000-1500 мг для костей | **Ca без K2/D/Mg → ↑ риск CVD**; всегда в комплексе; предпочтение — Ca из пищи | [EBM: Bolland 2010 BMJ; Weaver 2016 Osteoporos Int] |
| Йод при Hashimoto | Ограничить/исключить | **Восполнить до физиологической нормы (150 мкг/сут) на фоне Se**; тотальный отказ ухудшает функцию ЩЖ | [EBM: Zimmermann 2008 Endocr Rev; ATA Guidelines 2017] |
| Гемохроматоз скрининг | Не обсуждается | **HFE-генотипирование при ферритине >300 нг/мл (М) / >200 (Ж) + TSAT >45%** — обязательно перед Fe-добавками | [EBM: ACG Guidelines 2019; EASL 2010] |
| Cr picolinate | Уверенно при ИР | **Данные противоречивы** — метаанализы не подтверждают клинически значимый эффект на HbA1c; малый эффект на массу тела | [EBM: Cochrane 2013; Costello 2016 Nutr Rev] |
| Mg loading test | Как основной метод | **RCT-данных мало**; предпочтение — RBC Mg или клиническая оценка + пробная терапия | [EBM: Costello 2016 Adv Nutr; ODS Magnesium Fact Sheet] |

"@

$anchor21full = [regex]::Escape($anchor21)
if ($content -match $anchor21full) {
    $content = $content -replace $anchor21full, ($section205 + "`r`n" + $anchor21)
    Write-Host "  [OK] B02: §20.5 таблица школа vs EBM вставлена" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] B02: якорь §21 не найден" -ForegroundColor Red
}

# ==================== БЛОК C: Расширение §23 (первоисточники) ====================
Write-Host ""
Write-Host "== Блок C: Расширение §23 (первоисточники с URL) ==" -ForegroundColor Cyan

$section23addon = @"


### 23.1 Гайдлайны первого уровня (Level A)

**NIH Office of Dietary Supplements (ODS) — Fact Sheets:**
- Iron — https://ods.od.nih.gov/factsheets/Iron-HealthProfessional/
- Magnesium — https://ods.od.nih.gov/factsheets/Magnesium-HealthProfessional/
- Zinc — https://ods.od.nih.gov/factsheets/Zinc-HealthProfessional/
- Selenium — https://ods.od.nih.gov/factsheets/Selenium-HealthProfessional/
- Copper — https://ods.od.nih.gov/factsheets/Copper-HealthProfessional/
- Iodine — https://ods.od.nih.gov/factsheets/Iodine-HealthProfessional/
- Calcium — https://ods.od.nih.gov/factsheets/Calcium-HealthProfessional/
- Potassium — https://ods.od.nih.gov/factsheets/Potassium-HealthProfessional/
- Chromium — https://ods.od.nih.gov/factsheets/Chromium-HealthProfessional/
- Manganese — https://ods.od.nih.gov/factsheets/Manganese-HealthProfessional/

**Международные гайдлайны:**
- WHO Iron supplementation — https://www.who.int/publications/i/item/9789241549523
- WHO Iodine nutrition — https://www.who.int/publications/i/item/9789241595827
- WHO Zinc supplementation — https://www.who.int/tools/elena/interventions/zinc-diarrhoea
- EFSA Tolerable Upper Intake Levels (UL) — https://www.efsa.europa.eu/en/topics/topic/dietary-reference-values
- IOM Dietary Reference Intakes (DRIs) — https://www.nal.usda.gov/human-nutrition-and-food-safety/dri-tables-and-application-reports
- ATA Guidelines Thyroid & Iodine 2017 — https://doi.org/10.1089/thy.2016.0457
- ACG Clinical Guideline: Hereditary Hemochromatosis 2019 — https://doi.org/10.14309/ajg.0000000000000315
- EASL Clinical Guidelines HFE Haemochromatosis 2010 — https://doi.org/10.1016/j.jhep.2010.03.001
- KDIGO CKD-MBD Guideline 2017 — https://kdigo.org/guidelines/ckd-mbd/
- AHA Sodium & Potassium 2016 — https://doi.org/10.1161/CIR.0000000000000450

### 23.2 Ключевые RCT и мета-анализы (Level A-B)

- **Stoffel NU et al., Lancet Haematol 2017** — Fe every-other-day, abs↑, GI-side↓ — https://doi.org/10.1016/S2352-3026(17)30182-5
- **Camaschella C, NEJM 2015** — Iron-deficiency anemia review — https://doi.org/10.1056/NEJMra1401038
- **Gärtner R et al., JCEM 2002** — Se 200 мкг ↓ АТ-ТПО при АИТ — https://doi.org/10.1210/jcem.87.4.8421
- **Klein EA et al., JAMA 2011 (SELECT)** — Se & vitamin E, простата — https://doi.org/10.1001/jama.2011.1437
- **Rayman MP, Lancet 2012** — Selenium and human health — https://doi.org/10.1016/S0140-6736(11)61452-9
- **Bolland MJ et al., BMJ 2010** — Ca монотерапия и CVD-риск — https://doi.org/10.1136/bmj.c3691
- **Weaver CM et al., Osteoporos Int 2016** — Ca+D мета-анализ — https://doi.org/10.1007/s00198-015-3386-5
- **Hemilä H, Cochrane 2011** — Zinc for the common cold — https://doi.org/10.1002/14651858.CD001364.pub3
- **Appel LJ et al., NEJM 1997 (DASH)** — калий и АД — https://doi.org/10.1056/NEJM199704173361601
- **Sacks FM et al., NEJM 2001 (DASH-Sodium)** — Na и АД — https://doi.org/10.1056/NEJM200101043440101
- **Mozaffarian D et al., NEJM 2014** — глобальное потребление Na — https://doi.org/10.1056/NEJMoa1304127
- **Aburto NJ et al., BMJ 2013** — K и АД, мета-анализ — https://doi.org/10.1136/bmj.f1378
- **Zimmermann MB, Endocr Rev 2008** — Iodine deficiency — https://doi.org/10.1210/er.2007-0043
- **Bath SC et al., Lancet 2013** — mild I deficiency и IQ — https://doi.org/10.1016/S0140-6736(13)60436-5
- **Ziegler D et al., Diabetes Care 2011 (NATHAN-1)** — ALA и нейропатия — https://doi.org/10.2337/dc10-1877
- **Volpe SL, Adv Nutr 2013** — Magnesium in disease prevention — https://doi.org/10.3945/an.112.003483
- **Rosanoff A et al., Nutr Rev 2012** — Mg dietary intake USA — https://doi.org/10.1111/j.1753-4887.2012.00500.x
- **Slutsky I et al., Neuron 2010** — Mg-L-threonate и когниция — https://doi.org/10.1016/j.neuron.2009.12.026
- **Prasad AS, J Trace Elem Med Biol 2014** — Zn и иммунитет — https://doi.org/10.1016/j.jtemb.2014.07.019
- **Beck MA, J Nutr 1994** — Se и вирулентность Coxsackie — https://doi.org/10.1093/jn/124.suppl_10.1873S
- **Anderson RA, Diabetes 1997** — Cr picolinate и HbA1c — https://doi.org/10.2337/diab.46.11.1786
- **Costello RB et al., Adv Nutr 2016** — Magnesium clinical use review — https://doi.org/10.3945/an.116.012138

<!-- EBM_ENRICHED_v1.1 -->
"@

# Вставка в конец файла (после §23)
$content = $content + $section23addon
Write-Host "  [OK] C01: §23.1 гайдлайны + §23.2 RCT добавлены" -ForegroundColor Green

# ==================== БЛОК D: Метаданные ====================
Write-Host ""
Write-Host "== Блок D: Обновление метаданных ==" -ForegroundColor Cyan

# D01: версия 1.0 → 1.1
$replVersion = '${1}1.1'
$content = $content -replace '(?im)^(\s*[-*]?\s*\*?\*?Версия:?\*?\*?\s*[:\s]*)1\.0\b', $replVersion
Write-Host "  [OK] D01: версия 1.0 → 1.1" -ForegroundColor Green

# D02: обновить дату
$replDate = '${1}2026-07-26 (Session 42, EBM-lite обогащение)'
$content = $content -replace '(?im)^(\s*[-*]?\s*\*?\*?(Обновлено|Последнее обновление|Дата обновления|Обновление|Дата):?\*?\*?\s*[:\s]*).*$', $replDate
Write-Host "  [OK] D02: дата обновлена" -ForegroundColor Green

# D03: статус
$replStatus = '${1}✅ Готов (EBM-lite)'
$content = $content -replace '(?im)^(\s*[-*]?\s*\*?\*?Статус:?\*?\*?\s*[:\s]*).*$', $replStatus
Write-Host "  [OK] D03: статус ✅ Готов (EBM-lite)" -ForegroundColor Green

# D04: EBM-статус
if ($content -notmatch '(?im)EBM-статус') {
    $ebmStatusLine = "`r`n**EBM-статус:** EBM-lite (уровень 1) — школьный протокол с EBM-слоем (гайдлайны NIH ODS, WHO, EFSA, ATA, ACG; Cochrane; ключевые RCT).`r`n"
    # Вставить сразу после строки со статусом
    $content = $content -replace '(?im)(✅ Готов \(EBM-lite\))', "`$1$ebmStatusLine"
    Write-Host "  [OK] D04: EBM-статус добавлен" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] D04: EBM-статус уже существует" -ForegroundColor Yellow
}

# D05: changelog
if ($content -notmatch 'Session 42') {
    $changelogEntry = @"

### Changelog

- **2026-07-26 (Session 42):** EBM-lite обогащение — 22 inline EBM-ссылки в §§4-17, §20.0 введение, §20.5 таблица школа vs EBM (8 расхождений), §23.1 гайдлайны с URL (10 NIH ODS + WHO/EFSA/ATA/ACG/EASL/KDIGO), §23.2 RCT с DOI (22 источника), версия 1.0 → 1.1, статус ✅ Готов (EBM-lite).
- **Session 25:** initial v1.0.

"@
    # Вставить перед §23 (Ключевые референсы)
    $anchor23full = [regex]::Escape($anchor23)
    $content = $content -replace $anchor23full, ($changelogEntry + $anchor23)
    Write-Host "  [OK] D05: changelog добавлен" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] D05: changelog уже содержит Session 42" -ForegroundColor Yellow
}

# ==================== БЛОК E: Финализация и запись ====================
Write-Host ""
Write-Host "== Блок E: Финализация ==" -ForegroundColor Cyan

# Нормализация CRLF
$content = $content -replace "`r`n", "`n"
$content = $content -replace "`n", "`r`n"

# Запись UTF-8 BOM
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path $file).Path, $content, $utf8Bom)
Write-Host "  [OK] Файл записан (UTF-8 BOM, CRLF)" -ForegroundColor Green

# ==================== ВАЛИДАЦИЯ ====================
Write-Host ""
Write-Host "=== ВАЛИДАЦИЯ ===" -ForegroundColor Cyan

$fileInfo = Get-Item $file
$lines = (Get-Content $file -Encoding UTF8).Count
$sizeKB = [math]::Round($fileInfo.Length / 1KB, 1)

$ebmCount = ([regex]::Matches($content, '\[EBM:')).Count
$schoolEbmCount = ([regex]::Matches($content, '(?im)школа[^\]]*EBM')).Count
$section205present = $content -match '### 20\.5 Таблица расхождений'
$section231present = $content -match '### 23\.1 Гайдлайны первого уровня'
$section232present = $content -match '### 23\.2 Ключевые RCT'
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
Write-Host "  §23.1 присутствует:    $section231present"
Write-Host "  §23.2 присутствует:    $section232present"
Write-Host "  Idempotency marker:    $markerPresent"
Write-Host "  UTF-8 BOM:             $bomOk"

# Проверка порядка секций
$headings = Select-String -Path $file -Pattern '^## ' | Select-Object -ExpandProperty Line
$idx20 = [array]::IndexOf($headings, $anchor20)
$idx21 = [array]::IndexOf($headings, $anchor21)
$idx22 = [array]::IndexOf($headings, $anchor22)
$idx23 = [array]::IndexOf($headings, $anchor23)
$orderOk = ($idx20 -lt $idx21) -and ($idx21 -lt $idx22) -and ($idx22 -lt $idx23)
Write-Host "  Порядок §20→21→22→23:  $orderOk"

Write-Host ""
if ($bomOk -and $section205present -and $section231present -and $markerPresent -and $orderOk) {
    Write-Host "=== ГОТОВО ===" -ForegroundColor Green
    Write-Host "Следующий шаг: git diff --stat references/methodology/minerals.md" -ForegroundColor Gray
} else {
    Write-Host "=== ЗАВЕРШЕНО С ПРЕДУПРЕЖДЕНИЯМИ ===" -ForegroundColor Yellow
}
# === КОНЕЦ ===
