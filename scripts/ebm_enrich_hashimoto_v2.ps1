# ============================================================
# EBM-обогащение references/methodology/hashimoto.md
# Стандарт: project/EBM_STANDARD.md v1.0
# Идемпотентный маркер: <!-- EBM_ENRICHED_v1.2 -->
# Стратегия A: 10 inline-тегов, 24 → 34 EBM-тегов
# ============================================================

$ErrorActionPreference = "Stop"
$repoRoot = "C:\Users\ЗС\Agent-Nutri"
$path = Join-Path $repoRoot "references\methodology\hashimoto.md"
$oldMarker = "<!-- EBM_ENRICHED_v1.1 -->"
$newMarker = "<!-- EBM_ENRICHED_v1.2 -->"

Write-Host "=== ebm_enrich_hashimoto_v2.ps1 ===" -ForegroundColor Cyan

# 1. ПРОВЕРКИ
if (-not (Test-Path $path)) { throw "Файл не найден: $path" }
$content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
if ($content -match [regex]::Escape($newMarker)) {
    Write-Host "⚠ Маркер v1.2 уже есть — идемпотентный exit" -ForegroundColor Yellow
    exit 0
}
if (-not ($content -match [regex]::Escape($oldMarker))) {
    Write-Host "⚠ Маркер v1.1 не найден (ожидался)" -ForegroundColor Yellow
}

$origLen = $content.Length
$origTags = ([regex]::Matches($content, '\[EBM:')).Count
Write-Host "Исходно: $origLen символов, $origTags EBM-тегов"

# 2. BACKUP
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backup = "$path.bak.$stamp"
Copy-Item $path $backup -Force
Write-Host "Backup: $backup"

# 3. LF-нормализация
$content = $content -replace "`r`n", "`n"

# 4. ПАТЧИ (Old → New)
$patches = @(
    @{
        Name = "P1: §3.4 послеродовый период"
        Old  = "Послеродовый период (условно 3-12 месяцевпосле родов) представляет собой критическое диагностическое окно"
        New  = "Послеродовый период (условно 3-12 месяцев после родов) представляет собой критическое диагностическое окно [EBM: Stagnaro-Green 2011 ATA Postpartum Thyroiditis]"
    },
    @{
        Name = "P1b: §3.4 послеродовый (альтернативный якорь без опечатки)"
        Old  = "Послеродовый период (условно 3-12 месяцев после родов) представляет собой критическое диагностическое окно"
        New  = "Послеродовый период (условно 3-12 месяцев после родов) представляет собой критическое диагностическое окно [EBM: Stagnaro-Green 2011 ATA Postpartum Thyroiditis]"
    },
    @{
        Name = "P2: §3.5 стресс и HPA"
        Old  = "Хронический психологический и физиологический стресс модулирует функцию иммунной системы через ось гипоталамус-гипофиз-надпочечники (HPA)"
        New  = "Хронический психологический и физиологический стресс модулирует функцию иммунной системы через ось гипоталамус-гипофиз-надпочечники (HPA) [EBM: Mizokami 2004 Thyroid стресс-АИТ]"
    },
    @{
        Name = "P3: §3.6 Ch'ng 2007 целиакия-АИТ"
        Old  = "Ch'ng 2007** (систематический обзор литературы)"
        New  = "Ch'ng 2007** (систематический обзор литературы) [EBM: Ch'ng 2007 Clin Med Res целиакия-АИТ]"
    },
    @{
        Name = "P4: §3.7 IFN-индуцированный тиреоидит"
        Old  = "**Интерферон-индуцированный тиреоидит** — хорошодокументированное"
        New  = "**Интерферон-индуцированный тиреоидит** [EBM: Tomer 2013 J Autoimmun IFN-α thyroiditis] — хорошо документированное"
    },
    @{
        Name = "P4b: §3.7 IFN (альтернативный якорь без опечатки)"
        Old  = "**Интерферон-индуцированный тиреоидит** — хорошо документированное"
        New  = "**Интерферон-индуцированный тиреоидит** [EBM: Tomer 2013 J Autoimmun IFN-α thyroiditis] — хорошо документированное"
    },
    @{
        Name = "P5: §7.2 витамин D 5000-10000 МЕ"
        Old  = "**5000-10000 МЕ/сут напротяжении 2-3 месяцев**"
        New  = "**5000-10000 МЕ/сут на протяжении 2-3 месяцев** [EBM: Kim 2017 Nutr Res D3-АИТ мета-анализ]"
    },
    @{
        Name = "P5b: §7.2 витамин D (альтернативный якорь)"
        Old  = "**5000-10000 МЕ/сут на протяжении 2-3 месяцев**"
        New  = "**5000-10000 МЕ/сут на протяжении 2-3 месяцев** [EBM: Kim 2017 Nutr Res D3-АИТ мета-анализ]"
    },
    @{
        Name = "P6: §7.4 цинк 15-30 мг"
        Old  = "**Рекомендуемая доза: 15-30 мг/сут** элементарного цинка"
        New  = "**Рекомендуемая доза: 15-30 мг/сут** элементарного цинка [EBM: Mahmoodianfard 2015 J Am Coll Nutr Zn+Se АИТ]"
    },
    @{
        Name = "P7: §7.3 ферритин >70"
        Old  = "**Целевой показатель: уровень ферритина выше 70 нг/мл**"
        New  = "**Целевой показатель: уровень ферритина выше 70 нг/мл** [EBM: Rayman 2019 Proc Nutr Soc micronutrients thyroid]"
    },
    @{
        Name = "P8: §8.4 соя-изофлавоны"
        Old  = "снижать эффективность всасывания перорального левотироксина при одновременном приёме в один временной промежуток"
        New  = "снижать эффективность всасывания перорального левотироксина при одновременном приёме в один временной промежуток [EBM: Messina 2006 Thyroid soy isoflavones]"
    },
    @{
        Name = "P9: §9.1 L-T4 утром натощак"
        Old  = "Приём препарата должен строго осуществлятьсяутром натощак, за 30-60 минут до завтрака"
        New  = "Приём препарата должен строго осуществляться утром натощак, за 30-60 минут до завтрака [EBM: Skelin 2017 Clin Ther T4 absorption interactions]"
    },
    @{
        Name = "P9b: §9.1 L-T4 (альтернативный якорь)"
        Old  = "Приём препарата должен строго осуществляться утром натощак, за 30-60 минут до завтрака"
        New  = "Приём препарата должен строго осуществляться утром натощак, за 30-60 минут до завтрака [EBM: Skelin 2017 Clin Ther T4 absorption interactions]"
    },
    @{
        Name = "P10: §9.3 беременность ТТГ <2.5"
        Old  = "применительно к I триместру беременности"
        New  = "применительно к I триместру беременности [EBM: Alexander 2017 ATA Pregnancy Guidelines]"
    }
)

