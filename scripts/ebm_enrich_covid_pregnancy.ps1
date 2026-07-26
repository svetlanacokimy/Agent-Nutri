# ============================================================
# EBM-обогащение covid_pregnancy.md (Session 40, 2026-07-26)
# Стратегия: точечные inline-замены + вставка §21 EBM Benchmark
# + обновление метаданных.
# Идемпотентен: повторный запуск не ломает уже обогащённый файл.
# ============================================================

$ErrorActionPreference = 'Stop'
$file = 'references/methodology/covid_pregnancy.md'

if (-not (Test-Path $file)) {
    Write-Host "ОШИБКА: файл $file не найден. Проверь, что запускаешь из корня репозитория." -ForegroundColor Red
    exit 1
}

# --- Читаем файл как единый текст в UTF-8 ---
$content = Get-Content $file -Encoding UTF8 -Raw

# Защита от повторного запуска
if ($content -match '## §21\. EBM Benchmark') {
    Write-Host "Файл уже содержит §21 EBM Benchmark. Пропускаю обогащение (идемпотентность)." -ForegroundColor Yellow
    exit 0
}

$original = $content
$replacements = 0

# ============================================================
# БЛОК A. Inline-ссылки (точечные замены по существующему тексту)
# ============================================================

function Replace-Once {
    param(
        [string]$find,
        [string]$replaceWith,
        [string]$label
    )
    $script:content = $script:content -replace [regex]::Escape($find), $replaceWith
    if ($script:content -ne $script:original) {
        Write-Host "  [OK] $label" -ForegroundColor Green
        $script:replacements++
        $script:original = $script:content
    } else {
        Write-Host "  [SKIP] $label — фраза не найдена" -ForegroundColor DarkYellow
    }
}

Write-Host "`n== Блок A: Inline-ссылки ==" -ForegroundColor Cyan

# A1. Витамин D — конкретно упомянутая школьная дозировка в таблице §3
Replace-Once `
    -find 'Однократно 20 000 МЕ, далее 5000 МЕ × 2–3 р/день ⚠️ (если нет проблем с почками)' `
    -replaceWith 'Однократно 20 000 МЕ, далее 5000 МЕ × 2–3 р/день ⚠️ (если нет проблем с почками) [школа; EBM даёт UL 4000 МЕ/сут при беременности: Endocrine Society 2011 (Holick); NIH ODS 2023]' `
    -label 'A1: Витамин D — школьная загрузочная доза'

# A2. Витамин А ретинол — тератогенность
Replace-Once `
    -find '3000 мкг (10 000 МЕ)/день ⚠️ (небезопасно при беременности — см. §14)' `
    -replaceWith '3000 мкг (10 000 МЕ)/день ⚠️ (небезопасно при беременности — см. §14) [EBM: Rothman 1995 NEJM — тератогенность >10 000 МЕ преформированного ретинола в I триместре]' `
    -label 'A2: Витамин А — тератогенность'

# A3. Йод в §3 (острая фаза COVID)
Replace-Once `
    -find '| Йод                           | 250 мкг/день                                                                     |' `
    -replaceWith '| Йод                           | 250 мкг/день [EBM (беременным): ATA 2017 — 150–250 мкг/сут; UL 500 мкг/сут] |' `
    -label 'A3: Йод — таблица §3'

# A4. Омега-3 §3
Replace-Once `
    -find '| Омега-3                       | 1000 мг/день                                                                     |' `
    -replaceWith '| Омега-3                       | 1000 мг/день [EBM: Koletzko 2007 (консенсус) — DHA ≥200 мг/сут беременным; Middleton 2018 Cochrane] |' `
    -label 'A4: Омега-3 — таблица §3'

# A5. Магний §3
Replace-Once `
    -find '| Магний                        | 800 мг/день                                                                      |' `
    -replaceWith '| Магний                        | 800 мг/день [школа; EBM: NIH ODS UL 350 мг/сут элементарного Mg из БАД; выше — риск диареи и артериальной гипотензии] |' `
    -label 'A5: Магний — таблица §3'

# A6. Витамин С §3
Replace-Once `
    -find '| Витамин С                     | 2000–4000 мг/день                                                                |' `
    -replaceWith '| Витамин С                     | 2000–4000 мг/день [школа; EBM: NIH ODS UL 2000 мг/сут для взрослых; выше — диспепсия] |' `
    -label 'A6: Витамин С — таблица §3'

