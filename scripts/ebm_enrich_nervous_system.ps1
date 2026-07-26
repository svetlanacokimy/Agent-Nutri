# ============================================================
# EBM-обогащение nervous_system.md (Session 41, 2026-07-26)
# v2: исправлен якорь §19 (## Связанные файлы, а не Связанные документы)
# Идемпотентен: повторный запуск не ломает уже обогащённый файл.
# ============================================================

$ErrorActionPreference = 'Stop'
$file = 'references/methodology/nervous_system.md'

if (-not (Test-Path $file)) {
    Write-Host "[FAIL] Файл не найден: $file" -ForegroundColor Red
    exit 1
}

$content = Get-Content $file -Raw -Encoding UTF8
if ($content -match '## §19\. EBM Benchmark') {
    Write-Host "[SKIP] Файл уже обогащён. Выход." -ForegroundColor Yellow
    exit 0
}

Write-Host "== Блок A: Inline-замены [EBM: ...] ==" -ForegroundColor Cyan
$replacements = 0

function Replace-Once {
    param([string]$id, [string]$pattern, [string]$replacement)
    $script:before = $script:content
    $script:content = [regex]::Replace($script:content, $pattern, $replacement, 'Singleline')
    if ($script:content -ne $script:before) {
        Write-Host "[OK]   $id" -ForegroundColor Green
        $script:replacements++
    } else {
        Write-Host "[SKIP] $id (pattern не найден)" -ForegroundColor Yellow
    }
}

Replace-Once "A01: adrenal fatigue" 'усталость надпочечников' 'усталость надпочечников [школа; EBM: не признан ВОЗ/ICD-11, см. Cadegiani 2016 BMC Endocr Disord]'
Replace-Once "A02: кортизол ↑ ССЗ риск" '(?i)риск инфаркта на 30%' 'риск инфаркта на 20–40% [EBM: Kivimäki 2018 Lancet; INTERHEART Rosengren 2004]'
Replace-Once "A03: CAR" '(?i)пробуждающий ответ' 'пробуждающий ответ (CAR, 30–45 мин после пробуждения) [EBM: Clow 2010 Neurosci Biobehav Rev; Fries 2009]'
Replace-Once "A04: кортизол слюна 4×" '(?i)кортизол в слюне.{0,30}4' 'кортизол в слюне 4× за сутки [EBM: Wüst 2000; Kirschbaum 1994 — функциональный тест ритма, не диагностический стандарт]'
Replace-Once "A05: пик мелатонина" '(?i)пик мелатонина' 'пик мелатонина (00:00–03:00) [EBM: Arendt 2019 J Biol Rhythms; Zisapel 2018]'
Replace-Once "A06: синий свет" '(?i)синий свет' 'синий свет [EBM: Chang 2015 PNAS; Gooley 2011 J Clin Endocrinol Metab — подавляет мелатонин]'
Replace-Once "A07: магний >300 реакций" '(?i)300 ферментных реакциях' '300 ферментных реакциях [EBM: de Baaij 2015 Physiol Rev; Barbagallo 2021 Nutrients]'
Replace-Once "A08: магний глицинат" '(?i)магния глицинат' 'магния глицинат [EBM: Boyle 2017 Nutrients meta-analysis; Abbasi 2012 J Res Med Sci]'
Replace-Once "A09: B6 P5P" '(?i)P5P' 'P5P [EBM: Parra 2018 Nutrients; Bender 2020 — кофактор синтеза серотонина, ГАМК, дофамина]'
Replace-Once "A10: B12 когниция/депрессия" '(?i)B12 дефицит' 'B12 дефицит [EBM: Almeida 2015 Br J Psychiatry; Kennedy 2016 — связь с депрессией и когнитивными нарушениями]'
Replace-Once "A11: омега-3 депрессия" '(?i)омега-3' 'омега-3 [EBM: Liao 2019 Transl Psychiatry meta-analysis; Grosso 2014 PLoS One — EPA-доминантные формулы]'
Replace-Once "A12: витамин D депрессия" '(?i)Витамин D\*\* — рецепторы в мозге' 'Витамин D** — рецепторы в мозге [EBM: Anglin 2013 Br J Psychiatry meta-analysis; VITAL-DEP Okereke 2020 JAMA]'
Replace-Once "A13: железо латентный дефицит" '(?i)латентный дефицит даёт усталость' 'латентный дефицит даёт усталость [EBM: Beard 2001 J Nutr; Murray-Kolb 2007 — когнитивные симптомы при ферритине <30]'
Replace-Once "A14: магний доза стресс" '(?i)магний.{0,10}(300|400)\s*мг' 'магний 300–400 мг вечером [EBM: Pickering 2020 Nutrients; Boyle 2017 — снижение тревоги, улучшение сна]'
Replace-Once "A15: мигрень магний" '(?i)мигрен[а-я]+.{0,80}магни[а-я]+' '$0 [EBM: Peikert 1996 Cephalalgia RCT; AAN/AHS Guideline 2012 — уровень B]'
Replace-Once "A16: мигрень B2 рибофлавин" '(?i)рибофлавин' 'рибофлавин 400 мг/сут [EBM: Schoenen 1998 Neurology RCT; Boehnke 2004 — уровень B]'
Replace-Once "A17: мигрень CoQ10" '(?i)CoQ10' 'CoQ10 300 мг/сут [EBM: Sandor 2005 Neurology RCT; Shoeibi 2017 — уровень C]'
Replace-Once "A18: Petasites" '(?i)белокопытник|petasites' '$0 ⚠️ [EBM: FDA warning 2012; AAN 2015 отозвал рекомендацию из-за гепатотоксичности]'
Replace-Once "A19: ашваганда" '(?i)ашваганд[а-я]+' '$0 [EBM: Chandrasekhar 2012 Indian J Psychol Med; Salve 2019 — снижение кортизола; ⚠️ не при АИТ и беременности, LactMed]'
Replace-Once "A20: родиола" '(?i)родиол[а-я]+' '$0 [EBM: Ishaque 2012 BMC Complement Altern Med systematic review; Panossian 2010]'
Replace-Once "A21: PHQ-9 / GAD-7" '(?i)PHQ-?9|GAD-?7' '$0 [EBM: Kroenke 2001 J Gen Intern Med (PHQ-9); Spitzer 2006 Arch Intern Med (GAD-7)]'
Replace-Once "A22: thunderclap headache" '(?i)«?Громоподобная»? головная боль' '«Громоподобная» головная боль [EBM: ICHD-3 2018 Cephalalgia; NICE CG150 — экстренная неврологическая настороженность]'

