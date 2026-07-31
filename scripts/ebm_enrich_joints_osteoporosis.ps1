# ============================================================================
# scripts/ebm_enrich_joints_osteoporosis.ps1
# EBM-обогащение references/methodology/joints_osteoporosis.md
# Стандарт: project/EBM_STANDARD.md v1.0
# Идемпотентный: маркер <!-- EBM_ENRICHED_v1.1 -->
# Стратегия A: 14 inline-тегов + маркер + метаданные v1.0 → v1.1
# ============================================================================

$ErrorActionPreference = "Stop"
$repoRoot = "C:\Users\ЗС\Agent-Nutri"
Set-Location $repoRoot

$path = Join-Path $repoRoot "references\methodology\joints_osteoporosis.md"
$marker = "<!-- EBM_ENRICHED_v1.1 -->"
$bt = [char]96

Write-Host "=== ebm_enrich_joints_osteoporosis.ps1 ===" -ForegroundColor Cyan
Write-Host "Файл: $path"

if (-not (Test-Path $path)) {
    Write-Host "ОШИБКА: файл не найден" -ForegroundColor Red
    exit 1
}

# --- 1. Читаем ---
$content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
$origLen = $content.Length
Write-Host "Прочитано: $origLen символов"

# --- 2. Идемпотентность ---
if ($content.Contains($marker)) {
    Write-Host "SKIP: маркер $marker уже присутствует." -ForegroundColor Yellow
    exit 0
}

# --- 3. Backup ---
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = "$path.bak.$timestamp"
Copy-Item $path $backupPath -Force
Write-Host "Backup: $backupPath" -ForegroundColor Green

# --- 4. LF ---
$content = $content -replace "`r`n", "`n"

# --- 5. Патчи inline-тегов ---
# Строим массив: [OldText, NewText, PatchName]
$patches = @(
    @{
        Name = "§2 ОА — Kellgren-Lawrence"
        Old  = "Kellgren-Lawrence"
        New  = "Kellgren-Lawrence [EBM: Kellgren-Lawrence 1957]"
    },
    @{
        Name = "§2 ОА — Kellgren–Lawrence (en-dash)"
        Old  = "Kellgren–Lawrence"
        New  = "Kellgren-Lawrence [EBM: Kellgren-Lawrence 1957]"
    },
    @{
        Name = "§2 ОА — куркумин"
        Old  = "куркумин"
        New  = "куркумин [EBM: Kuptniratsaikul 2014 — куркумин ≈ ибупрофен при гонартрозе]"
    },
    @{
        Name = "§2 ОА — коллагеновые пептиды"
        Old  = "коллагеновые пептиды"
        New  = "коллагеновые пептиды [EBM: Zdzieblik 2017; Konig 2018]"
    },
    @{
        Name = "§2 ОА — глюкозамин"
        Old  = "глюкозамин"
        New  = "глюкозамин [EBM: GAIT 2006 — эффект в подгруппе middle-to-severe pain]"
    },
    @{
        Name = "§2 ОА — снижение массы тела"
        Old  = "снижение массы тела"
        New  = "снижение массы тела [EBM: Messier 2013 IDEA]"
    },
    @{
        Name = "§5 ОП — T-score ≤ -2.5 (ВОЗ)"
        Old  = "T-score ≤ -2.5"
        New  = "T-score ≤ -2.5 [EBM: WHO 1994]"
    },
    @{
        Name = "§7 диагностика — DEXA"
        Old  = "DEXA"
        New  = "DEXA [EBM: ISCD 2019]"
    },
    @{
        Name = "§7 диагностика — FRAX"
        Old  = "FRAX"
        New  = "FRAX [EBM: Kanis 2008 FRAX]"
    },
    @{
        Name = "§9 нутриенты — витамин D"
        Old  = "витамин D"
        New  = "витамин D [EBM: VITAL/Manson 2019; LeBoff 2022]"
    },
    @{
        Name = "§9 нутриенты — кальций"
        Old  = "кальций"
        New  = "кальций [EBM: Bolland 2010; NOF 2022 — приоритет пищевой источник]"
    },
    @{
        Name = "§9 нутриенты — витамин K2"
        Old  = "витамин K2"
        New  = "витамин K2 [EBM: Knapen 2013]"
    },
    @{
        Name = "§9 нутриенты — креатин"
        Old  = "креатин"
        New  = "креатин [EBM: Chilibeck 2017 — креатин + силовые тренировки ↑ прочность кости]"
    },
    @{
        Name = "§12 лекарства — бисфосфонаты"
        Old  = "бисфосфонаты"
        New  = "бисфосфонаты [EBM: NOF 2022; ACR 2017 GIOP]"
    }
)

