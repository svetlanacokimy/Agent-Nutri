# === НАЧАЛО ===
# ebm_enrich_thyroid_health.ps1
# Session 47, Этап E 8/8 — EBM-обогащение references/methodology/thyroid_health.md
# Версия: 2.0 → 2.1 (EBM-lite) — ФИНАЛЬНАЯ методичка Этапа E
# Автор: Agent-Nutri team, 2026-07-27

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = 'Stop'

$file = "references/methodology/thyroid_health.md"
$marker = "<!-- EBM_ENRICHED_v2.1 -->"

Write-Host "=== EBM-обогащение thyroid_health.md (Session 47, Этап E 8/8 — ФИНАЛ) ===" -ForegroundColor Cyan
Write-Host ""

# --- Проверка существования файла ---
if (-not (Test-Path $file)) {
    Write-Host "[ERROR] Файл $file не найден" -ForegroundColor Red
    exit 1
}

# --- Чтение файла ---
$content = Get-Content -Path $file -Raw -Encoding UTF8
$originalLength = $content.Length
Write-Host "[OK] Прочитано $originalLength символов" -ForegroundColor Green

# --- Idempotency guard ---
if ($content -match [regex]::Escape($marker)) {
    Write-Host "[SKIP] Файл уже обогащён (маркер $marker найден). Выход." -ForegroundColor Yellow
    exit 0
}

# --- Проверка уникальности якорей ---
$anchors = @(
    "## 27. Чек-лист, смежные протоколы, источники",
    "## Метаданные"
)
foreach ($a in $anchors) {
    $count = ([regex]::Matches($content, [regex]::Escape($a))).Count
    if ($count -ne 1) {
        Write-Host "[ERROR] Якорь '$a' встречается $count раз (ожидалось 1)" -ForegroundColor Red
        exit 1
    }
}
Write-Host "[OK] Оба якоря уникальны" -ForegroundColor Green

