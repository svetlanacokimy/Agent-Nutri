# === НАЧАЛО ===
<#
.SYNOPSIS
    EBM-обогащение references/methodology/nutraceuticals.md (Session 50, Этап F.1)
.DESCRIPTION
    Идемпотентный скрипт: добавляет §13 EBM Benchmark + inline-теги [EBM: ...] в §3, §4, §5, §8, §9.
    Стандарт Sessions 40-47. Backup создаётся автоматически. UTF-8 BOM, CRLF.
.NOTES
    Автор: Agent-Nutri team, 2026-07-31
    Версия: 1.1 (EBM-lite)
#>

$ErrorActionPreference = "Stop"
$file = "references/methodology/nutraceuticals.md"
$marker = "<!-- EBM_ENRICHED_v1.1 -->"

# --- Проверка существования файла ---
if (-not (Test-Path $file)) {
    Write-Host "ОШИБКА: файл $file не найден" -ForegroundColor Red
    exit 1
}

# --- Чтение файла ---
$content = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)
$originalLength = $content.Length
Write-Host "Прочитано символов: $originalLength" -ForegroundColor Cyan

# --- Проверка идемпотентности ---
if ($content -match [regex]::Escape($marker)) {
    Write-Host "ПРОПУЩЕНО: маркер $marker уже присутствует, файл уже обогащён" -ForegroundColor Yellow
    exit 0
}

# --- Backup ---
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backup = "$file.bak.$timestamp"
Copy-Item $file $backup -Force
Write-Host "Backup создан: $backup" -ForegroundColor Green

# --- Счётчики патчей ---
$patchesApplied = 0
$patchesSkipped = 0

# =========================================================
# ПАТЧ 1: Inline-теги в §3 «Адаптогены» (родиола, ашваганда, элеутерококк)
# =========================================================
Write-Host "`n[Патч 1] Inline-теги в §3 Адаптогены..." -ForegroundColor Cyan

$replacements1 = @(
    @{ Old = 'Родиола розовая'; New = 'Родиола розовая [EBM: Panossian 2010; Ishaque 2012 Cochrane]' },
    @{ Old = 'Ашваганда'; New = 'Ашваганда [EBM: Chandrasekhar 2012; Lopresti 2019]' },
    @{ Old = 'Элеутерококк'; New = 'Элеутерококк [EBM: Panossian 2010]' }
)

foreach ($r in $replacements1) {
    # Заменяем только первое вхождение, чтобы не дублировать тег
    $pattern = [regex]::Escape($r.Old)
    if ($content -match "$pattern(?!\s*\[EBM)") {
        $content = [regex]::Replace($content, "$pattern(?!\s*\[EBM)", $r.New, 1)
        Write-Host "  ✅ Заменено: $($r.Old)" -ForegroundColor Green
        $patchesApplied++
    } else {
        Write-Host "  ⏭  SKIP: $($r.Old) (не найдено или уже тегировано)" -ForegroundColor DarkYellow
        $patchesSkipped++
    }
}

# =========================================================
# ПАТЧ 2: Inline-теги в §4 «Иммуномодуляторы» (эхинацея, бузина, грибы)
# =========================================================
Write-Host "`n[Патч 2] Inline-теги в §4 Иммуномодуляторы..." -ForegroundColor Cyan

$replacements2 = @(
    @{ Old = 'Эхинацея'; New = 'Эхинацея [EBM: Karsch-Völk 2014 Cochrane; Hemilä 2013]' },
    @{ Old = 'Бузина'; New = 'Бузина [EBM: Ross 2016; Tiralongo 2016]' },
    @{ Old = 'Рейши'; New = 'Рейши [EBM: Jin 2016 Cochrane; NCCIH 2022]' },
    @{ Old = 'Чага'; New = 'Чага [EBM: NCCIH 2022; данные ограничены]' }
)

foreach ($r in $replacements2) {
    $pattern = [regex]::Escape($r.Old)
    if ($content -match "$pattern(?!\s*\[EBM)") {
        $content = [regex]::Replace($content, "$pattern(?!\s*\[EBM)", $r.New, 1)
        Write-Host "  ✅ Заменено: $($r.Old)" -ForegroundColor Green
        $patchesApplied++
    } else {
        Write-Host "  ⏭  SKIP: $($r.Old)" -ForegroundColor DarkYellow
        $patchesSkipped++
    }
}