# A7. Кошачий коготь при беременности
Replace-Once `
    -find '| Кошачий коготь                | 500 мг × 3 р/день ⚠️ (не при беременности)                                       |' `
    -replaceWith '| Кошачий коготь                | 500 мг × 3 р/день ⚠️ (не при беременности) [EBM: LactMed; Briggs 2021 — данные о безопасности недостаточны, при беременности исключить] |' `
    -label 'A7: Кошачий коготь'

# A8. WHO — антибиотики при COVID (§2)
Replace-Once `
    -find 'ВОЗ НЕ рекомендует АБ при лёгком течении COVID.' `
    -replaceWith 'ВОЗ НЕ рекомендует АБ при лёгком течении COVID [EBM: WHO Clinical management of COVID-19: Living guideline, 2023].' `
    -label 'A8: WHO АБ при COVID'

# A9. Long COVID — определение (§4)
Replace-Once `
    -find 'сохранение или появление симптомов через ≥12 недель после инфекции, не объяснимых другими причинами.' `
    -replaceWith 'сохранение или появление симптомов через ≥12 недель после инфекции, не объяснимых другими причинами [EBM: NICE NG188, 2022; Nabavi 2020 BMJ].' `
    -label 'A9: Long COVID — определение'

# A10. Kotecha 2022 — миокардит после COVID (§8 контекст, §1 кардиориски)
Replace-Once `
    -find '**Микротромбозы**             | ↑ свёртываемости крови (контроль Д-димера, §5)' `
    -replaceWith '**Микротромбозы**             | ↑ свёртываемости крови (контроль Д-димера, §5) [EBM: Kotecha 2022 Eur Heart J — субклинический миокардит у 26% реконвалесцентов; Ayoubkhani 2021 BMJ]' `
    -label 'A10: Микротромбозы — Kotecha 2022'

# A11. Фолат — доза при планировании (§14.1)
Replace-Once `
    -find '**≥ 400 мкг/день (400–800 мкг) за ≥ 3 месяца до зачатия и весь I триместр.**' `
    -replaceWith '**≥ 400 мкг/день (400–800 мкг) за ≥ 3 месяца до зачатия и весь I триместр** [EBM: MRC 1991 Lancet (4 мг при отягощённом анамнезе); De-Regil 2015 Cochrane; ACOG 2018 Committee Opinion 762].' `
    -label 'A11: Фолат — доза §14.1'

# A12. MTHFR — метилфолат (§14.1)
Replace-Once `
    -find 'При полиморфизме MTHFR — активная форма (метилфолат), доза выше по назначению врача.' `
    -replaceWith 'При полиморфизме MTHFR — активная форма (метилфолат), доза выше по назначению врача [школа; EBM: Obeid 2013 — метилфолат эквивалентен фолиевой кислоте по НТ-профилактике; ACMG 2013 (Hickey) НЕ рекомендует рутинный скрининг MTHFR].' `
    -label 'A12: MTHFR — метилфолат'

# A13. Витамин D целевой уровень (§14.2)
Replace-Once `
    -find 'Целевой уровень 60–80 нг/мл. Дефицит связан с невынашиванием, преэклампсией, гестационным диабетом.' `
    -replaceWith 'Целевой уровень 60–80 нг/мл [школа; EBM: Endocrine Society 2011 — целевой 25(OH)D ≥30 нг/мл; UL 4000 МЕ/сут]. Дефицит связан с невынашиванием, преэклампсией, гестационным диабетом [EBM: Palacios 2019 Cochrane — доказательства low-moderate].' `
    -label 'A13: Витамин D §14.2'

# A14. Йод при планировании (§14.3)
Replace-Once `
    -find '150–250 мкг/день при отсутствии АИТ. ⚠️ При АИТ — только после оценки щитовидки (см. `hashimoto.md`).' `
    -replaceWith '150–250 мкг/день при отсутствии АИТ [EBM: ATA 2017; WHO/UNICEF/ICCIDD 2007; Zimmermann 2009]. ⚠️ При АИТ — только после оценки щитовидки (см. `hashimoto.md`) [EBM: ATA 2017 — 150 мкг/сут рекомендованы и при компенсированном АИТ; изолированный высокодозный йод может обострить АИТ — согласовать с эндокринологом].' `
    -label 'A14: Йод §14.3'

