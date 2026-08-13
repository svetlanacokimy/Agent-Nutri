# =============================================================================
# scripts/update_tech_debt_and_lessons_s59_tail.ps1
# Session 59 tail: TD-008/009/010 + L-059-02/03 + Playbook v1.1 -> v1.2
# 3 файла, 3 патча TECH_DEBT + 2 патча LESSONS + 5 патчей Playbook
# Правила: L-057-01 (single quotes), TD-006 (no md-tables/backticks in body),
#          TD-007 (short commit), TD-008 (UTF-8 BOM), TD-009 (thresholds by fact)
# =============================================================================

$ErrorActionPreference = 'Stop'
$tdFile   = 'project/TECH_DEBT.md'
$lsFile   = 'project/LESSONS.md'
$pbFile   = 'project/PLAYBOOKS/session_ebm_enrichment.md'
$stamp    = Get-Date -Format 'yyyyMMdd-HHmmss'

Write-Host '=== Session 59 tail: TECH_DEBT + LESSONS + Playbook ==='
Write-Host ''

# ---- Guard
$tdRaw0 = Get-Content $tdFile -Raw -Encoding UTF8
$lsRaw0 = Get-Content $lsFile -Raw -Encoding UTF8
$pbRaw0 = Get-Content $pbFile -Raw -Encoding UTF8

if ($tdRaw0 -match 'TD-008') {
    Write-Host '[ABORT] TECH_DEBT.md уже содержит TD-008.'
    exit 1
}
if ($lsRaw0 -match 'L-059-02') {
    Write-Host '[ABORT] LESSONS.md уже содержит L-059-02.'
    exit 1
}
if ($pbRaw0 -match 'PLAYBOOK_v1.2_APPLIED') {
    Write-Host '[ABORT] Playbook уже содержит маркер v1.2.'
    exit 1
}

# ---- Backup
$tdBak = "$tdFile.bak.$stamp"
$lsBak = "$lsFile.bak.$stamp"
$pbBak = "$pbFile.bak.$stamp"
Copy-Item $tdFile $tdBak -Force
Copy-Item $lsFile $lsBak -Force
Copy-Item $pbFile $pbBak -Force
Write-Host "[OK] Backup: $tdBak"
Write-Host "[OK] Backup: $lsBak"
Write-Host "[OK] Backup: $pbBak"

$sizeTdBefore = (Get-Item $tdFile).Length
$sizeLsBefore = (Get-Item $lsFile).Length
$sizePbBefore = (Get-Item $pbFile).Length

$td = $tdRaw0
$ls = $lsRaw0
$pb = $pbRaw0
$patches = @()

function Apply-Patch {
    param([string]$Name,[string]$Target,[string]$Old,[string]$New)
    $ref = switch ($Target) {
        'td' { [ref]$script:td }
        'ls' { [ref]$script:ls }
        'pb' { [ref]$script:pb }
    }
    if ($ref.Value -notmatch [regex]::Escape($Old)) {
        throw "[FAIL] Patch '$Name' -- anchor not found"
    }
    $ref.Value = $ref.Value.Replace($Old, $New)
    $script:patches += $Name
    Write-Host "[OK] $Name"
}

# =============================================================================
# TECH_DEBT.md -- 3 патча (TD-008/009/010) + 2 метаданных
# =============================================================================

# T1: вставить TD-008/009/010 перед секцией Resolved
$t1Anchor = '## ✅ Resolved'
$t1New = @'
## TD-008 (P1): PowerShell 5.1 читает файлы без BOM как cp1251

