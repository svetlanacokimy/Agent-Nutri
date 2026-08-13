# =====НАЧАЛО=====
# =============================================================================
# close_session62.ps1
# Session 62 close (variant Y): STATUS + SOURCES + TECH_DEBT + LESSONS
# 22 patches, ~50 validations, adaptive size limits
# =============================================================================

$ErrorActionPreference = 'Stop'

$statusFile = 'project/STATUS.md'
$sourcesFile = 'v2/SOURCES_INDEX.md'
$techDebtFile = 'project/TECH_DEBT.md'
$lessonsFile = 'project/LESSONS.md'

Write-Host '=== Session 62 close (variant Y) ==='
Write-Host ''

# --- Read files ---
$sRaw = Get-Content $statusFile -Encoding UTF8 -Raw
$soRaw = Get-Content $sourcesFile -Encoding UTF8 -Raw
$tdRaw = Get-Content $techDebtFile -Encoding UTF8 -Raw
$leRaw = Get-Content $lessonsFile -Encoding UTF8 -Raw

# --- Guard ---
if ($sRaw -match 'STATUS_SESSION62_APPLIED') {
    Write-Host '[ABORT] STATUS_SESSION62_APPLIED already present.'
    exit 1
}
if ($soRaw -match 'SOURCES_INDEX_EBM_APPLIED_v62') {
    Write-Host '[ABORT] SOURCES_INDEX_EBM_APPLIED_v62 already present.'
    exit 1
}
Write-Host '[OK] Guard passed'

# --- Sizes before ---
$sizesBefore = @{
    STATUS = (Get-Item $statusFile).Length
    SOURCES = (Get-Item $sourcesFile).Length
    TECH_DEBT = (Get-Item $techDebtFile).Length
    LESSONS = (Get-Item $lessonsFile).Length
}

# --- Backups ---
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
Copy-Item $statusFile "$statusFile.bak.$stamp" -Force
Copy-Item $sourcesFile "$sourcesFile.bak.$stamp" -Force
Copy-Item $techDebtFile "$techDebtFile.bak.$stamp" -Force
Copy-Item $lessonsFile "$lessonsFile.bak.$stamp" -Force
Write-Host "[OK] Backups created (stamp: $stamp)"
Write-Host ''

$applied = 0
$failed = @()

# =============================================================================
# STATUS.md patches (10)
# =============================================================================
Write-Host '=== STATUS.md patches ==='

# S1: L6 last event
$s1Old = '**Последнее событие:** Session 61, Этап F.2 — EBM-обогащение `liver_health.md` (NO_EBM → FULL_EBM, 0 → 30 EBM-тегов, +30 inline с нуля, v2.0 → v2.1). Прогресс: 14 → **15 FULL_EBM** файлов (28.3 %), 0 PARTIAL, 634 → **664 EBM-тегов** (+30). 🎯 Третье NO_EBM → FULL_EBM подряд с нуля, 0 инцидентов в третьей сессии — playbook v1.2 доказал устойчивость (35/35 патчей + 39/39 валидаций с первого прогона). Замыкание кластера 5 (ИР → NAFLD → цирроз). Методология стабильно масштабируется на оставшиеся 37 файлов.'
$s1New = '**Последнее событие:** Session 62, Этап F.2 — EBM-обогащение `intestinal_health.md` (NO_EBM → FULL_EBM, 0 → 30 EBM-тегов, +30 inline с нуля, v2.0 → v2.1). Прогресс: 15 → **16 FULL_EBM** файлов (30.2 %), 0 PARTIAL, 664 → **694 EBM-тегов** (+30). 🎯 Четвёртое NO_EBM → FULL_EBM подряд с нуля, 2 инцидента (P25 пробел в кириллице, size limit 8000) исправлены — playbook v1.2 требует апгрейда до v1.3 (адаптивный лимит + hex-dump якорей). Замыкание кластера 2 (ЖКТ, gut-brain-liver axis). Преодолён порог 30 % FULL_EBM.'
if ($sRaw.Contains($s1Old)) { $sRaw = $sRaw.Replace($s1Old, $s1New); $applied++; Write-Host '  [OK] S1 (L6 last event)' } else { $failed += 'S1: L6 anchor NOT FOUND' }

# S2: L87 FULL_EBM count
$s2Old = '- **FULL_EBM: 15/53 файлов (28.3%)** — было 14, +1 (`liver_health.md`)'
$s2New = '- **FULL_EBM: 16/53 файлов (30.2%)** — было 15, +1 (`intestinal_health.md`)'
if ($sRaw.Contains($s2Old)) { $sRaw = $sRaw.Replace($s2Old, $s2New); $applied++; Write-Host '  [OK] S2 (L87 FULL_EBM)' } else { $failed += 'S2: L87 anchor NOT FOUND' }

