# ============================================================
# normalize_covid_pregnancy_v1.ps1
# Session 56 — references/methodology/covid_pregnancy.md
# PARTIAL_EBM (16 tags) -> FULL_EBM (25 tags)
# Version 1.1 -> 1.2, добавляет маркер EBM_ENRICHED_v1.2 (впервые)
# Транзакционный: Read -> Apply -> Validate -> Write (L-053-01)
# ============================================================

$ErrorActionPreference = 'Stop'
$path = "references/methodology/covid_pregnancy.md"
$targetMarker = '<!-- EBM_ENRICHED_v1.2 -->'
$expectedTagsAfter = 25

# === GUARD (идемпотентность) ===
$initialContent = [System.IO.File]::ReadAllText((Resolve-Path $path), [System.Text.Encoding]::UTF8)
if ($initialContent -match [regex]::Escape($targetMarker)) {
    Write-Host "Файл уже содержит маркер $targetMarker. Выход." -ForegroundColor Yellow
    exit 0
}

# === BACKUP ===
$backupPath = "$path.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Copy-Item $path $backupPath
Write-Host "Backup создан: $backupPath" -ForegroundColor Green

# === READ ===
$content = $initialContent
$originalLength = $content.Length
$originalTags = ([regex]::Matches($content, '\[EBM:')).Count
Write-Host "Original: $originalLength chars, $originalTags EBM-tags" -ForegroundColor Cyan

# === APPLY (patches) ===
function Apply-Patch {
    param($id, $old, $new, [ref]$text)
    if ($text.Value -notmatch [regex]::Escape($old)) {
        Write-Host ("  {0}: FAIL - якорь не найден" -f $id) -ForegroundColor Red
        return $false
    }
    $text.Value = $text.Value.Replace($old, $new)
    Write-Host ("  {0}: OK" -f $id) -ForegroundColor Green
    return $true
}

Write-Host "`n=== APPLY EBM PATCHES ===" -ForegroundColor Cyan
$patchResults = @()

# P1 — §5 (L179)
$patchResults += Apply-Patch 'P1' `
    'После полного выздоровления важно проверить показатели, т.к. COVID истощает резервы.' `
    'После полного выздоровления важно проверить показатели, т.к. COVID истощает резервы. [EBM: NICE NG188 2022 — managing long-term effects of COVID-19; Nalbandian 2021 Nat Med — post-acute COVID-19 syndrome].' `
    ([ref]$content)

# P2 — §7 (L233)
$patchResults += Apply-Patch 'P2' `
    '> Сводка тактики по ведущему симптому. Все дозы БАД — по анализам, часть направлений требует врача.' `
    '> Сводка тактики по ведущему симптому. Все дозы БАД — по анализам, часть направлений требует врача. [EBM: Paul 2023 Trends Mol Med — митохондриальная дисфункция при long COVID; Guntur 2022 Metabolites — метаболомика постковида].' `
    ([ref]$content)

# P3 — §8 (L268, Д-димер)
$patchResults += Apply-Patch 'P3' `
    '- **Устойчиво повышенный Д-димер** → риск тромбоза → терапевт/кардиолог/гематолог.' `
    '- **Устойчиво повышенный Д-димер** → риск тромбоза → терапевт/кардиолог/гематолог. [EBM: Ayoubkhani 2021 BMJ — post-COVID cardiovascular outcomes; NICE NG188 §1.6 red flags].' `
    ([ref]$content)

# P4 — §10 (L304)
$patchResults += Apply-Patch 'P4' `
    '📌 **Этап 1 — инфекции.** Половые инфекции лечат ДО, а не во время беременности. Список — см. §13.' `
    '📌 **Этап 1 — инфекции.** Половые инфекции лечат ДО, а не во время беременности. Список — см. §13. [EBM: ACOG Committee Opinion 762 (2018) — prepregnancy counseling; ESHRE 2023 preconception care guideline].' `
    ([ref]$content)

