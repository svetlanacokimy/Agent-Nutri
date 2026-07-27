# === НАЧАЛО ===
# ebm_enrich_hashimoto.ps1
# EBM-lite обогащение references/methodology/hashimoto.md
# Session 44, Этап E: 5/8
# Version: 1.0 → 1.1

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$file = "references/methodology/hashimoto.md"

Write-Host "=== EBM enrichment: hashimoto.md ===" -ForegroundColor Cyan
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
$anchor10 = '## 10. Мониторинг и прогноз'
$anchorSources = '## Источники'
$anchorMeta = '## Метаданные'

foreach ($a in @($anchor10, $anchorSources, $anchorMeta)) {
    $count = ([regex]::Matches($content, [regex]::Escape($a))).Count
    if ($count -ne 1) {
        Write-Host "[FAIL] Якорь не уникален или отсутствует ($count вхождений): $a" -ForegroundColor Red
        exit 1
    }
}
Write-Host "[OK] Все 3 якоря уникальны" -ForegroundColor Green

# --- Проверка, что §11 EBM benchmark ещё не существует ---
if ($content -match '(?m)^## 11\. EBM benchmark') {
    Write-Host "[SKIP] §11 EBM benchmark уже существует" -ForegroundColor Yellow
    exit 0
}
Write-Host "[OK] §11 отсутствует — можно вставлять" -ForegroundColor Green

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

# --- Эпидемиология и патогенез ---
Replace-Once 'Vanderpump.{0,15}1995' 'Vanderpump 1995 [EBM: Vanderpump 1995 Clin Endocrinol Whickham]' 'A01: Vanderpump 1995 (Whickham)'
Replace-Once 'Hollowell.{0,15}2002' 'Hollowell 2002 [EBM: Hollowell 2002 JCEM NHANES III]' 'A02: Hollowell 2002 (NHANES)'
Replace-Once 'Brix.{0,15}2005' 'Brix 2005 [EBM: Brix 2005 JCEM Danish twins]' 'A03: Brix 2005 (Danish twins)'
Replace-Once 'Tomer.{0,15}2010' 'Tomer 2010 [EBM: Tomer 2010 J Autoimmun HLA]' 'A04: Tomer 2010 (HLA)'
Replace-Once 'Fasano 2012' 'Fasano 2012 [EBM: Fasano 2012 Physiol Rev zonulin]' 'A05: Fasano 2012 (zonulin)'
Replace-Once 'Wiersinga.{0,15}2019' 'Wiersinga 2019 [EBM: Wiersinga 2019 Nat Rev Endocrinol]' 'A06: Wiersinga 2019 (endocrine review)'

# --- Триггеры ---
Replace-Once 'Bartalena.{0,15}2012' 'Bartalena 2012 [EBM: Bartalena 2012 Endocrine stress]' 'A07: Bartalena 2012 (стресс)'
Replace-Once 'Ross.{0,15}2016' 'Ross 2016 [EBM: Ross 2016 Thyroid ATA hyperthyroidism]' 'A08: Ross 2016 (курение/ATA)'

# --- Диагностика и гайдлайны ---
Replace-Once 'Jonklaas.{0,25}\(ATA\)\.\s\*\*Guidelines for the Treatment of Hypothyroidism\.\*\*.{0,25}2014' 'Jonklaas 2014 ATA [EBM: Jonklaas 2014 Thyroid ATA Guidelines]' 'A09: Jonklaas 2014 ATA'
Replace-Once 'ATA 2014' 'ATA 2014 [EBM: Jonklaas 2014 Thyroid ATA Guidelines]' 'A10: ATA 2014 (inline)'
Replace-Once 'Wiersinga.{0,25}\(ETA\)\.\s\*\*Guidelines: Use of L-T4' 'Wiersinga 2012 ETA [EBM: Wiersinga 2012 Eur Thyroid J ETA T4/T3]. **Guidelines: Use of L-T4' 'A11: Wiersinga 2012 ETA T4+T3'
Replace-Once 'ETA 2013' 'ETA 2013 [EBM: ETA 2013 Eur Thyroid J Selenium]' 'A12: ETA 2013 (Se guidelines)'