# S3: L89 NO_EBM count
$s3Old = '- **NO_EBM: 37/53 файлов (69.8%)** — было 38, -1 (`liver_health.md` ушёл в FULL_EBM)'
$s3New = '- **NO_EBM: 36/53 файлов (67.9%)** — было 37, -1 (`intestinal_health.md` ушёл в FULL_EBM)'
if ($sRaw.Contains($s3Old)) { $sRaw = $sRaw.Replace($s3Old, $s3New); $applied++; Write-Host '  [OK] S3 (L89 NO_EBM)' } else { $failed += 'S3: L89 anchor NOT FOUND' }

# S4: L91 lines total
$s4Old = '- Всего строк: 37 465'
$s4New = '- Всего строк: 37 527'
if ($sRaw.Contains($s4Old)) { $sRaw = $sRaw.Replace($s4Old, $s4New); $applied++; Write-Host '  [OK] S4 (L91 lines)' } else { $failed += 'S4: L91 anchor NOT FOUND' }

# S5: L102 goal (Session 62 план → Session 63 план)
$s5Old = '**Цель:** EBM-обогащение `intestinal_health.md` (NO_EBM → FULL_EBM, 0 → ~30 EBM-тегов, полное обогащение с нуля — WGO 2023 Global Guidelines, ESPGHAN 2023, Cochrane пробиотики, Sonnenburg 2016 Cell, ACG IBS 2021, Ford 2020 Lancet)'
$s5New = '**Цель:** EBM-обогащение `menopause.md` (NO_EBM → FULL_EBM, 0 → ~30 EBM-тегов, полное обогащение с нуля — WHI 2002 JAMA, NAMS 2022 Position Statement, MHT, isoflavones, Endocrine Society 2015 CPG)'
if ($sRaw.Contains($s5Old)) { $sRaw = $sRaw.Replace($s5Old, $s5New); $applied++; Write-Host '  [OK] S5 (L102 goal Session 63)' } else { $failed += 'S5: L102 anchor NOT FOUND' }

# S6: L106 target file
$s6Old = '- `references/methodology/intestinal_health.md`: файл в списке NO_EBM (37/53), кластер 2 (гастроэнтерология, микробиом)'
$s6New = '- `references/methodology/menopause.md`: файл в списке NO_EBM (36/53), кластер 4 (эндокринология, женское здоровье)'
if ($sRaw.Contains($s6Old)) { $sRaw = $sRaw.Replace($s6Old, $s6New); $applied++; Write-Host '  [OK] S6 (L106 target file)' } else { $failed += 'S6: L106 anchor NOT FOUND' }

# S7: L148 forecast Session 62 → Session 63
$s7Old = '- Session 62: intestinal_health.md (0 → ~30 тегов, NO_EBM → FULL_EBM — WGO 2023, ESPGHAN 2023, Sonnenburg 2016 Cell, Ford 2020 Lancet, Cochrane 2017 пробиотики, ACG IBS 2021; gut-liver axis замыкание кластера 2)'
$s7New = '- Session 63: menopause.md (0 → ~30 тегов, NO_EBM → FULL_EBM — WHI 2002 JAMA, NAMS 2022, Endocrine Society 2015 CPG, MHT, isoflavones; кластер 4 эндокринология)'
if ($sRaw.Contains($s7Old)) { $sRaw = $sRaw.Replace($s7Old, $s7New); $applied++; Write-Host '  [OK] S7 (L148 forecast Session 63)' } else { $failed += 'S7: L148 anchor NOT FOUND' }

# S8: L151 Session 61 факт → keep + add Session 62 факт after it
$s8Anchor = '**Session 61 факт:** 15/53 FULL_EBM (28.3 %), 0 PARTIAL, **37 NO_EBM**, **664 EBM-тегов** (+30). 🎯 Milestone: третье NO_EBM → FULL_EBM подряд с нуля, 0 инцидентов третью сессию подряд — playbook v1.2 (Invariants 8+9) стабильно работает. Замыкание кластера 5 (гепато-панкреатическая ось: pancreas_health.md + insulin_resistance.md + liver_health.md все FULL_EBM). Обогащение liver_health.md за один проход (30 патчей контента + 5 метаданных, 35/35 патчей + 39/39 валидаций OK), density 100 %. Commit f483080. Дополнительно закрыто 3 tech-debt (TD-011/012/013) + 1 lesson (L-061-01).'
$s8Insert = "`n`n**Session 62 факт:** 16/53 FULL_EBM (30.2 %), 0 PARTIAL, **36 NO_EBM**, **694 EBM-тегов** (+30). 🎯 Milestone: преодолён порог 30 % FULL_EBM. Четвёртое NO_EBM → FULL_EBM подряд с нуля, 2 инцидента (P25 пробел в кириллице ""функциональный подход"" vs ""функциональныйподход""; size limit 8000 превышен на 665 байт из-за длинных названий Nature Reviews/Cell) — оба исправлены в этой же сессии. Замыкание кластера 2 (ЖКТ, gut-brain-liver axis). Обогащение intestinal_health.md за один проход после фиксов (35/35 патчей + 32/32 валидаций OK), density 100 %. Commit ea67cf2. Дополнительно закрыто 3 tech-debt (TD-014 адаптивный лимит, TD-015 LAST_UPDATED парсинг, TD-016 git branch expectation) + 2 lessons (L-062-01 hex-dump якорей, L-062-02 адаптивный лимит размера)."
if ($sRaw.Contains($s8Anchor)) { $sRaw = $sRaw.Replace($s8Anchor, $s8Anchor + $s8Insert); $applied++; Write-Host '  [OK] S8 (L151 Session 62 факт)' } else { $failed += 'S8: L151 anchor NOT FOUND' }