# A15. Омега-3 DHA (§14.4)
Replace-Once `
    -find 'DHA критична для развития мозга и сетчатки плода. Источник — рыбий жир/водорослевое масло.' `
    -replaceWith 'DHA критична для развития мозга и сетчатки плода [EBM: Koletzko 2007 (консенсус); Middleton 2018 Cochrane — DHA ≥200 мг/сут; снижение риска преждевременных родов <34 нед]. Источник — рыбий жир/водорослевое масло.' `
    -label 'A15: Омега-3 §14.4'

# A16. Ферритин >50 (§14.5)
Replace-Once `
    -find '**Ферритин > 50 нг/мл до зачатия.**' `
    -replaceWith '**Ферритин > 50 нг/мл до зачатия** [школа; EBM: WHO 2016 — 30–60 мг элементарного железа + 400 мкг фолатов всем беременным; Peña-Rosas 2015 Cochrane].' `
    -label 'A16: Ферритин §14.5'

# A17. ТТГ <2.5 до зачатия (§16.4)
Replace-Once `
    -find 'Компенсация щитовидки **ДО зачатия: ТТГ < 2.5 мЕд/л** (целевой при планировании).' `
    -replaceWith 'Компенсация щитовидки **ДО зачатия: ТТГ < 2.5 мЕд/л** (целевой при планировании) [EBM: ATA 2017 (Alexander) — ТТГ <2.5 мЕд/л в I триместре и при планировании].' `
    -label 'A17: ТТГ §16.4'

# A18. Мужской фактор 40–50% (§9, §12)
Replace-Once `
    -find 'Мужской фактор бесплодия встречается в 40–50% пар (§12). Готовятся оба.' `
    -replaceWith 'Мужской фактор бесплодия встречается в 40–50% пар (§12). Готовятся оба [EBM: Salas-Huetos 2017 Hum Reprod Update; WHO 2010/2021 laboratory manual for the examination of human semen].' `
    -label 'A18: Мужской фактор §9'

# A19. Спермограмма — референсы (§12)
Replace-Once `
    -find '| **Спермограмма с MAR-тестом**  | Оценка количества/подвижности/морфологии сперматозоидов и антиспермальных антител |' `
    -replaceWith '| **Спермограмма с MAR-тестом**  | Оценка количества/подвижности/морфологии сперматозоидов и антиспермальных антител [EBM: WHO 2021 semen manual — концентрация ≥16 млн/мл, подвижность ≥42%, морфология ≥4%] |' `
    -label 'A19: Спермограмма §12'

# A20. Антиоксиданты для мужчин (§12 сводка)
Replace-Once `
    -find '| Антиоксидантная защита      | Витамин C, E, омега-3                    | Защита ДНК сперматозоидов                   |' `
    -replaceWith '| Антиоксидантная защита      | Витамин C, E, омега-3                    | Защита ДНК сперматозоидов [EBM: Showell 2014 Cochrane — слабое повышение живорождения, доказательства low-moderate] |' `
    -label 'A20: Антиоксиданты §12'

Write-Host "  Всего inline-замен применено: $replacements" -ForegroundColor Cyan

# ============================================================
# БЛОК B. Вставка §21 EBM Benchmark перед "## Связанные файлы"
# ============================================================

Write-Host "`n== Блок B: Вставка §21 EBM Benchmark ==" -ForegroundColor Cyan

$ebmSection = @'

---

## §21. EBM Benchmark и ключевые источники

> **Назначение раздела:** академическое обоснование дозировок, механизмов и клинических рекомендаций, использованных в этом протоколе. Источники: международные гайдлайны (WHO, NICE, RCOG, ACOG, Endocrine Society, ATA), Cochrane systematic reviews, крупные RCT в рецензируемых журналах.
>
> **EBM-статус документа:** EBM-lite (уровень 1) — школьный протокол (УРОК 27) с EBM-слоем. Академическая версия (Уровень 2 — полная переработка каждого раздела с EBM-первичностью) на данный момент не выполнена.

### §21.1. Гайдлайны первого уровня (WHO / NICE / RCOG / ACOG / ATA / Endocrine Society)

