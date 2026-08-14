# =============================================================================
# scripts/close_session61.ps1
# Session 61 close (variant Y - объединённый):
#   STATUS.md + SOURCES_INDEX.md + TECH_DEBT.md + LESSONS.md
# После EBM-обогащения liver_health.md (NO_EBM -> FULL_EBM, +30 тегов)
# 21 patches (10 STATUS + 6 SOURCES + 3 TECH_DEBT + 2 LESSONS)
# Rules: L-057-01, TD-006, TD-008/L-059-02 UTF-8 BOM,
#        TD-010/Invariant 8 byte-verified anchors, L-059-03 factual thresholds
# =============================================================================

$ErrorActionPreference = 'Stop'
$statusPath   = 'project/STATUS.md'
$sourcesPath  = 'v2/SOURCES_INDEX.md'
$techdebtPath = 'project/TECH_DEBT.md'
$lessonsPath  = 'project/LESSONS.md'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

Write-Host '=== Session 61 close (variant Y): STATUS + SOURCES + TECH_DEBT + LESSONS ==='

$statusRaw0   = Get-Content $statusPath   -Raw -Encoding UTF8
$sourcesRaw0  = Get-Content $sourcesPath  -Raw -Encoding UTF8
$techdebtRaw0 = Get-Content $techdebtPath -Raw -Encoding UTF8
$lessonsRaw0  = Get-Content $lessonsPath  -Raw -Encoding UTF8
if ($statusRaw0   -match 'STATUS_SESSION61_APPLIED')      { Write-Host '[ABORT] STATUS.md уже содержит SESSION61_APPLIED.';      exit 1 }
if ($sourcesRaw0  -match 'SOURCES_INDEX_EBM_APPLIED_v61') { Write-Host '[ABORT] SOURCES_INDEX.md уже содержит v61.';             exit 1 }
if ($techdebtRaw0 -match '## TD-011')                     { Write-Host '[ABORT] TECH_DEBT.md уже содержит TD-011.';              exit 1 }
if ($lessonsRaw0  -match '## L-061-01')                   { Write-Host '[ABORT] LESSONS.md уже содержит L-061-01.';              exit 1 }

$bakS  = "$statusPath.bak.$stamp"
$bakI  = "$sourcesPath.bak.$stamp"
$bakT  = "$techdebtPath.bak.$stamp"
$bakL  = "$lessonsPath.bak.$stamp"
Copy-Item $statusPath   $bakS -Force
Copy-Item $sourcesPath  $bakI -Force
Copy-Item $techdebtPath $bakT -Force
Copy-Item $lessonsPath  $bakL -Force
Write-Host "[OK] Backups created (stamp $stamp)"

$sizeS0 = (Get-Item $statusPath).Length
$sizeI0 = (Get-Item $sourcesPath).Length
$sizeT0 = (Get-Item $techdebtPath).Length
$sizeL0 = (Get-Item $lessonsPath).Length
Write-Host "Before: STATUS $sizeS0, SOURCES $sizeI0, TECH_DEBT $sizeT0, LESSONS $sizeL0"

$statusRaw   = $statusRaw0
$sourcesRaw  = $sourcesRaw0
$techdebtRaw = $techdebtRaw0
$lessonsRaw  = $lessonsRaw0
$patches = @()

function Apply-PatchS { param([string]$Name,[string]$Old,[string]$New)
  if ($script:statusRaw -notmatch [regex]::Escape($Old)) { throw "[FAIL] Patch '$Name' -- anchor not found in STATUS.md" }
  $script:statusRaw = $script:statusRaw.Replace($Old,$New); $script:patches += $Name; Write-Host "[OK] $Name"
}
function Apply-PatchI { param([string]$Name,[string]$Old,[string]$New)
  if ($script:sourcesRaw -notmatch [regex]::Escape($Old)) { throw "[FAIL] Patch '$Name' -- anchor not found in SOURCES_INDEX.md" }
  $script:sourcesRaw = $script:sourcesRaw.Replace($Old,$New); $script:patches += $Name; Write-Host "[OK] $Name"
}
function Apply-PatchT { param([string]$Name,[string]$Old,[string]$New)
  if ($script:techdebtRaw -notmatch [regex]::Escape($Old)) { throw "[FAIL] Patch '$Name' -- anchor not found in TECH_DEBT.md" }
  $script:techdebtRaw = $script:techdebtRaw.Replace($Old,$New); $script:patches += $Name; Write-Host "[OK] $Name"
}
function Apply-PatchL { param([string]$Name,[string]$Old,[string]$New)
  if ($script:lessonsRaw -notmatch [regex]::Escape($Old)) { throw "[FAIL] Patch '$Name' -- anchor not found in LESSONS.md" }
  $script:lessonsRaw = $script:lessonsRaw.Replace($Old,$New); $script:patches += $Name; Write-Host "[OK] $Name"
}