# S9: append marker after existing STATUS_SESSION61_APPLIED
$s9Old = '<!-- STATUS_SESSION61_APPLIED -->'
$s9New = "<!-- STATUS_SESSION61_APPLIED -->`n<!-- STATUS_SESSION62_APPLIED -->"
if ($sRaw.Contains($s9Old)) { $sRaw = $sRaw.Replace($s9Old, $s9New); $applied++; Write-Host '  [OK] S9 (marker STATUS_SESSION62_APPLIED)' } else { $failed += 'S9: S61 marker NOT FOUND' }

# S10: update cluster 2 status line (L46) — already says 7/7 with intestinal_health, but note EBM completion
# Skipping S10 — kept for future explicit cluster status update; no-op to preserve line count clarity

Write-Host ''

# =============================================================================
# SOURCES_INDEX.md patches (5)
# =============================================================================
Write-Host '=== SOURCES_INDEX.md patches ==='

# I1: L620 date/session header
$i1Old = '**Текущая карта состояний (2026-08-13, Session 61):**'
$i1New = '**Текущая карта состояний (2026-08-13, Session 62):**'
if ($soRaw.Contains($i1Old)) { $soRaw = $soRaw.Replace($i1Old, $i1New); $applied++; Write-Host '  [OK] I1 (L620 date/session)' } else { $failed += 'I1: L620 anchor NOT FOUND' }

# I2: L624 FULL_EBM list (add intestinal_health.md alphabetically after insulin_resistance.md)
$i2Old = '- **FULL_EBM — 15 файлов (28.3 %):** `autoimmune_basics.md`, `covid_pregnancy.md`, `female_hormones.md`, `gallbladder_health.md`, `hashimoto.md`, `insulin_resistance.md`, `joints_osteoporosis.md`, `liver_health.md`, `minerals.md`, `nervous_system.md`, `nutraceuticals.md`, `pancreas_health.md`, `stress_adrenals.md`, `thyroid_health.md`, `vitamins.md`.'
$i2New = '- **FULL_EBM — 16 файлов (30.2 %):** `autoimmune_basics.md`, `covid_pregnancy.md`, `female_hormones.md`, `gallbladder_health.md`, `hashimoto.md`, `insulin_resistance.md`, `intestinal_health.md`, `joints_osteoporosis.md`, `liver_health.md`, `minerals.md`, `nervous_system.md`, `nutraceuticals.md`, `pancreas_health.md`, `stress_adrenals.md`, `thyroid_health.md`, `vitamins.md`.'
if ($soRaw.Contains($i2Old)) { $soRaw = $soRaw.Replace($i2Old, $i2New); $applied++; Write-Host '  [OK] I2 (L624 FULL_EBM list)' } else { $failed += 'I2: L624 anchor NOT FOUND' }

# I3: L626 PARTIAL note update
$i3Old = '- **PARTIAL_EBM — 0 файлов (0 %):** ✅ исчерпан с Session 58. После Session 59 `stress_adrenals.md` переведён из NO_EBM в FULL_EBM (Benchmark §14 присутствовал, +30 inline тегов добавлено с нуля). После Session 60 `insulin_resistance.md` переведён из NO_EBM в FULL_EBM (Benchmark создан с нуля, +30 inline тегов, 23 H2 + 7 H3). После Session 61 `liver_health.md` переведён из NO_EBM в FULL_EBM (Benchmark создан с нуля, +30 inline тегов, 23 H2 + 7 H3, замыкание кластера 5).'
$i3New = '- **PARTIAL_EBM — 0 файлов (0 %):** ✅ исчерпан с Session 58. После Session 59 `stress_adrenals.md` переведён из NO_EBM в FULL_EBM (Benchmark §14 присутствовал, +30 inline тегов добавлено с нуля). После Session 60 `insulin_resistance.md` переведён из NO_EBM в FULL_EBM (Benchmark создан с нуля, +30 inline тегов, 23 H2 + 7 H3). После Session 61 `liver_health.md` переведён из NO_EBM в FULL_EBM (Benchmark создан с нуля, +30 inline тегов, 23 H2 + 7 H3, замыкание кластера 5). После Session 62 `intestinal_health.md` переведён из NO_EBM в FULL_EBM (Benchmark §25 присутствовал, +30 inline тегов, 25 H2 + 5 H3, замыкание кластера 2 gut-brain-liver axis, преодолён порог 30 %).'
if ($soRaw.Contains($i3Old)) { $soRaw = $soRaw.Replace($i3Old, $i3New); $applied++; Write-Host '  [OK] I3 (L626 PARTIAL note)' } else { $failed += 'I3: L626 anchor NOT FOUND' }

