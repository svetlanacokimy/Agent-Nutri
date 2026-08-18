# =============================================================================
# update_playbook_L057.ps1
# Session 57 tail — интеграция L-057-01 в session_ebm_enrichment.md
# Транзакционная схема: Read -> Apply -> Validate -> Write (L-053-01)
# Все якоря с markdown-бэктиками — в single quotes (L-057-01, self-check)
# =============================================================================

$ErrorActionPreference = 'Stop'
$file = 'project/PLAYBOOKS/session_ebm_enrichment.md'

Write-Host "=== update_playbook_L057.ps1 ===" -ForegroundColor Cyan
Write-Host "  Target: $file"
Write-Host ""

# --- Guard идемпотентности ---
$raw = [System.IO.File]::ReadAllText((Resolve-Path $file), [System.Text.Encoding]::UTF8)
if ($raw -match '<!--\s*PLAYBOOK_v1\.1_APPLIED\s*-->') {
    Write-Host "[GUARD] Маркер PLAYBOOK_v1.1_APPLIED уже присутствует — скрипт уже применён. Выход." -ForegroundColor Yellow
    exit 0
}

$sizeBefore = $raw.Length
Write-Host "[INFO] Размер до: $sizeBefore chars" -ForegroundColor Gray

# --- Backup ---
$ts = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = "$file.bak.$ts"
Copy-Item -Path $file -Destination $backup -Force
Write-Host "[BACKUP] $backup" -ForegroundColor Gray
Write-Host ""

$c = $raw

# =============================================================================
# ПАТЧИ
# =============================================================================

# --- P1: вставка блока "Ловушка PowerShell" в конец Шага 4, перед "## Шаг 5" ---
$p1old = '## Шаг 5 — Прогон и валидация'
$p1new = @'
### ⚠️ Ловушка PowerShell (L-057-01)

Если якорная строка содержит markdown-бэктики (например, имя файла в обратных кавычках), **всегда** оборачивай её в **single quotes** (одинарные кавычки), а не в double quotes.

Причина: в double-quoted строке PowerShell бэктик — это escape-префикс, он исчезает из строки, и `-replace` не находит якорь → `ANCHOR NOT FOUND`.

Плохо (бэктики съедаются):

    $anchor = "- `covid_pregnancy.md` (обогащён)"   # бэктики исчезнут

Хорошо (литерал сохраняется):

    $anchor = '- `covid_pregnancy.md` (обогащён)'   # бэктики на месте

Для многострочных якорей — конкатенация single-quoted литералов или here-string на одинарных кавычках.

Инцидент: close_session57.ps1 v1 упал на [S2] из-за escape-эффекта → фикс v2 через single quotes → 19 патчей + 23 валидации зелёные.

## Шаг 5 — Прогон и валидация
'@

if ($c.IndexOf($p1old) -lt 0) { throw "[P1] ANCHOR NOT FOUND: $p1old" }
$c = $c.Replace($p1old, $p1new)
Write-Host "[OK] P1 — блок 'Ловушка PowerShell' вставлен перед Шагом 5" -ForegroundColor Green

# --- P2: добавление пункта 7 в блок Инвариантов ---
$p2old = '6. Guard идемпотентности в начале каждого скрипта — обязателен.'
$p2new = @'
6. Guard идемпотентности в начале каждого скрипта — обязателен.
7. Якорные строки с markdown-бэктиками, знаками доллара или двойными кавычками — только в single quotes (L-057-01). Double quotes + backtick = escape-ловушка.
'@

if ($c.IndexOf($p2old) -lt 0) { throw "[P2] ANCHOR NOT FOUND: $p2old" }
$c = $c.Replace($p2old, $p2new)
Write-Host "[OK] P2 — пункт 7 добавлен в Инварианты" -ForegroundColor Green

# --- P3a: PLAYBOOK_VERSION 1.0 -> 1.1 + маркер применения ---
$p3aOld = '<!-- PLAYBOOK_VERSION: 1.0 -->'
$p3aNew = '<!-- PLAYBOOK_VERSION: 1.1 -->' + "`n" + '<!-- PLAYBOOK_v1.1_APPLIED -->'
if ($c.IndexOf($p3aOld) -lt 0) { throw "[P3a] ANCHOR NOT FOUND: $p3aOld" }
$c = $c.Replace($p3aOld, $p3aNew)
Write-Host "[OK] P3a — VERSION 1.0 -> 1.1 + маркер применения" -ForegroundColor Green