$s1Old = '**Последнее событие:** Session 60, Этап F.2 — EBM-обогащение `insulin_resistance.md` (NO_EBM → FULL_EBM, 0 → 30 EBM-тегов, +30 inline с нуля, v2.0 → v2.1). Прогресс: 13 → **14 FULL_EBM** файлов (26.4 %), 0 PARTIAL, 604 → **634 EBM-тегов** (+30). 🎯 Второе NO_EBM → FULL_EBM подряд с нуля — playbook v1.2 (Invariants 8+9) обеспечил 35/35 патчей и 38/38 валидаций с первого прогона, 0 инцидентов. Методология стабильно масштабируется на оставшиеся 38 файлов.'
$s1New = '**Последнее событие:** Session 61, Этап F.2 — EBM-обогащение `liver_health.md` (NO_EBM → FULL_EBM, 0 → 30 EBM-тегов, +30 inline с нуля, v2.0 → v2.1). Прогресс: 14 → **15 FULL_EBM** файлов (28.3 %), 0 PARTIAL, 634 → **664 EBM-тегов** (+30). 🎯 Третье NO_EBM → FULL_EBM подряд с нуля, 0 инцидентов в третьей сессии — playbook v1.2 доказал устойчивость (35/35 патчей + 39/39 валидаций с первого прогона). Замыкание кластера 5 (ИР → NAFLD → цирроз). Методология стабильно масштабируется на оставшиеся 37 файлов.'
Apply-PatchS 'S1 L6 главная сводка' $s1Old $s1New

Apply-PatchS 'S2 L87 FULL_EBM 14->15' `
  '- **FULL_EBM: 14/53 файлов (26.4%)** — было 13, +1 (`insulin_resistance.md`)' `
  '- **FULL_EBM: 15/53 файлов (28.3%)** — было 14, +1 (`liver_health.md`)'

Apply-PatchS 'S3 L89 NO_EBM 38->37' `
  '- **NO_EBM: 38/53 файлов (71.7%)** — было 39, -1 (`insulin_resistance.md` ушёл в FULL_EBM)' `
  '- **NO_EBM: 37/53 файлов (69.8%)** — было 38, -1 (`liver_health.md` ушёл в FULL_EBM)'

Apply-PatchS 'S4 L90 tags 634->664' `
  '- Всего EBM-тегов: **634** (было 604, +30 — полное EBM-обогащение insulin_resistance.md с нуля в 23 H2 + 7 H3, density 100 %)' `
  '- Всего EBM-тегов: **664** (было 634, +30 — полное EBM-обогащение liver_health.md с нуля в 23 H2 + 7 H3, density 100 %)'

Apply-PatchS 'S5 L91 lines 37457->37465' `
  '- Всего строк: 37 457' `
  '- Всего строк: 37 465'

$s6Old = @'
## ➡️ Следующая сессия — Session 61 (Этап F.2 продолжение)

**Цель:** EBM-обогащение `liver_health.md` (NO_EBM → FULL_EBM, 0 → ~30 EBM-тегов, полное обогащение с нуля — EASL 2024, AASLD 2023, Younossi 2016, PIVENS 2010, Chalasani 2018, Sanyal 2021 resmetirom, Romero-Gómez 2017 lifestyle meta)

### Исходное состояние

- `references/methodology/liver_health.md`: файл в списке NO_EBM (38/53), кластер 5 (гепатология, NAFLD/MASLD)
- **0 EBM-тегов сейчас** (порог FULL_EBM = 30), Benchmark-секция подлежит созданию с нуля
- Прямые связки с уже готовыми FULL_EBM: `pancreas_health.md` (β-клетки, метаболизм) и `insulin_resistance.md` (ИР → NAFLD ключевая ось) — логическое замыкание кластера 5: ИР → NAFLD → цирроз
- Маркер обогащения будет: `<!-- EBM_ENRICHED_v2.1 -->` (новый)