# I4: L628 NO_EBM count + priority candidates
$i4Old = '- **NO_EBM — 37 файлов (69.8 %):** в основном методологические и клиентские файлы, где EBM в форме RCT неприменима (интервью с клиентом, мотивационное интервью, этика, шаблоны меню, антипаразитарные протоколы без RCT-базы). Приоритетные кандидаты на FULL_EBM: `intestinal_health.md` (Session 62 — gut-liver axis, замыкание кластера 2), `menopause.md`, `digestion_basics.md`.'
$i4New = '- **NO_EBM — 36 файлов (67.9 %):** в основном методологические и клиентские файлы, где EBM в форме RCT неприменима (интервью с клиентом, мотивационное интервью, этика, шаблоны меню, антипаразитарные протоколы без RCT-базы). Приоритетные кандидаты на FULL_EBM: `menopause.md` (Session 63 — WHI 2002, NAMS 2022, MHT, isoflavones, кластер 4 эндокринология), `digestion_basics.md`, `stomach_health.md`, `sibo_sifo.md`.'
if ($soRaw.Contains($i4Old)) { $soRaw = $soRaw.Replace($i4Old, $i4New); $applied++; Write-Host '  [OK] I4 (L628 NO_EBM candidates)' } else { $failed += 'I4: L628 anchor NOT FOUND' }

# I5: L630 total tags
$i5Old = '- **Всего:** 664 EBM-тегов, ~37 500 строк методологии (обновлено Session 61, 2026-08-13 — полное EBM-обогащение liver_health.md с нуля, +30 inline тегов; density 100 %; playbook v1.2 третий прогон без инцидентов — 35/35 патчей, 39/39 валидаций; замыкание кластера 5).'
$i5New = '- **Всего:** 694 EBM-тегов, ~37 527 строк методологии (обновлено Session 62, 2026-08-13 — полное EBM-обогащение intestinal_health.md с нуля, +30 inline тегов; density 100 %; playbook v1.2 четвёртый прогон с 2 исправимыми инцидентами — 35/35 патчей, 32/32 валидаций после фиксов; замыкание кластера 2; преодолён порог 30 %).'
if ($soRaw.Contains($i5Old)) { $soRaw = $soRaw.Replace($i5Old, $i5New); $applied++; Write-Host '  [OK] I5 (L630 total tags)' } else { $failed += 'I5: L630 anchor NOT FOUND' }

# I6: L671 marker v61 → v62
$i6Old = '<!-- SOURCES_INDEX_EBM_APPLIED_v61 -->'
$i6New = '<!-- SOURCES_INDEX_EBM_APPLIED_v62 -->'
if ($soRaw.Contains($i6Old)) { $soRaw = $soRaw.Replace($i6Old, $i6New); $applied++; Write-Host '  [OK] I6 (marker v62)' } else { $failed += 'I6: v61 marker NOT FOUND' }

Write-Host ''

# =============================================================================
# TECH_DEBT.md patches (4)
# =============================================================================
Write-Host '=== TECH_DEBT.md patches ==='

# T1: insert TD-014, TD-015, TD-016 before <!-- TECH_DEBT_LAST_UPDATED
$t1Anchor = '<!-- TECH_DEBT_LAST_UPDATED: 2026-08-13, Session 61 -->'
$t1Insert = @'
## TD-014 (P2): Жёсткий верхний лимит размера в normalize-скриптах

**Симптом:** Session 62 (2026-08-13). При обогащении intestinal_health.md валидация Size delta <= 8000 bytes упала (delta: 8665 bytes). Все 35 патчей и 30 PMID применились корректно, но скрипт прервался в валидации.

**Причина:** предустановленный верхний лимит 8000 байт был рассчитан исходя из ~250 байт/тег × 30 тегов = 7500 байт. На файлах с длинными названиями источников (Nature Reviews Gastroenterology, Cell Host Microbe, Physiological Reviews) реальный размер тега достигает 289 байт → 30 тегов = 8670 байт.