# --- P3b: PLAYBOOK_LAST_UPDATED ---
$p3bOld = '<!-- PLAYBOOK_LAST_UPDATED: 2026-08-05, Session 55 -->'
$p3bNew = '<!-- PLAYBOOK_LAST_UPDATED: 2026-08-06, Session 57 -->'
if ($c.IndexOf($p3bOld) -lt 0) { throw "[P3b] ANCHOR NOT FOUND: $p3bOld" }
$c = $c.Replace($p3bOld, $p3bNew)
Write-Host "[OK] P3b — LAST_UPDATED -> Session 57" -ForegroundColor Green

# --- P3c: BASED_ON_SESSIONS ---
$p3cOld = '<!-- BASED_ON_SESSIONS: 53, 54, 55 -->'
$p3cNew = '<!-- BASED_ON_SESSIONS: 53, 54, 55, 57 -->'
if ($c.IndexOf($p3cOld) -lt 0) { throw "[P3c] ANCHOR NOT FOUND: $p3cOld" }
$c = $c.Replace($p3cOld, $p3cNew)
Write-Host "[OK] P3c — BASED_ON_SESSIONS += 57" -ForegroundColor Green

Write-Host ""

# =============================================================================
# ВАЛИДАЦИИ
# =============================================================================
Write-Host "=== ВАЛИДАЦИИ ===" -ForegroundColor Cyan

$checks = @(
    @{ Name = 'L-057-01 присутствует в тексте';           Test = { $c -match 'L-057-01' } },
    @{ Name = 'Блок Ловушка PowerShell присутствует';     Test = { $c -match 'Ловушка PowerShell' } },
    @{ Name = 'Упоминание single quotes присутствует';    Test = { $c -match 'single quotes' } },
    @{ Name = 'Пункт 7 в Инвариантах присутствует';       Test = { $c -match '7\.\s+Якорные строки' } },
    @{ Name = 'PLAYBOOK_VERSION 1.1 присутствует';        Test = { $c -match '<!--\s*PLAYBOOK_VERSION:\s*1\.1\s*-->' } },
    @{ Name = 'PLAYBOOK_VERSION 1.0 удалён';              Test = { -not ($c -match '<!--\s*PLAYBOOK_VERSION:\s*1\.0\s*-->') } },
    @{ Name = 'Маркер PLAYBOOK_v1.1_APPLIED вставлен';    Test = { $c -match '<!--\s*PLAYBOOK_v1\.1_APPLIED\s*-->' } },
    @{ Name = 'Session 57 в LAST_UPDATED';                Test = { $c -match 'PLAYBOOK_LAST_UPDATED:.*Session 57' } },
    @{ Name = 'Session 55 удалён из LAST_UPDATED';        Test = { -not ($c -match 'PLAYBOOK_LAST_UPDATED:.*Session 55') } },
    @{ Name = 'BASED_ON_SESSIONS содержит 57';            Test = { $c -match 'BASED_ON_SESSIONS: 53, 54, 55, 57' } },
    @{ Name = 'Шаг 5 остался на месте';                   Test = { $c -match '## Шаг 5 — Прогон и валидация' } },
    @{ Name = 'Шаг 4 остался на месте';                   Test = { $c -match '## Шаг 4 — Скрипт normalize' } },
    @{ Name = 'Инварианты остались на месте';             Test = { $c -match '## Инварианты \(нарушать нельзя\)' } },
    @{ Name = 'Пункт 6 в Инвариантах не сломан';          Test = { $c -match '6\.\s+Guard идемпотентности' } },
    @{ Name = 'Размер вырос (>= +500 chars)';             Test = { ($c.Length - $sizeBefore) -ge 500 } }
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
    Write-Host "[ABORT] $failed валидаций провалено — файл НЕ записан. Backup: $backup" -ForegroundColor Red
    exit 1
}

Write-Host ""

# =============================================================================
# ЗАПИСЬ (UTF-8 BOM)
# =============================================================================
$enc = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path $file), $c, $enc)

$sizeAfter = $c.Length
Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "  File:     $file"
Write-Host "  Backup:   $backup"
Write-Host "  Size:     $sizeBefore -> $sizeAfter (delta +$($sizeAfter - $sizeBefore))"
Write-Host "  Version:  1.0 -> 1.1"
Write-Host "  Session:  55 -> 57"
Write-Host "  Patches:  5 applied (P1, P2, P3a, P3b, P3c)"
Write-Host "  Checks:   $($checks.Count)/$($checks.Count) OK"
Write-Host ""
Write-Host "=== DONE ===" -ForegroundColor Green
