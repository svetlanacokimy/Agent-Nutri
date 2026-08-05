# STATUS.md — состояние проекта Agent-Nutri v2

## 📌 Текущее состояние (на 2026-07-31, Session 53)

**Ветка:** `main`
**Последнее событие:** Session 55, Этап F.2 — EBM-обогащение `female_hormones.md` (PARTIAL → FULL_EBM, 29 → 37 EBM-тегов, +8 inline, v2.1 → v2.2). Прогресс: 8 → **9 FULL_EBM** файлов (17.0 %), 5 → 4 PARTIAL, 492 → **500 EBM-тегов** (+8). 🎉 Полтысячи EBM-тегов в методологии.
**Источник нумерации кластеров:** `references/methodology/_clusters.md` (SSoT), версия 1.1.

### Слой знаний — снимок

- **Файлов в `references/methodology/` (контентных):** 55 (47 из Этапа A + 8 новых из Этапа B2) + 4 служебных (`README.md`, `_clusters.md`, `_conventions.md`, `_template.md`).
- **Подключено в `v2/SOURCES_INDEX.md`:** 55/55 (**100 %**).
- **Кластеров:** 18 (было 11, добавлено 7 новых: 12–18).
- **Старый плоский слой `references/NN_*.md`:** сохранён (14 файлов) как исторический архив. Не удаляется никогда.

### Этапы миграции базы знаний

| Этап | Описание                                                                    | Статус |
| ---- | --------------------------------------------------------------------------- | ------ |
| A    | Подключение существующих 47 файлов в `SOURCES_INDEX`                        | ✅     |
| B1   | Создание 8 новых методичек (Категория B + расширение)                       | ✅     |
| B2   | Синхронизация `SOURCES_INDEX.md` + `_clusters.md` (кластеры 12–18)          | ✅     |
| B3   | Переключение прямых ссылок в скилах и пайплайнах                            | ⏳     |
| C    | Создание `joints_osteoporosis.md` (последний плановый протокол Категории B) | ⏳     |
| D    | Проставление DEPRECATED-шапок в старых файлах `references/NN_*.md`          | ⏳     |

### Открытые вопросы миграции

- **Категория B (плановые протоколы), осталось 1 из 4:**
  - ✅ `nutraceuticals.md` (создан 2026-07-27, 551 строка)
  - ✅ `skin_hair_health.md` (создан 2026-07-27, 618 строк)
  - ✅ `nervous_system.md` (создан 2026-07-27, 637 строк)
  - ⏳ `joints_osteoporosis.md` — суставы, остеопороз (запланирован).

- **Этап B3 — переключение ссылок:**
  - `skills/client_intake.md` (стр. 24, 25) → `client_intake.md`/`client_assessment.md`, `protocols/lab_diagnostics.md`.
  - `skills/create_menu.md:27` → `nutrition_basics.md` + `nutrition_principles.md` + `menus.md`.
  - `skills/recommend.md:22` → `vitamins.md` + `minerals.md` + `nutraceuticals.md`.
  - `skills/unit_conversion.md` → `references/methodology/tables/unit_conversions.md`.
  - `v2/PIPELINES.md` (стр. 138, 172) → новый слой.
  - `v2/KNOWLEDGE_PROTOCOL.md` (стр. 13, 60), `v2/SELF_LEARNING.md:92`, `RULES.md:45` → актуализация примеров.

### Активные кластеры (1–18) — статус