**Влияние:** ложное срабатывание защиты, требуется ручная правка лимита и перезапуск скрипта (потеря ~5 минут на инцидент, риск паники у оператора).

**Решение (правило):** адаптивный лимит в normalize-скриптах: `Size delta <= max(8000, 300 * patches_count)`. Для 30 патчей это 9000 байт, для 40 патчей — 12000 байт. Верхняя граница остаётся защитой от катастрофического роста файла (например, ошибки регекса, размножающей теги).

**Обнаружено:** Session 62 (2026-08-13). Исправлено локально в normalize_intestinal_health_v1.ps1 (лимит поднят до 10000). Требуется апгрейд playbook v1.2 → v1.3 с явным правилом.

## TD-015 (P3): TECH_DEBT.md LAST_UPDATED парсинг ловит описательный текст

**Симптом:** Session 62 (2026-08-13). Команда диагностики `if ($tdRaw -match ''LAST_UPDATED[:\s]*([^\r\n]+)'')` возвращает значение `устарел — пропуск обновления в Session 59 tail` вместо реальной даты `2026-08-13, Session 61`.

**Причина:** регекс `LAST_UPDATED` находит первое вхождение, а в TD-013 (описание проблемы устаревания LAST_UPDATED из Session 59 tail) слово `LAST_UPDATED` встречается в тексте описания раньше, чем метаданные-маркер `<!-- TECH_DEBT_LAST_UPDATED: ... -->` в конце файла.

**Влияние:** аудит-скрипты могут неверно показывать статус синхронизации TECH_DEBT.md; при автоматической валидации в close-скриптах может дать false negative.

**Решение (правило):** использовать более специфичный регекс `<!-- TECH_DEBT_LAST_UPDATED: ([^-]+) -->` или искать только в последних 20 строках файла. Аналогичный риск в LESSONS.md.

**Обнаружено:** Session 62 (2026-08-13). Требует апгрейда всех диагностических скриптов.

## TD-016 (P3): Локальная git-обёртка проверяет ветку copilot/build-v2-nutrition-agent-core

**Симптом:** при каждом запуске normalize-скрипта в PowerShell появляется предупреждение `Ветка: main ⚠️ (ожидается: copilot/build-v2-nutrition-agent-core)`. Работа идёт на main, ветка copilot/build-v2-nutrition-agent-core уже неактуальна.

**Причина:** локальный profile.ps1 или обёртка Agent-Nutri проверяет соответствие текущей ветки ожидаемой; ожидаемая ветка захардкожена как `copilot/build-v2-nutrition-agent-core` (была рабочей веткой в фазе F.1).

**Влияние:** шум в выводе всех скриптов, риск игнорирования реальных предупреждений синхронизации.

**Решение (правило):** обновить обёртку — ожидать `main` или сделать проверку опциональной (переменная окружения). Найти файл обёртки: `Get-Content $PROFILE` или искать `copilot/build-v2-nutrition-agent-core` в скриптах Agent-Nutri.

**Обнаружено:** Session 62 (2026-08-13). Косметика, не блокирует работу.

'@
$t1NewInsert = $t1Insert + $t1Anchor
if ($tdRaw.Contains($t1Anchor)) { $tdRaw = $tdRaw.Replace($t1Anchor, $t1NewInsert); $applied++; Write-Host '  [OK] T1 (TD-014/015/016 inserted)' } else { $failed += 'T1: TD anchor NOT FOUND' }

# T2: update TECH_DEBT_LAST_UPDATED
$t2Old = '<!-- TECH_DEBT_LAST_UPDATED: 2026-08-13, Session 61 -->'
$t2New = '<!-- TECH_DEBT_LAST_UPDATED: 2026-08-13, Session 62 -->'
if ($tdRaw.Contains($t2Old)) { $tdRaw = $tdRaw.Replace($t2Old, $t2New); $applied++; Write-Host '  [OK] T2 (TECH_DEBT_LAST_UPDATED)' } else { $failed += 'T2: TECH_DEBT_LAST_UPDATED NOT FOUND' }

# T3: update TECH_DEBT_COUNT_OPEN 13 → 16
$t3Old = '<!-- TECH_DEBT_COUNT_OPEN: 13 -->'
$t3New = '<!-- TECH_DEBT_COUNT_OPEN: 16 -->'
if ($tdRaw.Contains($t3Old)) { $tdRaw = $tdRaw.Replace($t3Old, $t3New); $applied++; Write-Host '  [OK] T3 (TECH_DEBT_COUNT_OPEN 13->16)' } else { $failed += 'T3: TECH_DEBT_COUNT_OPEN NOT FOUND' }

Write-Host ''

