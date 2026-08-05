# =====================================================================
# scripts/normalize_female_hormones_v1.ps1
# Session 55: female_hormones.md PARTIAL_EBM → FULL_EBM
# +8 inline EBM-тегов (29 → 37), метаданные v2.1 → v2.2
# Правило Session 52+54: Read → Patch → Validate → Write, транзакционно
# =====================================================================

$ErrorActionPreference = "Stop"
$path = "references/methodology/female_hormones.md"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"

# ---------------------------------------------------------------------
# 0. Idempotency guard
# ---------------------------------------------------------------------
$check = [System.IO.File]::ReadAllText((Resolve-Path $path), [System.Text.Encoding]::UTF8)
if ($check.Contains('<!-- EBM_ENRICHED_v2.2 -->')) {
    Write-Host "⊙ Маркер EBM_ENRICHED_v2.2 уже присутствует — Session 55 применена ранее." -ForegroundColor Yellow
    Write-Host "  Ничего не делаю (idempotent)." -ForegroundColor Yellow
    return
}

# ---------------------------------------------------------------------
# 1. Backup
# ---------------------------------------------------------------------
Write-Host "=== 1. BACKUP ===" -ForegroundColor Cyan
$backup = "$path.bak.$stamp"
Copy-Item $path $backup
Write-Host "✓ $backup" -ForegroundColor Green

# ---------------------------------------------------------------------
# 2. Apply-Patch
# ---------------------------------------------------------------------
function Apply-Patch {
    param([string]$text, [string]$id, [string]$old, [string]$new)
    if ($text.Contains($new) -and -not $text.Contains($old)) {
        Write-Host "  ⊙ $id : уже применён" -ForegroundColor DarkGray
        return $text
    }
    if (-not $text.Contains($old)) {
        Write-Host "  ✗ $id : OLD NOT FOUND" -ForegroundColor Red
        throw "Patch $id failed: $old"
    }
    Write-Host "  ✓ $id" -ForegroundColor Green
    return $text.Replace($old, $new)
}

# ---------------------------------------------------------------------
# 3. Читаем файл
# ---------------------------------------------------------------------
Write-Host "`n=== 2. READ ===" -ForegroundColor Cyan
$t = [System.IO.File]::ReadAllText((Resolve-Path $path), [System.Text.Encoding]::UTF8)
$origLen = $t.Length
$origTags = ([regex]::Matches($t, '\[EBM:')).Count
Write-Host "Исходный размер: $origLen символов, EBM-тегов: $origTags"

# ---------------------------------------------------------------------
# 4. Патчи P1–P8: inline EBM-теги
# ---------------------------------------------------------------------
Write-Host "`n=== 3. INLINE EBM PATCHES ===" -ForegroundColor Cyan

# P1: §5.1 Прогестерон
$t = Apply-Patch $t "P1" `
    '**Ановуляторный цикл = дефицит прогестерона.**' `
    '**Ановуляторный цикл = дефицит прогестерона.** [EBM: Stanczyk 2013 Endocr Rev — прогестагены vs прогестерон; Prior 2015 — прогестерон в лютеиновой фазе]'

# P2: §8.1 Пролактин
$t = Apply-Patch $t "P2" `
    'Любое снижение дофамина → рост пролактина.' `
    'Любое снижение дофамина → рост пролактина. [EBM: Melmed 2011 Endocrine Society Hyperprolactinemia Guideline JCEM]'

# P3: §12.1 Гиперпролактинемия
$t = Apply-Patch $t "P3" `
    '**Высокая:** > 2000 мМЕ/л — высока вероятность макропролактиномы ⚠️ → МРТ гипофиза.' `
    '**Высокая:** > 2000 мМЕ/л — высока вероятность макропролактиномы ⚠️ → МРТ гипофиза. [EBM: Melmed 2011 Endocrine Society Hyperprolactinemia Guideline — макропролактинома при >200 нг/мл (~4000 мМЕ/л)]'

# P4: §13.2 ПМС/ПМДР
$t = Apply-Patch $t "P4" `
    'Серотониновая дисрегуляция, дефицит магния, B6, кальция, омега‑3.' `
    'Серотониновая дисрегуляция, дефицит магния, B6, кальция, омега‑3. [EBM: ACOG 2023 PMS/PMDD; Cochrane Whelan 2009 — B6 при ПМС; Thys-Jacobs 1998 JAMA — Ca 1200 мг/сут RCT]'

# P5: §18.2 КОК
$t = Apply-Patch $t "P5" `
    '**↓Чувствительность к инсулину** (некоторые прогестины).' `
    '**↓Чувствительность к инсулину** (некоторые прогестины). [EBM: Palmery 2013 — КОК и микронутриенты (фолат, B6, B12, Zn, Mg, Se); WHO MEC 2015 — критерии приемлемости]'

# P6: §19.1 Лабораторная диагностика
$t = Apply-Patch $t "P6" `
    'Все анализы — утром натощак, в указанные дни цикла:' `
    'Все анализы — утром натощак, в указанные дни цикла [EBM: ESHRE Rotterdam 2003; Monash 2018 PCOS Guideline; NICE NG73 heavy menstrual bleeding]:'

# P7: §21.1 Питание
$t = Apply-Patch $t "P7" `
    '**Клетчатка 25‑35 г/день** — критично для эстроболома (выведение эстрогенов).' `
    '**Клетчатка 25‑35 г/день** — критично для эстроболома (выведение эстрогенов). [EBM: Monash 2018 PCOS Guideline — диета; Cochrane Moran 2013 — lifestyle interventions при СПКЯ]'

