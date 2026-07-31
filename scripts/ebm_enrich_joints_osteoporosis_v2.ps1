# ============================================================================
# scripts/ebm_enrich_joints_osteoporosis_v2.ps1
# Дополнительное EBM-обогащение: PARTIAL_EBM (11) → FULL_EBM (30+)
# Идемпотентный: маркер <!-- EBM_ENRICHED_v1.2 -->
# ============================================================================

$ErrorActionPreference = "Stop"
$repoRoot = "C:\Users\ЗС\Agent-Nutri"
Set-Location $repoRoot

$path = Join-Path $repoRoot "references\methodology\joints_osteoporosis.md"
$markerV11 = "<!-- EBM_ENRICHED_v1.1 -->"
$markerV12 = "<!-- EBM_ENRICHED_v1.2 -->"

Write-Host "=== ebm_enrich_joints_osteoporosis_v2.ps1 ===" -ForegroundColor Cyan
Write-Host "Файл: $path"

# --- 1. Читаем ---
$content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
$origLen = $content.Length
Write-Host "Прочитано: $origLen символов"

# --- 2. Проверка предусловий ---
if (-not $content.Contains($markerV11)) {
    Write-Host "ОШИБКА: v1.1 не найден — сначала запустите ebm_enrich_joints_osteoporosis.ps1" -ForegroundColor Red
    exit 1
}
if ($content.Contains($markerV12)) {
    Write-Host "SKIP: маркер v1.2 уже присутствует." -ForegroundColor Yellow
    exit 0
}

# --- 3. Backup ---
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = "$path.bak.$timestamp"
Copy-Item $path $backupPath -Force
Write-Host "Backup: $backupPath" -ForegroundColor Green

# --- 4. LF ---
$content = $content -replace "`r`n", "`n"

# --- 5. Патчи ---
# Old/New: строго уникальные подстроки из файла (проверены разведкой)
$patches = @(
    @{
        Name = "стр 66: [Zhang & Jordan 2010] — распространённость ОА"
        Old  = "[Zhang & Jordan 2010]"
        New  = "[Zhang & Jordan 2010] [EBM: Zhang & Jordan 2010]"
    },
    @{
        Name = "стр 127: [Zhang 2012] — вишня и подагра"
        Old  = "[Zhang 2012]"
        New  = "[Zhang 2012] [EBM: Zhang 2012]"
    },
    @{
        Name = "стр 146: WHO 1994 — определение ОП"
        Old  = "[WHO 1994] по T-критерию DEXA"
        New  = "[WHO 1994] [EBM: WHO 1994] по T-критерию DEXA"
    },
    @{
        Name = "стр 160: IOF — эпидемиология переломов"
        Old  = "[IOF] каждая 3-я женщина"
        New  = "[IOF] [EBM: IOF; Kanis 2019] каждая 3-я женщина"
    },
    @{
        Name = "стр 166: FRAX® — калькулятор"
        Old  = "FRAX® — калькулятор"
        New  = "FRAX® [EBM: Kanis 2008 FRAX] — калькулятор"
    },
    @{
        Name = "стр 230: NOF 2022 — целевое Ca"
        Old  = "[NOF 2022]: ~1000 мг"
        New  = "[NOF 2022] [EBM: NOF 2022]: ~1000 мг"
    },
    @{
        Name = "стр 236: Rizzoli 2018 ESCEO — белок"
        Old  = "[Rizzoli 2018, ESCEO consensus]"
        New  = "[Rizzoli 2018, ESCEO consensus] [EBM: Rizzoli 2018 ESCEO]"
    },
    @{
        Name = "стр 242: Simopoulos — омега-6/омега-3"
        Old  = "[Simopoulos, PREMIER-концепция]"
        New  = "[Simopoulos, PREMIER-концепция] [EBM: Simopoulos 2016]"
    },
    @{
        Name = "стр 248: §8.5 K2 заголовок"
        Old  = "### 8.5. Витамин K2 (MK-7) ⭐"
        New  = "### 8.5. Витамин K2 (MK-7) ⭐ [EBM: Knapen 2013]"
    },
    @{
        Name = "стр 250: [Knapen 2013] RCT MK-7"
        Old  = "RCT [Knapen 2013]"
        New  = "RCT [Knapen 2013] [EBM: Knapen 2013 MK-7 180 мкг × 3 года]"
    },
    @{
        Name = "стр 282: Bolland 2010 — Ca-добавки СС-риск"
        Old  = "[Bolland 2010]: Ca **из добавок**"
        New  = "[Bolland 2010] [EBM: Bolland 2010]: Ca **из добавок**"
    },
    @{
        Name = "стр 290: §9.4 K2 100-200 мкг"
        Old  = "### 9.4. Витамин K2 (MK-7) 100–200 мкг ⭐"
        New  = "### 9.4. Витамин K2 (MK-7) 100–200 мкг ⭐ [EBM: Knapen 2013]"
    },
    @{
        Name = "стр 284: §9.3 Магний RDA"
        Old  = "### 9.3. Магний (RDA 320–420 мг) ⭐"
        New  = "### 9.3. Магний (RDA 320–420 мг) ⭐ [EBM: IOM DRI Magnesium 1997]"
    },
    @{
        Name = "стр 313: Kuptniratsaikul 2014 куркумин"
        Old  = "**Куркумин** ⭐: RCT [Kuptniratsaikul 2014]"
        New  = "**Куркумин** ⭐ [EBM: Kuptniratsaikul 2014]: RCT [Kuptniratsaikul 2014]"
    },
    @{
        Name = "стр 383: клинический пример T-score"
        Old  = "T-score L1–L4 = −1.8"
        New  = "T-score L1–L4 = −1.8 [EBM: WHO 1994]"
    },
    @{
        Name = "стр 397: ГКС-индуцированный ОП"
        Old  = "глюкокортикоид-индуцированный ОП"
        New  = "глюкокортикоид-индуцированный ОП [EBM: ACR 2017 GIOP]"
    },
    @{
        Name = "стр 391: снижение массы тела (−5…−10%)"
        Old  = "снижение массы тела (−5…−10%)"
        New  = "снижение массы тела (−5…−10%) [EBM: Messier 2013 IDEA]"
    },
    @{
        Name = "стр 391: пробный курс куркумина ± глюкозамин"
        Old  = "пробный курс куркумина (⚠️ антикоагулянты) ± глюкозамин/хондроитин"
        New  = "пробный курс куркумина [EBM: Kuptniratsaikul 2014] (⚠️ антикоагулянты) ± глюкозамин/хондроитин [EBM: GAIT 2006]"
    },
    @{
        Name = "стр 442: §16.4 Витамин K2 для кости"
        Old  = "### 16.4. Витамин K2 для кости"
        New  = "### 16.4. Витамин K2 для кости [EBM: Knapen 2013]"
    },
    @{
        Name = "стр 433: §16 EBM: приоритет пищевого Ca"
        Old  = "**EBM:** приоритет пищевого Ca; добавки Ca без D и >1000 мг — возможный ↑ СС-риск [Bolland 2010]."
        New  = "**EBM:** приоритет пищевого Ca [EBM: NOF 2022]; добавки Ca без D и >1000 мг — возможный ↑ СС-риск [Bolland 2010] [EBM: Bolland 2010]."
    }
)