### Ключевые источники для добавления

- **EASL–EASD–EASO Clinical Practice Guidelines 2024** — MASLD (обновлённая номенклатура NAFLD), диагностика, стратификация
- **AASLD 2023 Practice Guidance** (Rinella et al., Hepatology) — многодисциплинарное ведение MASLD/MASH
- **Younossi 2016 Hepatology** — глобальная эпидемиология NAFLD (мета-анализ, 8.5 млн пациентов, 86 исследований)
- **PIVENS 2010 NEJM** (Sanyal) — витамин E 800 МЕ/сут vs пиоглитазон vs плацебо при NASH без диабета
- **Sanyal 2021/2024 NEJM (MAESTRO-NASH)** — resmetirom, первый одобренный препарат для MASH (2024)
'@
$s6New = @'
## ➡️ Следующая сессия — Session 62 (Этап F.2 продолжение)

**Цель:** EBM-обогащение `intestinal_health.md` (NO_EBM → FULL_EBM, 0 → ~30 EBM-тегов, полное обогащение с нуля — WGO 2023 Global Guidelines, ESPGHAN 2023, Cochrane пробиотики, Sonnenburg 2016 Cell, ACG IBS 2021, Ford 2020 Lancet)

### Исходное состояние

- `references/methodology/intestinal_health.md`: файл в списке NO_EBM (37/53), кластер 2 (гастроэнтерология, микробиом)
- **0 EBM-тегов сейчас** (порог FULL_EBM = 30), Benchmark-секция подлежит созданию с нуля (или уточнению)
- Прямые связки с уже готовыми FULL_EBM: `liver_health.md` (gut-liver axis) и `pancreas_health.md` (энзимы, SIBO/SIFO) — логическое продолжение gut-liver-pancreas cross-talk
- Маркер обогащения будет: `<!-- EBM_ENRICHED_v2.1 -->` (новый)

### Ключевые источники для добавления

- **WGO Global Guidelines 2023** — probiotics and prebiotics (обновлённый мультицентровой consensus)
- **ESPGHAN 2023 Position Paper** — probiotics for pediatric conditions
- **Sonnenburg & Sonnenburg 2016 Cell** — Diet-microbiota interactions в западной популяции
- **Ford 2020 Lancet** — Irritable bowel syndrome (обновлённый обзор ACG)
- **Cochrane 2017 (AlFaleh)** — probiotics for prevention of NEC in preterm infants
'@
Apply-PatchS 'S6 L100-115 Session 62 план' $s6Old $s6New

Apply-PatchS 'S7 L147 Session 61 план -> факт' `
  '- Session 61: liver_health.md (0 → ~30 тегов, NO_EBM → FULL_EBM — EASL 2024, AASLD 2023, Younossi 2016, PIVENS 2010, Chalasani 2018, Sanyal 2021, Romero-Gómez 2017; создание Benchmark-секции с нуля + inline-теги)' `
  '- Session 61: liver_health.md ✅ выполнено (0 → 30 тегов, NO_EBM → FULL_EBM — EASL-EASD-EASO 2024 MASLD CPG, Rinella 2023 AASLD, Younossi 2016 глобальная эпидемиология (13 965 cited), Sanyal 2010 NEJM PIVENS, Harrison 2024 NEJM MAESTRO-NASH resmetirom, Chalasani 2018 AASLD (8 857 cited), Vilar-Gomez 2015 Gastroenterology (3 093 cited), Prati 2002 Ann Intern Med ALT, Sterling 2006 FIB-4, Angulo 2007 NFS, Zelber-Sagi 2017 Mediterranean, Keating 2012 exercise meta, Kennedy 2016 coffee meta, Rehm 2013 ALD burden, Bosma 1995 NEJM UGT1A1, EASL 2015 AIH, EASL 2009 cholestasis, Chalasani 2014 ACG DILI, Wah Kheong 2017 silymarin RCT, Corbin 2012 choline, Katayama 2014 Zn cirrhosis, Andrade 2019 DILI, Estes 2018 burden 2030, Romero-Gómez 2017 lifestyle meta; 23 H2 + 7 H3, density 100 %)'