**Issue:** Windows PowerShell 5.1 `powershell -File script.ps1` по умолчанию читает исходники в кодировке cp1251 (кодовая страница системы), а не UTF-8. Если PS-скрипт записан без BOM, кириллица в строковых литералах превращается в mojibake (например `Последнее` → `РџРѕСЃР»РµРґРЅРµРµ`), и скрипт падает с `UnexpectedToken`.
**Priority:** P1 (критично — блокирует выполнение скриптов).
**Found:** Session 59 (2026-08-10), инцидент при попытке фикса якоря S1 в close_session59.ps1: команда `[System.IO.File]::WriteAllText(..., new UTF8Encoding($false))` перезаписала скрипт без BOM, следующий запуск — mojibake + parse errors.
**Impact:** ~15 минут потеряно на диагностику и перезалив скрипта из VS Code.
**Fix (rule):** (a) при сохранении PS-скриптов в VS Code — только `UTF-8 with BOM` (правый нижний угол); (b) при записи из PS-скрипта — только `Set-Content -Encoding UTF8` (в 5.1 всегда пишет BOM) или `[System.IO.File]::WriteAllText(path, content, (New-Object System.Text.UTF8Encoding($true)))`; (c) `UTF8Encoding($false)` — запрещено.
**Estimation:** 0 min (правило, применяется с Session 60).

---

## TD-009 (P2): Пороги валидации размера — только по факту первого прогона

**Issue:** Оценочные пороги дельты размера в валидациях (`$deltaSize -ge N`) часто дают false-positive fail, потому что реальная дельта не совпадает с эвристической оценкой (30 тегов × 50 chars ≠ фактический прирост из-за сокращений в других патчах).
**Priority:** P2 (не блокирует, но откладывает запись файла и требует повторного запуска).
**Found:** Session 59, два инцидента: (a) `normalize_stress_adrenals_v1.ps1` порог +2500 chars, факт +2467 → fail, снижен до +1500; (b) `close_session59.ps1` порог SOURCES +200 chars, факт +137 → fail, снижен до +50.
**Impact:** ~5–10 минут на инцидент (диагностика + правка порога + повторный запуск).
**Fix (rule):** (a) первый запуск скрипта — «сухой» с намеренно низкими порогами (например +50 chars) для сбора реальных дельт; (b) финальные пороги = 50–70 % от реальной дельты (запас 20–30 % на изменения текстов патчей); (c) альтернатива: `[Math]::Abs($sizeAfter - $sizeBefore) -ge N` учитывает и сокращения; (d) для SOURCES-подобных файлов, где патчи могут быть и удалениями — использовать `Abs()`.
**Estimation:** 0 min (методологический сдвиг).

---

## TD-010 (P3): Побайтная валидация якорей до отправки скрипта

**Issue:** Строковые литералы `$Old` в `Apply-Patch` содержат невидимые артефакты (пробел или его отсутствие после запятой, пробел перед/после Unicode-стрелки, неразрывный пробел U+00A0), не совпадающие с реальным содержимым файла. `Replace` не находит якорь → `[FAIL] anchor not found`.
**Priority:** P3 (косметический — легко чинится диагностической командой, но задерживает).
**Found:** Session 59, три инцидента: (a) S1 в close_session59.ps1 — якорь `v2.0→ v2.1` vs факт `v2.0 → v2.1` (пробел перед стрелкой); (b) S9 — якорь `40 NO_EBM,574` vs факт `40 NO_EBM, 574` (пробел после запятой); (c) P28 в normalize_stress_adrenals_v1.ps1 — якорь `### Fries et al. 2005` vs факт `### Позиция для нутрициолога` (несуществующий заголовок).
**Impact:** ~5 минут на инцидент (побайтная диагностика через `for ($i=0; $i -lt $line.Length; $i++) { [int]$line[$i] }` + правка якоря).
**Fix (rule):** (a) перед составлением якорей — обязательный вывод целевых строк через `(Get-Content $file -Encoding UTF8)[N-1]` с проверкой `.Contains($anchor)`; (b) для H3-якорей — вывод `Select-String -Pattern '^### '` по диапазону строк раздела; (c) в playbook Шаг 3 добавлен Invariant #8 «побайтная валидация якорей».
**Estimation:** 0 min (интегрируется через playbook v1.2).

---

'@ + $t1Anchor
Apply-Patch 'T1 TD-008/009/010 blocks' 'td' $t1Anchor $t1New

# T2: TECH_DEBT_COUNT_OPEN 7 -> 10
$t2Old = 'TECH_DEBT_COUNT_OPEN: 7'
$t2New = 'TECH_DEBT_COUNT_OPEN: 10'
Apply-Patch 'T2 COUNT_OPEN 7->10' 'td' $t2Old $t2New

