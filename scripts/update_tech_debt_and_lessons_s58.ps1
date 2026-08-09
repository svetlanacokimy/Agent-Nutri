# =============================================================================
# update_tech_debt_and_lessons_s58.ps1
# Session 58 tail — TD-003/004/005 в TECH_DEBT.md + L-058-01 в LESSONS.md
# Схема: Read -> Apply -> Validate -> Write (L-053-01)
# Все якоря в single quotes (L-057-01)
# =============================================================================

$ErrorActionPreference = 'Stop'

$tdFile      = 'project/TECH_DEBT.md'
$lessonsFile = 'project/LESSONS.md'

Write-Host "=== update_tech_debt_and_lessons_s58.ps1 ===" -ForegroundColor Cyan
Write-Host ""

$rawTd      = [System.IO.File]::ReadAllText((Resolve-Path $tdFile),      [System.Text.Encoding]::UTF8)
$rawLessons = [System.IO.File]::ReadAllText((Resolve-Path $lessonsFile), [System.Text.Encoding]::UTF8)

if ($rawTd -match 'TD-003') {
    Write-Host "[GUARD] TD-003 уже присутствует в TECH_DEBT.md — выход." -ForegroundColor Yellow
    exit 0
}
if ($rawLessons -match 'L-058-01') {
    Write-Host "[GUARD] L-058-01 уже присутствует в LESSONS.md — выход." -ForegroundColor Yellow
    exit 0
}

$tdSizeBefore      = $rawTd.Length
$lessonsSizeBefore = $rawLessons.Length
Write-Host "[INFO] TECH_DEBT.md: $tdSizeBefore chars"
Write-Host "[INFO] LESSONS.md:   $lessonsSizeBefore chars"
Write-Host ""

$ts = Get-Date -Format 'yyyyMMdd-HHmmss'
$tdBackup      = "$tdFile.bak.$ts"
$lessonsBackup = "$lessonsFile.bak.$ts"
Copy-Item -Path $tdFile      -Destination $tdBackup      -Force
Copy-Item -Path $lessonsFile -Destination $lessonsBackup -Force
Write-Host "[BACKUP] $tdBackup"
Write-Host "[BACKUP] $lessonsBackup"
Write-Host ""

$td = $rawTd
$ls = $rawLessons
$applied = 0

function Apply-PatchTd {
    param([string]$Name, [string]$Old, [string]$New)
    if ($script:td.IndexOf($Old) -lt 0) { throw "[$Name] ANCHOR NOT FOUND в TECH_DEBT.md" }
    $script:td = $script:td.Replace($Old, $New)
    $script:applied++
    Write-Host "[OK] $Name" -ForegroundColor Green
}

function Apply-PatchLs {
    param([string]$Name, [string]$Old, [string]$New)
    if ($script:ls.IndexOf($Old) -lt 0) { throw "[$Name] ANCHOR NOT FOUND в LESSONS.md" }
    $script:ls = $script:ls.Replace($Old, $New)
    $script:applied++
    Write-Host "[OK] $Name" -ForegroundColor Green
}

Write-Host "=== TECH_DEBT.md патчи ===" -ForegroundColor Cyan

$tdOld = '## ✅ Resolved (закрытый долг)'
$tdNew = @'
### TD-003 — устаревшая метрика строк в metadata pancreas_health.md

**Приоритет**: 🟢 P3
**Обнаружен**: Session 58 (2026-08-06)
**Область**: references/methodology/pancreas_health.md, блок Метаданные

**Симптом**: в метаданных указано 891 строк, фактически после обогащения FULL_EBM — 925 строк (по аудит-скрипту).

**Причина**: при обогащении Session 58 не обновляли поле «строк» в metadata (фокус был на EBM-тегах, версии, статусе, маркерах). Аналог TD-002 для gallbladder.

**Влияние**: косметическое расхождение. Не влияет на аудит, не влияет на классификацию FULL_EBM.

**План фикса**: при следующем касании файла обновить строку 891 строк на актуальное значение. Одно поле, ~30 секунд.

---

### TD-004 — косметика audit-скрипта при нулевом PARTIAL_EBM

**Приоритет**: 🟢 P3
**Обнаружен**: Session 58 (2026-08-06)
**Область**: scripts/audit_ebm_compliance.ps1, форматирование итоговых метрик

**Симптом**: при PARTIAL_EBM = 0/53 строка вывода отображается как "PARTIAL_EBM:  / 53 files (0%)" — пропущено число перед слэшем.

**Причина**: вероятно, formatting-строка использует -f с пустой переменной, когда счётчик = 0, или пропускает placeholder. Другие категории (FULL_EBM, NO_EBM) отображаются корректно.

**Влияние**: только визуальный дефект в консольном выводе. Реальные метрики (запись в файлы STATUS/SOURCES_INDEX) не затронуты — там числа корректные.

**План фикса**: посмотреть блок вывода метрик в audit_ebm_compliance.ps1, добавить явное форматирование или проверку на null перед подстановкой. ~5 минут.