Apply-PatchS 'S8 L148 прогноз -> Session 62' `
  '- Прогноз к концу Session 61: **15/53 FULL_EBM (28.3 %), 0 PARTIAL, 37 NO_EBM**, ~664 EBM-тегов.' `
  '- Session 62: intestinal_health.md (0 → ~30 тегов, NO_EBM → FULL_EBM — WGO 2023, ESPGHAN 2023, Sonnenburg 2016 Cell, Ford 2020 Lancet, Cochrane 2017 пробиотики, ACG IBS 2021; gut-liver axis замыкание кластера 2)
- Прогноз к концу Session 62: **16/53 FULL_EBM (30.2 %), 0 PARTIAL, 36 NO_EBM**, ~694 EBM-тегов.'

$s9Old = '**Session 58 факт:** 12/53 FULL_EBM (22.6 %), **0 PARTIAL** (stress_adrenals оказался без Benchmark → переклассифицирован в NO_EBM), 40 NO_EBM, 574 EBM-тегов. 🎯 Milestone: PARTIAL_EBM полностью исчерпан.'
$s9New = @'
**Session 61 факт:** 15/53 FULL_EBM (28.3 %), 0 PARTIAL, **37 NO_EBM**, **664 EBM-тегов** (+30). 🎯 Milestone: третье NO_EBM → FULL_EBM подряд с нуля, 0 инцидентов третью сессию подряд — playbook v1.2 (Invariants 8+9) стабильно работает. Замыкание кластера 5 (гепато-панкреатическая ось: pancreas_health.md + insulin_resistance.md + liver_health.md все FULL_EBM). Обогащение liver_health.md за один проход (30 патчей контента + 5 метаданных, 35/35 патчей + 39/39 валидаций OK), density 100 %. Commit f483080. Дополнительно закрыто 3 tech-debt (TD-011/012/013) + 1 lesson (L-061-01).

**Session 58 факт:** 12/53 FULL_EBM (22.6 %), **0 PARTIAL** (stress_adrenals оказался без Benchmark → переклассифицирован в NO_EBM), 40 NO_EBM, 574 EBM-тегов. 🎯 Milestone: PARTIAL_EBM полностью исчерпан.
'@
Apply-PatchS 'S9 Session 61 факт (insert перед S58)' $s9Old $s9New

Apply-PatchS 'S10 маркер STATUS_SESSION61_APPLIED' `
  '<!-- STATUS_SESSION60_APPLIED -->' `
  @'
<!-- STATUS_SESSION60_APPLIED -->
<!-- STATUS_SESSION61_APPLIED -->
'@

Apply-PatchI 'I1 L620 дата Session 60 -> 61' `
  '**Текущая карта состояний (2026-08-13, Session 60):**' `
  '**Текущая карта состояний (2026-08-13, Session 61):**'

Apply-PatchI 'I2 L624 FULL_EBM 15 файлов + liver_health.md' `
  '- **FULL_EBM — 14 файлов (26.4 %):** `autoimmune_basics.md`, `covid_pregnancy.md`, `female_hormones.md`, `gallbladder_health.md`, `hashimoto.md`, `insulin_resistance.md`, `joints_osteoporosis.md`, `minerals.md`, `nervous_system.md`, `nutraceuticals.md`, `pancreas_health.md`, `stress_adrenals.md`, `thyroid_health.md`, `vitamins.md`.' `
  '- **FULL_EBM — 15 файлов (28.3 %):** `autoimmune_basics.md`, `covid_pregnancy.md`, `female_hormones.md`, `gallbladder_health.md`, `hashimoto.md`, `insulin_resistance.md`, `joints_osteoporosis.md`, `liver_health.md`, `minerals.md`, `nervous_system.md`, `nutraceuticals.md`, `pancreas_health.md`, `stress_adrenals.md`, `thyroid_health.md`, `vitamins.md`.'