- **Кластер 1** (Основы питания и пищеварения): `digestion_basics.md`, `nutrition_basics.md`, `nutrition_principles.md` — 3/3 ✅
- **Кластер 2** (ЖКТ): 7/7 ✅ — `stomach_health.md`, `intestinal_health.md`, `colon_coprogram.md`, `sibo_sifo.md`, `gluten_celiac.md`, `ibs.md`, `ibd.md`.
- **Кластер 3** (Гепато-билиарно-панкреатическая система): `liver_health.md`, `gallbladder_health.md`, `pancreas_health.md` — 3/3 ✅
- **Кластер 4** (Щитовидная железа): `thyroid_health.md`, `hashimoto.md` — 2/2 ✅
- **Кластер 5** (Метаболизм и углеводы): `insulin_resistance.md` — 1/1 ✅
- **Кластер 6** (Женское здоровье): `female_hormones.md`, `menopause.md`, `mastopathy.md` — 3/3 ✅
- **Кластер 7** (Стресс и надпочечники): `stress_adrenals.md` — 1/1 ✅
- **Кластер 8** (Микронутриенты, витамины и минералы): `vitamins.md`, `minerals.md` — 2/2 ✅
- **Кластер 9** (Аутоиммунные): `autoimmune_basics.md` + 9 подпротоколов — ✅
- **Кластер 10** (Паразитология): `parasitology_basics.md`, `giardia.md`, `blastocystis.md`, `helminths.md`, `protozoa_others.md`, `sibo_parasites_overlap.md` — 6/6 ✅
- **Кластер 11** (Клиентская работа): 8/8 ✅
- **Кластер 12** (Кожа, волосы, ногти): `skin_hair_health.md` — 1/1 ✅ **(NEW)**
- **Кластер 13** (Урогенитальные инфекции): `urogenital_infections.md` — 1/1 ✅ **(NEW)**
- **Кластер 14** (Лимфа и иммунитет): `lymph_immune.md` — 1/1 ✅ **(NEW)**
- **Кластер 15** (Нервная система): `nervous_system.md` — 1/1 ✅ **(NEW)**
- **Кластер 16** (COVID и подготовка к беременности): `covid_pregnancy.md` — 1/1 ✅ **(NEW)**
- **Кластер 17** (Меню и рационы): `menus.md` — 1/1 ✅ **(NEW)**
- **Кластер 18** (Нутрицевтики): `nutraceuticals.md` — 1/1 ✅ **(NEW)**

**Инфраструктура (вне кластерной нумерации):**

- `references/methodology/tables/unit_conversions.md` — перенесён из `references/` (2026-07-27).
- `references/methodology/tables/lab_values_master.md` (85 параметров).
- `references/methodology/protocols/lab_diagnostics.md` (7-шаговый алгоритм).

**Итого:** 55/55 контентных файлов подключены (**100 %**). Все 18 кластеров имеют файлы на диске и в индексе.

---

## 🔄 Последняя сессия — 2026-07-31 (Session 53, Этап F.2)

**Тема:** EBM-обогащение `female_hormones.md` — PARTIAL_EBM → FULL_EBM (+8 inline тегов в §5/§8/§12/§13/§18/§19/§21/§23)

### Что сделано

- `references/methodology/hashimoto.md`: v1.1 → v1.2, **34 EBM-тега** (было 24, +10), 625 строк, 181.4 KB. Коммит `ff2008b` (+13/-13 строк, Δ +536 символов).
- `scripts/ebm_enrich_hashimoto_v2.ps1` (180 строк): идемпотентный маркер `<!-- EBM_ENRICHED_v1.2 -->`, 10 успешных inline-патчей из 14 попыток (4 альтернативных якоря для устойчивости к опечаткам склеенных слов в исходном тексте).
- Новые EBM-источники: **Stagnaro-Green 2011** (ATA Postpartum Thyroiditis), **Mizokami 2004** (стресс-АИТ), **Ch'ng 2007** (целиакия-АИТ), **Tomer 2013** (IFN-α thyroiditis), **Kim 2017** (D3-АИТ мета-анализ), **Mahmoodianfard 2015** (Zn+Se), **Rayman 2019** (micronutrients thyroid), **Messina 2006** (soy isoflavones), **Skelin 2017** (T4 absorption), **Alexander 2017** (ATA Pregnancy Guidelines).
- Покрытые зоны: §3.4 послеродовый период, §3.5 стресс-HPA, §3.6 глютен-целиакия, §3.7 IFN-тиреоидит, §7.2 витамин D, §7.3 ферритин >70, §7.4 цинк, §8.4 соя, §9.1 L-T4 приём, §9.3 беременность ТТГ<2.5.

### Результаты аудита (по `project/EBM_STANDARD.md` v1.0)