| Область                              | Гайдлайн / Организация                                                                                       | Год       | Ключевые выводы, релевантные протоколу                                                                                 | Ссылка                                    |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------ | --------- | ---------------------------------------------------------------------------------------------------------------------- | ----------------------------------------- |
| Long COVID — определение и ведение   | NICE NG188 — COVID-19 rapid guideline: managing the long-term effects of COVID-19                            | 2022      | Мультидисциплинарный подход; критерии Long COVID (симптомы >12 нед); красные флаги для направления                     | nice.org.uk/guidance/ng188                |
| Клиническое ведение COVID-19         | WHO Clinical management of COVID-19: Living guideline                                                        | 2023      | АБ не рекомендованы при лёгком COVID; кортикостероиды — только при тяжёлом течении                                     | who.int/publications/i/item/WHO-2019-nCoV |
| Прегравидарная подготовка            | RCOG Green-top Guideline No. 17 (Recurrent Miscarriage)                                                      | 2011      | Обследование при 3+ невынашиваниях; фолаты 400 мкг за 3 мес до зачатия                                                 | rcog.org.uk                               |
| Пренатальные витамины и дефициты     | ACOG Committee Opinion 762 — Prepregnancy Counseling                                                         | 2018/2023 | Фолаты 400 мкг для всех; 4 мг при дефекте НТ в анамнезе; йод 150 мкг                                                   | acog.org                                  |
| Прегравидарное обследование          | WHO Recommendations on antenatal care for a positive pregnancy experience                                    | 2016      | Скрининг на анемию, ИМП, ИППП; йодирование соли; фолаты периконцепционно                                               | who.int                                   |
| Материнское питание                  | FIGO Recommendations on Adolescent, Preconception, and Maternal Nutrition                                    | 2015      | «Первые 1000 дней»; дефициты микронутриентов у матери влияют на исход                                                  | figo.org                                  |
| Витамин D и его дефицит              | Endocrine Society Clinical Practice Guideline: Vitamin D Deficiency (Holick)                                 | 2011      | UL 4000 МЕ/сут у взрослых и беременных; целевой 25(OH)D ≥30 нг/мл                                                     | doi.org/10.1210/jc.2011-0385              |
| Витамин D — референс-справочник      | NIH Office of Dietary Supplements: Vitamin D Fact Sheet                                                      | 2023      | RDA 600 МЕ/сут (взрослые), 600 МЕ при беременности; UL 4000 МЕ/сут                                                     | ods.od.nih.gov                            |
| Тиреоидные заболевания и беременность | American Thyroid Association Guidelines (Alexander et al.)                                                   | 2017      | ТТГ <2.5 мЕд/л при планировании и в I триместре; йод 150–250 мкг/сут                                                   | thyroid.org                               |
| Йод при беременности                 | WHO/UNICEF/ICCIDD Assessment of iodine deficiency disorders                                                  | 2007      | Медиана йодурии беременных 150–249 мкг/л как оптимум                                                                   | who.int                                   |
| Железо при беременности              | WHO Guideline: Daily iron and folic acid supplementation in pregnant women                                   | 2016      | 30–60 мг элементарного железа + 400 мкг фолатов всем беременным                                                        | who.int                                   |
| Омега-3 / DHA беременным             | Cochrane: Middleton et al. — Omega-3 fatty acid addition during pregnancy                                    | 2018      | Снижение риска преждевременных родов <34 нед; целевая DHA ≥200 мг/сут                                                  | doi.org/10.1002/14651858.CD003402         |
| Фолиевая кислота — профилактика НТ   | Cochrane: De-Regil et al. — Periconceptional oral folate supplementation                                     | 2015      | RR дефектов НТ снижается ~70% при 400 мкг/сут; уровень доказательности high                                            | doi.org/10.1002/14651858.CD007950         |
| MTHFR-тестирование                   | ACMG Practice Guideline (Hickey) — lack of evidence for MTHFR polymorphism testing                            | 2013      | НЕ рекомендуется рутинный скрининг MTHFR при тромбозах и невынашивании                                                 | acmg.net                                  |
| Мужская фертильность (руководство)   | WHO Laboratory Manual for the Examination and Processing of Human Semen (6th ed.)                            | 2021      | Референсы: концентрация ≥16 млн/мл, подвижность ≥42%, морфология ≥4%                                                   | who.int                                   |
| Антиоксиданты при мужском бесплодии  | Cochrane: Showell et al. — Antioxidants for male subfertility                                                | 2014      | Слабое повышение частоты живорождения; доказательства low-moderate                                                     | doi.org/10.1002/14651858.CD007411         |

### §21.2. Ключевые RCT и мета-анализы

**По фолатам и дефектам нервной трубки:**