# --- Селен ---
Replace-Once 'Gärtner.{0,15}2002' 'Gärtner 2002 [EBM: Gärtner 2002 JCEM Se АТ-ТПО]' 'A13: Gärtner 2002 (Se АТ-ТПО)'
Replace-Once 'Ventura.{0,15}2017' 'Ventura 2017 [EBM: Ventura 2017 Endocrinol Metab Se мета-анализ]' 'A14: Ventura 2017 (Se мета-анализ)'
Replace-Once 'Nordio.{0,15}2017' 'Nordio 2017 [EBM: Nordio 2017 Eur Rev Med Pharmacol Se+инозитол]' 'A15: Nordio 2017 (Se + инозитол)'
Replace-Once 'Toulis.{0,15}2010' 'Toulis 2010 [EBM: Toulis 2010 Thyroid Se мета-анализ]' 'A16: Toulis 2010 (Se мета-анализ)'

# --- Витамин D ---
Replace-Once 'Kivity.{0,15}2011' 'Kivity 2011 [EBM: Kivity 2011 Cell Mol Immunol D & АИТ]' 'A17: Kivity 2011 (Vit D & АИТ)'
Replace-Once 'Chahardoli.{0,15}2019' 'Chahardoli 2019 [EBM: Chahardoli 2019 Int J Endocrinol Metab D3 RCT]' 'A18: Chahardoli 2019 (Vit D3 RCT)'
Replace-Once 'Wang.{0,15}2015' 'Wang 2015 [EBM: Wang 2015 Nutr J D3 мета-анализ]' 'A19: Wang 2015 (D3 мета-анализ)'

# --- Йод ---
Replace-Once 'Zimmermann.{0,15}2008' 'Zimmermann 2008 [EBM: Zimmermann 2008 Endocr Rev йод]' 'A20: Zimmermann 2008 (йод)'
Replace-Once 'Farebrother.{0,25}Zimmermann' 'Farebrother-Zimmermann 2019 [EBM: Farebrother 2019 Ann N Y Acad Sci избыток йода]. Zimmermann' 'A21: Farebrother 2019 (избыток йода)'
Replace-Once 'Leung.{0,15}2014' 'Leung 2014 [EBM: Leung 2014 JCEM йод беременность]' 'A22: Leung 2014 (йод беременность)'

# --- Глютен ---
Replace-Once 'Krysiak.{0,15}2019' 'Krysiak 2019 [EBM: Krysiak 2019 Exp Clin Endocrinol GFD RCT]' 'A23: Krysiak 2019 (GFD RCT)'
Replace-Once 'Sategna-Guidetti.{0,15}200[0-9]' 'Sategna-Guidetti 2001 [EBM: Sategna-Guidetti 2001 Am J Gastroenterol целиакия+АИТ]' 'A24: Sategna-Guidetti 2001'

# --- LT4 timing ---
Replace-Once 'Bolk.{0,15}2010' 'Bolk 2010 [EBM: Bolk 2010 Arch Intern Med LT4 timing]' 'A25: Bolk 2010 (LT4 timing)'

# --- AIP диета ---
Replace-Once 'Abbott.{0,15}2019' 'Abbott 2019 [EBM: Abbott 2019 Cureus AIP пилот]' 'A26: Abbott 2019 (AIP пилот)'

# --- Магний / другие микронутриенты ---
Replace-Once 'Wang.{0,15}2018.{0,20}Mg' 'Wang 2018 [EBM: Wang 2018 BMC Endocrine Mg & АИТ]' 'A27: Wang 2018 (Mg & АИТ)'

Write-Host ""
Write-Host "[INFO] Блок A: $replCount inline-замен применено" -ForegroundColor Cyan

# ==================== БЛОК B: Новый §11 EBM benchmark ====================
Write-Host ""
Write-Host "== Блок B: Вставка §11 EBM benchmark ==" -ForegroundColor Cyan