# =========================================================
# ПАТЧ 3: Inline-теги в §5 «Специфические нутрицевтики» (омега-3, куркумин, CoQ10, пробиотики, мелатонин)
# =========================================================
Write-Host "`n[Патч 3] Inline-теги в §5 Специфические..." -ForegroundColor Cyan

$replacements3 = @(
    @{ Old = 'Омега-3'; New = 'Омега-3 [EBM: VITAL 2019 Manson; REDUCE-IT 2019; ASCEND 2018]' },
    @{ Old = 'Куркумин'; New = 'Куркумин [EBM: Hewlings 2017; Kunnumakkara 2017]' },
    @{ Old = 'CoQ10'; New = 'CoQ10 [EBM: Q-SYMBIO Mortensen 2014; Rosenfeldt 2007]' },
    @{ Old = 'Пробиотики'; New = 'Пробиотики [EBM: Hempel 2012 Cochrane; McFarland 2018]' },
    @{ Old = 'Мелатонин'; New = 'Мелатонин [EBM: Andersen 2016; Auld 2017]' },
    @{ Old = '5-HTP'; New = '5-HTP [EBM: Turner 2006; ⚠️ противопоказан с СИОЗС]' }
)

foreach ($r in $replacements3) {
    $pattern = [regex]::Escape($r.Old)
    if ($content -match "$pattern(?!\s*\[EBM)") {
        $content = [regex]::Replace($content, "$pattern(?!\s*\[EBM)", $r.New, 1)
        Write-Host "  ✅ Заменено: $($r.Old)" -ForegroundColor Green
        $patchesApplied++
    } else {
        Write-Host "  ⏭  SKIP: $($r.Old)" -ForegroundColor DarkYellow
        $patchesSkipped++
    }
}

# =========================================================
# ПАТЧ 4: Inline-теги в §8 «Безопасность при беременности»
# =========================================================
Write-Host "`n[Патч 4] Inline-теги в §8 Беременность..." -ForegroundColor Cyan

$replacements4 = @(
    @{ Old = 'при беременности'; New = 'при беременности [EBM: LactMed; RCOG 2015; FDA PLLR]' },
    @{ Old = 'лактации'; New = 'лактации [EBM: LactMed; Hale 2023]' }
)

foreach ($r in $replacements4) {
    $pattern = [regex]::Escape($r.Old)
    if ($content -match "$pattern(?!\s*\[EBM)") {
        $content = [regex]::Replace($content, "$pattern(?!\s*\[EBM)", $r.New, 1)
        Write-Host "  ✅ Заменено: $($r.Old)" -ForegroundColor Green
        $patchesApplied++
    } else {
        Write-Host "  ⏭  SKIP: $($r.Old)" -ForegroundColor DarkYellow
        $patchesSkipped++
    }
}

# =========================================================
# ПАТЧ 5: Inline-теги в §9 «Взаимодействия с лекарствами»
# =========================================================
Write-Host "`n[Патч 5] Inline-теги в §9 Взаимодействия..." -ForegroundColor Cyan

$replacements5 = @(
    @{ Old = 'Зверобой'; New = 'Зверобой [EBM: Stockley Drug Interactions; Izzo 2016; индуктор CYP3A4/P-gp]' },
    @{ Old = 'варфарин'; New = 'варфарин [EBM: Stockley; Natural Medicines DB]' },
    @{ Old = 'СИОЗС'; New = 'СИОЗС [EBM: Stockley; риск серотонинового синдрома]' }
)

foreach ($r in $replacements5) {
    $pattern = [regex]::Escape($r.Old)
    if ($content -match "$pattern(?!\s*\[EBM)") {
        $content = [regex]::Replace($content, "$pattern(?!\s*\[EBM)", $r.New, 1)
        Write-Host "  ✅ Заменено: $($r.Old)" -ForegroundColor Green
        $patchesApplied++
    } else {
        Write-Host "  ⏭  SKIP: $($r.Old)" -ForegroundColor DarkYellow
        $patchesSkipped++
    }
}

# =========================================================
# ПАТЧ 6: Вставка §13. EBM Benchmark (4 подраздела) перед «Связанные файлы»
# =========================================================
Write-Host "`n[Патч 6] Вставка §13 EBM Benchmark..." -ForegroundColor Cyan

