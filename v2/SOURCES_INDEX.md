# SOURCES_INDEX.md — Карта «тема → файл»


Где искать знания по конкретной клинической теме.

**Порядок чтения (приоритет сверху вниз):**
1. **Гайдлайн** — `references/clinical_guidelines/*.md` — клинические протоколы по конкретным состояниям (с международными источниками).
2. **Протокол** — `references/methodology/protocols/*.md` — алгоритмы школы.
3. **Таблица** — `references/methodology/tables/*.md` — справочные таблицы (мастер-референсы).
4. **Выжимка** — `references/01_…13_*.md` — старый плоский слой (на период миграции, см. D-11 в `project/ROADMAP.md`).
5. **Первичный** — `text_extracted/*.txt` — сырой материал школы.
6. **Связанные** — смежные файлы для контекста.

Если темы нет ни на одном уровне — см. `v2/KNOWLEDGE_PROTOCOL.md`, Категория B или C.

**Период миграции (с 2026-05-22):** новый четырёхуровневый слой (`biochemistry/`, `clinical_guidelines/`, `methodology/`, `personal_practice/`) сосуществует со старым плоским слоем. Старые файлы помечены DEPRECATED по мере замены.


---

## Лабораторная диагностика

Таблица: `references/methodology/tables/lab_values_master.md` — мастер-таблица референсов (85 показателей, 12 разделов, 3 уровня: 🔵 лабораторный / 🟡 клинический / 🟢 функциональный). **Приоритетный источник норм.**
Протокол: `references/methodology/protocols/lab_diagnostics.md` — алгоритм первичного осмотра (7 шагов), опорные паттерны (анемии, воспаление, ИР, щитовидка, метилирование), расхождения с гайдлайнами, чек-лист годовых анализов. **Приоритетный источник алгоритмов.**
Выжимка (DEPRECATED): `references/methodology/tables/lab_values_master.md` — старые референсы, заменены master-таблицей.
Выжимка (DEPRECATED): `references/03_lab_diagnostics.md` — старые принципы, заменены протоколом.
Первичный: `text_extracted/УРОК 7. ЛАБОРАТОРНАЯ ДИАГНОСТИКА.txt`
Первичный: `text_extracted/УРОК 15. Общий анализ крови (ОАК).txt`
Первичный: `text_extracted/УРОК 16. Биохимический анализ крови.txt`
Первичный: `text_extracted/Таблица референсов и оптимальных значений.txt`
Первичный: `text_extracted/Чек-лист с оптимальными значениями.txt`
Первичный: `text_extracted/Чек-лист по анализам для клиента.txt`
Первичный: `text_extracted/Разбор анализа № 4.txt`
Первичный: `text_extracted/УРОК 19. Разбор анализов.txt`
Связанные: `text_extracted/Таблица для отслеживания результатов.txt`


---

## Железодефицит и анемия

Гайдлайн: `references/clinical_guidelines/iron_deficiency.md` — протокол при железодефиците (BSH 2021, AGA 2024, WHO 2020/2024 + школа). **Приоритетный источник.**
Протокол: `references/methodology/protocols/lab_diagnostics.md` (раздел 6 «Анемии — алгоритм») — дифференциация по MCV, стадии Fe-дефицита, учёт воспаления.
Таблица: `references/methodology/tables/lab_values_master.md` (раздел 4 «Железо») — референсы ферритина, Fe, ОЖСС, TSAT.
Выжимка: `references/05_vitamins_minerals.md` (раздел «Железодефицитная анемия») — на период миграции.
Первичный: `text_extracted/УРОК 14. Железодефицитная анемия.txt`
Первичный: `text_extracted/УРОК 15. Общий анализ крови (ОАК).txt`
Связанные: `text_extracted/УРОК 16. Биохимический анализ крови.txt`


---

## Инсулинорезистентность и диабет

Методология: `references/methodology/insulin_resistance.md` _(полный протокол, 1106 строк, 25 разделов)_
Выжимка: `references/04_lipids_insulin.md`
Первичный: `text_extracted/УРОК 11. Инсулинорезстенстность. Диабет. Cхема работы.txt` _(имя файла сохранено as-is; тема: инсулинорезистентность)_
Связанные: `text_extracted/Рекомендации для диабетиков.txt`
Связанные: `references/09_nutraceuticals.md` (берберин, хром, альфа-липоевая кислота)

Смежные протоколы:
- `references/methodology/liver_health.md` — НАЖБП как следствие/причина ИР
- `references/methodology/pancreas_health.md` — β-клетки, панкреатогенный СД
- `references/methodology/sibo_sifo.md` — дисбиоз как фактор ИР
- `references/methodology/stomach_health.md` — гипоацидность и углеводный обмен

---

## Щитовидная железа и АИТ

Методология: `references/methodology/thyroid_health.md` _(полный протокол, 692 строки, 27 разделов; физиология HPT-оси и периферической конверсии, гипо-/гипертиреоз, АИТ Хашимото, болезнь Грейвса, узлы и TIRADS, йод школьный vs ATA/ETA, селен 200 мкг при АИТ, безглютеновая диета, стратегия с L-тироксином, 11+ красных флагов)_
Первичный: `text_extracted/УРОК 17. Щитовидная железа. Йод.txt` _(487 строк, основной источник: ЩЖ, гипо/гипертиреоз, АИТ, йод, патч-тест, феномен Браунштейна, отмена L-тироксина)_
Связанные: `text_extracted/УРОК 12. Селен, йод, цинк.txt` _(нутрицевтика при ЩЖ)_
Связанные: `text_extracted/УРОК 19. Разбор анализов.txt` _(лабораторная диагностика)_
Связанные: `text_extracted/УРОК 22. Аутоиммунные заболевания.txt` _(АИТ, триггеры)_