Apply-PatchI 'I3 L626 PARTIAL + Session 61 note' `
  '- **PARTIAL_EBM — 0 файлов (0 %):** ✅ исчерпан с Session 58. После Session 59 `stress_adrenals.md` переведён из NO_EBM в FULL_EBM (Benchmark §14 присутствовал, +30 inline тегов добавлено с нуля). После Session 60 `insulin_resistance.md` переведён из NO_EBM в FULL_EBM (Benchmark создан с нуля, +30 inline тегов, 23 H2 + 7 H3).' `
  '- **PARTIAL_EBM — 0 файлов (0 %):** ✅ исчерпан с Session 58. После Session 59 `stress_adrenals.md` переведён из NO_EBM в FULL_EBM (Benchmark §14 присутствовал, +30 inline тегов добавлено с нуля). После Session 60 `insulin_resistance.md` переведён из NO_EBM в FULL_EBM (Benchmark создан с нуля, +30 inline тегов, 23 H2 + 7 H3). После Session 61 `liver_health.md` переведён из NO_EBM в FULL_EBM (Benchmark создан с нуля, +30 inline тегов, 23 H2 + 7 H3, замыкание кластера 5).'

Apply-PatchI 'I4 L628 NO_EBM 37 файлов + кандидаты Session 62+' `
  '- **NO_EBM — 38 файлов (71.7 %):** в основном методологические и клиентские файлы, где EBM в форме RCT неприменима (интервью с клиентом, мотивационное интервью, этика, шаблоны меню, антипаразитарные протоколы без RCT-базы). Приоритетные кандидаты на FULL_EBM: `liver_health.md` (Session 61 — замыкание кластера 5: ИР → NAFLD → цирроз), `menopause.md`, `intestinal_health.md`.' `
  '- **NO_EBM — 37 файлов (69.8 %):** в основном методологические и клиентские файлы, где EBM в форме RCT неприменима (интервью с клиентом, мотивационное интервью, этика, шаблоны меню, антипаразитарные протоколы без RCT-базы). Приоритетные кандидаты на FULL_EBM: `intestinal_health.md` (Session 62 — gut-liver axis, замыкание кластера 2), `menopause.md`, `digestion_basics.md`.'

Apply-PatchI 'I5 L630 tags 664 + Session 61' `
  '- **Всего:** 634 EBM-тегов, ~37 500 строк методологии (обновлено Session 60, 2026-08-13 — полное EBM-обогащение insulin_resistance.md с нуля, +30 inline тегов; density 100 %; playbook v1.2 первый прогон без инцидентов — 35/35 патчей, 38/38 валидаций).' `
  '- **Всего:** 664 EBM-тегов, ~37 500 строк методологии (обновлено Session 61, 2026-08-13 — полное EBM-обогащение liver_health.md с нуля, +30 inline тегов; density 100 %; playbook v1.2 третий прогон без инцидентов — 35/35 патчей, 39/39 валидаций; замыкание кластера 5).'

Apply-PatchI 'I6 маркер v60 -> v61' `
  '<!-- SOURCES_INDEX_EBM_APPLIED_v60 -->' `
  '<!-- SOURCES_INDEX_EBM_APPLIED_v61 -->'

$tOld = @'
<!-- TECH_DEBT_LAST_UPDATED: 2026-08-10, Session 59 -->
<!-- TECH_DEBT_COUNT_OPEN: 10 -->
'@
$tNew = @'
## TD-011 (P3): Пропуск нумерации H2 §8/§9 в liver_health.md

**Симптом:** файл `references/methodology/liver_health.md` имеет пропуск нумерации разделов — после §7 (Синдром Жильбера) сразу идёт §10 (NAЖБП/MASLD). Разделы §8 и §9 отсутствуют.

**Причина:** историческая — §8 (Циррозы) и §9 (Печёночная недостаточность) планировались, но не были написаны при первом релизе (Сессия 12, 2026-05-29).

**Влияние:** косметическое. Все клинические темы покрыты в §10-§23. EBM-целостность не страдает (Session 61 обогащение прошло 35/35 патчей + 39/39 валидаций).

**Решение:** отдельная тех-задача — либо восстановить §8/§9 (написать циррозы + печёночную недостаточность), либо перенумеровать §10-§26 в §8-§24. Не блокирует Этап F.2.

**Обнаружено:** Session 61 (2026-08-13).

---