# =============================================================================
# LESSONS.md patches (3)
# =============================================================================
Write-Host '=== LESSONS.md patches ==='

# Le1: insert L-062-01, L-062-02 before <!-- LESSONS_LAST_UPDATED
$le1Anchor = '<!-- LESSONS_LAST_UPDATED: 2026-08-13, Session 61 -->'
$le1Insert = @'
## L-062-01: Пробелы в кириллических якорях — использовать hex-dump при первом FAIL

**Контекст:** Session 62 (2026-08-13). Патч P25 упал с сообщением `anchor NOT FOUND: ## 25. Бенчмарк: школьная гастроэнтерология vs EBM-функциона`. Диагностика через hex-dump показала: реальный заголовок содержит пробел `функциональный подход`, но в mapping-таблице якорь был скопирован из вывода PowerShell как `функциональныйподход` (визуальный перенос строки при выводе съел пробел).

**Причина:** PowerShell при выводе длинных строк может визуально сливать слова при переносе, особенно в узком терминале. При копировании из вывода теряется реальный пробел между словами.

**Урок:** при первом FAIL в normalize-скрипте немедленно запускать hex-dump якоря для проверки байтов: `[System.Text.Encoding]::UTF8.GetBytes($line) | ForEach-Object { $_.ToString(''X2'') }`. UTF-8 пробел = `20`, дефис = `2D`, неразрывный пробел (NBSP) = `C2 A0`.

**Профилактика:** в будущем движке (ebm_normalize.ps1) якоря строить по семантике (`^## $N\.`), а не по полному тексту — устойчиво к пробелам, эмодзи, дефисам.

<!-- LESSON_APPLIED_SESSION: 62 -->

## L-062-02: Адаптивный лимит размера файла в валидации normalize-скриптов

**Контекст:** Session 62 (2026-08-13). Валидация `Size delta <= 8000 bytes` упала с delta 8665 байт. Все патчи применились корректно, но скрипт прервался.

**Причина:** предустановленный лимит 8000 байт рассчитан на средний размер тега ~250 байт. На файлах с длинными названиями источников (Nature Reviews Gastroenterology, Cell Host Microbe, Physiological Reviews, IDSA/SHEA guidelines) реальный размер достигает 289 байт/тег.

**Данные из предыдущих сессий:**
- stress_adrenals: +3600 байт / 30 тегов = 120 байт/тег
- insulin_resistance: +4440 байт / 30 тегов = 148 байт/тег
- liver_health: +3786 байт / 30 тегов = 126 байт/тег
- intestinal_health: +8668 байт / 30 тегов = 289 байт/тег (максимум)

**Урок:** использовать адаптивный лимит `Size delta <= max(8000, 300 * patches_count)`. Для 30 патчей: 9000 байт. Для 40: 12000. Верхняя граница остаётся защитой от катастрофического роста файла.

**Профилактика:** апгрейд playbook v1.2 → v1.3 с явным правилом. Реализовано локально в normalize_intestinal_health_v1.ps1 (лимит поднят до 10000).

<!-- LESSON_APPLIED_SESSION: 62 -->

'@
$le1NewInsert = $le1Insert + $le1Anchor
if ($leRaw.Contains($le1Anchor)) { $leRaw = $leRaw.Replace($le1Anchor, $le1NewInsert); $applied++; Write-Host '  [OK] Le1 (L-062-01/02 inserted)' } else { $failed += 'Le1: LESSONS anchor NOT FOUND' }

# Le2: update LESSONS_LAST_UPDATED
$le2Old = '<!-- LESSONS_LAST_UPDATED: 2026-08-13, Session 61 -->'
$le2New = '<!-- LESSONS_LAST_UPDATED: 2026-08-13, Session 62 -->'
if ($leRaw.Contains($le2Old)) { $leRaw = $leRaw.Replace($le2Old, $le2New); $applied++; Write-Host '  [OK] Le2 (LESSONS_LAST_UPDATED)' } else { $failed += 'Le2: LESSONS_LAST_UPDATED NOT FOUND' }

# Le3: update LESSONS_COUNT 11 → 13
$le3Old = '<!-- LESSONS_COUNT: 11 -->'
$le3New = '<!-- LESSONS_COUNT: 13 -->'
if ($leRaw.Contains($le3Old)) { $leRaw = $leRaw.Replace($le3Old, $le3New); $applied++; Write-Host '  [OK] Le3 (LESSONS_COUNT 11->13)' } else { $failed += 'Le3: LESSONS_COUNT NOT FOUND' }

Write-Host ''
Write-Host "Patches applied: $applied / 21"

if ($failed.Count -gt 0) {
    Write-Host ''
    Write-Host '[FAIL] Some patches failed:'
    $failed | ForEach-Object { Write-Host "  - $_" }
    Write-Host ''
    Write-Host '[ABORT] Files NOT written. Backups preserved.'
    exit 1
}

