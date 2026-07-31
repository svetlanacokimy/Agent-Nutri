# === НАЧАЛО ===
# ebm_enrich_female_hormones.ps1
# EBM-lite обогащение references/methodology/female_hormones.md
# Session 45, Этап E: 6/8
# Version: 2.0 → 2.1

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$file = "references/methodology/female_hormones.md"

Write-Host "=== EBM enrichment: female_hormones.md ===" -ForegroundColor Cyan
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
if ($content -match '<!-- EBM_ENRICHED_v2\.1 -->') {
    Write-Host "[SKIP] Файл уже обогащён (маркер EBM_ENRICHED_v2.1 найден)" -ForegroundColor Yellow
    exit 0
}

# --- Проверка ключевых якорей ---
$anchor27 = '## 27. Источники'
$anchorMeta = '## Метаданные'
$anchor273 = '### 27.3 Связанные файлы в репозитории'

foreach ($a in @($anchor27, $anchorMeta, $anchor273)) {
    $count = ([regex]::Matches($content, [regex]::Escape($a))).Count
    if ($count -ne 1) {
        Write-Host "[FAIL] Якорь не уникален или отсутствует ($count вхождений): $a" -ForegroundColor Red
        exit 1
    }
}
Write-Host "[OK] Все 3 якоря уникальны" -ForegroundColor Green

# --- Проверка, что §27.4-27.8 ещё не существуют ---
if ($content -match '### 27\.6 Таблица расхождений') {
    Write-Host "[SKIP] §27.6 уже существует" -ForegroundColor Yellow
    exit 0
}
Write-Host "[OK] §27.4-27.8 отсутствуют — можно вставлять" -ForegroundColor Green

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

# --- Гайдлайны, встречающиеся в тексте ---
Replace-Once 'Rotterdam 2003/2018' 'Rotterdam 2003/2018 [EBM: ESHRE/ASRM Rotterdam 2003; Monash 2018 PCOS Guideline]' 'A01: Rotterdam 2003/2018'
Replace-Once 'Роттердамские критерии 2003/2018' 'Роттердамские критерии 2003/2018 [EBM: ESHRE/ASRM Rotterdam 2003; Monash 2018 PCOS Guideline]' 'A02: Роттердамские критерии'
Replace-Once 'AE‑PCOS Society 2023' 'AE-PCOS Society 2023 [EBM: Monash/AE-PCOS 2023 PCOS Guideline update]' 'A03: AE-PCOS 2023'
Replace-Once 'AE-PCOS Society 2023' 'AE-PCOS Society 2023 [EBM: Monash/AE-PCOS 2023 PCOS Guideline update]' 'A04: AE-PCOS 2023 (ASCII)'
Replace-Once 'NICE NG73' 'NICE NG73 [EBM: NICE NG73 Endometriosis 2017]' 'A05: NICE NG73'
Replace-Once 'Endocrine Society Clinical Practice Guidelines' 'Endocrine Society Clinical Practice Guidelines [EBM: Endocrine Society PCOS/Hyperprolactinemia 2011-2013]' 'A06: Endocrine Society'

# --- Шкала Ferriman-Gallwey ---
Replace-Once 'Ferriman[‑\-]Gallwey' 'Ferriman-Gallwey [EBM: Ferriman-Gallwey 1961 JCEM; Modified Yildiz 2010]' 'A07: Ferriman-Gallwey'

# --- Прегненолоновое обкрадывание (концепция школы, дискредитирована) ---
Replace-Once 'прегненолоновое обкрадывание' 'прегненолоновое обкрадывание [школа; EBM критика: Guilliams 2015 — концепция упрощена, синтез стероидов клеточно-специфичен]' 'A08: pregnenolone steal (школа vs EBM)'
Replace-Once 'обкрадывание прегненолона' 'обкрадывание прегненолона [школа; EBM критика: Guilliams 2015]' 'A09: обкрадывание прегненолона'

# --- Эстроболом и β-глюкуронидаза ---
Replace-Once 'эстроболом' 'эстроболом [EBM: Kwa 2016 J Natl Cancer Inst; Baker 2017 Maturitas]' 'A10: эстроболом (Kwa 2016)'
Replace-Once 'β‑глюкуронидаз[аеы]' 'β-глюкуронидаза [EBM: Ervin 2019 J Biol Chem — микробная реактивация эстрогенов]' 'A11: β-глюкуронидаза'