Смежные протоколы:
- `references/methodology/female_hormones.md` — ↑пролактин при гипотиреозе, СПКЯ-имитация, СДЭ, мастопатия
- `references/methodology/insulin_resistance.md` — гипотиреоз и ИР, общий аутоиммунный фон
- `references/methodology/liver_health.md` — конверсия T4→T3, НАЖБП и гипотиреоз
- `references/methodology/intestinal_health.md` — целиакия + АИТ, всасывание L-тироксина
- `references/methodology/sibo_sifo.md` — СИБР при гипотиреозе
- `references/methodology/stomach_health.md` — H. pylori и всасывание L-тироксина и Fe
- `references/methodology/protocols/lab_diagnostics.md` — интерпретация панели ЩЖ

---

## Молочная железа и мастопатия

**Методология (полный протокол):**
- `references/methodology/mastopathy.md` — 789 строк, 27 разделов, 103 подзаголовка. Покрывает физиологию МЖ (HPG/HPT/печёночно-кишечная оси, эмбриогенез, циклические изменения, лактация, йод в ткани МЖ), патологию (классификация ФКМ по МКБ-10, Dupont-Page, BI-RADS, 6-факторный патогенез, мастодиния, выделения из соска, факторы риска РМЖ, наследственные синдромы BRCA1/2, CHEK2, PALB2), диагностику (УЗИ, маммография, томосинтез, МРТ, биопсия), терапию (нутрицевтики с разбором школа vs доказательная: DIM/I3C, кальций-D-глюкарат, селен, магний, B6, омега-3, витамин D, мелатонин, витекс, GLA), питание, образ жизни, 4-шаговый чек-лист. Два двухколонных раздела: 11 (6 причин ФКМ) и 22 (йод при ФКМ — Ghent 1993, Kessler 2004, формы KI/I₂/Lugol, дозы, противопоказания).

**Первичные источники (школа):**
- `text_extracted/УРОК 21. Гормоны…txt` — раздел 3 (мастопатия): СДЭ, прогестерон-дефицит, ПМС-мастодиния, нутрицевтики (DIM, индол-3-карбинол, магний B6, омега-3, витекс, прогестерон трансдермально).
- `text_extracted/УРОК 17. Щитовидная железа. Йод.txt` — йод как фактор лечения ФКМ (Ghent, Kessler, патч-тест, дозы 400-600 мкг, противопоказания при АИТ и узлах).
- `text_extracted/УРОК 12. Селен, йод, цинк.txt` — селен 200 мкг при АИТ-ассоциированной ФКМ, цинк, формы йода.
- `text_extracted/УРОК 22. Аутоиммунные заболевания.txt` — АИТ как фактор риска ФКМ через гиперпролактинемию.

**Связанные методологии:**
- `references/methodology/female_hormones.md` — СДЭ, прогестерон-дефицит, гиперпролактинемия, СПКЯ, ПМС (основа патогенеза ФКМ).
- `references/methodology/thyroid_health.md` — гипотиреоз → ↑ТРГ → ↑PRL → ФКМ; йод и селен как кофакторы МЖ и ЩЖ.
- `references/methodology/insulin_resistance.md` — ↓ГСПГ, ↑ИФР-1, метаболический синдром как факторы риска ФКМ и РМЖ.
- `references/methodology/liver_health.md` — 1-2 фазы детоксикации эстрогенов, метаболиты 2/4/16α-OH-E1, COMT/SULT/GST.
- `references/methodology/intestinal_health.md` — эстраболом, β-глюкуронидаза, дисбиоз и реабсорбция эстрогенов.
- `references/methodology/protocols/lab_diagnostics.md` — гормональные и микроэлементные панели.
- `references/methodology/nutrition_basics.md` — крестоцветные, льняное семя, омега-3, клетчатка, ограничение алкоголя.

**Гайдлайны:**
- NCCN Breast Cancer Screening and Diagnosis 2024.
- NICE NG101 (РМЖ, 2018/2023), NICE CG164 (наследственный РМЖ, 2013/2023).
- ESMO Primary Breast Cancer 2023.
- ACR BI-RADS Atlas 2013 (5-е изд.) + ACR Appropriateness Criteria 2022.
- USPSTF Screening for Breast Cancer 2024.
- WHO Iodine Deficiency Disorders 2007/2023.

**Ключевые исследования:**
- Ghent 1993 (йод при ФКМ, открытое исследование); Kessler 2004 (молекулярный йод РКИ, n=111).
- Reed 2008 (DIM/I3C и соотношение метаболитов эстрогенов).
- Wuttke 2003, van Die 2013 (витекс при мастодинии и ПМС).
- Pruthi 2010 (омега-3 при циклической масталгии, n=555).
- Plottel & Blaser 2011, Kwa 2016 (эстраболом и РМЖ).
- Sun 2014, Farebrother 2019 (избыточный йод и АИТ).
- Garland 2009 (витамин D и риск РМЖ).
- Friedenreich 2010 (физическая активность и РМЖ).
- Collaborative Group 2002 (лактация и РМЖ, n=147 000).
- Hamajima 2002 (алкоголь и РМЖ, n=58 515).