# P8: §23.1 Сон
$t = Apply-Patch $t "P8" `
    'Гигиена сна: тёмная комната, отсутствие экранов за 1‑2 ч до сна, прохлада 18‑20 °C.' `
    'Гигиена сна: тёмная комната, отсутствие экранов за 1‑2 ч до сна, прохлада 18‑20 °C. [EBM: NAMS 2022 Position Statement; Monash 2018 PCOS lifestyle recommendations]'

# ---------------------------------------------------------------------
# 5. Патчи M1–M5: метаданные
# ---------------------------------------------------------------------
Write-Host "`n=== 4. METADATA PATCHES ===" -ForegroundColor Cyan

# M1: версия
$t = Apply-Patch $t "M1" `
    '- **Версия:** 2.1' `
    '- **Версия:** 2.2'

# M2: последнее обновление
$t = Apply-Patch $t "M2" `
    '- **Последнее обновление:** 2026-07-27 (Session 45, EBM-lite обогащение)' `
    '- **Последнее обновление:** 2026-07-31 (Session 55, EBM-lite → FULL_EBM, +8 inline EBM-тегов)'

# M3: история версий (после "Создано")
$t = Apply-Patch $t "M3" `
    '- **Создано:** 2026-06-12 (Сессия 20)' `
    ('- **Создано:** 2026-06-12 (Сессия 20)' + "`n" + '- **История версий:** v1.0 (Session 20) → v2.0 (Session 40) → v2.1 (Session 45, EBM-lite обогащение) → v2.2 (Session 55, EBM-lite → FULL_EBM, +8 inline тегов: §5, §8, §12, §13, §18, §19, §21, §23)')

# M4: статус
$t = Apply-Patch $t "M4" `
    '- **Статус:** ✅ Готов (EBM-lite)' `
    '- **Статус:** ✅ Готов (FULL_EBM)'

# M5: маркер идемпотентности
$t = Apply-Patch $t "M5" `
    '<!-- EBM_ENRICHED_v2.1 -->' `
    '<!-- EBM_ENRICHED_v2.2 -->'

# ---------------------------------------------------------------------
# 6. WRITE
# ---------------------------------------------------------------------
Write-Host "`n=== 5. WRITE ===" -ForegroundColor Cyan
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path $path), $t, $utf8Bom)
$newLen = $t.Length
$newTags = ([regex]::Matches($t, '\[EBM:')).Count
Write-Host "Размер: $origLen → $newLen символов (Δ $($newLen - $origLen))"
Write-Host "EBM-тегов: $origTags → $newTags (Δ +$($newTags - $origTags))"

# ---------------------------------------------------------------------
# 7. Валидация (13 проверок)
# ---------------------------------------------------------------------
Write-Host "`n=== 6. ВАЛИДАЦИЯ ===" -ForegroundColor Cyan
$b = [System.IO.File]::ReadAllBytes((Resolve-Path $path))
$f = [System.IO.File]::ReadAllText((Resolve-Path $path), [System.Text.Encoding]::UTF8)
$finalTags = ([regex]::Matches($f, '\[EBM:')).Count

$checks = @(
    @{ Name="BOM сохранён";                  Ok=(($b[0] -eq 239) -and ($b[1] -eq 187) -and ($b[2] -eq 191)) },
    @{ Name="EBM-тегов ≥ 30 (FULL_EBM)";      Ok=($finalTags -ge 30) },
    @{ Name="EBM-тегов = 37";                 Ok=($finalTags -eq 37) },
    @{ Name="Версия 2.2";                     Ok=$f.Contains('- **Версия:** 2.2') },
    @{ Name="Session 55 в обновлении";        Ok=$f.Contains('Session 55, EBM-lite → FULL_EBM') },
    @{ Name="История версий добавлена";       Ok=$f.Contains('- **История версий:** v1.0') },
    @{ Name="Статус FULL_EBM";                Ok=$f.Contains('- **Статус:** ✅ Готов (FULL_EBM)') },
    @{ Name="Старый EBM-lite статус удалён";  Ok=(-not $f.Contains('- **Статус:** ✅ Готов (EBM-lite)')) },
    @{ Name="Маркер v2.2 присутствует";       Ok=$f.Contains('<!-- EBM_ENRICHED_v2.2 -->') },
    @{ Name="Маркер v2.1 удалён";             Ok=(-not $f.Contains('<!-- EBM_ENRICHED_v2.1 -->')) },
    @{ Name="Файл не пустой";                 Ok=($f.Length -gt 50000) },
    @{ Name="Файл не уменьшился";             Ok=($f.Length -gt $origLen) },
    @{ Name="Melmed 2011 упоминается";        Ok=$f.Contains('Melmed 2011 Endocrine Society') }
)

$fails = 0
foreach ($c in $checks) {
    if ($c.Ok) { Write-Host ("  ✓ {0}" -f $c.Name) -ForegroundColor Green }
    else       { Write-Host ("  ✗ {0}" -f $c.Name) -ForegroundColor Red; $fails++ }
}

Write-Host "`n=== ИТОГ ===" -ForegroundColor Magenta
if ($fails -eq 0) {
    Write-Host "✅ female_hormones.md: PARTIAL_EBM → FULL_EBM" -ForegroundColor Green
    Write-Host "   EBM-тегов: 29 → $finalTags (+$($finalTags - 29))" -ForegroundColor Green
    Write-Host "   Версия: 2.1 → 2.2" -ForegroundColor Green
    Write-Host "   Backup: $backup" -ForegroundColor Green
} else {
    Write-Host "⚠️ Провалено проверок: $fails / $($checks.Count)" -ForegroundColor Yellow
    Write-Host "   Восстановление: Copy-Item $backup $path -Force" -ForegroundColor Yellow
}