# =============================================================================
# Validations
# =============================================================================
Write-Host ''
Write-Host '=== Validations ==='

$validations = @()

# STATUS.md
$validations += @{ Name='STATUS: 16/53 present'; Pass=($sRaw -match '16/53') }
$validations += @{ Name='STATUS: 36/53 present'; Pass=($sRaw -match '36/53') }
$validations += @{ Name='STATUS: 694 EBM present'; Pass=($sRaw -match '694 EBM') }
$validations += @{ Name='STATUS: 37 527 lines'; Pass=($sRaw -match '37 527') }
$validations += @{ Name='STATUS: Session 62 факт present'; Pass=($sRaw -match 'Session 62 факт') }
$validations += @{ Name='STATUS: STATUS_SESSION62_APPLIED marker'; Pass=($sRaw -match 'STATUS_SESSION62_APPLIED') }
$validations += @{ Name='STATUS: menopause.md as next target'; Pass=($sRaw -match 'menopause\.md') }
$validations += @{ Name='STATUS: old 15/53 removed from L87'; Pass=(-not ($sRaw -match '- \*\*FULL_EBM: 15/53')) }
$validations += @{ Name='STATUS: old 37/53 removed from L89'; Pass=(-not ($sRaw -match '- \*\*NO_EBM: 37/53')) }
$validations += @{ Name='STATUS: old 37 465 removed'; Pass=(-not ($sRaw -match '- Всего строк: 37 465')) }

# SOURCES_INDEX.md
$validations += @{ Name='SOURCES: 16 файлов (30.2%)'; Pass=($soRaw -match '16 файлов \(30\.2 %\)') }
$validations += @{ Name='SOURCES: 36 файлов (67.9%)'; Pass=($soRaw -match '36 файлов \(67\.9 %\)') }
$validations += @{ Name='SOURCES: 694 EBM'; Pass=($soRaw -match '694 EBM') }
$validations += @{ Name='SOURCES: Session 62 in header'; Pass=($soRaw -match '2026-08-13, Session 62') }
$validations += @{ Name='SOURCES: v62 marker'; Pass=($soRaw -match 'SOURCES_INDEX_EBM_APPLIED_v62') }
$validations += @{ Name='SOURCES: intestinal_health in FULL_EBM list'; Pass=($soRaw -match "FULL_EBM — 16 файлов.+intestinal_health") }
$validations += @{ Name='SOURCES: old 15 файлов removed'; Pass=(-not ($soRaw -match 'FULL_EBM — 15 файлов')) }
$validations += @{ Name='SOURCES: old 664 removed from total'; Pass=(-not ($soRaw -match 'Всего:\*\* 664')) }
$validations += @{ Name='SOURCES: old v61 marker removed'; Pass=(-not ($soRaw -match 'SOURCES_INDEX_EBM_APPLIED_v61')) }

# TECH_DEBT.md
$validations += @{ Name='TECH_DEBT: TD-014 present'; Pass=($tdRaw -match '## TD-014') }
$validations += @{ Name='TECH_DEBT: TD-015 present'; Pass=($tdRaw -match '## TD-015') }
$validations += @{ Name='TECH_DEBT: TD-016 present'; Pass=($tdRaw -match '## TD-016') }
$validations += @{ Name='TECH_DEBT: LAST_UPDATED Session 62'; Pass=($tdRaw -match 'TECH_DEBT_LAST_UPDATED: 2026-08-13, Session 62') }
$validations += @{ Name='TECH_DEBT: COUNT_OPEN 16'; Pass=($tdRaw -match 'TECH_DEBT_COUNT_OPEN: 16') }
$validations += @{ Name='TECH_DEBT: old COUNT_OPEN 13 removed'; Pass=(-not ($tdRaw -match 'TECH_DEBT_COUNT_OPEN: 13')) }
$validations += @{ Name='TECH_DEBT: old LAST_UPDATED Session 61 removed'; Pass=(-not ($tdRaw -match 'TECH_DEBT_LAST_UPDATED: 2026-08-13, Session 61')) }

# LESSONS.md
$validations += @{ Name='LESSONS: L-062-01 present'; Pass=($leRaw -match '## L-062-01') }
$validations += @{ Name='LESSONS: L-062-02 present'; Pass=($leRaw -match '## L-062-02') }
$validations += @{ Name='LESSONS: LAST_UPDATED Session 62'; Pass=($leRaw -match 'LESSONS_LAST_UPDATED: 2026-08-13, Session 62') }
$validations += @{ Name='LESSONS: COUNT 13'; Pass=($leRaw -match 'LESSONS_COUNT: 13') }
$validations += @{ Name='LESSONS: old COUNT 11 removed'; Pass=(-not ($leRaw -match 'LESSONS_COUNT: 11')) }
$validations += @{ Name='LESSONS: old LAST_UPDATED Session 61 removed'; Pass=(-not ($leRaw -match 'LESSONS_LAST_UPDATED: 2026-08-13, Session 61')) }

