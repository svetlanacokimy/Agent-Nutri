# STATUS.md — состояние проекта Agent-Nutri v2

## 📌 Текущее состояние (на 2026-07-31)

**Ветка:** `main` (ветка `copilot/build-v2-nutrition-agent-core` замёржена через PR #2 и удалена в Session 49).
**Последнее событие:** Этап F.1 — EBM-обогащение `nutraceuticals.md` (0 → 74 EBM-тега, §13 EBM Benchmark). Создана спецификация `project/EBM_STANDARD.md` v1.0 и аудит-инструмент `scripts/audit_ebm_compliance.ps1`.
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

## 🔄 Последняя сессия — 2026-07-31 (Session 50, Этап F.1)

**Тема:** Старт Этапа F — EBM-обогащение `nutraceuticals.md` + создание единой спецификации EBM-стандарта и инструмента аудита.

**Сделано:**

- **`references/methodology/nutraceuticals.md`**: 551 → 655 строк, 63 → 78 KB, **74 EBM-тега** (было 0). Добавлен §13 EBM Benchmark (4 подраздела: гайдлайны, RCT/мета-анализы, «школа vs EBM» на 8+ расхождений, красные зоны). Inline-теги в §3 (Родиола [EBM: Panossian 2010; Ishaque 2012 Cochrane], Мака [EBM: Gonzales 2014], Нони [EBM: West 2018]) и других секциях. Idempotency marker `<!-- EBM_ENRICHED_v1.1 -->`. Backup: `nutraceuticals.md.bak.20260731-184520`. Коммит `66d1a15` (+542/−50).

- **`scripts/ebm_enrich_nutraceuticals.ps1`** (26 987 байт, UTF-8 BOM): идемпотентный EBM-lite enrichment по стандарту Sessions 40–47. 14 патчей применено, 6 SKIP.

- **`project/EBM_STANDARD.md`** v1.0 (18 969 байт, 308 строк, 12 секций): единая спецификация EBM-обогащения — состояния файлов (NO_EBM/PARTIAL_EBM/FULL_EBM), формат inline-тегов, обязательные структурные элементы, idempotency marker, метрики (≥30 тегов, ≥8 расхождений), стандарты PowerShell-скриптов, разрешённые/запрещённые источники, pre-commit чек-лист. Коммит `a8c8cb2`.

- **`scripts/audit_ebm_compliance.ps1`**: аудит всех 53 контентных файлов `references/methodology/` по 15 критериям EBM_STANDARD v1.0. Результат: **FULL_EBM: 4 (7.5 %)** (autoimmune_basics, minerals, nutraceuticals, thyroid_health), **PARTIAL_EBM: 9 (17 %)** (covid_pregnancy, female_hormones, gallbladder_health, hashimoto, joints_osteoporosis, nervous_system, pancreas_health, stress_adrenals, vitamins), **NO_EBM: 40 (75.5 %)**. Всего 435 EBM-тегов, 37 373 строки. Коммит `a8c8cb2`.

**Технические уроки Session 50:**

- **Reality check важнее оптимизма.** До аудита предполагалось «6 файлов до FULL за 3–5 часов». Реальный аудит показал 40 файлов NO_EBM и 9 PARTIAL. Реальный объём Этапа F — 5–7 сессий.
- **Читать CLAUDE.md ДО работы.** Попытка создать параллельные документы (EBM_FACTORY.md, ETAPE_F_PLAN.md) без чтения существующей архитектуры — антипаттерн. Решение: используется существующая иерархия ROADMAP → STATUS → EBM_STANDARD → скрипты.
- **Единый блок кода = единая копия.** Правило проекта: скрипты и патчи присылаются одним PowerShell-блоком, не дробятся. Ручные правки поиском по файлу запрещены.
- **Backtick в PowerShell here-strings небезопасен.** Для литеральных обратных кавычек в @"..."@ использовать переменную `[char]96`. Иначе строка не совпадёт с искомой при .Contains().

**Итого коммитов Session 50:** 2 (`66d1a15`, `a8c8cb2`).

---

## 🔄 Session 49 — 2026-07-31 (закрытие миграции)

**Тема:** Merge PR #2 в `main`, удаление рабочей ветки, синхронизация локального репозитория.

**Сделано:**

- Merge PR #2 (`copilot/build-v2-nutrition-agent-core` → `main`): 69 коммитов, 79 файлов, +26 515 / −6 584 строк. Merge commit `cf54b6e`.
- Локальный `main` fast-forward: `7c679e6` → `cf54b6e`.
- Удалена ветка `copilot/build-v2-nutrition-agent-core` локально и на remote.

**Итого:** миграция базы знаний (Этапы A–E) полностью замёржена в `main`.

<!-- STATUS_SESSION50_APPLIED -->
---

## ➡️ Следующая сессия — Session 51 (Этап F.2)

**Контекст:** Этап F запущен. По данным `audit_ebm_compliance.ps1` от 2026-07-31:
- **FULL_EBM (4/53):** autoimmune_basics, minerals, nutraceuticals, thyroid_health.
- **PARTIAL_EBM (9/53):** covid_pregnancy, female_hormones, gallbladder_health, hashimoto, joints_osteoporosis, nervous_system, pancreas_health, stress_adrenals, vitamins.
- **NO_EBM (40/53):** методологические/клиентские файлы, EBM в форме RCT неприменима.

**План Этапа F — довести 9 PARTIAL до FULL:**

1. `joints_osteoporosis.md` (Session 51) — VITAL, LeBoff 2022, NOF 2022, GAIT 2006, FRAX.
2. `hashimoto.md` (Session 52) — ATA/ETA 2013, Chaker 2017, Rayman 2019.
3. `vitamins.md` (Session 53) — VITAL, IOM DRI, LactMed.
4. `female_hormones.md`, `covid_pregnancy.md`, `nervous_system.md`, `pancreas_health.md`, `stress_adrenals.md`, `gallbladder_health.md` — по мере готовности.

**Приоритет 1 (Session 51, ~60–90 мин):**

- EBM-обогащение `joints_osteoporosis.md` по стандарту `EBM_STANDARD.md` v1.0.
- Создать `scripts/ebm_enrich_joints_osteoporosis.ps1` (5 патчей + §17 EBM Benchmark).
- Целевые метрики: +30–40 EBM-тегов, +150–200 строк, idempotency marker `EBM_ENRICHED_v1.1`.
- Прогон `audit_ebm_compliance.ps1` до и после — подтвердить PARTIAL → FULL.

**Приоритет 2 (инфраструктура, опционально):**

- Обобщить `update_status_session50.ps1` → универсальный `scripts/update_status.ps1`.
- Зафиксировать правила проекта в `learning/corrections.md`: «единый блок кода = единая копия», «backtick-safe here-strings».

---
## 📜 История сессий (краткая хронология)

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

<!-- STATUS_SESSION50_APPLIED -->