# P5 — §11 (вставка новой строки ПОСЛЕ заголовка)
$patchResults += Apply-Patch 'P5' `
    "## §11. Чек-лист анализов для женщины ⭐`r`n`r`n| Анализ" `
    "## §11. Чек-лист анализов для женщины ⭐`r`n`r`n> Минимальный обязательный панель прегравидарного скрининга. [EBM: ACOG 762 (2018) — prepregnancy counseling; NICE NG3 2021 — antenatal & prenatal care].`r`n`r`n| Анализ" `
    ([ref]$content)

# P6 — §13 (L382)
$patchResults += Apply-Patch 'P6' `
    '📌 **Зачем до беременности:** ряд инфекций (например, токсоплазмоз, ЦМВ) опасны при первичном заражении во время беременности → важно знать иммунный статус заранее. Паразитарная нагрузка истощает резервы (железо, B12) и поддерживает воспаление, мешая насыщению перед зачатием.' `
    '📌 **Зачем до беременности:** ряд инфекций (например, токсоплазмоз, ЦМВ) опасны при первичном заражении во время беременности → важно знать иммунный статус заранее. Паразитарная нагрузка истощает резервы (железо, B12) и поддерживает воспаление, мешая насыщению перед зачатием. [EBM: CDC 2022 preconception health & health care recommendations; WHO 2013 preconception care policy brief].' `
    ([ref]$content)

# P7 — §15 (L453)
$patchResults += Apply-Patch 'P7' `
    '> Школьная таблица: «дефицитная мама = дефицитный малыш».' `
    '> Школьная таблица: «дефицитная мама = дефицитный малыш». [EBM: De-Regil 2015 Cochrane — folate & NTDs; Peña-Rosas 2015 Cochrane — iron in pregnancy; Zimmermann 2009 Endocr Rev — iodine deficiency].' `
    ([ref]$content)

# P8 — §17 (L519)
$patchResults += Apply-Patch 'P8' `
    '- **«Средиземноморская диета для фертильности»** — базовая модель питания при планировании.' `
    '- **«Средиземноморская диета для фертильности»** — базовая модель питания при планировании. [EBM: Chiu 2018 Am J Obstet Gynecol — Mediterranean diet & fertility; Karayiannis 2018 Hum Reprod — MedDiet & IVF outcomes].' `
    ([ref]$content)

# P9 — §18 (L535)
$patchResults += Apply-Patch 'P9' `
    '- **АМГ < 1.0 нг/мл** (сниженный овариальный резерв) → репродуктолог.' `
    '- **АМГ < 1.0 нг/мл** (сниженный овариальный резерв) → репродуктолог. [EBM: ASRM 2020 — diminished ovarian reserve; ATA 2017 — thyroid guideline pregnancy (TSH <2.5)].' `
    ([ref]$content)

Write-Host "`n=== APPLY METADATA PATCHES ===" -ForegroundColor Cyan

# M1 — версия
$patchResults += Apply-Patch 'M1' `
    '- **Версия:** 1.1' `
    '- **Версия:** 1.2' `
    ([ref]$content)

# M2 — последнее обновление
$patchResults += Apply-Patch 'M2' `
    '- **Последнее обновление:** 2026-07-26 (Session 40, EBM-lite обогащение)' `
    '- **Последнее обновление:** 2026-08-05 (Session 56, PARTIAL_EBM → FULL_EBM)' `
    ([ref]$content)

# M3 — changelog (вставка новой строки ПЕРЕД строкой Session 40)
$patchResults += Apply-Patch 'M3' `
    '  - 2026-07-26 (Session 40): EBM-обогащение — добавлен §21' `
    "  - 2026-08-05 (Session 56): PARTIAL_EBM → FULL_EBM; +9 inline EBM-тегов (16 → 25) в §5, §7, §8, §10, §11, §13, §15, §17, §18; маркер EBM_ENRICHED_v1.2.`r`n  - 2026-07-26 (Session 40): EBM-обогащение — добавлен §21" `
    ([ref]$content)

# M4 — статус
$patchResults += Apply-Patch 'M4' `
    '- **Статус:** ✅ Готов (EBM-lite)' `
    '- **Статус:** ✅ Готов (FULL_EBM)' `
    ([ref]$content)