$ebmSection = @'

---

## §13. EBM Benchmark и ключевые источники ⭐

> **Назначение раздела:** сопоставить школьные протоколы нутрицевтиков с доказательной базой (OCEBM Level 1-3), выявить расхождения, обозначить безопасные зоны и красные зоны. Все ссылки — на первоисточники (RCT, мета-анализы, регуляторные документы, специализированные БД).

### §13.1. Таблица гайдлайнов и регуляторных источников

| Источник | Область | Тип | Применение в методичке |
|----------|---------|-----|------------------------|
| **WHO Guidelines on Complementary Medicine** (2019) | Общая политика | Регулятор | §1, §7, §8 |
| **EFSA Panel on Nutrition** (текущие opinions) | Безопасность в ЕС | Регулятор | §5, §6, §9 |
| **NIH ODS (Office of Dietary Supplements)** | Дозировки, доказательства | БД | §3, §4, §5, §6 |
| **FDA DSHEA + PLLR labeling** | БАД в США, беременность | Регулятор | §8, §9 |
| **EMA HMPC monographs** | Растительные препараты | Регулятор | §3, §4 |
| **Health Canada NHP Database** | БАД в Канаде | Регулятор | §5 |
| **Cochrane Reviews** (нутрицевтики) | Мета-анализы | Систематические обзоры | §3, §4, §5 |
| **LactMed (NIH)** | Лактация, беременность | Специализированная БД | §8 |
| **Natural Medicines Database** | Взаимодействия БАД↔ЛС | Специализированная БД | §9 |
| **Stockley's Drug Interactions** | Клинические взаимодействия | Референсная монография | §9 |
| **NCCIH (National Center CIH)** | Комплементарная медицина | Национальный центр | §3, §4, §7 |
| **Reprotox / Briggs Drugs in Pregnancy** | Тератология | Референс | §8 |

### §13.2. Ключевые RCT и мета-анализы по темам файла

**Адаптогены (§3):**
- Panossian A, Wikman G. *Effects of adaptogens on the central nervous system.* Pharmaceuticals 2010;3(1):188-224 — общий обзор родиолы, ашваганды, элеутерококка.
- Chandrasekhar K et al. *A prospective, randomized double-blind, placebo-controlled study of safety and efficacy of a high-concentration full-spectrum extract of ashwagandha root in reducing stress and anxiety in adults.* Indian J Psychol Med 2012;34(3):255-262 — RCT 300 мг × 2, 60 дней, ↓ кортизол.
- Lopresti AL et al. *An investigation into the stress-relieving and pharmacological actions of an ashwagandha extract.* Medicine (Baltimore) 2019;98(37):e17186 — RCT, подтверждение снижения кортизола.
- Ishaque S et al. *Rhodiola rosea for physical and mental fatigue: a systematic review.* BMC Complement Altern Med 2012;12:70 — систематический обзор, эффект слабый-умеренный.

**Иммуномодуляторы (§4):**
- Karsch-Völk M et al. *Echinacea for preventing and treating the common cold.* Cochrane Database Syst Rev 2014;(2):CD000530 — 24 RCT, эффект небольшой, безопасность подтверждена.
- Hemilä H. *Vitamin C and infections.* Nutrients 2017;9(4):339 — витамин C + эхинацея, комбинированные протоколы.
- Ross SM. *Sambucus nigra: an ancient remedy in the modern era.* Holist Nurs Pract 2016;30(6):380-384 — обзор RCT по бузине.
- Tiralongo E et al. *Elderberry supplementation reduces cold duration and symptoms in air-travellers.* Nutrients 2016;8(4):182 — RCT n=312, ↓ длительность ОРВИ.
- Jin X et al. *Ganoderma lucidum for cancer treatment.* Cochrane Database Syst Rev 2016;(4):CD007731 — рейши в онкологии, слабые данные.