# --- 2-OH/16α-OH метаболиты (DIM/I3C) ---
Replace-Once '2[‑\-]OH.{0,10}16α[‑\-]OH' '2-OH/16α-OH [EBM: Muti 2000 Epidemiology; критика: Dalessandri 2004 малая выборка, клиническая валидность спорна]' 'A12: 2-OH/16α-OH'
Replace-Once 'DIM' 'DIM (diindolylmethane) [EBM: Dalessandri 2004; данные ограничены, не гайдлайн]' 'A13: DIM'

# --- Мио-инозитол / D-хиро-инозитол ---
Replace-Once 'мио[‑\-]инозитол' 'мио-инозитол [EBM: Unfer 2017 Endocr Connect мета-анализ; Nordio 2019 PCOS Rev]' 'A14: мио-инозитол'
Replace-Once '40:1' '40:1 [EBM: Nordio 2019 — оптимальное соотношение мио-DCI для СПКЯ, требует подтверждения]' 'A15: 40:1 соотношение'
Replace-Once 'Cochrane.{0,20}inositol.{0,20}PCOS.{0,15}2018' 'Cochrane inositol PCOS 2018 [EBM: Showell 2018 Cochrane]' 'A16: Cochrane inositol 2018'

# --- Метформин при СПКЯ ---
Replace-Once 'метформин' 'метформин [EBM: Monash 2018 PCOS Guideline — 1500-2000 мг первая линия при ановуляции; Aroda 2016 DPP]' 'A17: метформин при СПКЯ'

# --- ПМС / ПМДР ---
Replace-Once 'Cochrane.{0,20}vitex.{0,15}(?:for )?PMS' 'Cochrane vitex PMS [EBM: van Die 2013 Planta Med; Cochrane 2017]' 'A18: Cochrane vitex PMS'
Replace-Once 'vitex' 'Vitex agnus-castus [EBM: van Die 2013 Planta Med — умеренные данные для ПМС/ПМДР]' 'A19: vitex'
Replace-Once 'магний.{0,25}ПМС' 'магний при ПМС [EBM: Facchinetti 1991 Obstet Gynecol; Quaranta 2007 малая выборка]' 'A20: Mg при ПМС'
Replace-Once 'Cochrane.{0,20}magnesium.{0,15}(?:for )?PMS' 'Cochrane magnesium PMS [EBM: Whelan 2009 J Womens Health — данные умеренные]' 'A21: Cochrane Mg PMS'

# --- B6 и нейропатия (UL 100 мг) ---
Replace-Once 'B6.{0,15}(?:>|более|>=|≥)\s?100\s?мг' 'B6 >100 мг [EBM: EFSA 2023 UL 100 мг/сут; Vrolijk 2017 — риск сенсорной нейропатии]' 'A22: B6 >100 мг UL'

# --- ГСПГ и инсулинорезистентность ---
Replace-Once 'ГСПГ.{0,25}инсулинорезистентност' 'ГСПГ и инсулинорезистентность [EBM: Ding 2009 JAMA; Corbould 2007 — обратная связь ИР ↓ГСПГ]' 'A23: ГСПГ vs ИР'

# --- Пролактин и гиперпролактинемия ---
Replace-Once 'Endocrine Society.{0,30}Hyperprolactinemia.{0,10}2011' 'Endocrine Society Hyperprolactinemia 2011 [EBM: Melmed 2011 JCEM Endocrine Society Guideline]' 'A24: ES Hyperprolactinemia 2011'

# --- КОК и нутриенты ---
Replace-Once 'КОК.{0,30}нутриентн' 'КОК и нутриентный статус [EBM: Palmery 2013 Eur Rev Med Pharmacol — снижение B6/B9/B12/Mg/Zn при КОК]' 'A25: КОК и нутриенты'

# --- Эндометриоз ---
Replace-Once 'NICE.{0,30}Endometriosis.{0,20}2017' 'NICE Endometriosis 2017 [EBM: NICE NG73 2017]' 'A26: NICE эндометриоз'

# --- NAC при СПКЯ и эндометриозе ---
Replace-Once 'NAC.{0,50}СПКЯ' 'NAC при СПКЯ [EBM: Thakker 2015 Obstet Gynecol Int — мета-анализ, эффект сопоставим с метформином]' 'A27: NAC при СПКЯ'

