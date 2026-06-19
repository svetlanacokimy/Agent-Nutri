# STATUS.md — состояние проекта Agent-Nutri v2

## 📌 Текущее состояние (на 2026-06-19)

**Ветка:** `copilot/build-v2-nutrition-agent-core`
**Последний коммит:** Сессия 28 (intestinal_health.md + cleanup)
**Активный кластер:** Кластер 5 «ЖКТ-расширение» — **6/10 протоколов готовы (60 %)**

### Кластер 5 «ЖКТ-расширение» — статус

| Протокол | Строк | H2 | H3 | ⭐ | ◆ | ⚠️ | Статус |
|---|---|---|---|---|---|---|---|
| stomach_health.md | 964 | 26 | 62 | 103 | 75 | 39 | ✅ |
| colon_coprogram.md | 877 | 25 | 45 | 65 | 47 | 35 | ✅ |
| gallbladder_health.md | 663 | 26 | 57 | 29 | 15 | 46 | ✅ |
| intestinal_health.md | 879 | 28 | 92 | 90 | 30 | 65 | ✅ |
| liver_health.md | 984 | 27 | 97 | 54 | 32 | 45 | ✅ |
| **pancreas_health.md** | **901** | **27** | **92** | **45** | **31** | **60** | ✅ **(Сессия 27)** |
| gluten_celiac.md | 544 | 21 | 35 | 50 | 14 | 24 | ◐ |
| sibo_sifo.md | 463 | 24 | 23 | 35 | 16 | 22 | ◐ |
| ibs.md | — | — | — | — | — | — | ✗ |
| ibd.md | — | — | — | — | — | — | ✗ |

**Прогресс по бенчмаркам:** 8 в коллекции (stomach, colon, gallbladder, liver, pancreas + 3 ранних).

**Гепатобилиарно-панкреатический треугольник завершён** (liver + gallbladder + pancreas).

---

## 🔄 Последняя сессия — 2026-06-19 (Сессия 28: ЖКТ-кишечник + наведение порядка)

**Файл:** `references/methodology/intestinal_health.md`

**Метрики:** 445 → 879 строк (+434), 23 → 28 H2 (+5), 31 → 92 H3 (+61), ⭐ 0 → 90, ◆ 0 → 30, ⚠️ 1 → 65.

**Коммиты сессии (4 шт.):**
- `4d5822c` — Step 0: перенос протокола желчеоттока в `gallbladder_health.md` §18 и «сладкой зависимости» в `nutrition_principles.md` §9.
- `fd733af` — Part B: реструктуризация Part A + §§14–22 (анатомия, барьер, микробиота, SCFA, оси, FODMAP, восстановление, запор, диарея).
- `b193966` — Part C: §§23–25 (симптом-навигатор, диагностика, бенчмарк школа vs EBM).
- `d264c8f` — Cleanup: исправлены 3 кросс-ссылки (insulin_resistance.md §427, mastopathy.md §240 и §568); добавлены `references/methodology/_conventions.md` и `scripts/audit_links.ps1`.

**Ключевые источники:** ESPGHAN 2020, ACG 2021 (IBS), ACG 2018 (IBD), ACG 2016 (Acute Diarrhea), AGA 2017/2020 (Faecal Calprotectin, Probiotics), Rome IV 2016, BSG 2018, Fasano 2011 (zonulin), Ajamian 2019, NICE 2022 (BAD), Salerno 2015 (NCGS), Monash FODMAP, McFarland 2010 (S. boulardii).

**Инфраструктура порядка (новое):**
- `references/methodology/_conventions.md` — единый «контракт»: правила нумерации (стабильные H2-ID, без переиспользования), формат кросс-ссылок (`file.md §N`, диапазоны `§§7, 10–12`), легенда маркеров (⭐ ◆ ⚠️), workflow (backup → правка → аудит → метрики → commit), запрещённые практики (Notepad, длинные here-strings в консоль).
- `scripts/audit_links.ps1` — автоматический аудит кросс-ссылок: **109 проверено, 0 битых**.

---

## ➡️ Следующая сессия — Сессия 29: СИБР/СДК