---

### TD-005 — обязательная таблица «патч → +тегов» до отправки normalize-скрипта

**Приоритет**: 🟡 P2
**Обнаружен**: Session 58 (2026-08-06)
**Область**: процесс генерации normalize-скриптов (assistant workflow), потенциально playbook

**Симптом**: normalize-скрипт v1 pancreas_health.md планировался на 30 EBM-тегов, но по факту содержал 32 (2 «корректировочных» патча P5/P6 работали с неверной логикой якорей). Скрипт упал на P6 → пришлось делать v2 с ручным перебором. Аналогичная проблема потенциально могла возникнуть в Session 57 (gallbladder), но там повезло с якорями.

**Причина**: при составлении плана патчей считается «на глаз», без явной таблицы. Итоговое число тегов = сумма (заголовок += тег: +1) + сумма (вставка блока с тегом: +1). Легко ошибиться на 1-2 при 30+ патчах.

**Влияние**: удвоенное время на сессию enrichment (v1 → падение → v2 → успех). В Session 58 это стоило ~15 минут.

**План фикса**: (1) В assistant workflow: перед отправкой normalize-скрипта строить явную markdown-таблицу колонок P№, Секция, Действие, +тегов и суммировать колонку +тегов = целевое число. (2) В playbook session_ebm_enrichment.md Шаг 3: добавить пункт «обязательная таблица патч→тегов с суммой». (3) См. L-058-01 в LESSONS.md.

**Оценка фикса**: обновление playbook v1.1 → v1.2 в Session 59 или позже. ~10 минут.

---

## ✅ Resolved (закрытый долг)
'@
Apply-PatchTd 'T1 TD-003/004/005 вставлены' $tdOld $tdNew

Apply-PatchTd 'T2 LAST_UPDATED -> Session 58' `
    '<!-- TECH_DEBT_LAST_UPDATED: 2026-08-06, Session 57 -->' `
    '<!-- TECH_DEBT_LAST_UPDATED: 2026-08-06, Session 58 -->'

Apply-PatchTd 'T3 COUNT_OPEN 2 -> 5' `
    '<!-- TECH_DEBT_COUNT_OPEN: 2 -->' `
    '<!-- TECH_DEBT_COUNT_OPEN: 5 -->'

Write-Host ""
Write-Host "=== LESSONS.md патчи ===" -ForegroundColor Cyan

$lsOld = '<!-- LESSONS_LAST_UPDATED: 2026-08-05, Session 57 -->'
$lsNew = @'
### L-058-01 — обязательная таблица «патч → +тегов» до отправки normalize-скрипта

**Дата**: 2026-08-06
**Сессия**: 58 (normalize_pancreas_health_v1.ps1)

**Контекст**: скрипт v1 pancreas_health.md был отправлен пользователю с заявленной целью «30 EBM-тегов». По факту содержал 32 патча, каждый добавляющий 1 тег: 30 обычных (заголовок += тег) + 2 вставки блоков с тегами. При запуске упал на P6 из-за неверной логики «корректировочных патчей»: P6 искал якорь с уже вставленным тегом Tenner 2013 в заголовке §5, которого не существовало — тег ушёл в inline-блок перед §5, а не в сам заголовок.

**Проблема**: подсчёт тегов делался «на глаз» при 30+ патчах. Разница между «заголовок += тег» (+1) и «вставка блока с тегом» (+1) при разных якорях создаёт когнитивную нагрузку, где легко ошибиться на 1-2.

**Корневая причина**: отсутствие явного пре-flight пересчёта тегов в структурированной таблице.

**Правило**: перед отправкой любого normalize-скрипта пользователю ассистент обязан построить в своём ответе markdown-таблицу с колонками P№, Секция, Действие, +тегов, где каждый патч имеет явное количество добавляемых тегов, и убедиться, что сумма колонки +тегов равна целевому числу из плана. Если сумма не равна target — план правится ДО отправки, а не после падения скрипта.

**Верификация**: скрипт v2 pancreas_health.md был построен с явной таблицей (см. сообщение в чате Session 58), убраны P10 и P17 для точного попадания в 30 → прогон 30/30 патчей + 29/29 валидаций OK с первого раза.

**Смежные уроки**: L-053-01 (транзакционность), L-054-01 (создание скриптов через code), L-055-01 (полные строки для replace), L-057-01 (single quotes для якорей).

**Связь с TECH_DEBT**: TD-005 (методологический долг: интеграция правила в playbook Шаг 3).

**Файлы**: scripts/normalize_pancreas_health_v1.ps1 (v2 — успех), project/LESSONS.md (эта запись), project/TECH_DEBT.md (TD-005), в будущем project/PLAYBOOKS/session_ebm_enrichment.md (v1.1 → v1.2).

---

<!-- LESSONS_LAST_UPDATED: 2026-08-06, Session 58 -->
'@
Apply-PatchLs 'L1 L-058-01 вставлен + footer обновлён' $lsOld $lsNew