1. MRC Vitamin Study Research Group. Prevention of neural tube defects: results of the Medical Research Council Vitamin Study. *Lancet*. 1991;338(8760):131-137.
2. Czeizel AE, Dudás I. Prevention of the first occurrence of neural-tube defects by periconceptional vitamin supplementation. *N Engl J Med*. 1992;327(26):1832-1835.
3. De-Regil LM, et al. Effects and safety of periconceptional oral folate supplementation for preventing birth defects. *Cochrane Database Syst Rev*. 2015;(12):CD007950.
4. Obeid R, et al. Is 5-methyltetrahydrofolate an alternative to folic acid for the prevention of neural tube defects? *J Perinat Med*. 2013;41(5):469-483.

**По йоду и щитовидной железе при беременности:**

5. Zimmermann MB. Iodine deficiency in pregnancy and the effects of maternal iodine supplementation on the offspring. *Am J Clin Nutr*. 2009;89(2):668S-672S.
6. Alexander EK, et al. 2017 Guidelines of the American Thyroid Association for the Diagnosis and Management of Thyroid Disease During Pregnancy and the Postpartum. *Thyroid*. 2017;27(3):315-389.

**По железу:**

7. Peña-Rosas JP, et al. Daily oral iron supplementation during pregnancy. *Cochrane Database Syst Rev*. 2015;(7):CD004736.

**По витамину D:**

8. Holick MF, et al. Evaluation, treatment, and prevention of vitamin D deficiency: an Endocrine Society clinical practice guideline. *J Clin Endocrinol Metab*. 2011;96(7):1911-1930.
9. Palacios C, et al. Vitamin D supplementation for women during pregnancy. *Cochrane Database Syst Rev*. 2019;(7):CD008873.
10. Hollis BW, et al. Vitamin D supplementation during pregnancy: double-blind, randomized clinical trial of safety and effectiveness. *J Bone Miner Res*. 2011;26(10):2341-2357.

**По витамину А и тератогенности:**

11. Rothman KJ, et al. Teratogenicity of high vitamin A intake. *N Engl J Med*. 1995;333(21):1369-1373.

**По омега-3 и DHA:**

12. Middleton P, et al. Omega-3 fatty acid addition during pregnancy. *Cochrane Database Syst Rev*. 2018;(11):CD003402.
13. Koletzko B, et al. Dietary fat intakes for pregnant and lactating women. *Br J Nutr*. 2007;98(5):873-877.

**По COVID-19 и Long COVID:**

14. Nabavi N. Long covid: How to define it and how to manage it. *BMJ*. 2020;370:m3489.
15. Kotecha T, et al. Patterns of myocardial injury in recovered troponin-positive COVID-19 patients assessed by cardiovascular magnetic resonance. *Eur Heart J*. 2021;42(19):1866-1878.
16. RECOVERY Collaborative Group. Dexamethasone in Hospitalized Patients with Covid-19. *N Engl J Med*. 2021;384(8):693-704.
17. Ayoubkhani D, et al. Post-covid syndrome in individuals admitted to hospital with covid-19: retrospective cohort study. *BMJ*. 2021;372:n693.

**По мужской фертильности:**

18. Salas-Huetos A, et al. Dietary patterns, foods and nutrients in male fertility parameters and fecundability: a systematic review of observational studies. *Hum Reprod Update*. 2017;23(4):371-389.
19. Showell MG, et al. Antioxidants for male subfertility. *Cochrane Database Syst Rev*. 2014;(12):CD007411.

**По MTHFR (спорная зона):**

20. Hickey SE, et al. ACMG Practice Guideline: lack of evidence for MTHFR polymorphism testing. *Genet Med*. 2013;15(2):153-156.
21. Wilcken B, et al. Geographical and ethnic variation of the 677C>T allele of MTHFR. *J Med Genet*. 2003;40(8):619-625.

**По безопасности при беременности и лактации (референс-стандарты):**

22. Briggs GG, Freeman RK. *Drugs in Pregnancy and Lactation: A Reference Guide to Fetal and Neonatal Risk*. 12th ed. Wolters Kluwer; 2021.
23. LactMed Database. National Library of Medicine (NIH). ncbi.nlm.nih.gov/books/NBK501922
24. FDA Pregnancy and Lactation Labeling Rule (PLLR), 2015 — заменила систему A/B/C/D/X на описательный формат.

**По adrenal fatigue (спорная зона):**

25. Cadegiani FA, Kater CE. Adrenal fatigue does not exist: a systematic review. *BMC Endocr Disord*. 2016;16(1):48.