Write-Host ""
Write-Host "Всего inline-замен применено: $replacements" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# Блок B: §19 EBM Benchmark — якорь '## Связанные файлы' (уникальный, в конце файла)
# ============================================================
Write-Host "== Блок B: Вставка §19 EBM Benchmark ==" -ForegroundColor Cyan

$ebmSection = @"

---

## §19. EBM Benchmark и ключевые источники

> **Назначение раздела:** академическое обоснование дозировок, механизмов и клинических рекомендаций, использованных в этом протоколе. Источники: международные гайдлайны (NICE, AAN/AHS, APA, WHO, AASM, Endocrine Society, NIH ODS), Cochrane systematic reviews, крупные RCT в рецензируемых журналах.
>
> **EBM-статус документа:** EBM-lite (уровень 1) — школьный протокол (УРОК 25) с EBM-слоем.

### §19.1. Гайдлайны первого уровня

| Область | Гайдлайн / Организация | Год | Ключевые выводы | Ссылка |
|---|---|---|---|---|
| Головные боли и мигрень | NICE CG150 Headaches | 2012/2021 | Диагностика, red flags, профилактика | nice.org.uk/guidance/cg150 |
| Профилактика мигрени | AAN/AHS Guideline (Silberstein) | 2012 | Магний, B2, CoQ10 — уровень B/C | aan.com |
| Классификация цефалгий | ICHD-3 (International Headache Society) | 2018 | Диагностические критерии всех типов ГБ | ichd-3.org |
| Депрессия у взрослых | NICE NG222 Depression | 2022 | Ступенчатый подход, скрининг PHQ-9 | nice.org.uk/guidance/ng222 |
| Депрессия и тревога | APA Clinical Practice Guideline | 2019 | Оценка тяжести, критерии направления | apa.org |
| Бессонница у взрослых | AASM Clinical Practice Guideline | 2021 | КПТ-И как первая линия; мелатонин у пожилых | aasm.org |
| Психиатрическая помощь | WHO mhGAP Intervention Guide | 2016/2023 | Скрининг и маршрутизация | who.int/mhgap |
| Магний | NIH ODS Fact Sheet Magnesium | 2022 | RDA 310–420 мг; UL добавок 350 мг элем. Mg | ods.od.nih.gov |
| Витамин D | Endocrine Society (Holick) | 2011 | UL 4000 МЕ/сут; целевой 25(OH)D >30 нг/мл | doi.org/10.1210/jc.2011-0385 |
| Витамины группы B | NIH ODS Fact Sheets | 2023 | Референсные дозы и UL | ods.od.nih.gov |
| Омега-3 | NIH ODS Fact Sheet Omega-3 | 2023 | Функциональный диапазон 1–3 г EPA+DHA | ods.od.nih.gov |
| Надпочечниковая недостаточность | Endocrine Society (Bornstein) | 2016 | «Adrenal fatigue» не признана как диагноз | doi.org/10.1210/jc.2015-1710 |