Apply-PatchLs 'L2 COUNT 6 -> 7' `
    '<!-- LESSONS_COUNT: 6 -->' `
    '<!-- LESSONS_COUNT: 7 -->'

Write-Host ""
Write-Host "=== ВАЛИДАЦИИ ===" -ForegroundColor Cyan

$checks = @(
    @{ Name = 'TD: TD-003 присутствует';                       Test = { $td -match '### TD-003 —' } },
    @{ Name = 'TD: TD-004 присутствует';                       Test = { $td -match '### TD-004 —' } },
    @{ Name = 'TD: TD-005 присутствует';                       Test = { $td -match '### TD-005 —' } },
    @{ Name = 'TD: TD-005 упоминает Session 58';               Test = { $td -match 'TD-005[\s\S]*?Session 58' } },
    @{ Name = 'TD: раздел Resolved сохранён';                  Test = { $td -match '## ✅ Resolved' } },
    @{ Name = 'TD: TD-001 сохранён';                           Test = { $td -match '### TD-001' } },
    @{ Name = 'TD: TD-002 сохранён';                           Test = { $td -match '### TD-002' } },
    @{ Name = 'TD: LAST_UPDATED Session 58';                   Test = { $td -match 'TECH_DEBT_LAST_UPDATED:\s*2026-08-06,\s*Session 58' } },
    @{ Name = 'TD: старый LAST_UPDATED Session 57 удалён';     Test = { -not ($td -match 'TECH_DEBT_LAST_UPDATED:\s*2026-08-06,\s*Session 57') } },
    @{ Name = 'TD: COUNT_OPEN 5';                              Test = { $td -match 'TECH_DEBT_COUNT_OPEN:\s*5' } },
    @{ Name = 'TD: старый COUNT_OPEN 2 удалён';                Test = { -not ($td -match 'TECH_DEBT_COUNT_OPEN:\s*2\s*-->') } },
    @{ Name = 'LS: L-058-01 присутствует';                     Test = { $ls -match '### L-058-01 —' } },
    @{ Name = 'LS: заголовок про таблицу патч-тегов';          Test = { $ls -match 'таблица|патч.*тегов' } },
    @{ Name = 'LS: упоминание Session 58';                     Test = { $ls -match 'L-058-01[\s\S]*?Сессия.*58' } },
    @{ Name = 'LS: LAST_UPDATED Session 58';                   Test = { $ls -match 'LESSONS_LAST_UPDATED:\s*2026-08-06,\s*Session 58' } },
    @{ Name = 'LS: старый LAST_UPDATED Session 57 удалён';     Test = { -not ($ls -match 'LESSONS_LAST_UPDATED:\s*2026-08-05,\s*Session 57') } },
    @{ Name = 'LS: COUNT 7';                                   Test = { $ls -match 'LESSONS_COUNT:\s*7' } },
    @{ Name = 'LS: старый COUNT 6 удалён';                     Test = { -not ($ls -match 'LESSONS_COUNT:\s*6\s*-->') } },
    @{ Name = 'LS: L-057-01 сохранён';                         Test = { $ls -match 'L-057-01' } },
    @{ Name = 'TD: размер вырос (>= +1500 chars)';             Test = { ($td.Length - $tdSizeBefore) -ge 1500 } },
    @{ Name = 'LS: размер вырос (>= +1000 chars)';             Test = { ($ls.Length - $lessonsSizeBefore) -ge 1000 } }
)

$failed = 0
foreach ($chk in $checks) {
    if (& $chk.Test) {
        Write-Host "  [OK] $($chk.Name)" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $($chk.Name)" -ForegroundColor Red
        $failed++
    }
}

if ($failed -gt 0) {
    Write-Host ""
    Write-Host "[ABORT] $failed валидаций провалено — файлы НЕ записаны." -ForegroundColor Red
    Write-Host "  Backups: $tdBackup, $lessonsBackup" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

$enc = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path $tdFile),      $td, $enc)
[System.IO.File]::WriteAllText((Resolve-Path $lessonsFile), $ls, $enc)

Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "  TECH_DEBT.md:  $tdSizeBefore -> $($td.Length)   (delta +$($td.Length - $tdSizeBefore))"
Write-Host "  LESSONS.md:    $lessonsSizeBefore -> $($ls.Length)   (delta +$($ls.Length - $lessonsSizeBefore))"
Write-Host "  Patches:       $applied applied (3 TECH_DEBT + 2 LESSONS)"
Write-Host "  Checks:        $($checks.Count)/$($checks.Count) OK"
Write-Host ""
Write-Host "  TECH_DEBT: TD-001, TD-002, TD-003, TD-004, TD-005 (5 open)"
Write-Host "  LESSONS:   L-053-01 .. L-058-01 (7 lessons)"
Write-Host ""
Write-Host "=== DONE ===" -ForegroundColor Green
