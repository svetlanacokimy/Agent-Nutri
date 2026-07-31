# Аудит кросс-ссылок 2026-07-05

> **Session 35.** Только аудит — без правок. Правка отдельным шагом после одобрения.
> Методология: автоматический скан (`scripts/_temp/audit_crossrefs_v2.ps1`) по всем `v2/*.md`, `AGENT.md`, `RULES.md`, `CLAUDE.md`, `skills/*.md`, `references/**/*.md`, `clients/**/*.md`, `project/*.md` + ручная верификация найденных путей и статусов (DEPRECATED-метки, `_clusters.md`, `STATUS.md`).

## Сводка

- Проверено файлов: **~91** (v2/ 8, корень 3, skills/ 6, references/** ~44, clients/** ~25, project/\*.md 5)
- Найдено уникальных упоминаний путей: **838** (806 существующих + 32 несуществующих, после дедупликации по File+Line+Path)
- ✅ Валидных и актуальных: **~757**
- 🔄 Устаревших (путь существует, но есть версия в новом слое): **~49** (в основном `skills/*.md` и `v2/*.md`, ссылающиеся на `references/01…13_*.md`)
- ⚠️ DEPRECATED (файл существует, явно помечен устаревшим): **4** старых файла упомянуты как DEPRECATED хотя бы в одном месте (`03_lab_diagnostics.md`, `11_reference_values.md`, `01_digestion_gastro.md`, `02_nutrition_basics.md`)
- ❌ Битых (путь не существует): **29** реальных + **3** артефакта regex-скана (не являются настоящими ссылками, см. ниже)

---

## 🔴 Критичные (блокируют работу агента)

### RULES.md

- `RULES.md:97` → `clients/Karaianova/2026-04-19_recommendations_v2.md` — статус: ❌ **битая**. Реальный файл лежит по пути `clients/Karaianova/_archive/2026-04-19_recommendations_v2.md` (перемещён в архив, ссылка не обновлена). **Критично**, т.к. это заявленный «эталон глубины» для ВСЕХ expert-консультаций.
- `RULES.md:101` → тот же путь, тот же дубль-эталон, вторая битая ссылка на файл-образец в этом же документе.

### v2/SOURCES_INDEX.md

- `v2/SOURCES_INDEX.md:105` → `references/methodology/lab_diagnostics.md` — статус: ❌ **битая**, актуально: `references/methodology/protocols/lab_diagnostics.md` (файл лежит в подкаталоге `protocols/`, не напрямую в `methodology/`).
- `v2/SOURCES_INDEX.md:432` → `references/methodology/lab_diagnostics.md` — та же ошибка, второе упоминание.
- `v2/SOURCES_INDEX.md:74` → `text_extracted/УРОК 19. Анализы.txt` — статус: ❌ **битая**, актуальный файл называется `text_extracted/УРОК 19. Разбор анализов.txt`.

### skills/\*.md — устаревшие (не битые) ссылки на старый слой

Файлы существуют, поэтому формально не «битые», но `skills/*.md` — часть архитектурного слоя, который должен ссылаться на приоритетный (новый) слой знаний. Обнаружено **🔄 устаревших** ссылок:

- `skills/recommend.md:21` → `references/09_nutraceuticals.md` — 🔄 устарела; частичный аналог: `references/methodology/vitamins.md` (только витаминные БАД), полного протокола по нутрицевтикам в новом слое нет (кластер 8 не завершён).
- `skills/recommend.md:22` → `references/05_vitamins_minerals.md` — 🔄 устарела; частичный аналог: `references/methodology/vitamins.md` (минералы пока не мигрированы — планируется `minerals.md`).
- `skills/client_intake.md:24` → `references/13_client_work.md` — 🔄 устарела; аналога в `methodology/` нет (Кластер 11 «Клиентская работа» — 🟡 Запланирован в `_clusters.md`).
- `skills/client_intake.md:25` → `references/03_lab_diagnostics.md` — 🔄 устарела (файл сам себя помечает ⚠️ DEPRECATED); актуально: `references/methodology/protocols/lab_diagnostics.md`.
- `skills/client_intake.md:26`, `skills/analyze_blood.md:23/71/80`, `skills/unit_conversion.md:24/30`, `skills/compare_dynamics.md:27` → `references/11_reference_values.md` — 🔄 устарела (⚠️ DEPRECATED по `v2/SOURCES_INDEX.md:25`); актуально: `references/methodology/tables/lab_values_master.md`.
- `skills/create_menu.md:26` → `references/12_menus.md` — 🔄 устарела; аналога-протокола нет, есть только пустая папка `references/methodology/menus/`.
- `skills/create_menu.md:27` → `references/02_nutrition_basics.md` — 🔄 устарела (⚠️ DEPRECATED по `v2/SOURCES_INDEX.md:467`); актуально: `references/methodology/nutrition_basics.md` + `nutrition_principles.md`.

### v2/PIPELINES.md — устаревшие ссылки

- `v2/PIPELINES.md:154` → `references/11_reference_values.md` — 🔄 устарела → `references/methodology/tables/lab_values_master.md`.
- `v2/PIPELINES.md:138` → `references/12_menus.md`, `references/02_nutrition_basics.md` — 🔄 устарели → `nutrition_basics.md` / `nutrition_principles.md` (меню — нет аналога).
- `v2/PIPELINES.md:172` → `references/13_client_work.md`, `references/03_lab_diagnostics.md` — 🔄 устарели (второй уже ⚠️ DEPRECATED) → `protocols/lab_diagnostics.md` (для клиентской работы аналога нет).

### v2/KNOWLEDGE_PROTOCOL.md / v2/SELF_LEARNING.md

- `v2/KNOWLEDGE_PROTOCOL.md:13,60` → `references/09_nutraceuticals.md` — 🔄 устарела, приводится как канонический пример формата цитирования — стоило бы заменить на актуальный пример из нового слоя.
- `v2/SELF_LEARNING.md:92` → `references/09_nutraceuticals.md` — 🔄 устарела, тот же случай (пример диалога про берберин).
- `v2/SELF_LEARNING.md:64` → `references/файл.md / v2/файл.md` — это **не реальная ссылка**, а шаблон-placeholder в тексте инструкции («Источник правды: [пользователь / эталон / references/файл.md / v2/файл.md]»). Ложное срабатывание regex-скана, править не нужно.

### AGENT.md / CLAUDE.md

- `AGENT.md:166` → «`v2/ с RULES.md`» — **ложное срабатывание** (кусок предложения «...приоритеты определяются по `v2/HIERARCHY.md`. Краткий порядок: эталоны → v2/ → RULES.md → skills/\*.md» захвачен regex-парсером как единый путь). Реальная ссылка на `v2/HIERARCHY.md` в той же строке — ✅ валидна. Ничего чинить не нужно, кроме как исключить такие конструкции из будущих regex-аудитов.
- `CLAUDE.md:105` → «`v2/ и AGENT.md`» — тот же тип артефакта («правила — в v2/ и AGENT.md»). Не реальная битая ссылка.

---

## 🟡 Средние (references/methodology/)

- `references/methodology/female_hormones.md:772` → `references/methodology/lab_diagnostics.md` — ❌ **битая**, актуально: `references/methodology/protocols/lab_diagnostics.md`.
- `references/methodology/thyroid_health.md:657` → `references/methodology/lab_diagnostics.md` — ❌ **битая**, та же причина, актуально: `protocols/lab_diagnostics.md`.
- `references/methodology/nutrition_basics.md:11` → `text_extracted/УРОК 6. КБЖУ ДЛЯ ПОХУДЕНИЯ ИЛИ НАБОРА.txt` — ❌ **битая**, реальное имя файла длиннее: `УРОК 6. КБЖУ ДЛЯ ПОХУДЕНИЯ ИЛИ НАБОРА. ПОДДЕРЖКА РЕЗУЛЬТАТА.txt`.
- `references/methodology/tables/lab_values_master.md:825` → `references/clinical_guidelines/thyroid_disorders.md` — ❌ **битая**, но помечена в тексте как «создаётся» — это плановый TODO, не ошибка редактирования.
- `references/methodology/vitamins.md:17` → `references/methodology/minerals.md` — ❌ **битая**, плановый файл («создаётся в Сессии 35-36»).
- `references/methodology/vitamins.md:18` → `references/methodology/antioxidants.md` — ❌ **битая**, плановый файл («создаётся в Сессии 37»).
- `references/methodology/_clusters.md:62` → `project/_temp/CLUSTER_MIGRATION_2026-06-21.md` — ❌ **битая**, в тексте явно указано «будет создана при массовом обновлении метаданных» — плановый TODO.
- `references/methodology/sibo_sifo.md:11` → `references/methodology/intestinal_health.md` — ✅ валидна (для сравнения — большинство внутренних ссылок в methodology/ работают корректно).

**Итог по methodology/:** из ~24 файлов протоколов только 2 (`female_hormones.md`, `thyroid_health.md`) содержат реально «случайно» битую ссылку на `lab_diagnostics.md` без префикса `protocols/` — это систематическая опечатка (путь без подкаталога), легко чинится массовой заменой. Остальные битые ссылки в этом разделе — осознанные плейсхолдеры на будущие файлы, а не ошибки.

---

## 🟢 Низкие (старый слой `references/01…13_*.md`)

Сами файлы `references/01_…13_*.md` внутри себя почти не содержат исходящих битых ссылок — единственное исключение с явной пометкой:

- `references/03_lab_diagnostics.md` — весь файл открывается блоком ⚠️ **DEPRECATED** (строки 1-9), корректно ссылается на актуальные `references/methodology/tables/lab_values_master.md` и `references/methodology/protocols/lab_diagnostics.md` — образец правильного оформления deprecated-файла.
- Остальные 12 старых файлов (`01,02,04,05,06,07,08,09,10,11,12,13`) **не содержат** такого предупреждающего блока в самом файле — DEPRECATED-статус для `01_digestion_gastro.md`, `02_nutrition_basics.md`, `11_reference_values.md` указан только в `v2/SOURCES_INDEX.md`, а не в самих файлах. Это несогласованность оформления: агент, открывший файл напрямую (не через SOURCES_INDEX), не увидит предупреждения.

**Рекомендация (не является правкой в рамках этой задачи):** добавить в `02_nutrition_basics.md`, `11_reference_values.md`, `01_digestion_gastro.md` такой же DEPRECATED-блок, как в `03_lab_diagnostics.md`, для единообразия.

---

## 📋 Клиентские (clients/)

Все найденные битые ссылки в клиентских файлах находятся в `clients/Karaianova/_archive/` (уже архивированные исторические документы) и в связанном с ними `clients/Karaianova/_archive/2026-04-20_recommendations_expert.md`. Причина — переименование старого слоя `references/` на более раннем этапе проекта (до нынешней нумерации 01-13):

- `references/06_iron_anemia.md` → упоминается в `2026-04-19_recommendations_v2.md:602,623,662,683` и `2026-04-20_recommendations_expert.md:667,728,751` — файл был переименован/расформирован, содержание по железу теперь частично в `references/05_vitamins_minerals.md`.
- `references/01_lab_values.md` → `2026-04-19_recommendations_v2.md:623,662` и `2026-04-20_recommendations_expert.md:689,730` — переименован в `references/11_reference_values.md`.
- `references/08_thyroid.md` → `2026-04-19_recommendations_v2.md:703` — переименован в `references/06_thyroid_ait.md`.
- `references/07_hormones.md` → `2026-04-19_recommendations_v2.md:717` и `2026-04-20_recommendations_expert.md:788` — переименован в `references/07_hormones_skin_hair.md`.
- `clients/Karaianova/2026-04-19_recommendations_v2.md` (без `_archive/`) → `2026-04-20_recommendations_expert.md:811` — тот же путь, что и битая ссылка в `RULES.md` (см. 🔴 Критичные) — файл переехал в `_archive/`, ссылка не обновлена.

Так как это исторические документы конкретного клиента (не влияют на новые консультации), приоритет починки низкий, но стоит поправить хотя бы централизованно через маппинг (см. раздел «Рекомендации» ниже), т.к. `RULES.md` ссылается на тот же самый неправильный путь.

---

## Рекомендации по починке

### Автоматически (массовая замена по маппингу старый → новый)

| Старый путь                                                      | Новый путь                                                                       | Кол-во упоминаний (оценка)                                                                                |
| ---------------------------------------------------------------- | -------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| `references/methodology/lab_diagnostics.md`                      | `references/methodology/protocols/lab_diagnostics.md`                            | 5 (female_hormones.md, thyroid_health.md, v2/SOURCES_INDEX.md ×3)                                         |
| `clients/Karaianova/2026-04-19_recommendations_v2.md`            | `clients/Karaianova/_archive/2026-04-19_recommendations_v2.md`                   | 3 (RULES.md ×2, \_archive/2026-04-20_recommendations_expert.md ×1)                                        |
| `text_extracted/УРОК 19. Анализы.txt`                            | `text_extracted/УРОК 19. Разбор анализов.txt`                                    | 1 (v2/SOURCES_INDEX.md)                                                                                   |
| `text_extracted/УРОК 6. КБЖУ ДЛЯ ПОХУДЕНИЯ ИЛИ НАБОРА.txt`       | `text_extracted/УРОК 6. КБЖУ ДЛЯ ПОХУДЕНИЯ ИЛИ НАБОРА. ПОДДЕРЖКА РЕЗУЛЬТАТА.txt` | 1 (nutrition_basics.md)                                                                                   |
| `references/11_reference_values.md` (в skills/, v2/PIPELINES.md) | `references/methodology/tables/lab_values_master.md`                             | ~10 (skills/analyze_blood.md, unit_conversion.md, client_intake.md, compare_dynamics.md, v2/PIPELINES.md) |
| `references/03_lab_diagnostics.md` (в skills/, v2/PIPELINES.md)  | `references/methodology/protocols/lab_diagnostics.md`                            | ~3 (skills/client_intake.md, v2/PIPELINES.md)                                                             |
| `references/02_nutrition_basics.md` (в skills/, v2/PIPELINES.md) | `references/methodology/nutrition_basics.md` + `nutrition_principles.md`         | ~2 (skills/create_menu.md, v2/PIPELINES.md)                                                               |

Эти замены безопасны и однозначны — новый файл существует и содержательно замещает старый.

### Требуют ручного решения (нет однозначного соответствия)

- `references/09_nutraceuticals.md` (skills/recommend.md, v2/KNOWLEDGE_PROTOCOL.md, v2/SELF_LEARNING.md) — в новом слое нет отдельного протокола «Нутрицевтики»; частично покрыто `references/methodology/vitamins.md` (только витамины), минералы и остальные БАД (берберин, ашваганда, GSE и т.д.) не мигрированы. Решение: (а) оставить старый файл живым до создания протокола нутрицевтиков, (б) обновить ссылку на `vitamins.md` с явной оговоркой «частично».
- `references/05_vitamins_minerals.md` (skills/recommend.md) — аналогично, минералы не мигрированы (`minerals.md` только запланирован).
- `references/12_menus.md` (skills/create_menu.md, v2/PIPELINES.md) — папка `references/methodology/menus/` существует, но пуста. Решение: либо срочно мигрировать меню, либо явно оставить `12_menus.md` как единственный источник до миграции.
- `references/13_client_work.md` (skills/client_intake.md, v2/PIPELINES.md) — Кластер 11 «Клиентская работа» в `_clusters.md` помечен 🟡 Запланирован, файлов нет вообще. Оставить как есть до создания протокола.
- `references/08_autoimmune_neuro.md`, `references/10_antiparasitic.md`, `references/07_hormones_skin_hair.md` (частично — кожа/волосы не покрыты) — Кластеры 9 и 10 не начаты. Оставить как есть.
- `references/clinical_guidelines/thyroid_disorders.md`, `references/methodology/minerals.md`, `references/methodology/antioxidants.md`, `project/_temp/CLUSTER_MIGRATION_2026-06-21.md` — плановые файлы с явными пометками «создаётся в Сессии N» — не ошибка, а форвард-ссылка на будущую работу; не трогать до соответствующей сессии.
- Битые ссылки на переименованные старые файлы в `clients/Karaianova/_archive/*` (`06_iron_anemia.md`, `01_lab_values.md`, `08_thyroid.md`, `07_hormones.md`) — исторические документы. Решение: (а) не трогать вообще (архив как есть), (б) точечно исправить только для консистентности, без смысловых изменений.

---

## Не решено

- Судьба старого слоя `references/01-13_*.md` в целом: полностью deprecate (с переносом в `project/_archive/`, как уже сделано с планом для `03_lab_diagnostics.md`) или оставить как исторический архив на неопределённый срок? Сейчас только 1 из 13 файлов формально помечен DEPRECATED в самом файле; ещё 3 помечены только в `SOURCES_INDEX.md`, 9 — вообще без пометки.
- Судьба пустых папок `references/biochemistry/` (только README), `references/personal_practice/` (только README) и `references/methodology/menus/` (пусто) — заполнять контентом или удалить/отложить до появления материала?
- Нужно ли форматно различать в `skills/*.md` и `v2/PIPELINES.md` ссылки на старый слой явной пометкой `(временно, до миграции)`, чтобы не создавалось впечатление, что это финальный источник правды?
- Стоит ли исключить артефакты вида «`v2/ и AGENT.md`» / «`v2/ с RULES.md`» из будущих regex-аудитов (сузить паттерн захвата путей), чтобы не засорять отчёты ложными срабатываниями.

---

## Метаданные

- **Дата:** 2026-07-05
- **Сессия:** 35 (audit)
- **Автор:** Agent-Nutri team
- **Тип:** Аудит без правок
- **Источник данных:** `scripts/_temp/crossref_valid_final.csv`, `scripts/_temp/crossref_broken_final.csv` (сгенерированы `scripts/_temp/audit_crossrefs.ps1` + `audit_crossrefs_v2.ps1`), ручная верификация DEPRECATED-статусов.
- **Следующий шаг:** починка по одобрению — начать с раздела «Автоматически» (безопасные замены), затем разобрать «Требуют ручного решения».