## Менопауза и климактерий

**Методология:** `references/methodology/menopause.md` (868 строк, 27 разделов)

**Первичные источники (уроки школы):**
- Урок 21 — Менопауза, климактерический синдром, ЗГТ
- Урок 17 — Щитовидная железа (гипотиреоз маскирует климактерий)
- Урок 22 — Аутоиммунные заболевания (АИТ ↑ в перименопаузе)

**Связанные методологические файлы:**
- `references/methodology/female_hormones.md` — гормональная база до менопаузы
- `references/methodology/mastopathy.md` — ФКМ и риск РМЖ, йод
- `references/methodology/thyroid_health.md` — АИТ и гипотиреоз
- `references/methodology/insulin_resistance.md` — ИР в постменопаузе
- `references/methodology/liver_health.md` — НАЖБП, детокс эстрогенов
- `references/methodology/intestinal_health.md` — эстроболом

**Клинические руководства:**
- NAMS 2022 Hormone Therapy Position Statement — Menopause 2022;29(7):767-794
- IMS 2016 Recommendations on Women's Midlife Health — Climacteric 2016;19(2):109-150
- NICE NG23 Menopause: diagnosis and management (обновл. 2024)
- ACOG Practice Bulletin No. 141 — Management of Menopausal Symptoms
- Endocrine Society 2015 — Treatment of Symptoms of the Menopause
- ESC 2021 Guidelines on cardiovascular disease prevention
- ISCD 2019 Official Positions — DXA, FRAX
- USPSTF 2024 — Breast Cancer Screening

**Ключевые РКИ и метаанализы:**
- WHI 2002 (Rossouw) — JAMA 2002;288(3):321-333 (риски ЗГТ, критика дизайна)
- Manson 2017 — JAMA 2017;318(10):927-938 (18-летнее наблюдение WHI, mortality benefit <60 лет)
- ELITE (Hodis 2016) — N Engl J Med 2016;374:1221-1231 (timing hypothesis)
- KEEPS (Harman 2014) — Ann Intern Med 2014;161:249-260 (биоидентичные)
- Lethaby Cochrane 2013 — фитоэстрогены при вазомоторных симптомах
- Bommer 2011 — шалфей при приливах (РКИ)
- Konig 2018 — коллаген пептиды и BMD (РКИ)
- Bolland 2010 — BMJ, кальций добавки и СС-риск

**Двухколоночный анализ «школа vs доказательная медицина»:** разделы 18 (ЗГТ) и 22 (фитоэстрогены)


## Стресс и надпочечники

**Методология:** `references/methodology/stress_adrenals.md` (1017 строк, 27 разделов)

**Первичные источники (уроки школы):**
- Урок по стрессу и надпочечникам (определить точный номер)
- Урок 17 — Щитовидная железа (HPT-HPA cross-talk, low-T3 syndrome)
- Урок 12 — Селен, йод, цинк (нутрицевтики поддержки)

**Связанные методологические файлы:**
- `references/methodology/thyroid_health.md` — HPT-HPA cross-talk, маска «adrenal fatigue»
- `references/methodology/insulin_resistance.md` — кортизол → ИР, висцеральное ожирение
- `references/methodology/female_hormones.md` — pregnenolone steal, функциональный гипогонадизм
- `references/methodology/menopause.md` — адренопауза, ДГЭА в постменопаузе
- `references/methodology/mastopathy.md` — стресс ↑ пролактин, баланс Е/П
- `references/methodology/liver_health.md` — 11β-HSD1, метаболизм ГК
- `references/methodology/intestinal_health.md` — gut-brain axis, дисбиоз при стрессе

**Клинические руководства:**
- Endocrine Society 2016 — Primary Adrenal Insufficiency (Bornstein SR et al.) — JCEM 2016;101(2):364-389
- Endocrine Society 2008 — Diagnosis of Cushing's Syndrome (Nieman LK et al.) — JCEM 2008;93(5):1526-1540
- Endocrine Society 2014 — Pheochromocytoma and Paraganglioma (Lenders JW et al.) — JCEM 2014;99(6):1915-1942
- Endocrine Society 2018 — Congenital Adrenal Hyperplasia (Speiser PW et al.) — JCEM 2018;103(11):4043-4088
- ESE 2016/2023 — Management of Adrenal Incidentalomas (Fassnacht M et al.)
- Endocrine Society 2010 — позиция по «adrenal fatigue» (термин отвергнут)