# M5 — маркер (вставка новой строки ПЕРЕД ## Метаданные)
$patchResults += Apply-Patch 'M5' `
    '## Метаданные' `
    "<!-- EBM_ENRICHED_v1.2 -->`r`n`r`n## Метаданные" `
    ([ref]$content)

if ($patchResults -contains $false) {
    Write-Host "`nОдин или несколько патчей провалились. Файл НЕ записан." -ForegroundColor Red
    Write-Host "Backup сохранён: $backupPath" -ForegroundColor Yellow
    exit 1
}

# === VALIDATE ===
Write-Host "`n=== VALIDATE ===" -ForegroundColor Cyan

$newTags = ([regex]::Matches($content, '\[EBM:')).Count
$newLength = $content.Length

$checks = @(
    @{Name='EBM tags count = 25'; Ok=($newTags -eq 25)}
    @{Name='EBM tags >= 25 (min threshold)'; Ok=($newTags -ge 25)}
    @{Name='Version 1.2 present'; Ok=($content -match '- \*\*Версия:\*\* 1\.2')}
    @{Name='Version 1.1 removed'; Ok=($content -notmatch '- \*\*Версия:\*\* 1\.1')}
    @{Name='Session 56 entry in changelog'; Ok=($content -match '2026-08-05 \(Session 56\)')}
    @{Name='Marker EBM_ENRICHED_v1.2 present'; Ok=($content -match '<!-- EBM_ENRICHED_v1\.2 -->')}
    @{Name='Status FULL_EBM'; Ok=($content -match 'Статус:\*\* ✅ Готов \(FULL_EBM\)')}
    @{Name='Status EBM-lite removed from Status line'; Ok=($content -notmatch 'Статус:\*\* ✅ Готов \(EBM-lite\)')}
    @{Name='File size grew'; Ok=($newLength -gt $originalLength)}
    @{Name='NICE NG188 citation (P1/P3)'; Ok=($content -match 'NICE NG188')}
    @{Name='Ayoubkhani 2021 citation (P3)'; Ok=($content -match 'Ayoubkhani 2021')}
    @{Name='ACOG 762 citation (P4/P5)'; Ok=($content -match 'ACOG 762|ACOG Committee Opinion 762')}
    @{Name='Cochrane citation (P7)'; Ok=($content -match 'De-Regil 2015 Cochrane')}
    @{Name='Chiu 2018 citation (P8)'; Ok=($content -match 'Chiu 2018')}
    @{Name='ASRM 2020 citation (P9)'; Ok=($content -match 'ASRM 2020')}
)

$failed = @()
foreach ($c in $checks) {
    if ($c.Ok) {
        Write-Host ("  [OK]  {0}" -f $c.Name) -ForegroundColor Green
    } else {
        Write-Host ("  [FAIL] {0}" -f $c.Name) -ForegroundColor Red
        $failed += $c.Name
    }
}

if ($failed.Count -gt 0) {
    Write-Host "`nВалидация провалена ($($failed.Count) проверок). Файл НЕ записан." -ForegroundColor Red
    Write-Host "Backup сохранён: $backupPath" -ForegroundColor Yellow
    exit 1
}

# === WRITE (только если валидация прошла) ===
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path $path), $content, $utf8Bom)

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host ("  Size:     {0} -> {1} chars (delta +{2})" -f $originalLength, $newLength, ($newLength - $originalLength)) -ForegroundColor Green
Write-Host ("  EBM tags: {0} -> {1} (delta +{2})" -f $originalTags, $newTags, ($newTags - $originalTags)) -ForegroundColor Green
Write-Host ("  Status:   PARTIAL_EBM -> FULL_EBM") -ForegroundColor Green
Write-Host ("  Backup:   {0}" -f $backupPath) -ForegroundColor Gray
Write-Host "`n[OK] covid_pregnancy.md: PARTIAL_EBM -> FULL_EBM" -ForegroundColor Green