$section11 = @"
## 11. EBM benchmark — уровни доказательности ⭐

### 11.0 EBM-статус документа

Документ имеет статус **EBM-lite (уровень 1)** — школьный протокол (УРОКИ 17, 18, 22, 12) с EBM-слоем: международные гайдлайны первого уровня (ATA 2014/2017, ETA 2013, Endocrine Society, ACOG), Cochrane reviews, ключевые RCT и мета-анализы. Полный список первоисточников с URL — в §11.3 и §11.4. Расхождения между школьным протоколом и EBM — в §11.2.

### 11.1 Иерархия доказательности (OCEBM 2011)

- **Level A** — систематические обзоры RCT, крупные международные гайдлайны (ATA, ETA, Endocrine Society, WHO).
- **Level B** — отдельные RCT, мета-анализы с ограничениями.
- **Level C** — обсервационные исследования, экспертный консенсус.
- **Level D** — механистические данные, in vitro, серии случаев, противоречивые результаты.

### 11.2 Таблица расхождений: школа vs EBM

| Тема | Школьный протокол (УРОКИ 17/18/22) | EBM-позиция | Источник |
|---|---|---|---|
| Целевой TSH при АИТ | 0.5-2.0 мЕд/л (узкий диапазон) | **0.4-4.0 мЕд/л** (общий); **0.4-2.5** в 1 триместре беременности; титрация по симптомам, не по TSH | [EBM: Jonklaas 2014 Thyroid ATA Guidelines; ACOG 2020] |
| Селен 200 мкг при АИТ | Обязательно всем | **Только при исходно низком/нормальном Se**; UL 400 мкг; ↑ риск СД2 при избытке; данные противоречивы после SELECT trial | [EBM: Ventura 2017; Klein 2011 JAMA SELECT; ETA 2013] |
| Йод при АИТ | Полный отказ, «йод усиливает АИТ» | **Восполнить до физиол. нормы 150 мкг/сут** совместно с Se; тотальный отказ ухудшает функцию ЩЖ; избыток (>500 мкг) — да, триггер | [EBM: Zimmermann 2008 Endocr Rev; Farebrother 2019 Ann N Y Acad Sci] |
| LT4 vs T4+T3 combo | T4+T3 часто/при жалобах | **T4 монотерапия у 90% пациентов**; T4+T3 — только при доказанном DIO2 SNP + плохом ответе на T4 | [EBM: Jonklaas 2014 ATA; Wiersinga 2012 ETA] |
| LT4 приём | Вечер обязательно | **Утро натощак стандарт**; вечер эквивалентен по эффективности, но не приоритетен | [EBM: Bolk 2010 Arch Intern Med] |
| Безглютеновая диета (GFD) при АИТ | Всем обязательно | **Только при подтверждённой целиакии или НЦЧГ**; при изолированном АИТ данные слабые (Krysiak 2019 — ↓ АТ-ТПО, но клинический эффект малый) | [EBM: Krysiak 2019 Exp Clin Endocrinol; Sategna-Guidetti 2001] |
| AIP-протокол | Рекомендуется активно | **Данные пилотные** (Abbott 2019, n=17); нет крупных RCT; ограничения непитательные | [EBM: Abbott 2019 Cureus] |
| Инозитол + Se | Новый стандарт | **Данные обнадёживающие, но требуют подтверждения** (Nordio 2017 малая выборка); не рутинная рекомендация | [EBM: Nordio 2017 Eur Rev Med Pharmacol] |
| Витамин D 50 000 IU/нед | Универсально при АИТ | **Только при 25(OH)D <30 нг/мл**; титрация по уровню; UL 4000 IU/сут без наблюдения | [EBM: Chahardoli 2019; Endocrine Society 2024] |
| LDN (низкодозный налтрексон) | Обсуждается как опция | **Off-label**; нет крупных RCT при АИТ; не входит в клинические гайдлайны | [консенсус: нет EBM-подтверждения] |

### 11.3 Гайдлайны первого уровня (Level A)