**Ключевые исследования:**
- Cadegiani FA, Kater CE 2016 — «Adrenal fatigue does not exist: a systematic review» — BMC Endocr Disord 2016;16(1):48
- McEwen BS 1998 — Allostasis and allostatic load — Ann N Y Acad Sci 1998;840:33-44
- Seeman TE et al. 1997 — Allostatic load (MacArthur Studies) — Arch Intern Med 1997;157(19):2259-2268
- Felitti VJ et al. 1998 — ACE Study — Am J Prev Med 1998;14(4):245-258
- Selye H 1936/1976 — The Stress of Life (General Adaptation Syndrome)
- Salve J et al. 2019 — Ashwagandha (KSM-66), Cureus 2019;11(12):e6466
- Lopresti AL et al. 2019 — Ashwagandha and stress/anxiety, Medicine 2019;98(37):e17186
- Pratte MA et al. 2014 — Ashwagandha systematic review, J Altern Complement Med
- Olsson EM et al. 2009 — Rhodiola rosea, stress and fatigue, Planta Med
- Hellhammer J et al. 2004 — Phosphatidylserine and stress, Stress 2004;7(2):119-126
- Goyal M et al. 2014 — Meditation meta-analysis, JAMA Intern Med 2014;174(3):357-368
- Kiecolt-Glaser JK et al. 2011 — Omega-3 and anxiety, Brain Behav Immun
- Boyle NB et al. 2017 — Magnesium and anxiety, Nutrients 2017;9(5):429
- Holt-Lunstad J et al. 2010 — Social relationships and mortality, PLoS Med
- Wilson JL 2001 — Adrenal Fatigue: The 21st Century Stress Syndrome (источник школьной концепции)

**Двухколоночный анализ «школа vs доказательная медицина»:** раздел 14 — «adrenal fatigue» vs HPA dysfunction (**5-й бенчмарк Кластера 4**)

## Витамины

Выжимка: `references/05_vitamins_minerals.md` (разделы жиро- и водорастворимых витаминов)
Первичный: `text_extracted/УРОК 12. Витамины. Формы. Анализы. Дозировки.txt`
Связанные: `references/09_nutraceuticals.md` (конкретные формы БАД)

---

## Минеральные элементы

Выжимка: `references/05_vitamins_minerals.md` (раздел «Минеральные элементы»)
Первичный: `text_extracted/УРОК 13. Минеральные элементы.txt`
Первичный: `text_extracted/Таблицы совместимости минералов и витаминов.txt`

---

## ЖКТ: желудок, гастрит, ГЭРБ, H. pylori

Методология: `references/methodology/stomach_health.md` (полный протокол: анатомия, секреция HCl и пепсина, гипо-/гиперацидность, гастриты по Сиднейской классификации, ГЭРБ, H. pylori и эрадикация по Маастрихт VI, рак желудка — красные флаги, гастропанель, нутрицевтическая поддержка, чек-лист Agent-Nutri)
Первичный: `text_extracted/УРОК 1. Желудок. Гастрит.txt` (Этап 2, II ступень)
Первичный: `text_extracted/УРОК 2. ГЭРБ. Схема работы.txt` (Этап 2, II ступень)
Первичный: `text_extracted/УРОК 3. Нelicobacter pylori. Нутрицевтическая схема работы.txt` (Этап 2, II ступень)
Смежные протоколы: `intestinal_health.md` (мальабсорбция B12/железа при гипоацидности), `sibo_sifo.md` (гипоацидность → СИБР), `gallbladder_health.md` (ДГР, нейтрализация HCl), `pancreas_health.md` (последовательность пищеварения), `colon_coprogram.md` (мышечные волокна как маркёр гипоацидности), `gluten_celiac.md` (аутоиммунные ассоциации)
---

## ЖКТ: кишечник — общая физиология и микрофлора

Протокол: `references/methodology/intestinal_health.md` ⭐ (тонкий кишечник, микрофлора, симбионты/УПФ, желчеотток, сладкая зависимость — Этап 1 Урок 4)
Протокол: `references/methodology/digestion_basics.md` ⭐ (основы пищеварения, дневник питания — Этап 1 Урок 1)
Выжимка: `references/01_digestion_gastro.md` (раздел «Кишечник») (DEPRECATED — мигрирует в Протоколы)
Первичный: `text_extracted/УРОК 4. КИШЕЧНИК. СЛАДКОЕ. ЗАВТРАК.txt`
Смежные протоколы: `sibo_sifo.md` (СИБР/СДК тонкого кишечника), `colon_coprogram.md` (толстый кишечник + копрограмма)

---

## ЖКТ: печень, НаЖБП/MASLD, синдром Жильбера

### Методология
- `references/methodology/liver_health.md` — клинический протокол (984 строки, 27 разделов из них 24 содержательных, 97 H3, ⭐54 / ◆32 / ⚠️45). Структура: физиология (1–3), лабораторная диагностика (4), патологии (5–7 гемангиома, нутрицевтики, СЖ), NAЖБП/MASLD блок (10–12 по AASLD/EASL 2023), DILI (13), вирусные гепатиты (14), аутоиммунные (15), холестаз (16), питание/алкоголь/образ жизни (17–19), нутриенты (20), гормональный метаболизм (21), особые группы (22), расширенная дифдиагностика (23), бенчмарк (24), правила и чек-лист (25–26).

### Бенчмарк (§24 — школа vs доказательная медицина)
- «Чистки печени» оливковым маслом + лимонным соком: псевдокамни как мыла жирных кислот (Sies, Lancet 2005)
- «Фаза 3 детоксикации» школьная vs реальная биохимия ABC-транспортёров MRP2/MDR1/BCRP (Keppler 2011)
- Силимарин как «универсальный гепатопротектор» vs Cochrane Rambaldi 2007 (умеренный эффект)
- «NAFLD лечится травами» vs EASL/AASLD 2023 (потеря веса −7–10%, resmetirom, GLP-1)
- «Печень регенерирует всё» vs стадии фиброза F0–F4 (F4 необратим)
- Гепатопротекторы «всем подряд курсами» vs показания (силимарин, УДХК, фосфолипиды)