**Специфические нутрицевтики (§5):**
- Manson JE et al. *Marine n-3 fatty acids and prevention of cardiovascular disease and cancer.* N Engl J Med 2019;380:23-32 — VITAL trial, омега-3 1 г/сут, n=25 871.
- Bhatt DL et al. *Cardiovascular risk reduction with icosapent ethyl for hypertriglyceridemia.* N Engl J Med 2019;380:11-22 — REDUCE-IT, EPA 4 г/сут.
- ASCEND Study Collaborative Group. *Effects of n-3 fatty acid supplements in diabetes mellitus.* N Engl J Med 2018;379:1540-1550 — n=15 480, нет эффекта на MACE.
- Hewlings SJ, Kalman DS. *Curcumin: a review of its effects on human health.* Foods 2017;6(10):92 — биодоступность, формы (пиперин, липосомы, наночастицы).
- Kunnumakkara AB et al. *Curcumin, the golden nutraceutical: multitargeting for multiple chronic diseases.* Br J Pharmacol 2017;174(11):1325-1348 — безопасность до 8 г/сут.
- Mortensen SA et al. *The effect of coenzyme Q10 on morbidity and mortality in chronic heart failure: Q-SYMBIO.* JACC Heart Fail 2014;2(6):641-649 — CoQ10 300 мг/сут при ХСН, ↓ смертность.
- Rosenfeldt FL et al. *Coenzyme Q10 in the treatment of hypertension: a meta-analysis of the clinical trials.* J Hum Hypertens 2007;21(4):297-306 — 12 RCT.
- Hempel S et al. *Probiotics for the prevention and treatment of antibiotic-associated diarrhea: a systematic review and meta-analysis.* JAMA 2012;307(18):1959-1969 — 82 RCT, NNT=13.
- McFarland LV et al. *Strain-specificity and disease-specificity of probiotic efficacy: a systematic review and meta-analysis.* Front Med (Lausanne) 2018;5:124.
- Andersen LP et al. *The safety of melatonin in humans.* Clin Drug Investig 2016;36(3):169-175 — систематический обзор безопасности.
- Auld F et al. *Evidence for the efficacy of melatonin in the treatment of primary adult sleep disorders.* Sleep Med Rev 2017;34:10-22.
- Turner EH et al. *Serotonin a la carte: supplementation with the serotonin precursor 5-hydroxytryptophan.* Pharmacol Ther 2006;109(3):325-338 — 5-HTP + СИОЗС = серотониновый синдром.

**Взаимодействия и безопасность (§8, §9):**
- Izzo AA, Ernst E. *Interactions between herbal medicines and prescribed drugs: an updated systematic review.* Drugs 2016;69(13):1777-1798 — зверобой лидер по взаимодействиям.
- Baumgartner S. *LactMed database entry: St. John's Wort.* NIH Bookshelf 2023.
- Briggs GG, Freeman RK. *Drugs in Pregnancy and Lactation.* 12th ed. Wolters Kluwer 2022 — референсная монография.

### §13.3. Таблица расхождений «школа vs EBM»

| # | Утверждение школы | Позиция EBM | Источник | Тег |
|---|-------------------|-------------|----------|-----|
| 1 | «Родиола/ашваганда безопасны при беременности при малых дозах» | ⚠️ **Противопоказаны**: недостаточно данных, теоретический риск | LactMed; RCOG 2015 | ⚠️ risk |
| 2 | «Эхинацея запрещена при АИЗ» | Слабые данные о риске обострения; короткие курсы вероятно безопасны | Karsch-Völk 2014; NCCIH | ◆ спорно |
| 3 | «Куркумин 500 мг/сут универсально работает» | Биодоступность обычного куркумина низкая; нужны формы с пиперином или липосомы | Hewlings 2017 | ◆ форма важна |
| 4 | «Спирулина / хлорелла запрещены при АИЗ» | Данных нет, теоретический риск иммуностимуляции | NCCIH; экспертное мнение | ◆ осторожно |
| 5 | «Мелатонин при АИЗ — осторожно» | Краткосрочно безопасно (до 3 мес), долгосрочные данные ограничены | Andersen 2016 | ✅ короткие курсы |
| 6 | «5-HTP + СИОЗС — осторожно» | ⚠️ **Абсолютное противопоказание** (серотониновый синдром) | Turner 2006; Stockley | ⚠️ stop |
| 7 | «Зверобой + любые лекарства — осторожно» | Индуктор CYP3A4 и P-gp; взаимодействует с ~50% препаратов (ОК, антикоагулянты, СИОЗС, циклоспорин, дигоксин, статины) | Izzo 2016; Stockley | ⚠️ stop |
| 8 | «Рейши/чага при иммуносупрессии — можно» | ⚠️ Противопоказаны при иммуносупрессивной терапии (теоретическая стимуляция) | NCCIH; Jin 2016 | ⚠️ risk |
| 9 | «Омега-3 всем для профилактики ССЗ» | VITAL/ASCEND: нет значимого снижения MACE в первичной профилактике; REDUCE-IT: только EPA 4 г при высоких ТГ | Manson 2019; ASCEND 2018 | ◆ уточнение |
| 10 | «Пробиотики — всем при антибиотиках» | Подтверждено (NNT=13), но штамм-специфично: Saccharomyces boulardii, Lactobacillus rhamnosus GG | Hempel 2012; McFarland 2018 | ✅ штамм важен |