# T3: LAST_UPDATED Session 58 -> Session 59
$t3Old = 'TECH_DEBT_LAST_UPDATED: 2026-08-09, Session 58'
$t3New = 'TECH_DEBT_LAST_UPDATED: 2026-08-10, Session 59'
Apply-Patch 'T3 LAST_UPDATED S58->S59' 'td' $t3Old $t3New

# =============================================================================
# LESSONS.md -- 2 патча (L-059-02/03) + 1 метаданных
# =============================================================================

# L1: вставить L-059-02 и L-059-03 перед футером
$l1Anchor = '<!-- LESSONS_COUNT'
$l1New = @'
## L-059-02: UTF-8 BOM обязателен для PowerShell 5.1

**Rule:** PS-скрипты сохранять только с `UTF-8 with BOM` кодировкой. При записи из PS — использовать `Set-Content -Encoding UTF8` (в 5.1 пишет BOM автоматически) или `[System.IO.File]::WriteAllText(path, content, (New-Object System.Text.UTF8Encoding($true)))`. Никогда — `UTF8Encoding($false)`.
**Rationale:** Windows PowerShell 5.1 без BOM читает файлы как cp1251 → кириллица в строковых литералах становится mojibake (`РџРѕСЃР»РµРґРЅРµРµ` вместо `Последнее`), скрипт падает с `UnexpectedToken`.
**Observed:** Session 59 инцидент фикса якоря S1 в close_session59.ps1. Команда `[System.IO.File]::WriteAllText(..., new UTF8Encoding($false))` сорвала BOM с исходного скрипта, следующий запуск — parse errors. Пришлось залить файл заново из VS Code с `UTF-8 with BOM`. Время потерь: ~15 минут.
**Related:** TD-008.

---

## L-059-03: Пороги валидации размера — по факту первого прогона

**Rule:** В валидациях `check($deltaSize -ge N)` порог N выставлять после первого «сухого» прогона по реальной дельте, а не эвристической оценкой. Первый запуск — с намеренно низким порогом (+50 chars) для сбора факта. Финальный порог = 50–70 % от реальной дельты. Для файлов, где патчи могут сокращать текст (SOURCES, метадата) — использовать `[Math]::Abs($sizeAfter - $sizeBefore) -ge N`.
**Rationale:** Эвристическая оценка «30 тегов × 50 chars = +1500» не учитывает сокращения в других патчах и сжатие Unicode при UTF-8-кодировании; порог получается завышенным, валидация фейлится, транзакция откатывается, инцидент требует повторного запуска.
**Observed:** Session 59 два инцидента: (a) `normalize_stress_adrenals_v1.ps1` порог +2500, факт +2467 → fail, снижен до +1500; (b) `close_session59.ps1` порог SOURCES +200, факт +137 → fail, снижен до +50. Оба раза файлы не пострадали (транзакционность), но потрачено ~10 минут на диагностику и повторный запуск.
**Related:** TD-009.

---

'@ + $l1Anchor
Apply-Patch 'L1 L-059-02/03 blocks' 'ls' $l1Anchor $l1New

# L2: LESSONS_COUNT 8 -> 10
$l2Old = 'LESSONS_COUNT: 8'
$l2New = 'LESSONS_COUNT: 10'
Apply-Patch 'L2 LESSONS_COUNT 8->10' 'ls' $l2Old $l2New

# =============================================================================
# Playbook -- 5 патчей (v1.1 -> v1.2)
# =============================================================================

# P1: version 1.1 -> 1.2 (в футере)
$p1Old = 'PLAYBOOK_VERSION: 1.1'
$p1New = 'PLAYBOOK_VERSION: 1.2'
Apply-Patch 'P1 version 1.1->1.2' 'pb' $p1Old $p1New

# P2: LAST_UPDATED Session 57 -> Session 59
$p2Old = 'PLAYBOOK_LAST_UPDATED: 2026-08-06, Session 57'
$p2New = 'PLAYBOOK_LAST_UPDATED: 2026-08-10, Session 59'
Apply-Patch 'P2 LAST_UPDATED S57->S59' 'pb' $p2Old $p2New