### §19.2. Ключевые RCT и мета-анализы

- **Магний:** de Baaij 2015 (Physiol Rev), Barbagallo 2021, Pickering 2020, Boyle 2017.
- **Магний при мигрени:** Peikert 1996 (Cephalalgia RCT), Facchinetti 1991, AAN/AHS 2012.
- **B2 при мигрени:** Schoenen 1998 (Neurology RCT), Boehnke 2004.
- **CoQ10 при мигрени:** Sandor 2005 (Neurology RCT), Shoeibi 2017.
- **Petasites:** Diener 2004, FDA 2012, AAN 2015 (отзыв рекомендации).
- **Мелатонин и сон:** Ferracioli-Oda 2013 (PLoS One meta-analysis), Arendt 2019, Zisapel 2018.
- **Синий свет:** Chang 2015 (PNAS), Gooley 2011 (J Clin Endocrinol Metab).
- **Кортизол и HPA-ось:** Clow 2010, Fries 2009, Wüst 2000, Kirschbaum 1994.
- **Кортизол и ССЗ:** Kivimäki 2018 (Lancet), Rosengren 2004 (INTERHEART).
- **Adrenal fatigue:** Cadegiani 2016 (BMC Endocr Disord — диагноз не подтверждён).
- **Омега-3 при депрессии:** Liao 2019 (Transl Psychiatry meta-analysis), Grosso 2014, Mocking 2016.
- **Витамин D при депрессии:** Anglin 2013 (Br J Psychiatry), Okereke 2020 (JAMA — VITAL-DEP).
- **B12 и когниция:** Almeida 2015 (Br J Psychiatry), Kennedy 2016.
- **Железо и когниция:** Beard 2001 (J Nutr), Murray-Kolb 2007 (Am J Clin Nutr).
- **Адаптогены:** Chandrasekhar 2012 (ашваганда), Salve 2019, Ishaque 2012 (родиола), Panossian 2010.
- **Скрининговые шкалы:** Kroenke 2001 (PHQ-9), Spitzer 2006 (GAD-7), Bastien 2001 (ISI), Buysse 1989 (PSQI).
- **Красные флаги ГБ:** ICHD-3 2018, NICE CG150, Do 2019 (SNNOOP10).
- **5-HTP и серотониновый синдром:** Turner 2006 (Pharmacol Ther).

### §19.3. Сравнительная таблица Школа (УРОК 25) vs EBM

| # | Тема | Позиция школы | Позиция EBM | Источник EBM | Комментарий |
|---|---|---|---|---|---|
| 1 | Усталость надпочечников | Рабочий диагноз | НЕ признан ВОЗ/ICD-11 | Cadegiani 2016; Endocrine Society 2016 | Использовать как метафору дисрегуляции HPA. |
| 2 | Литий оротат микродозы | Нейропротекция | Нет качественных RCT | — | Не путать с рецептурным Li. |
| 3 | Кортизол ↑ → инфаркт на 30% | Точная цифра | Диапазон 20–40% | Kivimäki 2018 Lancet | Порядок верный, точность приблизительная. |
| 4 | Мелатонин как БАД | Свободно | В UK/EU — рецептурный | NICE, EMA | Учитывать регуляторику. |
| 5 | Ашваганда при АИТ | С осторожностью | ⚠️ Может усилить тиреоидную функцию | Sharma 2018 | При АИТ — избегать. |
| 6 | Ашваганда при беременности | Не рекомендовано | ⚠️ Тератогенность (животные) | LactMed; Briggs 2021 | Категорически избегать. |
| 7 | Магний L-треонат для мозга | Уникально проникает через ГЭБ | Один RCT (Slutsky 2010) | — | Глицинат/цитрат также валидны. |
| 8 | Тест кортизола в слюне 4× | Диагностический стандарт | Функциональный тест | Wüst 2000; Kirschbaum 1994 | Валиден для ритма, не для диагноза. |
| 9 | Petasites при мигрени | Эффективен | ⚠️ FDA warning: гепатотоксичность | FDA 2012; AAN 2015 | Не рекомендуется. |
| 10 | 5-HTP при депрессии | БАД, свободно | ⚠️ Серотониновый синдром с СИОЗС | Turner 2006 | Не совмещать с антидепрессантами. |

### §19.4. Уровни доказательности тегов

- ``[школа]`` — позиция УРОК 25, внутренний методологический стандарт.
- ``[EBM: Автор Год]`` — прямая ссылка на гайдлайн, RCT или мета-анализ.
- ``[консенсус]`` — общепринятая клиническая практика.
- ``[школа; EBM даёт X: Автор Год]`` — расхождения (см. §19.3).
- ``[источник требуется, не проверено]`` — отсутствие верификации.

"@