## TD-012 (P2): Длинные многострочные git commit -m в PowerShell — риск незакрытой кавычки

**Симптом:** в Session 61 при выполнении git commit с двумя длинными -m параметрами PowerShell 5 раз подряд возвращал prompt, не воспринимая команду как завершённую. Причина — синтаксический анализатор PowerShell по-разному интерпретирует внутренние кавычки в длинных строках.

**Причина:** PowerShell парсер строк реагирует на любые двойные кавычки внутри -m параметра, даже экранированные. При длинных сообщениях свыше 1500 символов риск возрастает.

**Влияние:** блокирует git commit до правильного закрытия команды; трата 3-5 минут на попытки.

**Решение (правило):**
- Использовать git commit -F commit_msg.txt для длинных сообщений: сохранить текст в файл, передать через -F.
- Или писать одной короткой строкой без внутренних кавычек и переносов.
- Или использовать git commit без -m — откроется редактор (VS Code).

**Обнаружено:** Session 61 (2026-08-13).

---

## TD-013 (P3): LESSONS.md LAST_UPDATED устарел — пропуск обновления в Session 59 tail

**Симптом:** в конце Session 61 обнаружено, что LESSONS_LAST_UPDATED в project/LESSONS.md содержит значение 2026-08-06, Session 58, хотя в Session 59 tail (commit a143d5f) были добавлены L-059-02 и L-059-03 и обновлён LESSONS_COUNT с 8 до 10.

**Причина:** скрипт update_tech_debt_and_lessons_s59_tail.ps1 обновил LESSONS_COUNT, но пропустил обновление LESSONS_LAST_UPDATED (не был включён в список патчей).

**Влияние:** метаданные устарели; сбивает при аудите. TECH_DEBT_LAST_UPDATED был обновлён корректно, но LESSONS_LAST_UPDATED — нет.

**Решение (правило):** в каждом скрипте, который добавляет lesson или tech-debt, обязательный чек-лист: 1) добавить запись, 2) обновить _COUNT, 3) обновить _LAST_UPDATED. Валидация в скрипте: Select-String с паттерном _LAST_UPDATED и текущей сессией должен вернуть совпадение.

**Обнаружено:** Session 61 (2026-08-13). Исправлено в этой же сессии (LESSONS_LAST_UPDATED обновлён на Session 61 в патче Le1).

---

<!-- TECH_DEBT_LAST_UPDATED: 2026-08-13, Session 61 -->
<!-- TECH_DEBT_COUNT_OPEN: 13 -->
'@
Apply-PatchT 'T1 TD-011/012/013 + update counters' $tOld $tNew

$leOld = '<!-- LESSONS_LAST_UPDATED: 2026-08-06, Session 58 -->'
$leNew = @'
## L-061-01: PowerShell git commit -m — использовать -F для длинных сообщений

**Контекст:** Session 61 (2026-08-13). После успешного обогащения liver_health.md (35/35 патчей, 39/39 валидаций OK) команда git commit с двумя длинными -m параметрами (тело свыше 1500 символов с PMID перечислением) 5 раз подряд возвращала prompt в PowerShell — парсер не считал команду завершённой.

**Наблюдение:** PowerShell анализирует внутренние кавычки в -m параметре даже когда они правильно экранированы. При длинных сообщениях (свыше 1500 символов, много запятых, скобок) риск незакрытой кавычки резко возрастает.

**Правило:**
- Для длинных commit-сообщений использовать git commit -F с путём к файлу: сохранить текст в commit_msg.txt, передать через -F.
- Альтернатива: git commit без -m — откроется редактор (VS Code через git config core.editor).
- Короткие сообщения (одна строка, до 100 символов) — безопасны через -m.

**Побочный эффект:** ускоряет закрытие сессии (нет циклов попытка-prompt-отмена-новая попытка).

**Связано:** TD-012 (P2).

---

<!-- LESSONS_LAST_UPDATED: 2026-08-13, Session 61 -->
'@
Apply-PatchL 'Le1 L-061-01 + LAST_UPDATED -> Session 61' $leOld $leNew

Apply-PatchL 'Le2 LESSONS_COUNT 10 -> 11' `
  '<!-- LESSONS_COUNT: 10 -->' `
  '<!-- LESSONS_COUNT: 11 -->'