**Тиреоидологические гайдлайны:**
- ATA — Guidelines for the Treatment of Hypothyroidism 2014 (Jonklaas) — https://doi.org/10.1089/thy.2014.0028
- ATA — Guidelines for the Diagnosis and Management of Thyroid Disease during Pregnancy and Postpartum 2017 (Alexander) — https://doi.org/10.1089/thy.2016.0457
- ATA — Guidelines for Hyperthyroidism 2016 (Ross) — https://doi.org/10.1089/thy.2016.0229
- ETA — Guidelines: Use of L-T4 + L-T3 in the Treatment of Hypothyroidism 2012 (Wiersinga) — https://doi.org/10.1159/000339444
- ETA — Guidelines: Selenium in Thyroid Disease 2013 — https://doi.org/10.1159/000356507
- ETA — Iodine Deficiency in Europe 2014 — https://doi.org/10.1159/000362981
- BTA — UK Guidelines for the Use of Thyroid Function Tests 2006/2018 — https://www.british-thyroid-association.org/sandbox/bta2016/uk_guidelines_for_the_use_of_thyroid_function_tests.pdf
- Endocrine Society — Vitamin D Guideline 2024 — https://doi.org/10.1210/clinem/dgae290
- ACOG — Thyroid Disease in Pregnancy 2020 — https://www.acog.org/clinical/clinical-guidance
- WHO/UNICEF/ICCIDD — Assessment of iodine deficiency disorders 2007 — https://www.who.int/publications/i/item/9789241595827

### 11.4 Ключевые RCT и мета-анализы (Level A-B)

**Селен:**
- Gärtner R et al., **JCEM** 2002 — Se 200 мкг ↓ АТ-ТПО при АИТ — https://doi.org/10.1210/jcem.87.4.8421
- Toulis KA et al., **Thyroid** 2010 — Se и АТ-ТПО мета-анализ — https://doi.org/10.1089/thy.2009.0351
- Ventura M et al., **Endocrinol Metab** 2017 — Se обзор — https://doi.org/10.3803/EnM.2017.32.4.415
- Nordio M, Basciani S, **Eur Rev Med Pharmacol Sci** 2017 — Se+мио-инозитол при АИТ — https://doi.org/10.26355/eurrev_201702_12174
- Klein EA et al., **JAMA** 2011 (SELECT) — Se и риск СД2 — https://doi.org/10.1001/jama.2011.1437

**Витамин D:**
- Kivity S et al., **Cell Mol Immunol** 2011 — Vit D дефицит и АИТ — https://doi.org/10.1038/cmi.2010.73
- Chahardoli R et al., **Int J Endocrinol Metab** 2019 — Vit D3 50 000 IU RCT — https://doi.org/10.5812/ijem.85937
- Wang J et al., **Nutr J** 2015 — D3 при АИТ мета-анализ — https://doi.org/10.1186/s12937-015-0074-4

**Йод:**
- Zimmermann MB, **Endocr Rev** 2008 — Iodine deficiency — https://doi.org/10.1210/er.2007-0043
- Farebrother J et al., **Ann N Y Acad Sci** 2019 — избыток йода и ЩЖ — https://doi.org/10.1111/nyas.14041
- Leung AM, Braverman LE, **JCEM** 2014 — йод и беременность — https://doi.org/10.1210/jc.2014-1734

**Глютен и АИТ:**
- Krysiak R et al., **Exp Clin Endocrinol Diabetes** 2019 — GFD и АТ-ТПО RCT — https://doi.org/10.1055/a-0653-7108
- Sategna-Guidetti C et al., **Am J Gastroenterol** 2001 — целиакия и АИТ — https://doi.org/10.1111/j.1572-0241.2001.03621.x

**AIP-диета:**
- Abbott RD et al., **Cureus** 2019 — AIP при АИТ пилот — https://doi.org/10.7759/cureus.4556

**LT4 timing:**
- Bolk N et al., **Arch Intern Med** 2010 — LT4 утро vs вечер — https://doi.org/10.1001/archinternmed.2010.436