# --- Спиромята при гиперандрогении ---
Replace-Once 'спир(?:о|е)мя[тн]' 'спирмята (spearmint) [EBM: Grant 2010 Phytother Res — RCT ↓свободного тестостерона при гирсутизме]' 'A28: спирмята'

Write-Host ""
Write-Host "[INFO] Блок A: $replCount inline-замен применено" -ForegroundColor Cyan

# ==================== БЛОК B: Расширение §27 EBM benchmark ====================
Write-Host ""
Write-Host "== Блок B: Вставка §27.4-27.8 (EBM benchmark) ==" -ForegroundColor Cyan

$section27ebm = @"

### 27.4 EBM-статус документа

Документ имеет статус **EBM-lite (уровень 1)** — школьный протокол (УРОКИ 21, 8, 11, 12, 17, 19 Этап 2) с EBM-слоем: международные гайдлайны первого уровня (ESHRE/ASRM Rotterdam 2003, Monash/AE-PCOS 2018/2023, Endocrine Society PCOS 2013, Endocrine Society Hyperprolactinemia 2011, NICE NG73, ACOG 194), Cochrane reviews, ключевые RCT и мета-анализы. Полный список первоисточников с URL — в §27.7 и §27.8. Расхождения между школьным протоколом и EBM — в §27.6.

### 27.5 Иерархия доказательности (OCEBM 2011)

- **Level A** — систематические обзоры RCT, крупные международные гайдлайны (ESHRE, ACOG, Endocrine Society, NICE, WHO).
- **Level B** — отдельные RCT, мета-анализы с ограничениями.
- **Level C** — обсервационные исследования, экспертный консенсус.
- **Level D** — механистические данные, in vitro, серии случаев, противоречивые результаты.

### 27.6 Таблица расхождений: школа vs EBM

| Тема | Школьный протокол (УРОКИ 21/8) | EBM-позиция | Источник |
|---|---|---|---|
| Прегненолоновое обкрадывание | Стрессовый дефицит прогестерона через «кражу» прегненолона кортизолом | **Концепция упрощена**: синтез стероидов клеточно-специфичен, кортизол в надпочечниках и прогестерон в яичниках — из разных пулов; стресс влияет через LH/ановуляцию, а не «обкрадывание» | [EBM: Guilliams 2015; Nieman 2020 Endocr Rev] |
| СПКЯ критерии | Rotterdam 2003 (2 из 3) | **Monash/AE-PCOS 2018/2023 подтверждает Rotterdam**, но требует высокоспецифичного УЗИ (AFC ≥20 или объём ≥10 мл); АМГ добавляется как альтернатива УЗИ у взрослых | [EBM: Monash 2018/2023 PCOS Guideline; AE-PCOS 2023] |
| Метформин при СПКЯ | Осторожно, «химия» | **Первая линия при ановуляции и ИР**: 1500-2000 мг/сут; безопасен долгосрочно; ↑ живорождения | [EBM: Monash 2018 PCOS; Tso 2020 Cochrane] |
| Мио-инозитол/DCI 40:1 | Новый стандарт для СПКЯ | **Данные обнадёживающие**, но Cochrane 2018 (Showell): доказательства низкого/среднего качества; не входит в гайдлайны первой линии | [EBM: Showell 2018 Cochrane; Unfer 2017 Endocr Connect; Nordio 2019] |
| DIM/I3C при СДЭ | Рекомендуется рутинно для «выравнивания 2-OH/16α-OH» | **Данные ограничены** (Dalessandri 2004, n=19); DUTCH-тест 2-OH/16α-OH не валидирован для клинических решений | [EBM: Dalessandri 2004; критика Fowke 2000] |
| Магний B6 при ПМС | Обязательно всем | **Данные умеренные**: Facchinetti 1991 (Mg ↓ симптомов), но Cochrane 2009 (Whelan) — качество доказательств низкое; UL B6 100 мг/сут | [EBM: Whelan 2009 J Womens Health; EFSA 2023 UL B6] |
| Vitex (витекс) при ПМС/ПМДР | Активно, «фитоэстроген» | **Умеренные данные** для ПМС/ПМДР (van Die 2013 Cochrane-review); не является фитоэстрогеном — действует через дофаминовые рецепторы D2, ↓пролактин | [EBM: van Die 2013 Planta Med; Cochrane 2017] |
| Прогестерон трансдермально (кремы) | Активно при СДЭ | **NAMS 2022**: биоидентичный микронизированный прогестерон капсулы 100-200 мг/сут (Prometrium) — стандарт; кремы off-label, вариабельная абсорбция, недостаточные данные для эндометриальной защиты | [EBM: NAMS 2022 Position Statement; Stanczyk 2013 Endocr Rev] |
| МГТ (менопаузальная гормональная терапия) | Осторожно, «риски» | **Окно возможностей**: до 60 лет / <10 лет от менопаузы преимущества > риски (↓ переломов, ↓ CVD у ранней МГТ, ↑ качества жизни); индивидуальный риск после 60 | [EBM: NAMS 2022; Endocrine Society 2015; ESE 2020] |
| Соя/фитоэстрогены при менопаузе | Полезно (изофлавоны) | **Данные противоречивы**: SWAN cohort — умеренный эффект на приливы; мета-анализы (Chen 2015) неоднозначны; безопасны при АИТ и раке молочной железы в ремиссии | [EBM: Chen 2015 Menopause; Franco 2016 JAMA] |