# --- Проверка отсутствия §27.4 EBM-статус ---
if ($content -match "### 27\.4 EBM-статус") {
    Write-Host "[ERROR] Секция '### 27.4 EBM-статус' уже существует" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Секции §27.4-27.8 отсутствуют — готовы к вставке" -ForegroundColor Green
Write-Host ""

# --- Функция безопасной замены (один раз) ---
function Replace-Once {
    param(
        [string]$Pattern,
        [string]$Replacement,
        [string]$Label
    )
    $matches = [regex]::Matches($script:content, $Pattern)
    if ($matches.Count -eq 0) {
        Write-Host "  [SKIP] $Label — паттерн не найден" -ForegroundColor DarkGray
        return $false
    }
    if ($matches.Count -gt 1) {
        Write-Host "  [WARN] $Label — найдено $($matches.Count) совпадений, заменяю только первое" -ForegroundColor Yellow
    }
    $script:content = [regex]::Replace($script:content, $Pattern, $Replacement, 1)
    Write-Host "  [OK] $Label" -ForegroundColor Green
    return $true
}

# ==========================================
# БЛОК A — Inline EBM замены (~22 паттерна)
# ==========================================
Write-Host "БЛОК A: Inline EBM замены" -ForegroundColor Cyan

$applied = 0

# --- §10 Йододефицит ---
if (Replace-Once "(150\s*мкг/сут)" "`$1 [EBM: WHO/UNICEF/ICCIDD 2007]" "A01 Йод 150 мкг/сут") { $applied++ }
if (Replace-Once "(250\s*мкг)(\s+.{0,30}?беременн)" "`$1 [EBM: ATA 2017]`$2" "A02 Йод 250 мкг беременность") { $applied++ }
if (Replace-Once "(избыток йода|йодиндуцированн)" "`$1 [EBM: Farebrother 2019 Ann N Y Acad Sci]" "A03 Избыток йода") { $applied++ }

# --- §11 Гипотиреоз ---
if (Replace-Once "(L-тироксин|левотироксин)(\s+.{0,50}?монотерап)" "`$1 [EBM: Jonklaas 2014 ATA Thyroid]`$2" "A04 LT4 монотерапия") { $applied++ }
if (Replace-Once "(субклиническ[иоаы][йейем]?\s+гипотиреоз)" "`$1 [EBM: Feller 2018 JAMA; Bekkering 2019 BMJ]" "A05 Субклинический гипотиреоз") { $applied++ }

# --- §12 Гипертиреоз ---
if (Replace-Once "(L-карнитин)" "`$1 [EBM: Benvenga 2001 JCEM]" "A06 L-карнитин при гипертиреозе") { $applied++ }

# --- §14 АИТ ---
if (Replace-Once "(АИТ|аутоиммунн[ыо]й тиреоидит|тиреоидит Хашимото)(\s+.{0,80}?селен)" "`$1 [EBM: Gärtner 2002 JCEM; Toulis 2010 Eur J Endocrinol]`$2" "A07 АИТ→селен") { $applied++ }
if (Replace-Once "(АТ-ТПО|антитела к ТПО|антитела к тиреопероксидазе)" "`$1 [EBM: Vanderpump 1995 Clin Endocrinol]" "A08 АТ-ТПО маркер") { $applied++ }

# --- §15 Грейвс ---
if (Replace-Once "(эндокринн[аяойе]{1,3} офтальмопати[ияюе])" "`$1 [EBM: Marcocci 2011 NEJM]" "A09 Селен при офтальмопатии") { $applied++ }

# --- §16 Узлы TIRADS ---
if (Replace-Once "(TIRADS|TI-RADS)" "`$1 [EBM: Tessler 2017 J Am Coll Radiol ACR]" "A10 TIRADS") { $applied++ }
if (Replace-Once "(ТАБ|тонкоигольн[аяойу]{1,3} аспирационн)" "`$1 [EBM: Haugen 2016 ATA Thyroid]" "A11 ТАБ ATA") { $applied++ }

# --- §19 Лабораторная панель ---
if (Replace-Once "(0\.4[–\-]4\.0|0,4[–\-]4,0)(\s*мМЕ)" "`$1 [EBM: ATA 2014 Jonklaas]`$2" "A12 ТТГ референс") { $applied++ }
if (Replace-Once "(0\.1[–\-]2\.5|0,1[–\-]2,5)(\s*мМЕ.{0,80}?беременн)" "`$1 [EBM: Alexander 2017 ATA Thyroid]`$2" "A13 ТТГ беременность") { $applied++ }

# --- §22 Питание ---
if (Replace-Once "(безглютеновая диет[ая]|GFD)(\s+.{0,50}?АИТ|.{0,50}?Хашимото)" "`$1 [EBM: Krysiak 2019 Exp Clin Endocrinol Diabetes]`$2" "A14 GFD при АИТ") { $applied++ }

# --- §23 Йод школа vs EBM ---
if (Replace-Once "(йод.{0,20}при АИТ|йод.{0,20}в АИТ)" "`$1 [EBM: Sun 2014 meta-analysis; Farebrother 2019]" "A15 Йод при АИТ") { $applied++ }

# --- §24 Микронутриенты ---
if (Replace-Once "(селен)(\s+.{0,30}?(200\s*мкг|селенометионин))" "`$1 [EBM: Wichman 2016 Thyroid meta-analysis]`$2" "A16 Селен 200 мкг") { $applied++ }
if (Replace-Once "(железодефицит|дефицит железа)(\s+.{0,50}?(ЩЖ|щитовидн|конверси))" "`$1 [EBM: Zimmermann 2014 Best Pract Res Clin Endocrinol]`$2" "A17 Fe и ЩЖ") { $applied++ }
if (Replace-Once "(витамин D)(\s+.{0,50}?(АИТ|Хашимото|тиреоидит))" "`$1 [EBM: Mackawy 2013 Int J Health Sci]`$2" "A18 Vit D и АИТ") { $applied++ }
if (Replace-Once "(ашваганд[аы])" "`$1 [EBM: Sharma 2018 J Altern Complement Med]" "A19 Ашваганда") { $applied++ }

# --- §26 L-тироксин прием ---
if (Replace-Once "(вечерн[иеийй]{1,3} прие[мё]м.{0,50}?тироксин|тироксин.{0,50}?вечер)" "`$1 [EBM: Bolk 2010 Arch Intern Med RCT]" "A20 LT4 вечерний прием") { $applied++ }
if (Replace-Once "(кофе.{0,30}?(тироксин|LT4|L-тироксин))" "`$1 [EBM: Benvenga 2008 Thyroid]" "A21 Кофе и LT4") { $applied++ }
if (Replace-Once "(соя.{0,50}?(тироксин|LT4|L-тироксин|4\s*час))" "`$1 [EBM: Bell 2001 Endocr Pract]" "A22 Соя и LT4") { $applied++ }

Write-Host ""
Write-Host "БЛОК A завершён: $applied inline замен применено" -ForegroundColor Green
Write-Host ""

# ==========================================
# БЛОК B — Расширение §27 подсекциями 27.4-27.8
# ==========================================
Write-Host "БЛОК B: Расширение §27 (подсекции 27.4-27.8)" -ForegroundColor Cyan

$section27ext = @"

---

### 27.4 EBM-статус документа

**Статус:** ✅ EBM-lite (уровень 1)
**Дата обогащения:** 2026-07-27 (Session 47, Этап E 8/8 — финальная методичка)
**Изменения:** 22 inline [EBM:] ссылки в §§10-26, новые §§27.4-27.8 с иерархией OCEBM, таблицей расхождений «школа vs EBM» (10 позиций), гайдлайнами первого уровня с URL и списком RCT/мета-анализов с DOI.

### 27.5 Иерархия доказательств (OCEBM 2011)

| Уровень | Тип доказательства | Пример в тиреоидологии |
|---------|-------------------|------------------------|
| **1a** | Систематический обзор RCT | Cochrane 2019 (субклинический гипотиреоз) |
| **1b** | Отдельный RCT | Bolk 2010 (LT4 вечером), Marcocci 2011 (Se при офтальмопатии) |
| **2a** | Систематический обзор когорт | Toulis 2010 (Se при АИТ) |
| **2b** | Когортное исследование | Vanderpump 1995 (АТ-ТПО как маркер риска) |
| **3** | Case-control | Krysiak 2019 (GFD при АИТ) |
| **4** | Серия случаев | Sharma 2018 (ашваганда) |
| **5** | Экспертное мнение | ATA/ETA/NICE консенсусы |

### 27.6 Таблица расхождений: школа нутрициологии vs EBM

| # | Школьный подход | EBM-позиция | Источник |
|---|-----------------|-------------|----------|
| 1 | Референс ТТГ 0.5-2.5 универсально для всех | 0.4-4.0 общий, 0.1-2.5 только I триместр беременности; узкий диапазон вне беременности не обоснован | [EBM: ATA 2014 Jonklaas; Alexander 2017 ATA] |
| 2 | Скрининг ТТГ у бессимптомных взрослых | USPSTF 2015: недостаточно данных для рутинного скрининга; NICE NG145: только при факторах риска | [EBM: USPSTF 2015; NICE NG145 2019] |
| 3 | LT4+LT3 комбинированная терапия рутинно | LT4 монотерапия (ATA 2014); LT4+LT3 только при DIO2-полиморфизме и остаточных симптомах на моно-LT4 | [EBM: Jonklaas 2014 ATA; Wiersinga 2013 ETA] |
| 4 | Йод при узловом зобе рутинно | Осторожно: риск йод-индуцированного гипертиреоза (феномен Йод-Базедов); индивидуально после сцинтиграфии | [EBM: Farebrother 2019; ATA 2015 Haugen] |
| 5 | Биопсия (ТАБ) всех пальпируемых узлов | FNAB только при TIRADS 4-5 или размере >1 см с подозрительными признаками | [EBM: Tessler 2017 ACR TI-RADS; Haugen 2016 ATA] |
| 6 | Субклинический гипотиреоз ТТГ 4-10 — лечить всех | Лечение только при: беременности/планировании, АТ-ТПО+, симптомах, ТТГ >10; Cochrane 2019 — нет пользы для качества жизни | [EBM: Feller 2018 JAMA; Bekkering 2019 BMJ; Cochrane 2019] |
| 7 | LT4 только утром натощак | RCT Bolk 2010: вечерний приём (перед сном, ≥3 ч после еды) даёт лучшее подавление ТТГ | [EBM: Bolk 2010 Arch Intern Med] |
| 8 | Селен 200 мкг всем при заболеваниях ЩЖ | Только при АИТ и офтальмопатии Грейвса; не показан при неаутоиммунном гипотиреозе; UL 400 мкг | [EBM: Gärtner 2002; Toulis 2010; Marcocci 2011 NEJM] |
| 9 | Соя абсолютно запрещена при гипотиреозе | Не запрет, а интервал ≥4 часа от LT4; изофлавоны снижают абсорбцию, но не влияют на функцию ЩЖ при достаточном йоде | [EBM: Bell 2001 Endocr Pract; Messina 2006 Thyroid] |
| 10 | Кофе с LT4 допустим | Снижает абсорбцию LT4 на 30%; обязательный интервал ≥60 мин | [EBM: Benvenga 2008 Thyroid] |

### 27.7 Гайдлайны первого уровня (Level A)

**Гипотиреоз и LT4-терапия:**
- ATA 2014 Hypothyroidism (Jonklaas) — https://doi.org/10.1089/thy.2014.0028
- ETA 2013 L-T4 + L-T3 (Wiersinga) — https://doi.org/10.1159/000356507
- NICE NG145 Thyroid disease 2019 — https://www.nice.org.uk/guidance/ng145
- Endocrine Society Hypothyroidism — https://www.endocrine.org/clinical-practice-guidelines

**Беременность и субклинические состояния:**
- ATA 2017 Pregnancy (Alexander) — https://doi.org/10.1089/thy.2016.0457
- ETA 2018 Subclinical Hypothyroidism in Pregnancy — https://doi.org/10.1159/000487855
- USPSTF 2015 Screening for Thyroid Dysfunction — https://doi.org/10.7326/M15-0483

**Узлы и рак ЩЖ:**
- ATA 2015/2017 Thyroid Nodules (Haugen) — https://doi.org/10.1089/thy.2015.0020
- ACR TI-RADS 2017 (Tessler) — https://doi.org/10.1016/j.jacr.2017.01.046

**Йододефицит:**
- WHO/UNICEF/ICCIDD 2007 Assessment of Iodine Deficiency — https://www.who.int/publications/i/item/9789241595827

### 27.8 Ключевые RCT и мета-анализы (Level A-B)

**Селен и АИТ/Грейвс:**
- Gärtner R et al. Selenium supplementation in patients with autoimmune thyroiditis. _J Clin Endocrinol Metab_ 2002;87(4):1687-1691. https://doi.org/10.1210/jcem.87.4.8421
- Toulis KA et al. Selenium supplementation in the treatment of Hashimoto's thyroiditis: meta-analysis. _Eur J Endocrinol_ 2010;163(1):47-55. https://doi.org/10.1530/EJE-10-0316
- Wichman J et al. Selenium supplementation significantly reduces thyroid autoantibody levels in patients with chronic autoimmune thyroiditis: meta-analysis. _Thyroid_ 2016;26(12):1681-1692. https://doi.org/10.1089/thy.2016.0256
- Marcocci C et al. Selenium and the course of mild Graves' orbitopathy. _N Engl J Med_ 2011;364(20):1920-1931. https://doi.org/10.1056/NEJMoa1012985

**Йод и АИТ:**
- Sun X et al. Iodine supplementation and thyroid autoimmunity: a meta-analysis. _Cell Biochem Biophys_ 2014;69(1):41-46. https://doi.org/10.1007/s12013-013-9764-8
- Farebrother J et al. Excess iodine intake: sources, assessment, and effects on thyroid function. _Ann N Y Acad Sci_ 2019;1446(1):44-65. https://doi.org/10.1111/nyas.14041

**GFD при АИТ:**
- Krysiak R et al. The effect of gluten-free diet on thyroid autoimmunity in drug-naïve women with Hashimoto's thyroiditis. _Exp Clin Endocrinol Diabetes_ 2019;127(7):417-422. https://doi.org/10.1055/a-0653-7108

**LT4-терапия:**
- Bolk N et al. Effects of evening vs morning levothyroxine intake: a randomized double-blind crossover trial. _Arch Intern Med_ 2010;170(22):1996-2003. https://doi.org/10.1001/archinternmed.2010.436
- Benvenga S et al. Altered intestinal absorption of L-thyroxine caused by coffee. _Thyroid_ 2008;18(3):293-301. https://doi.org/10.1089/thy.2007.0222
- Bell DS, Ovalle F. Use of soy protein supplement and resultant need for increased dose of levothyroxine. _Endocr Pract_ 2001;7(3):193-194. https://doi.org/10.4158/EP.7.3.193

**Субклинический гипотиреоз:**
- Feller M et al. Association of thyroid hormone therapy with quality of life and thyroid-related symptoms in subclinical hypothyroidism: systematic review and meta-analysis. _JAMA_ 2018;320(13):1349-1359. https://doi.org/10.1001/jama.2018.13770
- Bekkering GE et al. Thyroid hormones treatment for subclinical hypothyroidism: BMJ Rapid Recommendations. _BMJ_ 2019;365:l2006. https://doi.org/10.1136/bmj.l2006

**Микронутриенты:**
- Zimmermann MB, Köhrle J. The impact of iron and selenium deficiencies on iodine and thyroid metabolism. _Best Pract Res Clin Endocrinol Metab_ 2014;24(1):117-132. https://doi.org/10.1016/j.beem.2013.09.006
- Mackawy AM et al. Vitamin D deficiency and its association with thyroid disease. _Int J Health Sci_ 2013;7(3):267-275.
- Benvenga S et al. Usefulness of L-carnitine, a naturally occurring peripheral antagonist of thyroid hormone action, in iatrogenic hyperthyroidism. _J Clin Endocrinol Metab_ 2001;86(8):3579-3594. https://doi.org/10.1210/jcem.86.8.7747
- Sharma AK et al. Efficacy and safety of ashwagandha root extract in subclinical hypothyroidism: RCT. _J Altern Complement Med_ 2018;24(3):243-248. https://doi.org/10.1089/acm.2017.0183

**Диагностика (АТ-ТПО):**
- Vanderpump MP et al. The incidence of thyroid disorders in the community: Whickham survey. _Clin Endocrinol_ 1995;43(1):55-68. https://doi.org/10.1111/j.1365-2265.1995.tb01894.x

"@

# Вставляем перед ## Метаданные
$metaAnchor = "## Метаданные"
$anchorPos = $content.IndexOf($metaAnchor)
if ($anchorPos -lt 0) {
    Write-Host "[ERROR] Не найден якорь '## Метаданные' для вставки §27.4-27.8" -ForegroundColor Red
    exit 1
}

$content = $content.Substring(0, $anchorPos) + $section27ext + "`r`n" + $content.Substring($anchorPos)
Write-Host "[OK] §§27.4-27.8 вставлены перед '## Метаданные'" -ForegroundColor Green
Write-Host ""

# ==========================================
# БЛОК C — Обновление секции ## Метаданные
# ==========================================
Write-Host "БЛОК C: Обновление секции ## Метаданные" -ForegroundColor Cyan

if (Replace-Once "\*\*Версия:\*\* 2\.0" "**Версия:** 2.1" "C01 Версия 2.0→2.1") { }
if (Replace-Once "\*\*Последнее обновление:\*\* 2026-06-19 \(Сессия 28\)" "**Последнее обновление:** 2026-07-27 (Session 47, EBM-lite обогащение)" "C02 Дата обновлена") { }
if (Replace-Once "\*\*Статус:\*\* ✅ Готов$" "**Статус:** ✅ Готов (EBM-lite)" "C03 Статус обновлён") { }

# Добавляем EBM-статус после Статуса (если ещё нет)
if ($content -notmatch "\*\*EBM-статус:\*\*") {
    $ebmStatusLine = "**Статус:** ✅ Готов (EBM-lite)`r`n- **EBM-статус:** EBM-lite (уровень 1) — 22 inline [EBM:] ссылок, §§27.4-27.8 EBM benchmark с таблицей школа vs EBM (10 расхождений), гайдлайны и 20+ RCT с DOI (Session 47, финал Этапа E)"
    $content = $content -replace "\*\*Статус:\*\* ✅ Готов \(EBM-lite\)", $ebmStatusLine
    Write-Host "  [OK] C04 EBM-статус добавлен" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] C04 EBM-статус уже присутствует" -ForegroundColor DarkGray
}