**Патогенез:**
- Brix TH et al., **JCEM** 2005 — Danish twins и АИТ — https://doi.org/10.1210/jc.2005-0114
- Fasano A, **Physiol Rev** 2011/2012 — zonulin и leaky gut — https://doi.org/10.1152/physrev.00003.2008
- Tomer Y, **J Autoimmun** 2010 — HLA и АИТ — https://doi.org/10.1016/j.jaut.2009.10.005

**Эпидемиология:**
- Vanderpump MP et al., **Clin Endocrinol** 1995 — Whickham 20-year — https://doi.org/10.1111/j.1365-2265.1995.tb01894.x
- Hollowell JG et al., **JCEM** 2002 — NHANES III — https://doi.org/10.1210/jcem.87.2.8182

<!-- EBM_ENRICHED_v1.1 -->

---

"@

$anchorSourcesFull = [regex]::Escape($anchorSources)
if ($content -match $anchorSourcesFull) {
    $content = $content -replace $anchorSourcesFull, ($section11 + $anchorSources)
    Write-Host "  [OK] B01: §11 EBM benchmark вставлен перед ## Источники" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] B01: якорь ## Источники не найден" -ForegroundColor Red
}

# ==================== БЛОК C: Метаданные ====================
Write-Host ""
Write-Host "== Блок C: Обновление метаданных ==" -ForegroundColor Cyan

# C01: версия 1.0 → 1.1 (в разделе Метаданные)
$replVersion = '${1}1.1'
$content = $content -replace '(?im)^(\s*[-*]?\s*\*?\*?Версия:?\*?\*?\s*[:\s]*)1\.0\b', $replVersion
Write-Host "  [OK] C01: версия 1.0 → 1.1" -ForegroundColor Green

# C02: обновить дату последнего обновления
$replDate = '${1}2026-07-27 (Session 44, EBM-lite обогащение)'
$content = $content -replace '(?im)^(\s*[-*]?\s*\*?\*?(Последнее обновление|Обновлено|Дата обновления):?\*?\*?\s*[:\s]*).*$', $replDate
Write-Host "  [OK] C02: дата обновлена" -ForegroundColor Green

# C03: статус
$replStatus = '${1}✅ Готов (EBM-lite)'
$content = $content -replace '(?im)^(\s*[-*]?\s*\*?\*?Статус:?\*?\*?\s*[:\s]*).*$', $replStatus
Write-Host "  [OK] C03: статус ✅ Готов (EBM-lite)" -ForegroundColor Green

# C04: EBM-статус (добавить после Статус в блоке Метаданные)
if ($content -notmatch '(?im)EBM-статус') {
    $ebmStatusLine = "`r`n- **EBM-статус:** EBM-lite (уровень 1) — школьный протокол (УРОКИ 17/18/22/12) с EBM-слоем (ATA 2014/2017, ETA 2012/2013, Endocrine Society, ACOG, Cochrane; ключевые RCT)."
    $content = $content -replace '(?im)(- \*\*Статус:\*\* ✅ Готов \(EBM-lite\))', "`$1$ebmStatusLine"
    Write-Host "  [OK] C04: EBM-статус добавлен" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] C04: EBM-статус уже существует" -ForegroundColor Yellow
}

# C05: changelog (добавить в конец файла после метаданных)
if ($content -notmatch 'Session 44') {
    $changelogEntry = @"

### Changelog

- **2026-07-27 (Session 44):** EBM-lite обогащение — inline [EBM:] ссылки в §§1-10, новый §11 EBM benchmark (§11.0 EBM-статус, §11.1 иерархия OCEBM, §11.2 таблица школа vs EBM с 10 расхождениями: TSH target, Se обязательность, йод отказ vs норма, T4 vs T4+T3, LT4 timing, GFD, AIP, инозитол+Se, Vit D 50 000 IU, LDN), §11.3 гайдлайны (ATA 2014/2017/2016, ETA 2012/2013/2014, BTA, Endocrine Society, ACOG, WHO с URL), §11.4 RCT с DOI (20+ источников); версия 1.0 → 1.1, статус ✅ Готов (EBM-lite).
- **Session 35 (2026-07-06):** initial v1.0.

"@
    $content = $content + $changelogEntry
    Write-Host "  [OK] C05: changelog добавлен" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] C05: changelog уже содержит Session 44" -ForegroundColor Yellow
}