- **FULL_EBM: 9/53 файлов (17.0%)** — было 8, +1 (`female_hormones.md`)
- **PARTIAL_EBM: 4/53 файлов (7.5%)** — было 5, -1
- **NO_EBM: 40/53 файлов (75.5%)** — без изменений
- Всего EBM-тегов: **500** (было 492, +8 — 🎉 полтысячи EBM-тегов в методологии)
- Всего строк: 37 375

### Технические уроки

- Разведка контента через `Select-String` + прямой вывод фрагментов файла с номерами строк перед составлением патчей — обязательный шаг для устойчивости к опечаткам.
- Стратегия «парных якорей» (P1/P1b и т.д.) — эффективный способ идемпотентно обрабатывать файлы с потенциально склеенными словами при копировании из PowerShell-вывода.
- Файлы с существующим §EBM Benchmark и подробными Src-ссылками требуют только inline-тегов, не структурного расширения (экономия ~50% усилий на сессию).
---

## ➡️ Следующая сессия — Session 56 (Этап F.2 продолжение)

**Цель:** структурная нормализация `nervous_system.md` (PARTIAL_EBM → FULL_EBM, быстрая доводка)

### Исходное состояние

- `references/methodology/vitamins.md`: 1777 строк, 171.6 KB (самая крупная методичка проекта)
- **36 EBM-тегов уже есть** (порог FULL_EBM = 30 перекрыт), §19 EBM Benchmark на месте
- `EBM Benchmark` секция присутствует (yes), метаданные отсутствуют (no)
- Маркер обогащения ещё не установлен → v1.1 (новый)

### Ключевые источники для добавления

- **IOM DRI 2011** — референсные диапазоны витамина D
- **Manson 2019 VITAL** — витамин D 2000 МЕ РКИ (кардио/онко)
- **LeBoff 2022 VITAL bone** — витамин D и переломы
- **Endocrine Society 2024** — обновлённые рекомендации по D
- **Autier 2014 Lancet Diabetes Endocrinol** — мета-анализ D
- **Green 2017 Blood** — диагностика дефицита B12
- **MRC 1991 Lancet** — фолиевая кислота и NTD (Neural Tube Defects)
- **Knapen 2013** — витамин K2 (переиспользовать из joints)
- **WHO 2011** — витамин А и иммунитет
- **Klein 2011 SELECT** — витамин E (переиспользовать из hashimoto)

### Оценка усилий

- 90–120 минут (файл в 3× больше hashimoto)
- Стратегия: разведка H2-структуры → 12–15 inline-патчей → расширение §EBM Benchmark если требуется
- Целевой маркер: `<!-- EBM_ENRICHED_v1.1 -->`

### Оставшиеся PARTIAL_EBM после Session 56

covid_pregnancy.md, female_hormones.md, gallbladder_health.md, nervous_system.md, pancreas_health.md, stress_adrenals.md — итого 6 файлов на Sessions 54–57.

### Долгосрочный план Этапа F.2

- Session 56: covid_pregnancy.md (16 тегов → ~25, добавить 9-10 тегов до FULL_EBM — ACOG COVID pregnancy, RCOG, WHO, Cochrane)
- Session 55: female_hormones.md (29 → ~35, добавить 5–8 тегов)
- Session 56: covid_pregnancy.md (16 → ~32 тега, +§21 добавления)
- Session 57: stress_adrenals.md (0 тегов, полный §Benchmark + inline-теги)
- Session 58: gallbladder_health.md + pancreas_health.md (0 тегов каждый, +Benchmark)

**Прогноз к концу Session 58:** 12/53 FULL_EBM (22.6 %), 0 PARTIAL, 41 NO_EBM.

## 📜 История сессий (краткая хронология)