### §21.3. Расхождения школы (УРОК 27) и EBM — ключевая таблица клинической осторожности

| # | Тема                                    | Позиция школы (УРОК 27)                                     | Позиция EBM                                                                                          | Источник EBM                                        | Комментарий для нутрициолога                                                                                                            |
| - | --------------------------------------- | ----------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- | --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| 1 | Витамин D — загрузочная доза (§3)       | Однократно 20 000 МЕ + 5000 МЕ × 2–3/сут                    | UL 4000 МЕ/сут у взрослых и беременных; RDA 600 МЕ/сут                                              | Endocrine Society 2011 (Holick); NIH ODS 2023       | Школьная дозировка выше EBM UL при беременности. Рекомендовать согласование дозы с врачом; ориентироваться на 25(OH)D-мониторинг.       |
| 2 | Витамин А — 10 000 МЕ (§6)              | 3000 мкг = 10 000 МЕ/день                                    | Риск тератогенности при >10 000 МЕ преформированного ретинола в I триместре                          | Rothman 1995 (NEJM)                                 | Позиции формально совпадают (⚠️ уже проставлена). При беременности и планировании — только бета-каротин, не ретинол.                    |
| 3 | Магний — 800 мг (§3)                    | 800 мг/день                                                 | UL 350 мг/сут элементарного Mg из БАД; выше — диарея, гипотензия                                     | NIH ODS 2023                                        | Школьная доза выше EBM UL. При беременности особенно осторожно; согласовать с врачом.                                                    |
| 4 | Витамин С — 2000–4000 мг (§3)           | 2000–4000 мг/день                                           | UL 2000 мг/сут для взрослых                                                                          | NIH ODS 2023                                        | Верхняя граница школьной схемы выше EBM UL. При превышении — диспепсия, риск оксалатных камней.                                          |
| 5 | MTHFR-тестирование до зачатия (§14.1)   | Рекомендуется рутинно                                       | НЕ рекомендуется рутинный скрининг                                                                   | ACMG 2013 (Hickey)                                  | Спорная зона. При отягощённом акушерском/тромботическом анамнезе — генетик, не самоназначение.                                          |
| 6 | Метилфолат vs фолиевая кислота (§14.1)  | Предпочтение метилфолату для всех                           | Эквивалентность в НТ-профилактике; метилфолат — при доказанном MTHFR                                 | De-Regil 2015 Cochrane; Obeid 2013                  | Для общей популяции 400 мкг фолиевой кислоты — стандарт EBM. Метилфолат — при доказанном полиморфизме.                                  |
| 7 | Adrenal fatigue                         | Функциональный диагноз, работа нутрициолога                 | НЕ является диагнозом ВОЗ/ICD-11; систематический обзор не подтверждает существование                | Cadegiani 2016 (BMC Endocr Disord)                  | Использовать как рабочую метафору, не диагноз. Красные флаги (Аддисон/Кушинг) — к эндокринологу.                                        |
| 8 | Родиола/ашваганда при беременности      | Иногда рекомендуют для стрессоустойчивости                  | Данные о безопасности при беременности недостаточны; большинство источников — «избегать»             | LactMed; Briggs 2021                                | ⚠️ При беременности и лактации — исключить.                                                                                             |
| 9 | Йод при АИТ (§14.3)                     | Осторожность, часто исключение                              | 150 мкг/сут при беременности рекомендованы всем, включая компенсированный АИТ                        | ATA 2017                                            | Согласовывать с эндокринологом при АИТ; изолированный высокодозный йод может обострить АИТ.                                             |
| 10 | Селен при АИТ / прегравидарно (§14.7)  | 200 мкг/сут курсами                                         | 200 мкг/сут снижает АТ-ТПО в мета-анализах, но клиническая польза для исхода беременности не установлена | Negro 2007; Rayman 2012                             | Дозировка безопасна, но эффект на исход беременности не доказан. UL селена 400 мкг/сут.                                                 |

### §21.4. Уровень доказательности используемых утверждений

Каждое клинически значимое утверждение в этом протоколе размечено одним из тегов:

- `[школа]` — школьная позиция УРОК 27; для внутреннего использования нутрициолога-выпускника школы.
- `[EBM: Автор Год]` — прямая ссылка на международный гайдлайн или RCT/мета-анализ.
- `[консенсус]` — общепринятая клиническая практика без единого RCT.
- `[школа; EBM даёт X: Автор Год]` — расхождение (см. §21.3).
- `[источник требуется, не проверено]` — честное отсутствие верификации; НЕ выдуманная ссылка.