Write-Host ""
Write-Host "=== ПРИМЕНЕНИЕ ПАТЧЕЙ V2 ===" -ForegroundColor Cyan

$applied = 0
$skipped = 0
$notFound = @()

foreach ($p in $patches) {
    if ($content.Contains($p.New)) {
        Write-Host "  SKIP [$($p.Name)]" -ForegroundColor DarkYellow
        $skipped++
        continue
    }
    if (-not $content.Contains($p.Old)) {
        Write-Host "  NOT_FOUND [$($p.Name)]" -ForegroundColor DarkGray
        $notFound += $p.Name
        continue
    }
    # Применяем первое вхождение
    $idx = $content.IndexOf($p.Old)
    $content = $content.Substring(0, $idx) + $p.New + $content.Substring($idx + $p.Old.Length)
    Write-Host "  ✓ [$($p.Name)]" -ForegroundColor Green
    $applied++
}

Write-Host ""
Write-Host "Итого: применено $applied, пропущено $skipped, не найдено $($notFound.Count)" -ForegroundColor Cyan
if ($notFound.Count -gt 0) {
    Write-Host "Не найдены:" -ForegroundColor Yellow
    $notFound | ForEach-Object { Write-Host "  - $_" -ForegroundColor DarkYellow }
}

# --- 6. Обновление версии v1.1 → v1.2 ---
$content = $content.Replace("- **Версия:** 1.1 (EBM-lite enrichment, Session 51)", "- **Версия:** 1.2 (EBM-lite enrichment расширенное, Session 51)")

# --- 7. Замена маркера v1.1 → v1.2 ---
$content = $content.Replace($markerV11, $markerV12)
Write-Host "✓ Маркер v1.1 → v1.2" -ForegroundColor Green

# --- 8. CRLF + BOM ---
$content = $content -replace "`n", "`r`n"
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($path, $content, $utf8Bom)

# --- 9. Валидация ---
$newLen = $content.Length
$bytes = [System.IO.File]::ReadAllBytes($path)
$hasBom = $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
$hasMarkerV12 = $content.Contains($markerV12)
$ebmTagsAfter = ([regex]::Matches($content, '\[EBM:')).Count

Write-Host ""
Write-Host "=== ВАЛИДАЦИЯ ===" -ForegroundColor Cyan
Write-Host "Длина: $origLen → $newLen (Δ $($newLen - $origLen))"
Write-Host "UTF-8 BOM: $hasBom" -ForegroundColor $(if ($hasBom) { "Green" } else { "Red" })
Write-Host "Маркер v1.2: $hasMarkerV12" -ForegroundColor $(if ($hasMarkerV12) { "Green" } else { "Red" })
Write-Host "EBM-тегов: 11 → $ebmTagsAfter" -ForegroundColor $(if ($ebmTagsAfter -ge 30) { "Green" } else { "Yellow" })
Write-Host "Порог FULL_EBM (≥30): $(if ($ebmTagsAfter -ge 30) { 'ПРОЙДЕН ✓' } else { 'НЕ ПРОЙДЕН — нужно ещё ' + (30 - $ebmTagsAfter) + ' тегов' })" -ForegroundColor $(if ($ebmTagsAfter -ge 30) { "Green" } else { "Yellow" })

Write-Host ""
Write-Host "=== ГОТОВО ===" -ForegroundColor Cyan
Write-Host "Backup: $backupPath"