# P3: BASED_ON_SESSIONS расширить
$p3Old = 'BASED_ON_SESSIONS: 53, 54, 55, 57'
$p3New = 'BASED_ON_SESSIONS: 53, 54, 55, 57, 58, 59'
Apply-Patch 'P3 BASED_ON расширен' 'pb' $p3Old $p3New

# P4: маркер PLAYBOOK_v1.1_APPLIED -> v1.2_APPLIED
$p4Old = 'PLAYBOOK_v1.1_APPLIED'
$p4New = 'PLAYBOOK_v1.2_APPLIED'
Apply-Patch 'P4 маркер v1.1->v1.2' 'pb' $p4Old $p4New

# P5: добавить Invariants 8 и 9 перед футером
$p5Anchor = '<!-- PLAYBOOK_v1.2_APPLIED -->'
$p5New = @'
## Invariant 8: Побайтная валидация якорей до отправки скрипта

Перед составлением `$Old` в `Apply-Patch` — обязательный вывод целевых строк из файла и побайтная сверка с текстом якоря:

    $line = (Get-Content $file -Encoding UTF8)[N-1]
    Write-Host "Contains anchor: $($line.Contains($anchor))"

Для якорей с Unicode-символами (стрелки →, тире —, буллеты •) — дополнительно вывести коды каждого символа в контексте якоря. Не полагаться на визуальное совпадение: пробел U+0020, неразрывный пробел U+00A0 и артефакты Write-Host в узкой консоли выглядят одинаково.

**Rationale:** L-057-01 (single quotes) закрывает интерпретацию бэктиков, но не решает проблему пробелов вокруг Unicode. Session 59 — три инцидента якорей (S1, S9, P28), суммарно ~15 минут потерь.

**Related lessons:** L-057-01, TD-010.

---

## Invariant 9: UTF-8 BOM для скриптов + пороги размера по факту

**9a. Кодировка PS-скриптов.** Все скрипты сохранять только с `UTF-8 with BOM`. При записи из PS — `Set-Content -Encoding UTF8` или `UTF8Encoding($true)`. Запрещено: `UTF8Encoding($false)` — Windows PowerShell 5.1 читает без BOM как cp1251, кириллица → mojibake, скрипт не парсится.

**9b. Пороги валидации размера.** Первый запуск скрипта — «сухой» с порогом +50 chars для сбора реальной дельты. Финальный порог = 50–70 % от факта (запас 20–30 %). Для метафайлов (SOURCES_INDEX, STATUS), где патчи могут сокращать — использовать `[Math]::Abs($delta) -ge N`.

**Rationale:** TD-008 (BOM) и TD-009 (пороги) — по 15 и 10 минут потерь в Session 59.

**Related lessons:** L-059-02, L-059-03. Related tech debt: TD-008, TD-009.

---

'@ + $p5Anchor
Apply-Patch 'P5 Invariants 8+9' 'pb' $p5Anchor $p5New

# =============================================================================
# ВАЛИДАЦИЯ
# =============================================================================

Write-Host ''
Write-Host '=== Валидация ==='

$sizeTdAfter = [System.Text.Encoding]::UTF8.GetByteCount($td)
$sizeLsAfter = [System.Text.Encoding]::UTF8.GetByteCount($ls)
$sizePbAfter = [System.Text.Encoding]::UTF8.GetByteCount($pb)
$deltaTd = $sizeTdAfter - $sizeTdBefore
$deltaLs = $sizeLsAfter - $sizeLsBefore
$deltaPb = $sizePbAfter - $sizePbBefore