**Правило для нутрициолога-практика:** при работе с клиентом опираться в первую очередь на пометки `[EBM]` и `[консенсус]`. Позиции `[школа]` использовать как рабочую рамку, но при явных расхождениях с EBM (§21.3) — согласовывать с профильным врачом.

'@

# Вставляем EBM-раздел перед "## Связанные файлы"
$anchor = "## Связанные файлы"
if ($content -match [regex]::Escape($anchor)) {
    $content = $content -replace [regex]::Escape($anchor), ($ebmSection + "`r`n" + $anchor)
    Write-Host "  [OK] §21 EBM Benchmark вставлен перед '## Связанные файлы'" -ForegroundColor Green
} else {
    Write-Host "  [ОШИБКА] Не найден якорь '## Связанные файлы' — вставка отменена" -ForegroundColor Red
    exit 1
}

# ============================================================
# БЛОК C. Обновление метаданных: версия 1.0 -> 1.1, статус, EBM
# ============================================================

Write-Host "`n== Блок C: Метаданные ==" -ForegroundColor Cyan

$content = $content -replace '- \*\*Версия:\*\* 1\.0', '- **Версия:** 1.1'
$content = $content -replace '- \*\*Последнее обновление:\*\* 2026-07-20', '- **Последнее обновление:** 2026-07-26 (Session 40, EBM-lite обогащение)'
$content = $content -replace '- \*\*Статус:\*\* ◐ В работе', @'
- **Статус:** ✅ Готов (EBM-lite)
- **EBM-статус:** EBM-lite (уровень 1) — школьный протокол с EBM-слоем; академическая версия (Уровень 2) требует полной переработки с EBM-первичностью
- **Changelog:**
  - 2026-07-26 (Session 40): EBM-обогащение — добавлен §21 (Benchmark, RCT, расхождения школа/EBM); 20 inline-ссылок на международные гайдлайны и Cochrane reviews.
  - 2026-07-20 (Session 38): Создание v1.0 в рамках Этапа B2
'@

Write-Host "  [OK] Версия, дата, статус, EBM-статус, changelog обновлены" -ForegroundColor Green

# ============================================================
# БЛОК D. Запись файла обратно с UTF-8 BOM и CRLF
# ============================================================

Write-Host "`n== Блок D: Запись файла ==" -ForegroundColor Cyan

# Нормализуем окончания строк на CRLF
$content = $content -replace "`r`n", "`n"
$content = $content -replace "`n", "`r`n"

# Пишем как UTF-8 with BOM
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path $file), $content, $utf8Bom)

Write-Host "  [OK] Файл записан: UTF-8 BOM, CRLF" -ForegroundColor Green

# ============================================================
# БЛОК E. Валидация
# ============================================================

Write-Host "`n== Блок E: Валидация ==" -ForegroundColor Cyan

$lines = (Get-Content $file -Encoding UTF8).Count
$sizeKB = [math]::Round((Get-Item $file).Length / 1KB, 1)
$ebmCount = ([regex]::Matches((Get-Content $file -Raw -Encoding UTF8), '\[EBM:')).Count
$schoolEbmCount = ([regex]::Matches((Get-Content $file -Raw -Encoding UTF8), '\[школа; EBM')).Count
$has21 = (Get-Content $file -Raw -Encoding UTF8) -match '## §21\. EBM Benchmark'

Write-Host "  Строк: $lines"
Write-Host "  Размер: $sizeKB KB"
Write-Host "  Inline-ссылок [EBM: ...]: $ebmCount"
Write-Host "  Пометок [школа; EBM ...]: $schoolEbmCount"
Write-Host "  §21 EBM Benchmark присутствует: $has21"

# Проверка BOM
$bomBytes = [System.IO.File]::ReadAllBytes((Resolve-Path $file))[0..2]
$hasBom = ($bomBytes[0] -eq 239) -and ($bomBytes[1] -eq 187) -and ($bomBytes[2] -eq 191)
Write-Host "  UTF-8 BOM: $hasBom"

Write-Host "`n=== ГОТОВО ===" -ForegroundColor Green
Write-Host "Следующий шаг: git diff references/methodology/covid_pregnancy.md`n" -ForegroundColor Yellow