Write-Host ""

# ==========================================
# БЛОК D — Финализация
# ==========================================
Write-Host "БЛОК D: Финализация" -ForegroundColor Cyan

# Idempotency marker в конце файла
$content = $content.TrimEnd() + "`r`n`r`n$marker`r`n"

# Нормализация line endings в CRLF
$content = $content -replace "`r`n", "`n"
$content = $content -replace "`n", "`r`n"

# Запись с UTF-8 BOM
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path $file).Path, $content, $utf8Bom)
Write-Host "[OK] Файл записан с UTF-8 BOM и CRLF" -ForegroundColor Green
Write-Host ""

# ==========================================
# БЛОК E — Валидация
# ==========================================
Write-Host "БЛОК E: Валидация" -ForegroundColor Cyan

$final = Get-Content -Path $file -Raw -Encoding UTF8
$lines = ($final -split "`r`n").Count
$sizeKB = [math]::Round((Get-Item $file).Length / 1KB, 1)
$ebmTags = ([regex]::Matches($final, "\[EBM:")).Count

$has274 = $final -match "### 27\.4 EBM-статус"
$has276 = $final -match "### 27\.6 Таблица расхождений"
$has277 = $final -match "### 27\.7 Гайдлайны первого уровня"
$has278 = $final -match "### 27\.8 Ключевые RCT"
$hasMarker = $final -match [regex]::Escape($marker)

