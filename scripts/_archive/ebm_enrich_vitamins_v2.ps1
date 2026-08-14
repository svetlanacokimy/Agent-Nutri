# =====================================================================
# scripts/ebm_enrich_vitamins_v2.ps1
# Session 53 — EBM enrichment vitamins.md: PARTIAL_EBM → FULL_EBM
# v1.1 → v1.2, +13 inline тегов (29 → 42)
# Правило Session 52: Old-паттерны скопированы дословно из вывода разведки
# =====================================================================

$ErrorActionPreference = "Stop"
$path = "references/methodology/vitamins.md"

Write-Host "=== 1. ПРЕДПРОВЕРКА ===" -ForegroundColor Cyan
if (-not (Test-Path $path)) { throw "Файл не найден: $path" }
$origBytes = [System.IO.File]::ReadAllBytes((Resolve-Path $path))
$origSize = $origBytes.Length
$origBom = ($origBytes[0] -eq 239) -and ($origBytes[1] -eq 187) -and ($origBytes[2] -eq 191)
Write-Host "Файл: $path, размер: $origSize байт, BOM: $origBom"

# BACKUP
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = "$path.bak.$stamp"
Copy-Item $path $backupPath
Write-Host "✓ Backup: $backupPath" -ForegroundColor Green

# Читаем как единый текст (сохраняя переводы строк)
$text = [System.IO.File]::ReadAllText((Resolve-Path $path), [System.Text.Encoding]::UTF8)
$origLen = $text.Length
$origTagCount = ([regex]::Matches($text, '\[EBM:')).Count
Write-Host "До: длина $origLen символов, тегов [EBM: $origTagCount"

# Проверка маркеров
if ($text -match '<!-- EBM_ENRICHED_v1\.2 -->') {
    Write-Host "⊙ Маркер v1.2 уже есть — файл обработан. Выход." -ForegroundColor Yellow
    exit 0
}
if (-not ($text -match '<!-- EBM_ENRICHED_v1\.1 -->')) {
    throw "Ожидался маркер v1.1 (Session 43), не найден"
}

Write-Host "`n=== 2. ПРИМЕНЕНИЕ 13 ПАТЧЕЙ ===" -ForegroundColor Cyan