**Рекомендуемый файл:** `references/methodology/sibo_sifo.md` (463 строки, 24 H2, 23 H3, ⭐ 35 / ◆ 16 / ⚠️ 22) — требует расширения существующих разделов и добавления навигационного слоя.

**Цель:** ~700 строк, 27 H2, ~50 H3, ⭐ 55, ◆ 25, ⚠️ 35.

**План (3 части):**
- **Part B** (PowerShell, +~150 строк): расширение §9 «Типы СИБР по доминирующему газу» (водородный/метановый/сероводородный — патогенез, тесты, антимикробики, диета); §12 «Лабораторная диагностика» (подготовка к breath-тесту, интерпретация H₂/CH₄/H₂S, glucose vs lactulose); §16 «Современные клинические дополнения» (рифаксимин 550 мг ×3 14 дней, neomycin при IMO, элементарная диета, прокинетики, herbal antimicrobials).
- **Part C** (Cline, +~180 строк): §23 «Симптом-навигатор СИБР/СДК», §24 «Бенчмарк школа vs EBM» (15+ вопросов: рифаксимин vs метронидазол, элементарная диета, длительный low-FODMAP, glucose vs lactulose, herbal vs АБ, FMT при СИБР, low-dose naltrexone, prokinetics), §25 «Метаданные».
- **Cleanup**: прогон `& scripts\audit_links.ps1` → ожидаем `Broken: 0`; обновление `STATUS.md`; удаление backup-файла `sibo_sifo.md.backup_sess29_step0`.

**Ключевые источники:** Pimentel 2011 (TARGET trials, рифаксимин), Pimentel 2004 (элементарная диета), Chedid 2014 (herbal antimicrobials), Rezaie 2017 (North American Consensus on breath testing), ACG 2020 (SIBO), Rao 2018 (H₂S SIBO), Pimentel 2020 (IMO).

**Принцип работы (по `_conventions.md`):** перед каждым коммитом — `& scripts\audit_links.ps1` (`Broken: 0`); большие правки — через Cline; точечные — через PowerShell с массивом строк; here-strings длиннее 50 строк — через `.ps1`-скрипт в `scripts/`.

---

## 📜 История сессий (краткая хронология)

- **Сессия 23** (mastopathy/menopause): начата работа над menopause.md и stress_adrenals.md (частично).
- **Сессия 24** (stomach, colon): завершены `stomach_health.md` (964 строки) и `colon_coprogram.md` (877 строк).
- **Сессия 25** (gallbladder, 2026-06-18): `gallbladder_health.md` 396 → 663 строк, бенчмарк §24 (EASL 2016, NICE CG188, Cochrane УДХК 2013).
- **Сессия 26** (liver, 2026-06-18): `liver_health.md` 580 → 984 строк, +13 новых разделов (MASLD, DILI, viral, AIH, cholestasis), бенчмарк §24 (EASL 2024, AASLD 2023, MAESTRO-NASH 2024, Cochrane Silymarin 2007).
- **Сессия 27** (pancreas, 2026-06-18): `pancreas_health.md` 469 → 901 строк, +9 новых разделов (EPI, PERT, СД 3c, IPMN, AIP, рак ПЖ), бенчмарк §26 (UEG 2017, Banks 2012, ACG 2020, Hardt 2008/Ewald 2012, Hamano 2001).
- **Сессия 28** (intestinal + cleanup, 2026-06-19): `intestinal_health.md` 445 -> 879 строк, +5 H2, +61 H3; добавлены §§14-25 (физиология, протоколы, навигатор, диагностика, бенчмарк); 4 коммита (4d5822c, fd733af, b193966, d264c8f); исправлены 3 кросс-ссылки; создана инфраструктура порядка - `_conventions.md` и `audit_links.ps1` (109 ссылок, 0 битых).

**Кластер 5 → 6/10 протоколов готовы (60 %).** Бенчмарков: 9.

---

## 🧭 Как пользоваться этим файлом

1. **Текущее состояние** — снимок прогресса кластеров и активной ветки.
2. **Последняя сессия** — что было сделано в предыдущую сессию (метрики, ключевые источники).
3. **Следующая сессия** — план на ближайшую сессию (файл, цель, 3-part структура, источники).
4. **История** — краткая хронология последних 5–6 сессий.

Обновляется в конце каждой сессии перед git commit & push.