- **Session 55** (2026-07-31, Этап F.2): `female_hormones.md` PARTIAL → FULL_EBM (+8 inline EBM-тегов: 29 → 37, v2.1 → v2.2). Теги в §5 Прогестерон (Stanczyk 2013 / Prior 2015), §8 Пролактин + §12 Гиперпролактинемия (Melmed 2011 Endocrine Society), §13 ПМС/ПМДР (ACOG 2023, Cochrane Whelan 2009 B6, Thys-Jacobs 1998 Ca RCT), §18 КОК (Palmery 2013, WHO MEC 2015), §19 Лабдиагностика (ESHRE Rotterdam 2003, Monash 2018, NICE NG73), §21 Питание и §23 Образ жизни (Monash 2018, NAMS 2022). Коммит `6013e29` (+13/-12). 🎉 **9/53 FULL_EBM (17.0 %), 500 EBM-тегов (+8) — полтысячи.**
- **Session 54** (2026-07-31, Этап F.2): `nervous_system.md` PARTIAL → FULL_EBM (36 EBM-тегов подтверждено, v1.1 → v1.2). Структурная нормализация без правки контента: маркер `<!-- EBM_ENRICHED_v1.2 -->`, статус EBM-lite → FULL_EBM, история версий v1.0 → v1.1 → v1.2. Атомарные патчи вместо multiline-скрипта (правило Session 52 + урок Session 54: multiline @-strings в PS 5.x → возврат к формату Session 50-53). Коммит `46fc173` (+6/-3). 🎉 **8/53 FULL_EBM (15.1 %), 492 тега (без изменений).**
- **Session 53** (2026-07-31, Этап F.2): `vitamins.md` PARTIAL → FULL_EBM (29 → 43 EBM-тега, v1.1 → v1.2). Скрипт `ebm_enrich_vitamins_v2.ps1` (168 строк, 13 патчей). Источники: Smith 2018 B12 neurology, Hemilä 2013 Cochrane Vit C, ATBC 1994 NEJM, Omenn 1996 CARET, Klein 2011 SELECT, Lonn 2005 HOPE-TOO, AIM-HIGH 2011, HPS2-THRIVE 2014, Schaumburg 1983, Caudill 2018, Wang 2011 TMAO, Koeth 2013, Unfer 2017 PCOS, D'Anna 2013 GDM. Коммит `1fb26fe` (+185/−17). 🎉 **7/53 FULL_EBM (13.2 %), 492 тега.**
- **Session 52** (2026-07-31, Этап F.2): `hashimoto.md` PARTIAL → FULL_EBM (24 → 34 EBM-тега, v1.1 → v1.2). Скрипт `ebm_enrich_hashimoto_v2.ps1` (180 строк, 10 патчей, стратегия парных якорей). Источники: Stagnaro-Green 2011, Mizokami 2004, Ch'ng 2007, Tomer 2013, Kim 2017, Mahmoodianfard 2015, Rayman 2019, Messina 2006, Skelin 2017, Alexander 2017 ATA Pregnancy. Коммиты: `ff2008b` (обогащение), `e55b583` (частичное закрытие), fix-коммит (ремонт). Прогресс: FULL 5→6, PARTIAL 8→7, тегов 468→478.

