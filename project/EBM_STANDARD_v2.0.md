# EBM Standard v3.1 — Единый стандарт научного цитирования Agent-Nutri Pro

> **Назначение документа:** единый источник истины (SSoT) для формата научного цитирования в проекте Agent-Nutri Pro. Определяет, как выглядит доказательный (EBM) тег в методических файлах и клиентских материалах, какие поля обязательны, как валидируется тег и как мигрируются старые форматы.
>
> **Версия:** 3.1 — 2026-08-15 (уроки пилота №1)
> **Дата:** 2026-08-15
> **Статус:** ACTIVE — замещает старый `project/EBM_STANDARD.md` (v1.1, EBM-lite, формат `[EBM: Автор Год]`).
> **Владелец:** Светлана + Claude
> **Обновлять:** при изменении структуры тега, словарей или точек валидации.
>
> **Changelog v3.0 → v3.1:** по итогам пилота миграции №1 (`pancreas_health.md`, 3 тега, 2026-08-14) добавлены 7 уроков (см. раздел 12): (1) автоматический fallback на PMC full-text; (2) `n/a` вместо `NOT_IN_ABSTRACT` в чистом теге методички; (3) удаление пустых плейсхолдеров substance/dose для non-interventional работ; (4) детекция guideline по нескольким источникам (не только PublicationType); (5) обработка legacy topic mismatch со вторым кандидатом; (6) правило для старых работ до ~1975 без abstract; (7) обязательный блок `## Verification` в annotated-версии.

---

## Оглавление

1. Философия и принципы
2. Формат базового тега (обязательные поля)
3. Условные поля
4. Список критичных веществ (требуют Safety)
5. Специальные форматы
6. Inline-версия для списков-перечислений
7. Правила стиля
8. 10 точек валидации
9. Миграция со старых стандартов
10. Примеры на реальных данных (5 полных тегов)
11. References (образец раздела для inline-версии)
12. Уроки пилота миграции №1 (v3.1)

---

## 1. Философия и принципы

Стандарт v3.0 отходит от «EBM-lite» формата `[EBM: Автор Год]` (v1.1), потому что короткий тег не самодостаточен: чтобы понять, что именно доказано, нутрициологу приходилось искать статью вручную. v3.0 переносит суть доказательства прямо в тег.

Три принципа.

**Принцип 1. Самодостаточность тега.** Тег отвечает на пять вопросов без открытия статьи: какой уровень доказательности, кто и когда, какое вещество в какой форме и дозе, какой эффект и насколько, на какой популяции. Нутрициолог принимает клиническое решение, не выходя из документа.

**Принцип 2. Машиночитаемость.** Каждое поле имеет фиксированную позицию и синтаксис, поэтому валидатор (`ebm_validator.ps1`) и движок миграции (`ebm_engine.ps1`) могут разбирать тег регулярными выражениями. Уровень доказательности `[Level Xa/b, TYPE]`, тип исхода `[surrogate/clinical/hard]`, PMID-ссылка — всё парсится однозначно.

**Принцип 3. Компактность.** Базовый тег — 5–7 строк, полный (с условными полями Safety/Interaction) — 8–10 строк. Больше — визуальный шум, меньше — теряется самодостаточность. Это верхняя и нижняя границы, а не пожелание.

Обоснование полей через клиническую практику нутрициолога:

- **Level + TYPE + blinding** — нутрициолог отличает мета-анализ RCT от единичного открытого исследования и калибрует уверенность рекомендации.
- **Форма вещества** — «селен» и «селенометионин» имеют разную биодоступность; клиент покупает конкретную форму, поэтому форма обязательна.
- **Доза + режим** — переносится напрямую в назначение.
- **Глагол эффекта + количественный результат** — «снижает антитела на 40 %» информативнее, чем «эффективен».
- **Population (n, длительность)** — применимость к конкретному клиенту (пол, возраст, диагноз) и надёжность (размер выборки, срок).
- **PMID-ссылка** — проверяемость за один клик, антигаллюцинационная защита.

---

## 2. Формат базового тега (обязательные поля)

Базовый тег — markdown-блокквот из пяти логических строк.