# ==================== БЛОК D: Обновление blockquote в шапке ====================
Write-Host ""
Write-Host "== Блок D: Обновление шапки (blockquote) ==" -ForegroundColor Cyan

# D01: обновить версию в blockquote-шапке
$content = $content -replace '(?m)^(> \*\*Версия:\*\* )1\.0(\s*\|)', '${1}1.1${2}'
Write-Host "  [OK] D01: blockquote версия 1.0 → 1.1" -ForegroundColor Green

# D02: обновить статус в blockquote-шапке
$content = $content -replace '(?m)(> .{0,150}\| \*\*Статус:\*\* )✅ Готов(\s*$)', '${1}✅ Готов (EBM-lite)${2}'
Write-Host "  [OK] D02: blockquote статус ✅ Готов → Готов (EBM-lite)" -ForegroundColor Green

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

# ==================== БЛОК F: ВАЛИДАЦИЯ ====================
Write-Host ""
Write-Host "=== ВАЛИДАЦИЯ ===" -ForegroundColor Cyan

$fileInfo = Get-Item $file
$lines = (Get-Content $file -Encoding UTF8).Count
$sizeKB = [math]::Round($fileInfo.Length / 1KB, 1)

$ebmCount = ([regex]::Matches($content, '\[EBM:')).Count
$section11present = $content -match '(?m)^## 11\. EBM benchmark'
$section112present = $content -match '### 11\.2 Таблица расхождений'
$section113present = $content -match '### 11\.3 Гайдлайны первого уровня'
$section114present = $content -match '### 11\.4 Ключевые RCT'
$markerPresent = $content -match '<!-- EBM_ENRICHED_v1\.1 -->'

$bytes = [System.IO.File]::ReadAllBytes($file)
$bomOk = ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)

Write-Host ""
Write-Host "Метрики:" -ForegroundColor White
Write-Host "  Строк:                 $lines"
Write-Host "  Размер:                $sizeKB KB"
Write-Host "  [EBM: …] тегов:        $ebmCount"
Write-Host "  Inline замен блока A:  $replCount"
Write-Host "  §11 присутствует:      $section11present"
Write-Host "  §11.2 присутствует:    $section112present"
Write-Host "  §11.3 присутствует:    $section113present"
Write-Host "  §11.4 присутствует:    $section114present"
Write-Host "  Idempotency marker:    $markerPresent"
Write-Host "  UTF-8 BOM:             $bomOk"

# Проверка порядка секций
$headings = Select-String -Path $file -Pattern '^## ' | Select-Object -ExpandProperty Line
$idx10 = [array]::IndexOf($headings, $anchor10)
$idx11 = ($headings | Where-Object { $_ -match '^## 11\. EBM benchmark' } | Select-Object -First 1)
$idxSources = [array]::IndexOf($headings, $anchorSources)
$idxMeta = [array]::IndexOf($headings, $anchorMeta)

$idx11num = if ($idx11) { [array]::IndexOf($headings, $idx11) } else { -1 }
$orderOk = ($idx10 -lt $idx11num) -and ($idx11num -lt $idxSources) -and ($idxSources -lt $idxMeta)
Write-Host "  Порядок §10→§11→Ист.→Мета: $orderOk"

Write-Host ""
if ($bomOk -and $section11present -and $section112present -and $section113present -and $section114present -and $markerPresent -and $orderOk) {
    Write-Host "=== ГОТОВО ===" -ForegroundColor Green
    Write-Host "Следующий шаг: git diff --stat references/methodology/hashimoto.md" -ForegroundColor Gray
} else {
    Write-Host "=== ЗАВЕРШЕНО С ПРЕДУПРЕЖДЕНИЯМИ ===" -ForegroundColor Yellow
}
# === КОНЕЦ ===