# Size deltas
$newSizeSTATUS = [System.Text.Encoding]::UTF8.GetByteCount($sRaw)
$newSizeSOURCES = [System.Text.Encoding]::UTF8.GetByteCount($soRaw)
$newSizeTECHDEBT = [System.Text.Encoding]::UTF8.GetByteCount($tdRaw)
$newSizeLESSONS = [System.Text.Encoding]::UTF8.GetByteCount($leRaw)

$deltaSTATUS = $newSizeSTATUS - $sizesBefore.STATUS
$deltaSOURCES = $newSizeSOURCES - $sizesBefore.SOURCES
$deltaTECHDEBT = $newSizeTECHDEBT - $sizesBefore.TECH_DEBT
$deltaLESSONS = $newSizeLESSONS - $sizesBefore.LESSONS

$validations += @{ Name='STATUS size delta >= 500'; Pass=($deltaSTATUS -ge 500); Detail="delta: $deltaSTATUS" }
$validations += @{ Name='STATUS size delta <= 5000'; Pass=($deltaSTATUS -le 5000); Detail="delta: $deltaSTATUS" }
$validations += @{ Name='SOURCES size delta >= 50'; Pass=($deltaSOURCES -ge 50); Detail="delta: $deltaSOURCES" }
$validations += @{ Name='SOURCES size delta <= 3000'; Pass=($deltaSOURCES -le 3000); Detail="delta: $deltaSOURCES" }
$validations += @{ Name='TECH_DEBT size delta >= 2000'; Pass=($deltaTECHDEBT -ge 2000); Detail="delta: $deltaTECHDEBT" }
$validations += @{ Name='TECH_DEBT size delta <= 8000'; Pass=($deltaTECHDEBT -le 8000); Detail="delta: $deltaTECHDEBT" }
$validations += @{ Name='LESSONS size delta >= 1000'; Pass=($deltaLESSONS -ge 1000); Detail="delta: $deltaLESSONS" }
$validations += @{ Name='LESSONS size delta <= 5000'; Pass=($deltaLESSONS -le 5000); Detail="delta: $deltaLESSONS" }

$okCount = 0
$failCount = 0
foreach ($v in $validations) {
    if ($v.Pass) {
        $okCount++
        $detail = if ($v.Detail) { " ($($v.Detail))" } else { '' }
        Write-Host "  [OK] $($v.Name)$detail"
    } else {
        $failCount++
        $detail = if ($v.Detail) { " ($($v.Detail))" } else { '' }
        Write-Host "  [FAIL] $($v.Name)$detail"
    }
}

Write-Host ''
Write-Host "Validations: $okCount OK, $failCount FAIL"

if ($failCount -gt 0) {
    Write-Host ''
    Write-Host '[ABORT] Validation failed. Files NOT written. Backups preserved.'
    exit 1
}

# =============================================================================
# Write files (UTF-8 with BOM)
# =============================================================================
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path $statusFile).Path, $sRaw, $utf8Bom)
[System.IO.File]::WriteAllText((Resolve-Path $sourcesFile).Path, $soRaw, $utf8Bom)
[System.IO.File]::WriteAllText((Resolve-Path $techDebtFile).Path, $tdRaw, $utf8Bom)
[System.IO.File]::WriteAllText((Resolve-Path $lessonsFile).Path, $leRaw, $utf8Bom)

Write-Host ''
Write-Host '=== SUCCESS ==='
Write-Host ("STATUS: {0} -> {1} bytes (delta: {2})" -f $sizesBefore.STATUS, $newSizeSTATUS, $deltaSTATUS)
Write-Host ("SOURCES: {0} -> {1} bytes (delta: {2})" -f $sizesBefore.SOURCES, $newSizeSOURCES, $deltaSOURCES)
Write-Host ("TECH_DEBT: {0} -> {1} bytes (delta: {2})" -f $sizesBefore.TECH_DEBT, $newSizeTECHDEBT, $deltaTECHDEBT)
Write-Host ("LESSONS: {0} -> {1} bytes (delta: {2})" -f $sizesBefore.LESSONS, $newSizeLESSONS, $deltaLESSONS)
Write-Host ''
Write-Host "Patches applied: $applied"
Write-Host "Validations OK: $okCount"
Write-Host "Backups stamp: $stamp"
Write-Host ''
Write-Host 'Ready for git add + commit (use git commit -F per L-061-01).'
# =====КОНЕЦ=====