- **Session 51** (Этап F.2, 2026-07-31): `joints_osteoporosis.md` PARTIAL → **FULL_EBM** (0 → 33 EBM-тега, v1.0 → v1.2), §16 EBM benchmark сохранён. Два скрипта: v1 (11/14 патчей) + v2 (20/20 патчей после точечной разведки). Источники: WHO 1994, NOF 2022, VITAL, GAIT, Knapen 2013, Kuptniratsaikul, Bolland, Rizzoli ESCEO. Коммит `59447a5` (+442/−30). 🎉 **5/53 FULL_EBM (9.4 %).**
- **Session 50** (Этап F.1, 2026-07-31): `nutraceuticals.md` 0 → 74 EBM-тегов, +150 строк, §13 EBM Benchmark. Создан `EBM_STANDARD.md` v1.0 (308 строк). Создан `audit_ebm_compliance.ps1` — карта состояний 53 файлов: 4 FULL / 9 PARTIAL / 40 NO_EBM. Коммиты `66d1a15`, `a8c8cb2`. 🎉 **Этап F запущен.**
- **Session 49** (закрытие миграции, 2026-07-31): Merge PR #2 (69 коммитов, +26 515 / −6 584) в `main`. Merge commit `cf54b6e`. Ветка `copilot/build-v2-nutrition-agent-core` удалена. 🎉 **Этапы A–E замёржены в main.**
- **Сессия 47** (EBM Этап E 8/8, 2026-07-27): `thyroid_health.md` v2.0→2.1, 798 строк, 106.5 KB, **116 EBM-тегов** (рекорд), 11 inline-замен, §§27.4–27.8 (OCEBM, таблица 10 расхождений, гайдлайны ATA/ETA/NICE, 20 RCT с DOI). Коммиты `bce6025` (+172/−81), `fefde08` (+326, script). 🎉 **Этап E закрыт 8/8 = 100 %.**
- **Сессия 46** (EBM 7/8, 2026-07-26): `autoimmune_basics.md` v1.0→1.1, 1017 строк, 87.2 KB, **81 EBM-тег**, 15 inline-замен, §10 EBM benchmark (иерархия, 10 расхождений, EULAR/ACR/ECCO, 20 RCT). Коммиты `c448de8` (+151/−61), `3af1f9a` (+316, script).
- **Сессия 45** (EBM 6/8, 2026-07-26): `female_hormones.md` v2.0→2.1, 885 строк, 86.9 KB, 29 EBM-тегов, 21 inline-замен, §§27.4–27.8 (Monash/AE-PCOS 2023, NICE NG73, NAMS 2022, 25 RCT). Коммиты `c9d2c01` (+113/−14), `5a2555a` (+350, script).
- **Сессия 44** (EBM 5/8, 2026-07-25): `hashimoto.md`, 624 строки, 180.8 KB, 24 EBM-тега. Diff +101/−18.
- **Сессия 43** (EBM 4/8, 2026-07-25): `vitamins.md`, 1776 строк, 171.6 KB, 29 EBM-тегов. Diff +107/−23.
- **Сессия 42** (EBM 3/8, 2026-07-25): `minerals.md`, 1376 строк, 94.2 KB, 30 EBM-тегов. Diff +105/−22.
- **Сессия 41** (EBM 2/8, 2026-07-24): `nervous_system.md`, ~900 строк, ~90 KB, ~25 EBM-тегов. Обработана структурная аномалия (дубликаты H2).
- **Сессия 40** (EBM 1/8, 2026-07-24): `covid_pregnancy.md`, ~800 строк, ~85 KB, ~25 EBM-тегов. Старт Этапа E — идемпотентный EBM-lite enrichment (уровень 1 OCEBM).
- **Сессия 39** (Этап C, 2026-07-21): создан `joints_osteoporosis.md` — суставы, остеоартроз, РА, остеопороз, DEXA, T/Z-score, кальций/D/K2/магний, бисфосфонаты. Открыт **Кластер 19**. Коммиты `a5243c6`, `0cd159f`, `f4c309a`. 🎉 **Этап C закрыт 9/9.**
- **Сессия 38** (миграция B2+B3, 2026-07-27): создано 8 методичек в `references/methodology/` (4 486 строк): `tables/unit_conversions.md` (408), `skin_hair_health.md` (618), `urogenital_infections.md` (605), `lymph_immune.md` (512), `nervous_system.md` (637), `covid_pregnancy.md` (654), `menus.md` (501), `nutraceuticals.md` (551). Синхронизированы реестры: `SOURCES_INDEX.md` (+25/−7, 619 строк), `_clusters.md` (+74/−17, 131 строка, кластеры 12–18, v1.1). Cleanup: `.gitignore` + `patch_sources_index.ps1`. 11 коммитов: `df720ad`, `1c64b15`, `223ac47`, `0ba0556`, `1e0a545`, `ff186f2`, `46e2b44`, `cb4a910`, `b748356`, `34411e5`, `3e241ab`. 🎉 **7 новых кластеров (12–18) открыты и закрыты.**
- **Миграция Этап A** (SOURCES_INDEX, 2026-07-13, коммит `22b93d1`): подключены 28 ранее «невидимых» файлов нового слоя в `v2/SOURCES_INDEX.md` → 47/47 (100 %). Cleanup клиентских папок — коммит `decd67f`.
- **Сессия 37** (Кластер 11 «Клиентская работа», 2026-07-05..2026-07-07): создано 8 файлов — `client_intake.md`, `client_assessment.md`, `motivational_interviewing.md`, `goal_setting.md`, `objection_handling.md`, `client_communication.md`, `long_term_support.md`, `ethics_scope.md`. Коммиты: `7423c7a`, `8134199`, `2e0d720`, `30b84a7`, `e40cb34`, `04ebf92`, `c37eca0`, `9814c50`, `07790ad`. Кластер 11 закрыт 8/8.
- **Сессия 36** (Кластер 10 «Паразитология», 2026-07-04): `parasitology_basics.md`, `blastocystis.md`, `giardia.md`, `helminths.md`, `protozoa_others.md`, `sibo_parasites_overlap.md`. Коммиты: `0e23e45`, `e89cccf`, `2d014d0`, `9d353a7`, `5c1c045`, `8196927`. Кластер 10 закрыт 6/6.
- **Сессия 35** (minerals, 2026-07-03): создан `minerals.md` (1293 строки, 14 минералов). Коммит `bc1ca3f`. Переименование Кластера 8 → «Микронутриенты (витамины и минералы)» — `e4cbb8f`. **Кластер 8 закрыт 2/2.**
- **Сессия 34** (vitamins, 2026-07-03): создан `vitamins.md` (1692 строки, 14 микронутриентов). 5 коммитов. **Кластер 8 открыт.**
- **Сессия 33** (ibd, 2026-06-24): `ibd.md` (884 строки). 6 коммитов. **Кластер 2 закрыт 7/7.**
- **Сессия 32** (ibs, 2026-06-23): `ibs.md` (673 строки). 5 коммитов.
- **Сессия 31** (gluten_celiac, 2026-06-22): `gluten_celiac.md` 538 → 788 строк. 5 коммитов.
- **Сессия 30** (sibo_sifo, 2026-06-22): `sibo_sifo.md` 472 → 661 строк. 4 коммита.
- **Сессия 29** (архитектурная реструктуризация, 2026-06-22): переход к 11-кластерной архитектуре, создан `_clusters.md` и `_template.md`. 5 коммитов.
- **Сессия 28.5** (унификация метаданных, 2026-06-20): все 17 файлов приведены к единому блоку `## Метаданные` v2.0.
- **Сессия 28** (intestinal + cleanup, 2026-06-19): `intestinal_health.md` 445 → 879 строк. Создана инфраструктура — `_conventions.md`, `audit_links.ps1`.
- **Сессия 27** (pancreas, 2026-06-18): `pancreas_health.md` 469 → 901 строк.
- **Сессия 26** (liver, 2026-06-18): `liver_health.md` 580 → 984 строк.
- **Сессия 25** (gallbladder, 2026-06-18): `gallbladder_health.md` 396 → 663 строк.
- **Сессия 24** (stomach, colon): `stomach_health.md` (964 строки), `colon_coprogram.md` (877 строк).