### Клинические рекомендации
- EASL Clinical Practice Guidelines on the management of metabolic dysfunction-associated steatotic liver disease (J Hepatol 2024)
- AASLD Practice Guidance on the clinical assessment and management of NAFLD/MASLD (Hepatology 2023)
- NICE NG49: Non-alcoholic fatty liver disease — assessment and management (2016, обновления)
- AASLD/IDSA HCV Guidance (hcvguidelines.org, обновляется ежегодно)
- LiverTox: Clinical and Research Information on Drug-Induced Liver Injury (NIH, livertox.nih.gov)
- WHO AUDIT — Alcohol Use Disorders Identification Test (2001)

### Ключевые исследования и обзоры
- Rinella ME et al. A multisociety Delphi consensus statement on new fatty liver disease nomenclature (Hepatology 2023)
- Younossi ZM et al. Global epidemiology of MASLD: systematic review and meta-analysis (Hepatology 2023, 38% распространённость)
- Harrison SA et al. A Phase 3, Randomized, Controlled Trial of Resmetirom in NASH with Liver Fibrosis — MAESTRO-NASH (NEJM 2024)
- Newsome PN et al. A Placebo-Controlled Trial of Subcutaneous Semaglutide in NASH (NEJM 2021)
- Lassailly G et al. Bariatric surgery provides long-term resolution of NASH and regression of fibrosis (Gastroenterology 2020)
- Wijarnpreecha K et al. Coffee consumption and risk of NAFLD: meta-analysis (Eur J Gastroenterol Hepatol 2017)
- Anania C et al. Mediterranean diet and NAFLD (World J Gastroenterol 2018)
- Cochrane: Milk thistle for liver diseases (Rambaldi 2007, обновления)
- Sanyal AJ et al. Prospective study of outcomes in adults with NAFLD (NEJM 2021, биомаркеры фиброза)
- GBD 2016 Alcohol Collaborators. Alcohol use and burden — global analysis (Lancet 2018)

### Связанные протоколы методологии
- `references/methodology/gallbladder_health.md` — желчные кислоты, ПХЭС, билиарный путь метаболизма эстрогенов
- `references/methodology/pancreas_health.md` — сфинктер Одди, билиарный панкреатит, диабет 3c
- `references/methodology/intestinal_health.md` — энтерогепатическая циркуляция
- `references/methodology/sibo_sifo.md` — СИБР при холестазе и ПХЭС
- `references/methodology/insulin_resistance.md` — MASLD как печёночное проявление метаболического синдрома
- `references/methodology/female_hormones.md` — метаболизм эстрогенов 2-OH/16α-OH через CYP1A1/CYP3A4
- `references/methodology/mastopathy.md` — связь печёночного метаболизма эстрогенов и риска пролиферации
- `references/methodology/menopause.md` — ЗГТ и печень
- `references/methodology/stress_adrenals.md` — кортизол и глюконеогенез, печёночный путь
- `references/methodology/thyroid_health.md` — конверсия T4→T3 через дейодиназу D1
- `references/methodology/gluten_celiac.md` — целиакия и повышение трансаминаз

## Желчный пузырь и желчевыводящие пути

### Методология
- `references/methodology/gallbladder_health.md` — клинический протокол (663 строки, 26 разделов, 57 H3, ⭐29 / ◆15 / ⚠️46). Структура: физиология (1–7), клиника и нутрицевтика (8–17), патология ЖКБ/ПХЭС/безопасность (18–23), бенчмарк «школа vs ДМ» (24), расширенная диагностика (25), кросс‑протоколы и источники (26).

### Бенчмарк (§24 — школа vs доказательная медицина)
- Симптомные ЖКБ: литолитики vs холецистэктомия (EASL 2016, NICE CG188, Cochrane УДХК 2013)
- Билиарный сладж и концепция «застоя желчи» (EASL 2016)
- Желчегонные травы — артишок, силимарин, куркумин (Holtmann 2003, Cochrane 2007)
- Дюбажи с магния сульфатом — риски при ЖКБ
- Психосоматика ЖП — TCM vs Rome IV (Cotton 2016)
- Холестериновые vs пигментные камни — что растворяется
- Последствия холецистэктомии — ПХЭС, СИБР, КРР (реальные риски)

### Клинические рекомендации
- EASL Clinical Practice Guidelines on gallstones (J Hepatol 2016)
- NICE CG188: Gallstone disease — diagnosis and management (2014, обновления)
- ACG Clinical Guideline: Functional Gallbladder Disorder (Cotton 2016, Rome IV)
- AGA Clinical Practice Update: Functional Gallbladder Disorder (2022)

### Ключевые исследования и обзоры
- Cochrane: Ursodeoxycholic acid for gallstones (2013)
- Cochrane: Milk thistle for liver diseases (Rambaldi 2007)
- Lammert F. et al. Gallstones. Nature Reviews Disease Primers (2016)
- Holtmann G. et al. Artichoke leaf extract in functional dyspepsia (Aliment Pharmacol Ther 2003)
- Acalovschi M. Cholesterol gallstones: epidemiology to prevention (Postgrad Med J 2001)
- Cotton PB et al. Rome IV. Gallbladder and sphincter of Oddi disorders (Gastroenterology 2016)