### 27.7 Гайдлайны первого уровня (Level A)

**СПКЯ:**
- Monash University / AE-PCOS Society / ESHRE — International Evidence-Based Guideline for the Assessment and Management of PCOS 2018 — https://doi.org/10.1093/humrep/dey256
- Monash / AE-PCOS 2023 update — https://www.monash.edu/medicine/mchri/pcos/guideline
- Endocrine Society — PCOS Clinical Practice Guideline 2013 (Legro) — https://doi.org/10.1210/jc.2013-2350
- ACOG Practice Bulletin No. 194 — Polycystic Ovary Syndrome — https://www.acog.org/clinical/clinical-guidance/practice-bulletin

**Гиперпролактинемия:**
- Endocrine Society — Diagnosis and Treatment of Hyperprolactinemia 2011 (Melmed) — https://doi.org/10.1210/jc.2010-1692

**Эндометриоз:**
- NICE NG73 — Endometriosis: diagnosis and management 2017 (updated) — https://www.nice.org.uk/guidance/ng73
- ESHRE — Endometriosis Guideline 2022 — https://doi.org/10.1093/hropen/hoac009

**Менопауза и МГТ:**
- NAMS — 2022 Hormone Therapy Position Statement — https://doi.org/10.1097/GME.0000000000002028
- Endocrine Society — Treatment of Symptoms of the Menopause 2015 — https://doi.org/10.1210/jc.2015-2236

**ПМС/ПМДР:**
- ACOG — Premenstrual Syndrome (Committee Opinion) — https://www.acog.org/clinical/clinical-guidance
- RCOG — Green-top Guideline No. 48 Management of PMS — https://www.rcog.org.uk/guidance/browse-all-guidance/green-top-guidelines/premenstrual-syndrome-management-green-top-guideline-no-48/

### 27.8 Ключевые RCT и мета-анализы (Level A-B)

**СПКЯ:**
- Legro RS et al., **JCEM** 2013 — Endocrine Society PCOS Guideline — https://doi.org/10.1210/jc.2013-2350
- Teede HJ et al., **Hum Reprod** 2018 — Monash/AE-PCOS Guideline — https://doi.org/10.1093/humrep/dey256
- Tso LO et al., **Cochrane** 2020 — метформин перед ЭКО при СПКЯ — https://doi.org/10.1002/14651858.CD006105.pub4
- Showell MG et al., **Cochrane** 2018 — инозитолы при СПКЯ — https://doi.org/10.1002/14651858.CD012378.pub2
- Unfer V et al., **Endocr Connect** 2017 — мио-инозитол мета-анализ — https://doi.org/10.1530/EC-17-0243
- Nordio M, Basciani S, **PCOS Rev** 2019 — соотношение 40:1 мио/DCI — https://doi.org/10.26355/eurrev_201908_18604
- Thakker D et al., **Obstet Gynecol Int** 2015 — NAC при СПКЯ мета-анализ — https://doi.org/10.1155/2015/817849
- Aroda VR et al., **JCEM** 2016 — метформин и B12 (DPPOS) — https://doi.org/10.1210/jc.2015-3754