Write-Host ''
Write-Host '=== Validation ==='

$deltaS = $statusRaw.Length   - $statusRaw0.Length
$deltaI = $sourcesRaw.Length  - $sourcesRaw0.Length
$deltaT = $techdebtRaw.Length - $techdebtRaw0.Length
$deltaL = $lessonsRaw.Length  - $lessonsRaw0.Length
Write-Host "Deltas: STATUS $deltaS, SOURCES $deltaI, TECH_DEBT $deltaT, LESSONS $deltaL"

$validations = @(
  @{Name='STATUS содержит 15/53 файлов (28.3%)';           Test={ $statusRaw -match '15/53 файлов \(28\.3%\)' }},
  @{Name='STATUS содержит 37/53 файлов (69.8%)';           Test={ $statusRaw -match '37/53 файлов \(69\.8%\)' }},
  @{Name='STATUS содержит 664 EBM-тегов';                  Test={ $statusRaw -match '664 EBM-тегов' }},
  @{Name='STATUS содержит 37 465 строк';                   Test={ $statusRaw -match '37 465' }},
  @{Name='STATUS содержит Session 61 факт';                Test={ $statusRaw -match 'Session 61 факт' }},
  @{Name='STATUS содержит intestinal_health.md';           Test={ $statusRaw -match 'intestinal_health\.md' }},
  @{Name='STATUS содержит WGO 2023';                        Test={ $statusRaw -match 'WGO 2023' }},
  @{Name='STATUS содержит Session 62 план';                Test={ $statusRaw -match 'Session 62 \(Этап F\.2' }},
  @{Name='STATUS содержит commit f483080';                 Test={ $statusRaw -match 'f483080' }},
  @{Name='STATUS содержит маркер SESSION61_APPLIED';       Test={ $statusRaw -match 'STATUS_SESSION61_APPLIED' }},
  @{Name='STATUS сохранил маркер SESSION60_APPLIED';       Test={ $statusRaw -match 'STATUS_SESSION60_APPLIED' }},
  @{Name='STATUS убрал 14/53 файлов (26.4%) из L87';       Test={ -not ($statusRaw -match '\*\*FULL_EBM: 14/53 файлов') }},
  @{Name='STATUS убрал 38/53 файлов из L89';               Test={ -not ($statusRaw -match '\*\*NO_EBM: 38/53 файлов') }},
  @{Name='STATUS убрал 634 EBM-тегов из L90';              Test={ -not ($statusRaw -match 'Всего EBM-тегов: \*\*634\*\*') }},
  @{Name='STATUS убрал старый блок Session 61 план';       Test={ -not ($statusRaw -match 'Следующая сессия — Session 61') }},
  @{Name='STATUS размер +1200 chars';                      Test={ $deltaS -ge 1200 }},
  @{Name='SOURCES содержит Session 61 в заголовке';        Test={ $sourcesRaw -match '2026-08-13, Session 61' }},
  @{Name='SOURCES содержит 15 файлов (28.3 %)';            Test={ $sourcesRaw -match '15 файлов \(28\.3 %\)' }},
  @{Name='SOURCES содержит liver_health.md алфавитно';     Test={ $sourcesRaw -match 'joints_osteoporosis\.md`, `liver_health\.md`, `minerals' }},
  @{Name='SOURCES содержит 37 файлов (69.8 %)';            Test={ $sourcesRaw -match '37 файлов \(69\.8 %\)' }},
  @{Name='SOURCES содержит 664 EBM-тегов';                 Test={ $sourcesRaw -match '664 EBM-тегов' }},
  @{Name='SOURCES содержит маркер v61';                    Test={ $sourcesRaw -match 'SOURCES_INDEX_EBM_APPLIED_v61' }},
  @{Name='SOURCES убрал маркер v60';                       Test={ -not ($sourcesRaw -match 'SOURCES_INDEX_EBM_APPLIED_v60') }},
  @{Name='SOURCES убрал 14 файлов (26.4 %)';               Test={ -not ($sourcesRaw -match '14 файлов \(26\.4 %\)') }},
  @{Name='SOURCES убрал 634 EBM-тегов';                    Test={ -not ($sourcesRaw -match '634 EBM-тегов') }},
  @{Name='SOURCES размер Abs delta >= 50';                 Test={ [Math]::Abs($deltaI) -ge 50 }},
  @{Name='TECH_DEBT содержит TD-011';                       Test={ $techdebtRaw -match '## TD-011' }},
  @{Name='TECH_DEBT содержит TD-012';                       Test={ $techdebtRaw -match '## TD-012' }},
  @{Name='TECH_DEBT содержит TD-013';                       Test={ $techdebtRaw -match '## TD-013' }},
  @{Name='TECH_DEBT COUNT_OPEN 13';                         Test={ $techdebtRaw -match 'TECH_DEBT_COUNT_OPEN: 13' }},
  @{Name='TECH_DEBT LAST_UPDATED Session 61';               Test={ $techdebtRaw -match 'TECH_DEBT_LAST_UPDATED: 2026-08-13, Session 61' }},
  @{Name='TECH_DEBT убрал старый COUNT_OPEN 10';           Test={ -not ($techdebtRaw -match 'TECH_DEBT_COUNT_OPEN: 10') }},
  @{Name='TECH_DEBT размер +2000 chars';                    Test={ $deltaT -ge 2000 }},
  @{Name='LESSONS содержит L-061-01';                       Test={ $lessonsRaw -match '## L-061-01' }},
  @{Name='LESSONS COUNT 11';                                 Test={ $lessonsRaw -match 'LESSONS_COUNT: 11' }},
  @{Name='LESSONS LAST_UPDATED Session 61';                 Test={ $lessonsRaw -match 'LESSONS_LAST_UPDATED: 2026-08-13, Session 61' }},
  @{Name='LESSONS убрал старый LAST_UPDATED Session 58';   Test={ -not ($lessonsRaw -match 'LESSONS_LAST_UPDATED: 2026-08-06, Session 58') }},
  @{Name='LESSONS убрал старый COUNT 10';                   Test={ -not ($lessonsRaw -match 'LESSONS_COUNT: 10') }},
  @{Name='LESSONS размер +500 chars';                       Test={ $deltaL -ge 500 }}
)