### Связанные протоколы методологии
- `references/methodology/liver_health.md` — синтез желчных кислот, NAЖБП, метаболизм эстрогенов
- `references/methodology/pancreas_health.md` — сфинктер Одди, билиарный панкреатит
- `references/methodology/intestinal_health.md` — энтерогепатическая циркуляция
- `references/methodology/sibo_sifo.md` — СИБР при ПХЭС и холестазе
- `references/methodology/colon_coprogram.md` — маркеры дисфункции ЖП в стуле
- `references/methodology/female_hormones.md` — эстроген‑доминирование и литогенность желчи
- `references/methodology/mastopathy.md` — билиарный путь метаболизма эстрогенов
- `references/methodology/menopause.md` — ЗГТ и риск ЖКБ
- `references/methodology/insulin_resistance.md` — метаболический синдром и литогенность
- `references/methodology/stress_adrenals.md` — функциональные билиарные расстройства

## ЖКТ: поджелудочная железа, ферменты, панкреатит, EPI, СД 3c

### Методология

- [`references/methodology/pancreas_health.md`](../references/methodology/pancreas_health.md) — клинический протокол поджелудочной железы (901 строка, 27 разделов, 92 H3, маркеры ⭐45 / ◆31 / ⚠️60). Покрывает: анатомию и 10 ферментов, карту ферментов ЖКТ, связки с печенью/желчным/кишечником/инсулином, 8 правил приёма ферментов, дозировки по UEG 2017 (40–50 тыс. ед. липазы), лабораторную диагностику (липаза, амилаза, эластаза-1 кала как золотой стандарт EPI), острый и хронический панкреатит (Atlanta 2012, TIGAR-O), 6 причин (алкоголь 40 %, ЖКБ 35 %, ТГ), связь с ИР, диету по UEG 2017 (НЕ Певзнер 5п), нутрицевтики, EPI/PEI, PERT, СД 3c (Hardt/Ewald), кисты и IPMN (ACG 2018), аутоиммунный панкреатит (IgG4, Hamano 2001), онконастороженность (триада: желтуха + потеря веса + новый СД).

### Бенчмарк §26 (школа vs доказательная медицина) — 6 тем

1. Ферменты «для пищеварения» vs UEG 2017 (только при EPI с эластазой-1 <200)
2. «Панкреатит от жирного» vs Banks 2012 (алкоголь 40 %, ЖКБ 35 %, жиры — лишь при ТГ >1000)
3. Растительные ферменты (бромелайн/папаин) vs ACG 2020 (не заменяют PERT)
4. Дюбажи и «чистка ПЖ» vs отсутствие доказательств (риск при ЖКБ)
5. Диета 5п (Певзнер 1929) пожизненно vs UEG 2017 (нормокалорийная, жиры не ограничивать)
6. «СД при панкреатите = СД2» vs Hardt 2008 / Ewald 2012 (СД 3c — отдельный тип)

### Клинические рекомендации

- **UEG evidence-based guideline 2017** (Löhr JM et al., HaPanEU) — chronic pancreatitis, PERT, EPI
- **ACG Clinical Guideline 2020** (Gardner TB et al.) — chronic pancreatitis
- **ACG Guideline 2013** (Tenner S et al.) — acute pancreatitis
- **AGA Guideline 2018** — initial management of acute pancreatitis
- **ACG Guideline 2018** + **European 2018** — pancreatic cysts and IPMN
- **ICDC 2011** — autoimmune pancreatitis (International Consensus Diagnostic Criteria)

### Ключевые исследования

- **Banks PA et al. Gut 2013** — Atlanta classification 2012
- **Whitcomb DC. NEJM 2019** — chronic pancreatitis review; Whitcomb 1996 — PRSS1
- **Hardt PD et al. Diabetes Care 2008**; **Ewald N et al. 2012** — type 3c diabetes
- **Hamano H et al. NEJM 2001** — IgG4 autoimmune pancreatitis
- **Lowenfels AB et al. NEJM 1993** — pancreatic cancer risk in chronic pancreatitis
- **Wagner R et al. Nature Med 2020** — pancreatic steatosis and diabetes
- **GLOBOCAN 2020** — pancreatic cancer epidemiology

### Связанные протоколы

- [`references/methodology/liver_health.md`](../references/methodology/liver_health.md) — общий проток Одди, НАЖБП ↔ панкреатический стеатоз, AIP-1 ↔ PSC (IgG4)
- [`references/methodology/gallbladder_health.md`](../references/methodology/gallbladder_health.md) — билиарный панкреатит 35 % ОП, постхолецистэктомический синдром → EPI
- [`references/methodology/intestinal_health.md`](../references/methodology/intestinal_health.md) — энтерокиназа → активация трипсина, атрофия → функциональная EPI
- [`references/methodology/sibo_sifo.md`](../references/methodology/sibo_sifo.md) — СИБР маскирует EPI, ложно низкая эластаза-1
- [`references/methodology/gluten_celiac.md`](../references/methodology/gluten_celiac.md) — целиакия → функциональная EPI, дифдиагноз стеатореи
- [`references/methodology/colon_coprogram.md`](../references/methodology/colon_coprogram.md) — стеаторея в копрограмме = маркер EPI
- [`references/methodology/insulin_resistance.md`](../references/methodology/insulin_resistance.md) — СД 3c vs СД2, разная тактика
- [`references/methodology/digestion_basics.md`](../references/methodology/digestion_basics.md) — базовая физиология ферментного каскада
- [`references/methodology/nutrition_principles.md`](../references/methodology/nutrition_principles.md) — БЖУ, MCT-масла при EPI
- [`references/methodology/stress_adrenals.md`](../references/methodology/stress_adrenals.md) — кортизол → гипергликемия → нагрузка на бета-клетки
## ЖКТ: глютен и целиакия