$checks = @(
    @{Name='TECH_DEBT содержит TD-008';           Test={ $td -match 'TD-008' }},
    @{Name='TECH_DEBT содержит TD-009';           Test={ $td -match 'TD-009' }},
    @{Name='TECH_DEBT содержит TD-010';           Test={ $td -match 'TD-010' }},
    @{Name='TECH_DEBT COUNT_OPEN 10';             Test={ $td -match 'TECH_DEBT_COUNT_OPEN: 10' }},
    @{Name='TECH_DEBT LAST_UPDATED Session 59';   Test={ $td -match 'TECH_DEBT_LAST_UPDATED: 2026-08-10, Session 59' }},
    @{Name='TECH_DEBT нет старого COUNT 7';       Test={ -not ($td -match 'TECH_DEBT_COUNT_OPEN: 7') }},
    @{Name='LESSONS содержит L-059-02';           Test={ $ls -match 'L-059-02' }},
    @{Name='LESSONS содержит L-059-03';           Test={ $ls -match 'L-059-03' }},
    @{Name='LESSONS COUNT 10';                    Test={ $ls -match 'LESSONS_COUNT: 10' }},
    @{Name='LESSONS нет старого COUNT 8';         Test={ -not ($ls -match 'LESSONS_COUNT: 8') }},
    @{Name='LESSONS упоминает UTF-8 BOM';         Test={ $ls -match 'UTF-8 with BOM' }},
    @{Name='Playbook version 1.2';                Test={ $pb -match 'PLAYBOOK_VERSION: 1\.2' }},
    @{Name='Playbook LAST_UPDATED Session 59';    Test={ $pb -match 'PLAYBOOK_LAST_UPDATED: 2026-08-10, Session 59' }},
    @{Name='Playbook BASED_ON 53,54,55,57,58,59'; Test={ $pb -match 'BASED_ON_SESSIONS: 53, 54, 55, 57, 58, 59' }},
    @{Name='Playbook маркер v1.2_APPLIED';        Test={ $pb -match 'PLAYBOOK_v1\.2_APPLIED' }},
    @{Name='Playbook нет маркера v1.1_APPLIED';   Test={ -not ($pb -match 'PLAYBOOK_v1\.1_APPLIED') }},
    @{Name='Playbook Invariant 8 (якоря)';        Test={ $pb -match 'Invariant 8' }},
    @{Name='Playbook Invariant 9 (BOM+пороги)';   Test={ $pb -match 'Invariant 9' }},
    @{Name='TECH_DEBT размер +2500 chars';        Test={ $deltaTd -ge 2500 }},
    @{Name='LESSONS размер +1500 chars';          Test={ $deltaLs -ge 1500 }},
    @{Name='Playbook размер +1200 chars';         Test={ $deltaPb -ge 1200 }}
)

$failCount = 0
foreach ($c in $checks) {
    $ok = & $c.Test
    if ($ok) { Write-Host ('[OK] '   + $c.Name) }
    else     { Write-Host ('[FAIL] ' + $c.Name); $failCount++ }
}

if ($failCount -gt 0) {
    Write-Host ''
    Write-Host "[ABORT] $failCount валидаций провалено -- файлы НЕ записаны."
    Write-Host "Backup TECH_DEBT: $tdBak"
    Write-Host "Backup LESSONS:   $lsBak"
    Write-Host "Backup Playbook:  $pbBak"
    exit 1
}

Set-Content -Path $tdFile -Value $td -Encoding UTF8 -NoNewline
Set-Content -Path $lsFile -Value $ls -Encoding UTF8 -NoNewline
Set-Content -Path $pbFile -Value $pb -Encoding UTF8 -NoNewline

Write-Host ''
Write-Host '=== ИТОГ ==='
Write-Host ("TECH_DEBT.md: $sizeTdBefore -> $sizeTdAfter (delta $deltaTd bytes)")
Write-Host ("LESSONS.md:   $sizeLsBefore -> $sizeLsAfter (delta $deltaLs bytes)")
Write-Host ("Playbook:     $sizePbBefore -> $sizePbAfter (delta $deltaPb bytes)")
Write-Host ("Патчей применено: " + $patches.Count)
Write-Host ("Валидаций OK: " + $checks.Count)
Write-Host ''
Write-Host "Backup TECH_DEBT: $tdBak"
Write-Host "Backup LESSONS:   $lsBak"
Write-Host "Backup Playbook:  $pbBak"
Write-Host ''
Write-Host '[DONE] Session 59 tail complete. Готово к git add + commit.'