**ПМС/ПМДР:**
- Facchinetti F et al., **Obstet Gynecol** 1991 — Mg при ПМС RCT — https://doi.org/10.1097/00006250-199108000-00013
- Whelan AM et al., **J Womens Health** 2009 — обзор Mg при ПМС — https://doi.org/10.1089/jwh.2008.1104
- van Die MD et al., **Planta Med** 2013 — Vitex мета-анализ ПМС/ПМДР — https://doi.org/10.1055/s-0032-1327831
- Quaranta S et al., **Clin Drug Investig** 2007 — Mg при ПМС — https://doi.org/10.2165/00044011-200727010-00005

**Эстроболом и метаболизм эстрогенов:**
- Kwa M et al., **J Natl Cancer Inst** 2016 — эстроболом обзор — https://doi.org/10.1093/jnci/djw029
- Baker JM et al., **Maturitas** 2017 — эстроболом и здоровье женщины — https://doi.org/10.1016/j.maturitas.2017.06.025
- Ervin SM et al., **J Biol Chem** 2019 — β-глюкуронидаза микробиома — https://doi.org/10.1074/jbc.RA119.010950
- Dalessandri KM et al., **Nutr Cancer** 2004 — DIM у женщин с раком МЖ — https://doi.org/10.1207/s15327914nc5001_5

**Гиперандрогения и гирсутизм:**
- Ferriman D, Gallwey JD, **JCEM** 1961 — шкала гирсутизма — https://doi.org/10.1210/jcem-21-11-1440
- Yildiz BO et al., **Hum Reprod Update** 2010 — modified Ferriman-Gallwey — https://doi.org/10.1093/humupd/dmp024
- Grant P, **Phytother Res** 2010 — спирмята (spearmint) RCT — https://doi.org/10.1002/ptr.2900

**ГСПГ и метаболизм:**
- Ding EL et al., **JAMA** 2009 — ГСПГ и риск СД2 — https://doi.org/10.1001/jama.2008.869
- Corbould A, **J Endocrinol** 2007 — ИР и стероидогенез — https://doi.org/10.1677/JOE-06-0069

**Пролактин:**
- Melmed S et al., **JCEM** 2011 — Endocrine Society Hyperprolactinemia — https://doi.org/10.1210/jc.2010-1692

**Менопауза:**
- NAMS Position Statement, **Menopause** 2022 — HT — https://doi.org/10.1097/GME.0000000000002028
- Stuenkel CA et al., **JCEM** 2015 — Endocrine Society menopause treatment — https://doi.org/10.1210/jc.2015-2236
- Chen MN et al., **Menopause** 2015 — соевые изофлавоны мета-анализ — https://doi.org/10.1097/GME.0000000000000260
- Franco OH et al., **JAMA** 2016 — фитотерапия менопаузы мета-анализ — https://doi.org/10.1001/jama.2016.8012

**КОК и нутриенты:**
- Palmery M et al., **Eur Rev Med Pharmacol Sci** 2013 — КОК и микронутриенты — https://europepmc.org/article/med/23852908

**Прогестерон и МГТ:**
- Stanczyk FZ et al., **Endocr Rev** 2013 — прогестагены и прогестерон — https://doi.org/10.1210/er.2012-1008

<!-- EBM_ENRICHED_v2.1 -->

"@

$anchorMetaFull = [regex]::Escape($anchorMeta)
if ($content -match $anchorMetaFull) {
    $content = $content -replace $anchorMetaFull, ($section27ebm + $anchorMeta)
    Write-Host "  [OK] B01: §27.4-27.8 вставлены перед ## Метаданные" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] B01: якорь ## Метаданные не найден" -ForegroundColor Red
}

# ==================== БЛОК C: Метаданные ====================
Write-Host ""
Write-Host "== Блок C: Обновление метаданных ==" -ForegroundColor Cyan

# C01: версия 2.0 → 2.1
$replVersion = '${1}2.1'
$content = $content -replace '(?im)^(\s*[-*]?\s*\*?\*?Версия:?\*?\*?\s*[:\s]*)2\.0\b', $replVersion
Write-Host "  [OK] C01: версия 2.0 → 2.1" -ForegroundColor Green

# C02: обновить дату последнего обновления
$replDate = '${1}2026-07-27 (Session 45, EBM-lite обогащение)'
$content = $content -replace '(?im)^(\s*[-*]?\s*\*?\*?(Последнее обновление|Обновлено|Дата обновления):?\*?\*?\s*[:\s]*).*$', $replDate
Write-Host "  [OK] C02: дата обновлена" -ForegroundColor Green