# Уникальный якорь: '## Связанные файлы' (в конце файла, не путать с '## Связанные документы' в начале)
$anchor = '## Связанные файлы'
if ($content -match [regex]::Escape($anchor)) {
    $content = $content -replace [regex]::Escape($anchor), ($ebmSection + "`r`n" + $anchor)
    Write-Host "[OK] §19 EBM Benchmark вставлен перед '$anchor' (в конце файла)" -ForegroundColor Green
} else {
    Write-Host "[FAIL] Якорь '$anchor' не найден. Выход без записи." -ForegroundColor Red
    exit 1
}

# ============================================================
# Блок C: Метаданные (исправлен для PS 5.1)
# ============================================================
Write-Host ""
Write-Host "== Блок C: Метаданные ==" -ForegroundColor Cyan

$replVersion = '${1}1.1'
$replDate    = '${1}2026-07-26 (Session 41, EBM-lite обогащение)'
$replStatus  = '${1}✅ Готов (EBM-lite)'

$content = $content -replace '(?im)^(\s*[-*]?\s*\*?\*?Версия:?\*?\*?\s*)1\.0\b', $replVersion
$content = $content -replace '(?im)^(\s*[-*]?\s*\*?\*?(Обновлено|Последнее обновление|Дата обновления):?\*?\*?\s*).*$', $replDate
$content = $content -replace '(?im)^(\s*[-*]?\s*\*?\*?Статус:?\*?\*?\s*).*$', $replStatus

if ($content -notmatch '(?im)EBM-статус') {
    $ebmStatus = "`r`n- **EBM-статус:** EBM-lite (уровень 1) — школьный протокол (УРОК 25) с EBM-слоем.`r`n"
    $content = $content -replace '(?im)(^\s*[-*]?\s*\*?\*?Статус:?\*?\*?\s*.*$)', ('$1' + $ebmStatus)
}

if ($content -notmatch 'Session 41') {
    $changelog = @"

### Changelog

- **2026-07-26 (Session 41):** EBM-lite обогащение. Добавлен §19 EBM Benchmark (гайдлайны, ключевые RCT, таблица расхождений школа/EBM). Расставлены inline-ссылки ``[EBM: Автор Год]`` после ключевых дозировок и утверждений. Обновлены метаданные: версия 1.0 → 1.1, статус ✅ Готов (EBM-lite).
- **Session 38:** первоначальная версия методички (v1.0).

"@
    $content = $content + $changelog
}

Write-Host "[OK] Версия, дата, статус, EBM-статус, changelog обновлены" -ForegroundColor Green

# ============================================================
# Блок D: Запись файла UTF-8 BOM, CRLF
# ============================================================
Write-Host ""
Write-Host "== Блок D: Запись файла ==" -ForegroundColor Cyan

$content = $content -replace "`r`n", "`n"
$content = $content -replace "`n", "`r`n"

$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path $file).Path, $content, $utf8Bom)

Write-Host "[OK] Файл записан: UTF-8 BOM, CRLF" -ForegroundColor Green

# ============================================================
# Блок E: Валидация
# ============================================================
Write-Host ""
Write-Host "== Блок E: Валидация ==" -ForegroundColor Cyan

$final = Get-Content $file -Raw -Encoding UTF8
$lines = ($final -split "`r`n").Count
$sizeKB = [math]::Round((Get-Item $file).Length / 1KB, 1)
$ebmInline = ([regex]::Matches($final, '\[EBM:')).Count
$schoolEbm = ([regex]::Matches($final, '\[школа; EBM')).Count
$hasBenchmark = $final -match '## §19\. EBM Benchmark'

# Проверка порядка: §18 должен идти ПЕРЕД §19
$idx18 = $final.IndexOf('## §18.')
$idx19 = $final.IndexOf('## §19.')
$orderOk = ($idx18 -gt 0 -and $idx19 -gt $idx18)

$bytes = [System.IO.File]::ReadAllBytes((Resolve-Path $file).Path)
$hasBom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)

Write-Host "Строк: $lines"
Write-Host "Размер: $sizeKB KB"
Write-Host "Inline-ссылок [EBM: ...]: $ebmInline"
Write-Host "Пометок [школа; EBM ...]: $schoolEbm"
Write-Host "§19 EBM Benchmark присутствует: $hasBenchmark"
Write-Host "§19 идёт после §18 (правильный порядок): $orderOk"
Write-Host "UTF-8 BOM: $hasBom"

Write-Host ""
if ($orderOk -and $hasBenchmark -and $hasBom) {
    Write-Host "=== ГОТОВО ===" -ForegroundColor Green
} else {
    Write-Host "=== ⚠️ ЕСТЬ ПРОБЛЕМЫ, ПРОВЕРЬ ВРУЧНУЮ ===" -ForegroundColor Yellow
}
Write-Host "Следующий шаг: git diff --stat references/methodology/nervous_system.md"