**Активных кластеров:** 19 из 19. **Контентных файлов:** 56/56 подключены (100 %). **EBM-lite покрытие:** 8/8 приоритетных методичек (~360 EBM-тегов). **Этапы миграции:** A ✅ / B1 ✅ / B2 ✅ / B3 ✅ / C ✅ / D ✅ N/A / **E ✅**. **Примечание по Этапу D:** задача «DEPRECATED-заголовки в 14 файлах `references/NN_*.md`» признана фантомной (Session 48, 2026-07-27) — файлы не существуют ни в текущем состоянии репозитория, ни в истории git (`--diff-filter=D --all` дал пустой результат). Реальная миграция контента завершена в Этапах A–C.

---

## 🧭 Как пользоваться этим файлом

- **Верхний блок** (текущее состояние) — читать в первую очередь в начале каждой сессии.
- **Раздел «Следующая сессия»** — точка входа для новой сессии; там прописан приоритет задач.
- **История сессий** — обратная хронология; каждая запись содержит хеши коммитов для трассировки.
- **SSoT для нумерации кластеров** — `references/methodology/_clusters.md`; здесь только зеркало.
- **Обновлять STATUS.md** — в конце каждой сессии, не откладывать на потом.

<!-- STATUS_SESSION55_APPLIED -->