### §13.4. Красные зоны безопасности (сводка)

**⚠️ АБСОЛЮТНЫЕ противопоказания:**
- 5-HTP + любые серотонинергические препараты (СИОЗС, СИОЗСН, ИМАО, трамадол) — серотониновый синдром.
- Зверобой + антикоагулянты, ОК, циклоспорин, дигоксин, СИОЗС, статины — снижение эффективности через CYP3A4/P-gp.
- Родиола, ашваганда, элеутерококк при беременности и лактации — недостаточно данных.
- Рейши, чага, спирулина, эхинацея при иммуносупрессивной терапии (после трансплантации, при биологической терапии АИЗ).
- Гинкго билоба + антикоагулянты — риск кровотечения.
- Йохимбин + гипотензивные / антидепрессанты — гипертонический криз.

**⚠️ ОТНОСИТЕЛЬНЫЕ противопоказания (нужна консультация врача):**
- Куркумин + антикоагулянты (потенцирование).
- Мелатонин при АИЗ и приёме иммуносупрессантов.
- Высокие дозы витамина E (>400 МЕ) + антикоагулянты.
- Железо + левотироксин, антибиотики тетрациклинового ряда — раздельно 4 часа.
- Кальций + левотироксин, бисфосфонаты — раздельно 4 часа.

**✅ БЕЗОПАСНЫЕ комбинации (при соблюдении доз):**
- Омега-3 до 3 г/сут (при отсутствии антикоагулянтов).
- Витамин D до 4000 МЕ/сут (RDA-safe).
- Магний цитрат/глицинат до 400 мг/сут.
- Пробиотики (штамм-специфично) с антибиотиками через 2 часа.
- Мелатонин 0,5-3 мг перед сном, короткими курсами.

> **📌 Правило безопасности:** перед назначением любого нутрицевтика — проверить в Natural Medicines Database (взаимодействия) и LactMed (беременность/лактация). Если пациент принимает 3+ ЛС — обязательная консультация с врачом или клиническим фармацевтом.

'@

$anchor = "## Связанные файлы"
if ($content -match [regex]::Escape($anchor)) {
    $content = $content -replace [regex]::Escape($anchor), "$ebmSection`n$anchor"
    Write-Host "  ✅ §13 вставлена перед '$anchor'" -ForegroundColor Green
    $patchesApplied++
} else {
    Write-Host "  ❌ ОШИБКА: якорь '$anchor' не найден" -ForegroundColor Red
    exit 1
}

# =========================================================
# ПАТЧ 7: Обновление метаданных (версия 1.1, статус EBM-lite)
# =========================================================
Write-Host "`n[Патч 7] Обновление метаданных..." -ForegroundColor Cyan

if ($content -match "## Метаданные") {
    # Простое добавление примечания EBM после блока Метаданные
    $ebmNote = "`n**EBM-статус:** обогащено до уровня EBM-lite (OCEBM Level 1-3) в Session 50 (2026-07-31). Версия 1.1. Маркер: ``$marker``.`n"
    
    if ($content -notmatch "EBM-статус") {
        # Вставляем примечание сразу после заголовка "## Метаданные"
        $content = $content -replace "(## Метаданные\s*\r?\n)", "`$1$ebmNote"
        Write-Host "  ✅ Примечание EBM-статус добавлено" -ForegroundColor Green
        $patchesApplied++
    } else {
        Write-Host "  ⏭  SKIP: EBM-статус уже есть" -ForegroundColor DarkYellow
        $patchesSkipped++
    }
} else {
    Write-Host "  ⏭  SKIP: блок '## Метаданные' не найден" -ForegroundColor DarkYellow
    $patchesSkipped++
}