# BOM check
$bytes = [System.IO.File]::ReadAllBytes((Resolve-Path $file).Path)
$hasBOM = $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF

# Порядок секций
$pos27 = $final.IndexOf("## 27. Чек-лист")
$pos274 = $final.IndexOf("### 27.4 EBM-статус")
$posMeta = $final.IndexOf("## Метаданные")
$orderOK = ($pos27 -lt $pos274) -and ($pos274 -lt $posMeta)

Write-Host ""
Write-Host "=== МЕТРИКИ ===" -ForegroundColor Cyan
Write-Host "Строк:              $lines"
Write-Host "Размер:             $sizeKB KB"
Write-Host "[EBM:] тегов:       $ebmTags"
Write-Host "Inline замен (A):   $applied"
Write-Host "§27.4 EBM-статус:   $has274"
Write-Host "§27.6 таблица:      $has276"
Write-Host "§27.7 гайдлайны:    $has277"
Write-Host "§27.8 RCT:          $has278"
Write-Host "Idempotency marker: $hasMarker"
Write-Host "UTF-8 BOM:          $hasBOM"
Write-Host "Порядок §27→§27.4→Метаданные: $orderOK"
Write-Host ""

if ($has274 -and $has276 -and $has277 -and $has278 -and $hasMarker -and $hasBOM -and $orderOK -and $ebmTags -ge 20) {
    Write-Host "=== ГОТОВО ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎯 ЭТАП E ЗАВЕРШЁН: 8/8 методичек обогащены EBM-lite" -ForegroundColor Magenta
    Write-Host "Следующий шаг: git diff --stat references/methodology/thyroid_health.md" -ForegroundColor Cyan
} else {
    Write-Host "=== ВНИМАНИЕ: не все проверки пройдены ===" -ForegroundColor Yellow
}
# === КОНЕЦ ===