$patches = @(
    @{ Id="P1"; Zone="Z2 §5.5 B12/Smith";
       Old='деменция у пожилых (Smith 2018).';
       New='деменция у пожилых (Smith 2018 [EBM: Smith 2018 Annu Rev Nutr B12 neurology]).' },
    @{ Id="P2"; Zone="Z4 §7.5 Hemilä";
       Old='**Cochrane 2013 (Hemilä):** рутинный приём 200 мг/сут';
       New='**Cochrane 2013 (Hemilä) [EBM: Hemilä 2013 Cochrane Vitamin C common cold]:** рутинный приём 200 мг/сут' },
    @{ Id="P3"; Zone="Z5 §8.7 ATBC";
       Old='**ATBC Study 1994** (Финляндия, 29 000 курильщиков';
       New='**ATBC Study 1994** [EBM: ATBC 1994 NEJM β-carotene lung cancer] (Финляндия, 29 000 курильщиков' },
    @{ Id="P4"; Zone="Z5 §8.7 CARET";
       Old='**CARET 1996** (США, 18 000 курильщиков и работников асбеста,';
       New='**CARET 1996** [EBM: Omenn 1996 NEJM CARET β-carotene] (США, 18 000 курильщиков и работников асбеста,' },
    @{ Id="P5"; Zone="Z6 §9.6 SELECT";
       Old='**SELECT 2011 (Klein):** 400 IU dl‑α‑TOC/сут у 35 000 мужчин';
       New='**SELECT 2011 (Klein) [EBM: Klein 2011 JAMA SELECT prostate cancer]:** 400 IU dl‑α‑TOC/сут у 35 000 мужчин' },
    @{ Id="P6"; Zone="Z6 §9.6 HOPE-TOO";
       Old='**HOPE‑TOO 2005:** 400 IU/сут × 7 лет';
       New='**HOPE‑TOO 2005** [EBM: Lonn 2005 JAMA HOPE-TOO vitamin E]**:** 400 IU/сут × 7 лет' },
    @{ Id="P7"; Zone="Z8 §13.5 AIM-HIGH";
       Old='**AIM‑HIGH 2011** (RCT, 3414 пациентов на статинах с низким HDL)';
       New='**AIM‑HIGH 2011** [EBM: AIM-HIGH 2011 NEJM niacin] (RCT, 3414 пациентов на статинах с низким HDL)' },
    @{ Id="P8"; Zone="Z8 §13.5 HPS2-THRIVE";
       Old='**HPS2‑THRIVE 2014** (RCT, 25 673 пациента)';
       New='**HPS2‑THRIVE 2014** [EBM: HPS2-THRIVE 2014 NEJM niacin-laropiprant] (RCT, 25 673 пациента)' },
    @{ Id="P9"; Zone="Z9 §15.5 Schaumburg";
       Old='**Schaumburg 1983** (описание серии случаев)';
       New='**Schaumburg 1983** [EBM: Schaumburg 1983 NEJM B6 sensory neuropathy] (описание серии случаев)' },
    @{ Id="P10"; Zone="Z10 §17.5 Caudill";
       Old='**Caudill 2018** (РКИ): беременные, получавшие';
       New='**Caudill 2018** [EBM: Caudill 2018 FASEB J choline fetal cognition] (РКИ): беременные, получавшие' },
    @{ Id="P11"; Zone="Z11 §17.8 Wang/Koeth TMAO";
       Old='**Wang 2011**, **Koeth 2013** — обсервационные данные';
       New='**Wang 2011** [EBM: Wang 2011 Nature TMAO CVD], **Koeth 2013** [EBM: Koeth 2013 Nat Med L-carnitine TMAO] — обсервационные данные' },
    @{ Id="P12"; Zone="Z12 §18.3 Unfer";
       Old='**Unfer 2017** (метаанализ РКИ): **мио-инозитол 2 г × 2 раза/сут**';
       New='**Unfer 2017** [EBM: Unfer 2017 Endocr Connect myo-inositol PCOS meta-analysis] (метаанализ РКИ): **мио-инозитол 2 г × 2 раза/сут**' },
    @{ Id="P13"; Zone="Z12 §18.4 D'Anna";
       Old="**D'Anna 2013** (РКИ): мио-инозитол **2 г × 2 раза/сут**";
       New="**D'Anna 2013** [EBM: D'Anna 2013 Diabetes Care myo-inositol GDM] (РКИ): мио-инозитол **2 г × 2 раза/сут**" }
)

$applied = 0
$notFound = @()
foreach ($p in $patches) {
    if ($text -match [regex]::Escape($p.New)) {
        Write-Host ("⊙ {0} ({1}): уже применён" -f $p.Id, $p.Zone) -ForegroundColor Yellow
        $applied++
        continue
    }
    if ($text.Contains($p.Old)) {
        $text = $text.Replace($p.Old, $p.New)
        Write-Host ("✓ {0} ({1}): применён" -f $p.Id, $p.Zone) -ForegroundColor Green
        $applied++
    } else {
        Write-Host ("✗ {0} ({1}): OLD НЕ НАЙДЕН" -f $p.Id, $p.Zone) -ForegroundColor Red
        $notFound += $p.Id
    }
}

Write-Host "`n=== 3. ОБНОВЛЕНИЕ МЕТАДАННЫХ ===" -ForegroundColor Cyan

# Обновить маркер идемпотентности
$text = $text -replace '<!-- EBM_ENRICHED_v1\.1 -->', '<!-- EBM_ENRICHED_v1.2 -->'
Write-Host "✓ Маркер v1.1 → v1.2" -ForegroundColor Green