# 5. ПРИМЕНЕНИЕ ПАТЧЕЙ
$applied = 0
$skipped = 0
$notFound = @()
foreach ($p in $patches) {
    if ($content -match [regex]::Escape($p.New)) {
        Write-Host "  ⊙ SKIP $($p.Name) (уже применён)" -ForegroundColor DarkGray
        $skipped++
        continue
    }
    if ($content -match [regex]::Escape($p.Old)) {
        $content = $content -replace [regex]::Escape($p.Old), $p.New.Replace('$', '$$')
        Write-Host "  ✓ $($p.Name)" -ForegroundColor Green
        $applied++
    } else {
        Write-Host "  ✗ NOT FOUND $($p.Name)" -ForegroundColor Red
        $notFound += $p.Name
    }
}
Write-Host ""
Write-Host "Применено: $applied, пропущено: $skipped, не найдено: $($notFound.Count)"

# 6. МЕТАДАННЫЕ
$content = $content -replace "- \*\*Версия:\*\* 1\.1", "- **Версия:** 1.2 (EBM-lite v2 enrichment, Session 52)"
$content = $content -replace "- \*\*Последнее обновление:\*\* 2026-07-27 \(Session 44, EBM-lite обогащение\)", "- **Последнее обновление:** 2026-07-31 (Session 52, Этап F.2 — EBM-lite v2 обогащение)"

# 7. МАРКЕР
if ($content -match [regex]::Escape($oldMarker)) {
    $content = $content -replace [regex]::Escape($oldMarker), $newMarker
} else {
    $content = $content.TrimEnd() + "`n`n$newMarker`n"
}

# 8. CRLF + UTF-8 BOM запись
$content = $content -replace "`n", "`r`n"
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($path, $content, $utf8Bom)

# 9. ВАЛИДАЦИЯ
$finalBytes = [System.IO.File]::ReadAllBytes($path)
$finalContent = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
$finalLen = $finalContent.Length
$finalTags = ([regex]::Matches($finalContent, '\[EBM:')).Count
$hasBom = $finalBytes[0] -eq 0xEF -and $finalBytes[1] -eq 0xBB -and $finalBytes[2] -eq 0xBF
$hasMarker = $finalContent -match [regex]::Escape($newMarker)
$hasV12 = $finalContent -match "Версия:\*\* 1\.2"

Write-Host ""
Write-Host "=== ВАЛИДАЦИЯ ===" -ForegroundColor Cyan
Write-Host "Длина: $origLen → $finalLen (Δ $($finalLen - $origLen))"
Write-Host "EBM-тегов: $origTags → $finalTags (Δ $($finalTags - $origTags))"
Write-Host "UTF-8 BOM: $hasBom"
Write-Host "Маркер v1.2: $hasMarker"
Write-Host "Версия 1.2: $hasV12"
Write-Host "FULL_EBM порог ≥30: $($finalTags -ge 30)"

if ($notFound.Count -gt 0) {
    Write-Host ""
    Write-Host "Не найдены (проверьте вручную):" -ForegroundColor Yellow
    $notFound | ForEach-Object { Write-Host "  - $_" }
}

Write-Host ""
Write-Host "=== ГОТОВО ===" -ForegroundColor Green
Write-Host "Проверка: .\scripts\audit_ebm_compliance.ps1"
Write-Host "Diff:     git --no-pager diff --stat references/methodology/hashimoto.md"
Write-Host "Backup:   $backup"