Шаблон:

    > 📚 **EBM** [Level Xa/b, TYPE, blinding] [outcome-type]
    > **Author Surname I, et al. YYYY.** [Форма вещества] [доза] [режим] [глагол эффекта] [количественный результат] vs [контроль].
    > **Population:** [пол] [возраст] [диагноз/состояние] (n=X, длительность).
    > *Журнал* том(выпуск):страницы. PMID: [номер](https://pubmed.ncbi.nlm.nih.gov/номер)

Расшифровка полей:

- **Строка 1** — `📚 **EBM**`, затем в скобках уровень доказательности по OCEBM (`Level 1a`, `1b`, `2a`, `2b`, `3a`, `3b`, `4`, `5`), тип дизайна (`meta-analysis`, `RCT`, `cohort`, `case-control`, `guideline`), степень ослепления (`double-blind`, `single-blind`, `open-label`, `N/A`). Далее тип исхода: `surrogate` (суррогатный — лабораторный маркер), `clinical` (клинический симптом), `hard` (жёсткая конечная точка — смертность, перелом, инфаркт).
- **Строки 2–3** — библиографический якорь и суть эффекта. Автор в Vancouver-стиле `Surname I, et al. YYYY.`, затем форма вещества, доза, режим приёма, глагол эффекта из закрытого словаря, количественный результат и группа сравнения после `vs`.
- **Строка 4** — `**Population:**` — пол, возраст, диагноз/состояние, в скобках размер выборки `n=X` и длительность наблюдения.
- **Строка 5** — полная библиография: журнал курсивом, том(выпуск):страницы, `PMID:` с кликабельной markdown-ссылкой.

Полный пример (селенометионин при аутоиммунном тиреоидите):

    > 📚 **EBM** [Level 1b, RCT, double-blind] [surrogate]
    > **Gärtner R, et al. 2002.** Selenomethionine 200 mcg once daily reduces anti-TPO antibodies by 40 percent vs placebo.
    > **Population:** women and men with autoimmune thyroiditis, mean age 47 years (n=70, 3 months).
    > *J Clin Endocrinol Metab* 87(4):1687-1691. PMID: [11932302](https://pubmed.ncbi.nlm.nih.gov/11932302)

**Чистый тег при отсутствии данных (v3.1, урок 2).** В финальном v3.0-блоке, который вставляется в файл методологии, отсутствующие числовые поля пишутся как `n/a`, а не как отладочная плашка `NOT_IN_ABSTRACT`. Плашка `NOT_IN_ABSTRACT` живёт только в annotated-версии (для confidence-логирования и отладки, см. раздел 12).

    > 📚 **EBM** [Level 2b, cohort] [hard]
    > **Wagner R, et al. 2021.** Pathophysiology-based subphenotyping of individuals at elevated risk for type 2 diabetes identifies six clusters; cluster 6 has increased risk of kidney disease and all-cause mortality.
    > **Population:** men and women at elevated risk for type 2 diabetes (n=n/a, follow-up=n/a).
    > *Nature medicine* 27(1):49-57. PMID: [33398163](https://pubmed.ncbi.nlm.nih.gov/33398163)

---

## 3. Условные поля

Добавляются к базовому тегу при выполнении условия. Каждое — отдельной строкой блокквота после строки 5.

- `⚠️ **Safety:**` — **обязательно** для критичных веществ (см. раздел 4). Содержит ключевое ограничение безопасности: противопоказания, верхний предел (UL), беременность/лактацию, токсичность при передозировке.
- `🔗 **Interaction:**` — при клинически значимом взаимодействии с лекарством или другим нутриентом. Указывает вещество-партнёр, характер взаимодействия и интервал приёма, если применимо.
- `⏰ **Currency:**` — проставляется **автоматически валидатором**, если статья старше 10 лет и по теме существует более свежий мета-анализ. Содержит указатель на свежий источник (PMID). Вручную не добавляется.

Пример полного тега с условными полями:

    > 📚 **EBM** [Level 1b, RCT, double-blind] [surrogate]
    > **Gärtner R, et al. 2002.** Selenomethionine 200 mcg once daily reduces anti-TPO antibodies by 40 percent vs placebo.
    > **Population:** women and men with autoimmune thyroiditis, mean age 47 years (n=70, 3 months).
    > *J Clin Endocrinol Metab* 87(4):1687-1691. PMID: [11932302](https://pubmed.ncbi.nlm.nih.gov/11932302)
    > ⚠️ **Safety:** upper limit 400 mcg per day; selenosis above 900 mcg per day.
    > 🔗 **Interaction:** levothyroxine — take 4 hours apart to avoid absorption interference.
    > ⏰ **Currency:** newer meta-analysis available, see Wichman 2016 PMID 27833006.

---

## 4. Список критичных веществ (требуют Safety)

Для любого тега об этих веществах поле `⚠️ **Safety:**` обязательно. Порог в скобках означает: Safety обязателен при указанной дозе и выше.

**Микроэлементы:**

- селен (selenomethionine, sodium selenite)
- йод (potassium iodide)
- железо (ferrous bisglycinate, ferrous sulfate)
- медь (copper gluconate)
- цинк (zinc picolinate) — при дозе >40 мг
- марганец (manganese)
- хром (chromium picolinate)
- молибден (molybdenum)

**Витамины:**

- витамин A (retinol) — при дозе >10000 IU
- витамин D (cholecalciferol) — при дозе >4000 IU
- витамин E (alpha-tocopherol) — при дозе >400 IU
- витамин K (phylloquinone, menaquinone) — при приёме варфарина
- витамин B6 (pyridoxine) — при дозе >100 мг

**Гормоны и гормоноподобные:**

- DHEA (dehydroepiandrosterone)
- прегненолон (pregnenolone)
- мелатонин (melatonin) — при дозе >3 мг
- йодтиронин (препараты гормонов щитовидной железы)

**Лекарства:** все без исключения (метформин, левотироксин, СИОЗС и любые другие) — Safety и, как правило, Interaction обязательны.

**Растения с известной токсичностью / значимыми взаимодействиями:**

- солодка (licorice, glycyrrhiza)
- окопник (comfrey)
- кава (kava)
- эфедра (ephedra)
- зверобой (St. John's wort) — при совместном приёме с лекарствами

---

## 5. Специальные форматы

**5.1. Мета-анализ (Level 1a).** Вместо одиночной дозы/эффекта — сводная статистика: стандартизованная разность средних (SMD), относительный риск (RR) или отношение шансов (OR), 95 % доверительный интервал (CI), количество включённых RCT и суммарный n.

    > 📚 **EBM** [Level 1a, meta-analysis, N/A] [clinical]
    > **Pratte MA, et al. 2014.** Ashwagandha root extract improves anxiety scores, SMD -1.55 (95% CI -2.40 to -0.69) vs placebo.
    > **Population:** adults with anxiety and stress (5 RCT, total n=400, 6-12 weeks).
    > *J Altern Complement Med* 20(12):901-908. PMID: [25405876](https://pubmed.ncbi.nlm.nih.gov/25405876)

**5.2. Guideline (WHO, RUSSCO, ADA, ESC и т. п.).** У документа обычно нет PMID — вместо PMID даётся прямая ссылка на документ. Тип дизайна в строке 1 — `guideline`. Тип исхода необязателен.

    > 📚 **EBM** [Level 1a, guideline] [recommendation]
    > **WHO, 2023.** Iodine 250 mcg per day recommended during pregnancy and lactation to prevent maternal and neonatal iodine deficiency.
    > **Population:** pregnant and lactating women (population-level recommendation).
    > WHO Guideline on iodine supplementation. Available: [who.int](https://www.who.int/publications)

**5.3. Отсутствие PMID.** Если у peer-reviewed источника нет PMID — писать `PMID: N/A` и обязательно указать DOI или прямую ссылку.

    > *Journal Name* 12(3):45-52. PMID: N/A. DOI: [10.xxxx/yyyy](https://doi.org/10.xxxx/yyyy)

**5.4. Противоречивые данные.** Если по теме есть источники с противоположными выводами — в строке 1 добавляется метка `[⚡ Conflicting evidence]`, а после библиографии — строка `⚡ **Conflict:**` с указанием противоречащего источника и его PMID.

    > 📚 **EBM** [Level 1b, RCT, open-label] [surrogate] [⚡ Conflicting evidence]
    > **Yin J, et al. 2008.** Berberine 500 mg three times daily decreases HbA1c by 2.0 percent, comparable to metformin.
    > **Population:** adults with type 2 diabetes (n=36, 3 months).
    > *Metabolism* 57(5):712-717. PMID: [18442638](https://pubmed.ncbi.nlm.nih.gov/18442638)
    > ⚡ **Conflict:** larger trials show weaker glycemic effect, see Lan 2015 PMID 25498346.

---

## 6. Inline-версия для списков-перечислений

Когда одно вещество упоминается в перечислении показаний, полный блокквот избыточен. Используется inline-версия с надстрочным номером сноски.

Формат:

    [EBM¹: Author YYYY, PMID: XXXXX, Level 1a]

Правило: **каждый inline-тег обязан иметь полный блокквот-тег ниже в разделе «References» того же файла** под соответствующим номером сноски. Inline без полного тега в References — ошибка валидации.

Пример (витамин D в трёх показаниях):

    Витамин D (cholecalciferol) применяется при нескольких состояниях:
    - кости [EBM¹: Bischoff-Ferrari 2009, PMID: 19307517, Level 1a];
    - иммунитет [EBM²: Martineau 2017, PMID: 28202713, Level 1a];
    - настроение [EBM³: Okereke 2020, PMID: 32749491, Level 1b].

В разделе References этого файла тогда должны быть три полных тега под номерами 1, 2, 3 (см. раздел 11 — образец).

---

## 7. Правила стиля

- **Только слова.** Никаких стрелок `→`, `↔` и телеграфных сокращений внутри тега. Причинность выражается словами (`reduces`, `leads to`, `associated with`).
- **Закрытый словарь глаголов эффекта.** Допустимы только: `reduces`, `increases`, `improves`, `decreases`, `prevents`, `delays`, `restores`, `maintains`, `normalizes`. Другие глаголы (`boosts`, `cures`, `heals`) запрещены.
- **Форма вещества обязательна.** Пишем `selenomethionine`, а не `selenium`; `magnesium glycinate`, а не `magnesium`; `cholecalciferol`, а не `vitamin D`. Родовое название допустимо в скобках после формы.
- **Vancouver-стиль автора.** `Surname I, et al. YYYY.` — фамилия, инициал, `et al.` при более чем одном авторе, год, точка.
- **Язык тега — английский.** Все EBM-теги пишутся по-английски (термины, глаголы, Population). Русский язык — только в клиентских материалах вне тегов и в пояснительном тексте методичек.
- **PMID всегда кликабельный.** Формат markdown-ссылки `PMID: [номер](https://pubmed.ncbi.nlm.nih.gov/номер)`. Голый номер без ссылки — ошибка.
- **Бренды запрещены.** Только форма вещества или международное непатентованное наименование, без торговых марок.

---

## 8. 10 точек валидации

Список проверок для будущего `scripts/ebm_validator.ps1`. Каждый тег обязан проходить все применимые пункты.

1. **Иконка книги.** Тег начинается с `📚` в первой строке.
2. **Уровень и тип дизайна.** В первой строке присутствует `[Level Xa/b, TYPE]` (например, `[Level 1b, RCT, ...]`).
3. **Тип исхода.** Присутствует `[surrogate/clinical/hard]` для обычных EBM-тегов; для гайдлайнов (`guideline`) необязателен.
4. **Автор.** Соответствует формату `Surname I[, et al.] YYYY.` (Vancouver).
5. **Форма вещества.** Присутствует форма из словаря допустимых форм (`selenomethionine`, `magnesium glycinate`, `cholecalciferol` и т. п.), а не родовое название.
6. **Количественный результат.** Есть число/процент/CI/SMD/RR/OR (regex на цифры, `%`, `CI`, `SMD`).
7. **Population.** Присутствует строка `**Population:**` с `n=` и длительностью.
8. **Полная библиография.** Есть журнал + том + выпуск + страницы.
9. **Кликабельный PMID.** Валидная markdown-ссылка `PMID: [..](https://pubmed.ncbi.nlm.nih.gov/..)` либо `PMID: N/A` с DOI/ссылкой.
10. **Safety для критичных веществ.** Если вещество из раздела 4 — обязательно присутствует поле `⚠️ **Safety:**`.

---

## 9. Миграция со старых стандартов

Движок `scripts/ebm_engine.ps1 --migrate` (будет создан в Этапе 2) переводит теги на v3.0.

- **v1.1** — формат `[EBM: Author Year]` (EBM-lite, Sessions 40–62). Мигрируется в полный блокквот v3.0: движок находит источник, дотягивает недостающие поля (Level, форма, доза, Population, PMID) из пула источников и помечает файл как мигрированный.
- **v2.1** — частичный блокквот без строки `Population` и без `Safety`. Мигрируется дозаполнением недостающих обязательных и условных полей.

Статусы файлов (в метаданных методички и в аудите):

- `LEGACY_v1.1` — файл содержит только старые inline-теги `[EBM: Автор Год]`, миграция не начата.
- `MIGRATED_v3.0` — файл переведён движком автоматически, ожидает ручной сверки.
- `NATIVE_v3.0` — файл изначально написан или полностью выверен по v3.0.

Порядок перехода статуса: `LEGACY_v1.1` → `MIGRATED_v3.0` → `NATIVE_v3.0`.

---

## 10. Примеры на реальных данных (5 полных тегов)

**10.1. RCT: селенометионин при Хашимото (Gärtner 2002).**

    > 📚 **EBM** [Level 1b, RCT, double-blind] [surrogate]
    > **Gärtner R, et al. 2002.** Selenomethionine 200 mcg once daily reduces anti-TPO antibodies by 40 percent vs placebo.
    > **Population:** women and men with autoimmune thyroiditis, mean age 47 years (n=70, 3 months).
    > *J Clin Endocrinol Metab* 87(4):1687-1691. PMID: [11932302](https://pubmed.ncbi.nlm.nih.gov/11932302)
    > ⚠️ **Safety:** upper limit 400 mcg per day; selenosis above 900 mcg per day.

**10.2. Мета-анализ: ашваганда при тревожности (Pratte 2014).**

    > 📚 **EBM** [Level 1a, meta-analysis, N/A] [clinical]
    > **Pratte MA, et al. 2014.** Ashwagandha root extract improves anxiety scores, SMD -1.55 (95% CI -2.40 to -0.69) vs placebo.
    > **Population:** adults with anxiety and stress (5 RCT, total n=400, 6-12 weeks).
    > *J Altern Complement Med* 20(12):901-908. PMID: [25405876](https://pubmed.ncbi.nlm.nih.gov/25405876)
    > ⚠️ **Safety:** not recommended during pregnancy; caution with thyroid hormone therapy.

**10.3. Guideline: WHO йод для беременных.**

    > 📚 **EBM** [Level 1a, guideline] [recommendation]
    > **WHO, 2023.** Iodine 250 mcg per day recommended during pregnancy and lactation to prevent maternal and neonatal iodine deficiency.
    > **Population:** pregnant and lactating women (population-level recommendation).
    > WHO Guideline on iodine supplementation. Available: [who.int](https://www.who.int/publications)
    > ⚠️ **Safety:** upper limit 500 mcg per day; excess iodine may trigger thyroid dysfunction.

**10.4. Conflicting: берберин vs метформин при СД2.**

    > 📚 **EBM** [Level 1b, RCT, open-label] [surrogate] [⚡ Conflicting evidence]
    > **Yin J, et al. 2008.** Berberine 500 mg three times daily decreases HbA1c by 2.0 percent, comparable to metformin.
    > **Population:** adults with type 2 diabetes (n=36, 3 months).
    > *Metabolism* 57(5):712-717. PMID: [18442638](https://pubmed.ncbi.nlm.nih.gov/18442638)
    > ⚡ **Conflict:** larger trials show weaker glycemic effect, see Lan 2015 PMID 25498346.
    > 🔗 **Interaction:** metformin — additive glucose lowering, monitor for hypoglycemia.

**10.5. Критичное вещество с Safety: железо при гемохроматозе.**

    > 📚 **EBM** [Level 5, expert opinion] [clinical]
    > **Consensus, 2020.** Ferrous bisglycinate supplementation maintains iron status but is contraindicated in hereditary hemochromatosis.
    > **Population:** adults with iron overload / hereditary hemochromatosis (contraindication note).
    > *Clinical consensus.* PMID: N/A. DOI: [10.xxxx/hemochromatosis](https://doi.org/10.xxxx/hemochromatosis)
    > ⚠️ **Safety:** contraindicated in hemochromatosis; iron accumulation causes organ damage.

---

## 11. References (образец раздела для inline-версии)

Так выглядит раздел «References» в конце методички, раскрывающий inline-теги из раздела 6.

**References**

1. 📚 **EBM** [Level 1a, meta-analysis, N/A] [hard] — **Bischoff-Ferrari HA, et al. 2009.** Cholecalciferol 700-1000 IU per day reduces non-vertebral fractures by 20 percent vs placebo. **Population:** older adults (12 RCT, total n=42279, 12+ months). _BMJ_ 339:b3692. PMID: [19307517](https://pubmed.ncbi.nlm.nih.gov/19307517). ⚠️ **Safety:** upper limit 4000 IU per day.
2. 📚 **EBM** [Level 1a, meta-analysis, N/A] [clinical] — **Martineau AR, et al. 2017.** Cholecalciferol supplementation reduces acute respiratory infection risk, OR 0.88 (95% CI 0.81 to 0.96) vs placebo. **Population:** all ages (25 RCT, total n=11321, trial duration varied). _BMJ_ 356:i6583. PMID: [28202713](https://pubmed.ncbi.nlm.nih.gov/28202713).
3. 📚 **EBM** [Level 1b, RCT, double-blind] [clinical] — **Okereke OI, et al. 2020.** Cholecalciferol 2000 IU per day does not prevent depression vs placebo. **Population:** adults 50+ years (n=18353, median 5.3 years). _JAMA_ 324(5):471-480. PMID: [32749491](https://pubmed.ncbi.nlm.nih.gov/32749491).

---

## 12. Уроки пилота миграции №1 (v3.1)

Раздел выведен из пилотного прогона миграции 3 тегов файла `references/methodology/pancreas_health.md` на v3.0 (2026-08-14). Пилот выявил 7 системных проблем, каждая закрыта правилом ниже. Все правила действуют совместно с разделами 1–11.

### 12.1. PMC full-text fallback (automatic)

Если abstract статьи не содержит критичных числовых данных (`n`, длительность/follow-up, доза) — агент действует автоматически:

1. Проверяет наличие PMC ID в `esummary` (поле `articleids` с `idtype=pmc`, либо `pmc`).
2. При наличии PMC ID делает второй запрос: `efetch db=pmc id=<PMC_ID>&rettype=xml`.
3. Ищет числовые данные в секциях Methods / Results (размер выборки, длительность, доза).

Правила:

- Работает **автоматически** для open access статей (PMC full-text доступен).
- Если данные найдены в PMC — confidence остаётся **HIGH**, но поле помечается источником `[source: PMC full-text]` (в annotated-версии).
- Если статья не в open access или PMC ID отсутствует — fallback не выполняется, поля остаются `n/a` (см. урок 2).

### 12.2. `n/a` вместо `NOT_IN_ABSTRACT` в чистом теге

- В финальном v3.0-блоке для файла методологии числовые поля без данных пишутся как `n=n/a`, `follow-up=n/a`.
- Плашка `NOT_IN_ABSTRACT` используется **только** в annotated-версии тега (для отладки и confidence-логирования).
- Обоснование: файл методологии читает нутрициолог, ему нужен чистый тег; отладочные плашки — визуальный шум и ложный сигнал «ошибка».
- Пример чистого блока с `n/a` — см. раздел 2 (Wagner 2021).

### 12.3. Убирать пустые плейсхолдеры для non-interventional работ

Для работ типа **cohort / cross-sectional / guideline / registry / editorial** поля substance / dose / effect объективно неприменимы — исследование не про вещество и дозу.

- Вместо `[Substance/dose: NOT_IN_ABSTRACT] [Quantitative effect: NOT_IN_ABSTRACT]` — просто **одна фраза с findings** из abstract (что именно показано/рекомендовано).
- Пустые плейсхолдеры substance/dose остаются **только** для интервенционных работ (RCT, meta-analysis of RCT), где вещество и доза _должны были быть_, но их нет в abstract — это сигнал подозрительной работы, требующей ручной проверки.

### 12.4. Guideline detection по нескольким источникам

`PublicationType` не всегда содержит `Guideline` (в пилоте Löhr HaPanEU шёл в PubMed как `Review`, хотя это evidence-based guideline).

Правило v3.1: если **title** или **abstract** содержит любое из ключевых слов —
`guideline`, `guidelines`, `consensus`, `recommendations`, `position statement`, `criteria`, `HaPanEU`, `IAP/APA`, `ACG guideline` —
классифицировать источник как `[Level 5, Guideline]` **независимо** от `PublicationType`. Confidence: `[HIGH]`.

### 12.5. Legacy topic mismatch — предупреждение и второй кандидат

- Если legacy-тег в файле описывает тему X (по контексту предложения вокруг тега), а abstract новой найденной статьи — про тему Y, расхождение помечается `TOPIC_MISMATCH_DETECTED` в annotated-версии.
- В этом случае агент ищет **второго кандидата**: контекстный поиск в PubMed по теме legacy-тега на английском (auto-translate предложения-контекста RU→EN).
- Второй кандидат отбирается по фильтрам:
  - **Журнал** Q1–Q2 (impact factor > 5) или из белого списка: NEJM, Lancet, Gastroenterology, JAMA, Nature Medicine, BMJ, Diabetes Care, Gut, Am J Gastroenterol, Ann Intern Med, Circulation.
  - **PublicationType:** RCT / Meta-Analysis / Systematic Review / Guideline / Practice Guideline.
  - **Citations** > 50 (для работ ≥ 5 лет) или **Altmetric** > 20 (для новых).
- Если ни одна статья фильтры не проходит — второй кандидат не предлагается, оставляется только первый (из карты миграции).

### 12.6. Старые статьи без abstract

- Для работ до ~1975 года `<AbstractText>` в PubMed часто отсутствует.
- Правило: если `<AbstractText>` пустой — **не пытаться** извлечь Substance / Effect / Population из внутренних знаний.
- В annotated-версии ставится `[NO_ABSTRACT_AVAILABLE — pre-1975 publication]`, confidence `LOW`.
- В чистом теге v3.0 bibliographic record (автор, год, журнал, том, страницы, PMID) — полный, а клинические поля = `n/a`.
- Такие работы валидируются нутрициологом вручную.

### 12.7. Verification block обязателен

Каждый annotated-файл заканчивается секцией `## Verification` с двумя пунктами:

1. **Сверка author / year / journal** с картой миграции: `PASS` / `FAIL` (с деталями расхождения).
2. **Topic mismatch check** — совпадает ли тема legacy-тега с abstract: `PASS` / `MISMATCH_DETECTED` + описание расхождения.

---

## Приложение А. История изменений стандарта

- v3.1 (2026-08-15, уроки пилота №1): добавлен раздел 12 с 7 уроками (PMC full-text fallback, `n/a` вместо `NOT_IN_ABSTRACT` в чистом теге, удаление пустых плейсхолдеров для non-interventional работ, guideline-детекция по нескольким источникам, legacy topic mismatch + второй кандидат, правило для работ до ~1975 без abstract, обязательный блок `## Verification`). Уточнён пример чистого тега в разделе 2.
- v3.0 (2026-08-14): полный самодостаточный блокквот-тег (Level, форма, доза, эффект, Population, PMID), условные поля Safety/Interaction/Currency, 10 точек валидации, спецформаты (мета-анализ, guideline, conflicting, no-PMID), inline-версия с References. Замещает v1.1.
- v1.1 (2026-07-31, Session 50): EBM-lite, формат `[EBM: Автор Год]`. Переведён в статус LEGACY.

---

EBM_STANDARD_v3.1_APPLIED