# Обновить версию в метаданных
if ($text -match '- \*\*Версия:\*\* 1\.1') {
    $text = $text -replace '- \*\*Версия:\*\* 1\.1', '- **Версия:** 1.2'
    Write-Host "✓ Версия 1.1 → 1.2" -ForegroundColor Green
} else {
    Write-Host "✗ Строка версии не найдена" -ForegroundColor Red
}

# Обновить дату обновления
$oldUpdate = '- **Обновление:** 2026-07-27 (Session 43, EBM-lite обогащение)'
$newUpdate = '- **Обновление:** 2026-07-31 (Session 53, EBM enrichment PARTIAL → FULL_EBM)'
if ($text.Contains($oldUpdate)) {
    $text = $text.Replace($oldUpdate, $newUpdate)
    Write-Host "✓ Дата обновления → 2026-07-31 (Session 53)" -ForegroundColor Green
} else {
    Write-Host "✗ Строка обновления не найдена" -ForegroundColor Red
}

# Обновить статус
$text = $text -replace '- \*\*Статус:\*\* ✅ Готов \(EBM-lite\)', '- **Статус:** ✅ Готов (FULL_EBM)'

Write-Host "`n=== 4. ЗАПИСЬ ФАЙЛА (UTF-8 BOM) ===" -ForegroundColor Cyan
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path $path), $text, $utf8Bom)

$newBytes = [System.IO.File]::ReadAllBytes((Resolve-Path $path))
$newSize = $newBytes.Length
$newBom = ($newBytes[0] -eq 239) -and ($newBytes[1] -eq 187) -and ($newBytes[2] -eq 191)
$newTagCount = ([regex]::Matches($text, '\[EBM:')).Count

Write-Host "После: длина $($text.Length) символов, размер $newSize байт (Δ $($newSize - $origSize)), тегов [EBM: $newTagCount (Δ +$($newTagCount - $origTagCount))"

Write-Host "`n=== 5. ВАЛИДАЦИЯ (правило Session 52: КОНТЕНТНЫЕ маркеры) ===" -ForegroundColor Cyan
$checks = @(
    @{ Name="BOM present";              Ok=$newBom },
    @{ Name="Marker v1.2";              Ok=($text -match '<!-- EBM_ENRICHED_v1\.2 -->') },
    @{ Name="Version 1.2";              Ok=($text -match '- \*\*Версия:\*\* 1\.2') },
    @{ Name="Session 53 в метаданных";  Ok=($text -match 'Session 53') },
    @{ Name="Tags >= 30 (FULL_EBM)";    Ok=($newTagCount -ge 30) },
    @{ Name="Content: Hemila tag";      Ok=($text -match 'Hemilä 2013 Cochrane Vitamin C') },
    @{ Name="Content: ATBC tag";        Ok=($text -match 'ATBC 1994 NEJM β-carotene') },
    @{ Name="Content: SELECT tag";      Ok=($text -match 'Klein 2011 JAMA SELECT') },
    @{ Name="Content: AIM-HIGH tag";    Ok=($text -match 'AIM-HIGH 2011 NEJM niacin') },
    @{ Name="Content: Unfer tag";       Ok=($text -match 'Unfer 2017 Endocr Connect') }
)

$allOk = $true
foreach ($c in $checks) {
    if ($c.Ok) { Write-Host ("  ✓ {0}" -f $c.Name) -ForegroundColor Green }
    else { Write-Host ("  ✗ {0}" -f $c.Name) -ForegroundColor Red; $allOk = $false }
}

Write-Host "`n=== ИТОГ ===" -ForegroundColor Magenta
Write-Host "Применено патчей: $applied / $($patches.Count)"
if ($notFound.Count -gt 0) { Write-Host "НЕ НАЙДЕНЫ: $($notFound -join ', ')" -ForegroundColor Red }
Write-Host "Теги: $origTagCount → $newTagCount"
Write-Host "Размер: $origSize → $newSize байт"
if ($allOk -and $notFound.Count -eq 0) {
    Write-Host "✅ FULL_EBM достигнут, все валидации green" -ForegroundColor Green
} else {
    Write-Host "⚠️ Есть проблемы — проверьте вывод выше" -ForegroundColor Yellow
}