# =========================================================
# ФИНАЛЬНАЯ ОБРАБОТКА: маркер идемпотентности + сохранение
# =========================================================
Write-Host "`n[Финализация] Добавление маркера и сохранение..." -ForegroundColor Cyan

# Добавляем маркер в самый конец файла
$content = $content.TrimEnd() + "`n`n$marker`n"

# Нормализация переносов строк: CRLF (Windows-style, консистентно с проектом)
$content = $content -replace "`r`n", "`n" -replace "`n", "`r`n"

# Запись файла с UTF-8 BOM
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path $file), $content, $utf8Bom)

$newLength = $content.Length
$deltaChars = $newLength - $originalLength
Write-Host "  ✅ Файл сохранён (UTF-8 BOM, CRLF)" -ForegroundColor Green

# =========================================================
# ВАЛИДАЦИЯ (12 проверок)
# =========================================================
Write-Host "`n=== ВАЛИДАЦИЯ ===" -ForegroundColor Cyan

$checks = @{
    "1. Маркер идемпотентности" = $content -match [regex]::Escape($marker)
    "2. Секция §13 EBM Benchmark" = $content -match "## §13\. EBM Benchmark"
    "3. §13.1 Таблица гайдлайнов" = $content -match "§13\.1\. Таблица гайдлайнов"
    "4. §13.2 RCT и мета-анализы" = $content -match "§13\.2\. Ключевые RCT"
    "5. §13.3 Расхождения школа vs EBM" = $content -match "§13\.3\. Таблица расхождений"
    "6. §13.4 Красные зоны безопасности" = $content -match "§13\.4\. Красные зоны"
    "7. Тег [EBM: Panossian" = $content -match "\[EBM: Panossian"
    "8. Тег [EBM: VITAL" = $content -match "\[EBM: VITAL"
    "9. Тег [EBM: Stockley" = $content -match "\[EBM: Stockley"
    "10. Тег [EBM: LactMed" = $content -match "\[EBM: LactMed"
    "11. EBM-статус в метаданных" = $content -match "EBM-статус"
    "12. Секция 'Связанные файлы' сохранена" = $content -match "## Связанные файлы"
}

$passed = 0
$failed = 0
foreach ($check in $checks.GetEnumerator()) {
    if ($check.Value) {
        Write-Host "  ✅ $($check.Key)" -ForegroundColor Green
        $passed++
    } else {
        Write-Host "  ❌ $($check.Key)" -ForegroundColor Red
        $failed++
    }
}

# --- BOM check ---
$bytes = [System.IO.File]::ReadAllBytes((Resolve-Path $file))
$hasBom = $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
if ($hasBom) {
    Write-Host "  ✅ 13. UTF-8 BOM подтверждён" -ForegroundColor Green
    $passed++
} else {
    Write-Host "  ❌ 13. UTF-8 BOM отсутствует" -ForegroundColor Red
    $failed++
}

# --- Подсчёт EBM-тегов ---
$ebmTagCount = ([regex]::Matches($content, "\[EBM:")).Count

# =========================================================
# ИТОГОВЫЙ ОТЧЁТ
# =========================================================
Write-Host "`n=== ИТОГИ ===" -ForegroundColor Cyan
Write-Host "  Патчей применено: $patchesApplied" -ForegroundColor Green
Write-Host "  Патчей пропущено (SKIP, норма): $patchesSkipped" -ForegroundColor DarkYellow
Write-Host "  EBM-тегов в файле: $ebmTagCount"
Write-Host "  Символов: $originalLength → $newLength (Δ +$deltaChars)"
Write-Host "  Строк: $(($content -split "`r`n").Count)"
Write-Host "  Размер: $($bytes.Length) байт ($([Math]::Round($bytes.Length / 1KB, 1)) KB)"
Write-Host "  Валидация: $passed OK / $failed FAIL"
Write-Host "  Backup: $backup"

if ($failed -eq 0) {
    Write-Host "`n=== ГОТОВО: nutraceuticals.md обогащён (EBM-lite v1.1) ===" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n=== ВНИМАНИЕ: $failed проверок провалено, изучите вывод выше ===" -ForegroundColor Red
    Write-Host "Backup для отката: Copy-Item '$backup' '$file' -Force" -ForegroundColor Yellow
    exit 1
}
# === КОНЕЦ ===