Протокол: `references/methodology/gluten_celiac.md` ⭐ (полный протокол по глютену и целиакии — Этап 1 Урок 2 + Этап 2 Урок 7: биохимия глютена, 3 механизма повреждения слизистой, спектр состояний (целиакия, NCGS, аллергия), HLA-DQ2/DQ8, лабораторная диагностика (АТ к глиадину, биопсия, tTG, HLA), 18 признаков непереносимости, связки с ПЖ/ЖП/ЩЖ/молочкой, безглютеновая диета, восстановление слизистой)
Первичный (Этап 2): `text_extracted/УРОК 7. Поджелудочная железа. Ферменты. Глютен.txt` (раздел «Глютен», стр. 13-19)
Первичный (Этап 1): `text_extracted/УРОК 2. КЩБ. Тип тела. Стоп-продукты. Глютен и молочка.txt` (раздел «Глютен», стр. 14-15)

---

## ЖКТ: СИБР, СДК, дисбиоз тонкого кишечника

Протокол: `references/methodology/sibo_sifo.md` ⭐ (полный протокол СИБР/СДК/дисбиоза — Этап 2 Урок 8: 4 ступени дисбиоза, механизм СИБР, типы H₂/CH₄/H₂S ◆, диагностика (водородный тест ⭐, анализ по Осипову ⭐, копрограмма ⭐, α1-антитрипсин ⭐, кальпротектин ⭐, зонулин ◆), 8-пунктовая школьная схема (Буларди, куркумин, берберин, масло чёрного тмина, алоэ), low FODMAP ◆, прокинетики ◆, СИГР/кандидоз ◆, 10 правил безопасности)
Первичный: `text_extracted/УРОК 8. СИБР. СДК. Анализ по Осипову.txt` (Этап 2 Урок 8)
Смежные протоколы: `intestinal_health.md` (общая физиология), `gluten_celiac.md`, `gallbladder_health.md`, `pancreas_health.md`


## ЖКТ: толстый кишечник, копрограмма

Протокол: `references/methodology/colon_coprogram.md` ⭐ (полный протокол толстого кишечника и копрограммы — Этап 2 Урок 9: анатомия 4 отделов ободочной + прямая (160 см), 4 функции (детокс, выведение эстрогенов, всасывание воды, формирование кала), микрофлора и бутират ◆, Бристольская шкала ⭐ (все 7 типов ◆), запоры/диарея 4 механизма ⭐, СРК ◆ (3 подтипа, Римские критерии IV, low FODMAP), дивертикулёз ◆, копрограмма ⭐ (22 показателя, полная расшифровка), 4 синдрома по копрограмме ⭐ (желудок/ЖП/ПЖ/СИБР), современные маркеры ◆ (кальпротектин, лактоферрин, эластаза-1, sIgA, β-дефензин-2, зонулин), нутрицевтика ◆ (псиллиум, бутират, магний, пробиотики, L-глутамин, алоэ, цинк-карнозин, куркумин), 10 правил безопасности, чек-лист Agent-Nutri)
Первичный: `text_extracted/УРОК 9. Толстый кишечник. Копрограмма. Почки. ОАМ.txt` (Этап 2 Урок 9, разделы 1-2: толстый кишечник + копрограмма; разделы 3-4 «Почки» и «ОАМ» — для будущего кластера выделительной системы)
Смежные протоколы: `sibo_sifo.md` (СИБР/СДК), `gluten_celiac.md`, `pancreas_health.md`, `gallbladder_health.md`, `intestinal_health.md`, `digestion_basics.md`


## Липидный профиль, гомоцистеин

Выжимка: `references/04_lipids_insulin.md`
Первичный: `text_extracted/УРОК 10. Липидный профиль. Гомоцистеин.txt`

---

## Аутоиммунные заболевания

Выжимка: `references/08_autoimmune_neuro.md`
Первичный: `text_extracted/УРОК 22. Аутоиммунные заболевания.txt`
Связанные: `text_extracted/Аутоиммунное меню.txt`

---

## Гормоны: половые, СДЭ, мастопатия, КОК, менопауза

Методология: `references/methodology/female_hormones.md` _(полный протокол, 778 строк, 27 разделов; СДЭ, СПКЯ‑фенотип, гиперпролактинемия, ПМС, ВДКН, эстроболом, нутрицевтики)_
Выжимка: `references/07_hormones_skin_hair.md`
Первичный: `text_extracted/УРОК 21. Гормоны. СДЭ. Мастопатия. КОК. Менопауза.txt` _(722 строки, основной источник: СДЭ, КОК, мастопатия, менопауза)_
Связанные: `text_extracted/УРОК 8. Режим дня. Спорт. ПМС..txt` _(ПМС, режим дня)_
Связанные: `references/09_nutraceuticals.md` _(витекс, DIM, I3C, мио‑инозитол, кальций‑D‑глюкарат)_