$okCount = 0
$failCount = 0
foreach ($v in $validations) {
  $result = & $v.Test
  if ($result) { Write-Host "[OK]   $($v.Name)"; $okCount++ }
  else         { Write-Host "[FAIL] $($v.Name)"; $failCount++ }
}

Write-Host ''
Write-Host "Validation summary: $okCount OK, $failCount FAIL"

if ($failCount -gt 0) {
  Write-Host '[ABORT] Файлы НЕ записаны. Backups:'
  Write-Host "  $bakS"
  Write-Host "  $bakI"
  Write-Host "  $bakT"
  Write-Host "  $bakL"
  exit 1
}

$utf8bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path $statusPath),   $statusRaw,   $utf8bom)
[System.IO.File]::WriteAllText((Resolve-Path $sourcesPath),  $sourcesRaw,  $utf8bom)
[System.IO.File]::WriteAllText((Resolve-Path $techdebtPath), $techdebtRaw, $utf8bom)
[System.IO.File]::WriteAllText((Resolve-Path $lessonsPath),  $lessonsRaw,  $utf8bom)

$sizeS1 = (Get-Item $statusPath).Length
$sizeI1 = (Get-Item $sourcesPath).Length
$sizeT1 = (Get-Item $techdebtPath).Length
$sizeL1 = (Get-Item $lessonsPath).Length

Write-Host ''
Write-Host '=== SUCCESS ==='
Write-Host "STATUS:    $sizeS0 -> $sizeS1 bytes (delta $($sizeS1 - $sizeS0))"
Write-Host "SOURCES:   $sizeI0 -> $sizeI1 bytes (delta $($sizeI1 - $sizeI0))"
Write-Host "TECH_DEBT: $sizeT0 -> $sizeT1 bytes (delta $($sizeT1 - $sizeT0))"
Write-Host "LESSONS:   $sizeL0 -> $sizeL1 bytes (delta $($sizeL1 - $sizeL0))"
Write-Host "Patches applied: $($patches.Count)"
Write-Host "Validations OK:  $okCount"
Write-Host "Backups: $bakS ; $bakI ; $bakT ; $bakL"
Write-Host ''
Write-Host 'Ready for git add + commit.'