Write-Host ""
Write-Host "=== ПРИМЕНЕНИЕ ПАТЧЕЙ ===" -ForegroundColor Cyan

$applied = 0
$skipped = 0
$failed = @()

foreach ($p in $patches) {
    # Проверка: тег уже есть в замене? Тогда проверяем, нет ли уже применённой замены в тексте
    if ($content.Contains($p.New)) {
        Write-Host "  SKIP [$($p.Name)]: уже обогащено" -ForegroundColor DarkYellow
        $skipped++
        continue
    }
    # Проверка: старый текст присутствует?
    if (-not $content.Contains($p.Old)) {
        Write-Host "  NOT_FOUND [$($p.Name)]: '$($p.Old)' не найден" -ForegroundColor DarkGray
        $failed += $p.Name
        continue
    }
    # Применяем первое вхождение (чтобы не тегать каждое упоминание термина)
    $idx = $content.IndexOf($p.Old)
    $content = $content.Substring(0, $idx) + $p.New + $content.Substring($idx + $p.Old.Length)
    Write-Host "  ✓ [$($p.Name)]" -ForegroundColor Green
    $applied++
}

Write-Host ""
Write-Host "Итого: применено $applied, пропущено $skipped, не найдено $($failed.Count)" -ForegroundColor Cyan
if ($failed.Count -gt 0) {
    Write-Host "Не найдены: $($failed -join '; ')" -ForegroundColor Yellow
}

# --- 6. Обновление метаданных v1.0 → v1.1 ---
$oldMeta1 = "- **Версия:** 1.0"
$newMeta1 = "- **Версия:** 1.1 (EBM-lite enrichment, Session 51)"
if ($content.Contains($oldMeta1)) {
    $content = $content.Replace($oldMeta1, $newMeta1)
    Write-Host "✓ Метаданные: версия 1.0 → 1.1" -ForegroundColor Green
} else {
    Write-Host "  SKIP: строка версии не найдена в ожидаемом формате" -ForegroundColor Yellow
}

$oldMeta2 = "- **Последнее обновление:** 2026-07-21 (Session 39, Этап C)"
$newMeta2 = "- **Последнее обновление:** 2026-07-31 (Session 51, Этап F.2 — EBM-lite обогащение)"
if ($content.Contains($oldMeta2)) {
    $content = $content.Replace($oldMeta2, $newMeta2)
    Write-Host "✓ Метаданные: дата обновления" -ForegroundColor Green
}

# --- 7. Idempotency marker в конец ---
$content = $content.TrimEnd() + "`n`n$marker`n"
Write-Host "✓ Маркер добавлен: $marker" -ForegroundColor Green

# --- 8. CRLF + BOM ---
$content = $content -replace "`n", "`r`n"
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($path, $content, $utf8Bom)

# --- 9. Валидация ---
$newLen = $content.Length
$newLines = ($content -split "`r`n").Count
$bytes = [System.IO.File]::ReadAllBytes($path)
$hasBom = $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
$hasMarker = $content.Contains($marker)
$ebmTagsAfter = ([regex]::Matches($content, '\[EBM:')).Count
$hasV11 = $content.Contains("Версия:** 1.1")

Write-Host ""
Write-Host "=== ВАЛИДАЦИЯ ===" -ForegroundColor Cyan
Write-Host "Длина: $origLen → $newLen (Δ $($newLen - $origLen))"
Write-Host "Строк: $newLines"
Write-Host "UTF-8 BOM: $hasBom" -ForegroundColor $(if ($hasBom) { "Green" } else { "Red" })
Write-Host "Idempotency marker: $hasMarker" -ForegroundColor $(if ($hasMarker) { "Green" } else { "Red" })
Write-Host "EBM-тегов было: 0 → стало: $ebmTagsAfter" -ForegroundColor $(if ($ebmTagsAfter -ge 12) { "Green" } else { "Yellow" })
Write-Host "Версия 1.1: $hasV11" -ForegroundColor $(if ($hasV11) { "Green" } else { "Red" })

Write-Host ""
Write-Host "=== ГОТОВО ===" -ForegroundColor Cyan
Write-Host "Backup: $backupPath"
Write-Host "Проверка: git --no-pager diff --stat references/methodology/joints_osteoporosis.md"
Write-Host ""
Write-Host "Следующий шаг: прогнать audit_ebm_compliance.ps1 для проверки FULL_EBM"