Смежные протоколы:
- `references/methodology/insulin_resistance.md` — ИР как основа 70‑80 % СПКЯ‑фенотипа, снижение ГСПГ
- `references/methodology/liver_health.md` — детокс эстрогенов (фазы I/II), синтез ГСПГ
- `references/methodology/sibo_sifo.md` — эстроболом, β‑глюкуронидаза
- `references/methodology/intestinal_health.md` — выведение эстрогенов, клетчатка
- `references/methodology/nutrition_basics.md` — полноценные жиры для синтеза стероидов
- `references/methodology/protocols/lab_diagnostics.md` — референсы гормональной панели

---

## Кожа, волосы, ногти

Выжимка: `references/07_hormones_skin_hair.md`
Первичный: `text_extracted/УРОК 20. Кожа. Заболевания кожи. Коллаген.txt`
Первичный: `text_extracted/УРОК 24. Выпадение волос. Лимфатическая и иммунная системы.txt`
Первичный: `text_extracted/УРОК 23. Цистит. Кандидоз. Пигментация.txt`

---

## Нервная система, стресс, сон, мигрень

Выжимка: `references/08_autoimmune_neuro.md`
Первичный: `text_extracted/УРОК 25. Нервная система. Стресс. Мигрень.txt`
Первичный: `text_extracted/УРОК 8. Режим дня. Спорт. ПМС..txt`

---

## Паразиты, антипаразитарный курс

Выжимка: `references/10_antiparasitic.md`
Первичный: `text_extracted/УРОК 29. Антипаразитарный курс. Правила прохождения.txt`
Первичный: `text_extracted/АПК от Аврора от лямблий и аскарид.txt`
Первичный: `text_extracted/АПК от всех видов паразитов.txt`
Первичный: `text_extracted/Антипаразитарное меню.txt`

---

## КБЖУ, меню, рационы

Протокол: `references/methodology/nutrition_basics.md` ⭐ (расчёт КБЖУ, БЖУ, режим, вода, сочетаемость — уроки 3, 5, 6)
Протокол: `references/methodology/nutrition_principles.md` ⭐ (КЩБ, стоп-продукты, глютен, молочка, масла — урок 2)
Выжимка: `references/02_nutrition_basics.md` (DEPRECATED — мигрирует в Протокол)
Выжимка: `references/12_menus.md`
Первичный: `text_extracted/УРОК 3. БЖУ. ОБЕД.txt`
Первичный: `text_extracted/УРОК 5. Ужины. Перекусы. Сочетаемость продуктов. Вздутия. Вода.txt`
Первичный: `text_extracted/УРОК 6. КБЖУ ДЛЯ ПОХУДЕНИЯ ИЛИ НАБОРА. ПОДДЕРЖКА РЕЗУЛЬТАТА.txt`
Первичный: `text_extracted/УРОК 1. Процесс пищеварения. Системы питания. Дневник питания.txt`
Первичный: `text_extracted/Меню на 1300 ккал.txt`
Первичный: `text_extracted/Лакто-вегетарианское меню.txt`
Первичный: `text_extracted/Традиционное безмолочное и безглютеновое меню.txt`
Первичный: `text_extracted/Меню таблицы при запорах и диарее.txt`

---

## Нутрицевтики (БАД): описания, показания, дозировки

Выжимка: `references/09_nutraceuticals.md`
Первичный: `text_extracted/УРОК 28. Нутрицевтики.txt`
Связанные ссылки на покупку: `text_extracted/Ссылки БАД.txt`

---

## Суставы, остеопороз, тонзиллит

Первичный: `text_extracted/УРОК 26. Тонзиллит. Суставы. Остеопороз.txt`
(нет отдельной выжимки в references/ — общее знание + Категория B)

---

## COVID, подготовка к беременности

Первичный: `text_extracted/УРОК 27. Восстановление после COVID. Подготовка к беременности.txt`
(нет отдельной выжимки в references/ — нет в базе, требует досдачи или Категория C)

---

## Работа с клиентами, анкета, дневник питания

Выжимка: `references/13_client_work.md`
Первичный: `text_extracted/УРОК 30. Работа с клиентами. Социальные сети.txt`
Первичный: `text_extracted/АНКЕТА ДЛЯ ЗАПОЛНЕНИЯ.txt`
Первичный: `text_extracted/Дневник питания форма для печати.txt`

---

## Пересчёт единиц измерения

Выжимка: `references/unit_conversions.md`
(специализированный файл только для пересчётных коэффициентов)

---

## Темы, которых нет в базе (требуют досдачи или относятся к Категории B/C)

- Генетические полиморфизмы (MTHFR, VDR, COMT и др.) — нет в базе, Категория C.
- Микробиом (подробные протоколы) — частично в `references/01_digestion_gastro.md` и УРОК 4/8, но без протоколов восстановления.
- Восстановление после ковид — только УРОК 27, выжимки нет.
- Суставы / остеопороз — только УРОК 26, выжимки нет.
- Онкология, онкопрофилактика — нет в базе, Категория C.
- Препараты (рецептурные, фармакокинетика) — за пределами компетенции агента.