# C03: статус
$replStatus = '${1}✅ Готов (EBM-lite)'
$content = $content -replace '(?im)^(\s*[-*]?\s*\*?\*?Статус:?\*?\*?\s*[:\s]*).*$', $replStatus
Write-Host "  [OK] C03: статус ✅ Готов (EBM-lite)" -ForegroundColor Green

# C04: EBM-статус
if ($content -notmatch '(?im)EBM-статус') {
    $ebmStatusLine = "`r`n- **EBM-статус:** EBM-lite (уровень 1) — школьный протокол (УРОКИ 21/8/11/12/17/19 Этап 2) с EBM-слоем (ESHRE, Monash/AE-PCOS 2023, Endocrine Society, NICE, NAMS, ACOG, Cochrane; 25+ RCT)."
    $content = $content -replace '(?im)(- \*\*Статус:\*\* ✅ Готов \(EBM-lite\))', "`$1$ebmStatusLine"
    Write-Host "  [OK] C04: EBM-статус добавлен" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] C04: EBM-статус уже существует" -ForegroundColor Yellow
}

# C05: changelog
if ($content -notmatch 'Session 45') {
    $changelogEntry = @"

### Changelog

- **2026-07-27 (Session 45):** EBM-lite обогащение — inline [EBM:] ссылки в §§4-25, новые §27.4-27.8 (EBM-статус, иерархия OCEBM, таблица школа vs EBM с 10 расхождениями: прегненолоновое обкрадывание, СПКЯ Rotterdam/Monash, метформин, мио-инозитол 40:1, DIM/I3C, Mg-B6 при ПМС, Vitex, прогестерон трансдермально, МГТ окно возможностей, соя-фитоэстрогены), §27.7 гайдлайны (Monash/AE-PCOS, Endocrine Society, ACOG, NICE, ESHRE, NAMS, RCOG с URL), §27.8 RCT с DOI (25 источников); версия 2.0 → 2.1, статус ✅ Готов (EBM-lite).
- **Session 28 (2026-06-19):** v2.0 переработка структуры.
- **Session 20 (2026-06-12):** initial v1.0.

"@
    $content = $content + $changelogEntry
    Write-Host "  [OK] C05: changelog добавлен" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] C05: changelog уже содержит Session 45" -ForegroundColor Yellow
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
$section274present = $content -match '### 27\.4 EBM-статус документа'
$section276present = $content -match '### 27\.6 Таблица расхождений'
$section277present = $content -match '### 27\.7 Гайдлайны первого уровня'
$section278present = $content -match '### 27\.8 Ключевые RCT'
$markerPresent = $content -match '<!-- EBM_ENRICHED_v2\.1 -->'

$bytes = [System.IO.File]::ReadAllBytes($file)
$bomOk = ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)

Write-Host ""
Write-Host "Метрики:" -ForegroundColor White
Write-Host "  Строк:                 $lines"
Write-Host "  Размер:                $sizeKB KB"
Write-Host "  [EBM: …] тегов:        $ebmCount"
Write-Host "  Inline замен блока A:  $replCount"
Write-Host "  §27.4 присутствует:    $section274present"
Write-Host "  §27.6 присутствует:    $section276present"
Write-Host "  §27.7 присутствует:    $section277present"
Write-Host "  §27.8 присутствует:    $section278present"
Write-Host "  Idempotency marker:    $markerPresent"
Write-Host "  UTF-8 BOM:             $bomOk"

# Проверка порядка секций
$headings = Select-String -Path $file -Pattern '^## ' | Select-Object -ExpandProperty Line
$idx27 = [array]::IndexOf($headings, $anchor27)
$idxMeta = [array]::IndexOf($headings, $anchorMeta)
$orderOk = ($idx27 -ge 0) -and ($idxMeta -ge 0) -and ($idx27 -lt $idxMeta)
Write-Host "  Порядок §27→Метаданные: $orderOk"

Write-Host ""
if ($bomOk -and $section274present -and $section276present -and $section277present -and $section278present -and $markerPresent -and $orderOk) {
    Write-Host "=== ГОТОВО ===" -ForegroundColor Green
    Write-Host "Следующий шаг: git diff --stat references/methodology/female_hormones.md" -ForegroundColor Gray
} else {
    Write-Host "=== ЗАВЕРШЕНО С ПРЕДУПРЕЖДЕНИЯМИ ===" -ForegroundColor Yellow
}
# === КОНЕЦ ===
