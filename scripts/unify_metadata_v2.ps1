# scripts\unify_metadata_v2.ps1
# Унификация метаданных для остальных 9 файлов (Кластер 1, 2, 4)

$ErrorActionPreference = "Stop"
$methDir = "references\methodology"

$plan = @(
    # Кластер 1 (Основы пищеварения)
    @{ File="digestion_basics.md";    Cluster=1; Ver="2.0"; Created="2026-05-29"; SessC=11; Updated="2026-06-19"; SessU=28; Status="BAS"; School="УРОК 1 (Пищеварение. Дневник питания), Этап 1"; Related=@("nutrition_basics.md","nutrition_principles.md","stomach_health.md","intestinal_health.md","liver_health.md"); StripOldMeta="## 5. Метаданные"; StripHeaderLines=@("> **Версия:** 1.0","> **Дата:** 2026-05-30","> **Статус:** активный") }

    # Кластер 2 (Макронутриенты, КБЖУ, принципы)
    @{ File="nutrition_basics.md";    Cluster=2; Ver="2.0"; Created="2026-05-26"; SessC=9;  Updated="2026-06-19"; SessU=28; Status="OK";  School="УРОКИ 3, 5, 6 (КБЖУ, ужины, перекусы), Этап 1"; Related=@("nutrition_principles.md","digestion_basics.md","insulin_resistance.md","intestinal_health.md"); StripOldMeta="## 13. Метаданные"; StripHeaderLines=@("> **Версия:** 1.0","> **Дата:** 2026-05-26","> **Статус:** активный") }
    @{ File="nutrition_principles.md";Cluster=2; Ver="2.0"; Created="2026-05-26"; SessC=10; Updated="2026-06-19"; SessU=28; Status="OK";  School="УРОК 2 (КЩБ. Стоп-продукты. Глютен. Молочка), Этап 1"; Related=@("nutrition_basics.md","gluten_celiac.md","liver_health.md","gallbladder_health.md","intestinal_health.md"); StripOldMeta="## 11. Метаданные"; StripHeaderLines=@("> **Версия:** 1.0","> **Дата:** 2026-05-26","> **Статус:** активный") }

    # Кластер 4 (Эндокринология/метаболизм) - шапку не трогаем, только добавляем блок в конец
    @{ File="insulin_resistance.md";  Cluster=4; Ver="2.0"; Created="2026-06-12"; SessC=19; Updated="2026-06-19"; SessU=28; Status="OK";  School="УРОК 11 (ИР. Диабет), Этап 2 + ADA/IDF/EASD"; Related=@("liver_health.md","pancreas_health.md","sibo_sifo.md","intestinal_health.md","nutrition_basics.md","thyroid_health.md","stress_adrenals.md"); StripOldMeta=""; StripHeaderLines=@() }
    @{ File="female_hormones.md";     Cluster=4; Ver="2.0"; Created="2026-06-12"; SessC=20; Updated="2026-06-19"; SessU=28; Status="OK";  School="УРОКИ 21, 8 (Женские гормоны. ПМС), Этап 2 + ESHRE/Endocrine Society/NICE"; Related=@("menopause.md","mastopathy.md","thyroid_health.md","stress_adrenals.md","insulin_resistance.md","liver_health.md"); StripOldMeta=""; StripHeaderLines=@() }
    @{ File="thyroid_health.md";      Cluster=4; Ver="2.0"; Created="2026-06-17"; SessC=21; Updated="2026-06-19"; SessU=28; Status="OK";  School="УРОКИ 17, 12, 19, 22 (ЩЖ. Селен. Йод. Аутоиммунные), Этап 2 + ATA/ETA/NICE"; Related=@("insulin_resistance.md","female_hormones.md","mastopathy.md","stress_adrenals.md","intestinal_health.md"); StripOldMeta=""; StripHeaderLines=@() }
    @{ File="mastopathy.md";          Cluster=4; Ver="2.0"; Created="2026-06-17"; SessC=22; Updated="2026-06-19"; SessU=28; Status="OK";  School="УРОКИ 21, 17, 12, 22 (Мастопатия. Йод. Селен), Этап 2"; Related=@("female_hormones.md","menopause.md","thyroid_health.md","liver_health.md","insulin_resistance.md"); StripOldMeta=""; StripHeaderLines=@() }
    @{ File="menopause.md";           Cluster=4; Ver="2.0"; Created="2026-06-18"; SessC=23; Updated="2026-06-19"; SessU=28; Status="OK";  School="УРОК 21 (Менопауза), Этап 2 + NAMS 2022/WHI/ELITE/KEEPS"; Related=@("female_hormones.md","mastopathy.md","thyroid_health.md","stress_adrenals.md","insulin_resistance.md"); StripOldMeta=""; StripHeaderLines=@() }
    @{ File="stress_adrenals.md";     Cluster=4; Ver="2.0"; Created="2026-06-18"; SessC=23; Updated="2026-06-19"; SessU=28; Status="OK";  School="УРОК 22 (Стресс. Надпочечники), Этап 2 + Endocrine Society"; Related=@("thyroid_health.md","insulin_resistance.md","female_hormones.md","menopause.md","intestinal_health.md"); StripOldMeta=""; StripHeaderLines=@() }
)

$clusterNames = @{
    1 = "1 (Основы пищеварения)"
    2 = "2 (Питание: КБЖУ, принципы)"
    4 = "4 (Эндокринология/метаболизм)"
}

Write-Host "=== UNIFY METADATA v2: clusters 1, 2, 4 ===" -ForegroundColor Cyan
Write-Host ""

foreach ($item in $plan) {
    $path = Join-Path $methDir $item.File
    if (-not (Test-Path $path)) {
        Write-Host "  MISS: $($item.File) (file not found)" -ForegroundColor Red
        continue
    }

    # Backup
    Copy-Item $path "$path.backup_uniA" -Force

    $raw = Get-Content $path -Encoding UTF8 -Raw

    # 1. Удалить технические строки из шапки (точечная замена по точной строке)
    foreach ($line in $item.StripHeaderLines) {
        $raw = $raw.Replace("$line`r`n", "")
        $raw = $raw.Replace("$line`n", "")
    }

    # 2. Удалить старый блок ## N. Метаданные если указан
    if ($item.StripOldMeta -ne "") {
        $marker = $item.StripOldMeta
        $idx = $raw.IndexOf($marker)
        if ($idx -ge 0) {
            # Также удаляем "---" перед ним если есть
            $beforeMarker = $raw.Substring(0, $idx).TrimEnd()
            if ($beforeMarker.EndsWith("---")) {
                $beforeMarker = $beforeMarker.Substring(0, $beforeMarker.Length - 3).TrimEnd()
            }
            $raw = $beforeMarker
        }
    }

    $raw = $raw.TrimEnd()

    # 3. Метрики
    $linesArr = $raw -split "`n"
    $h2Count = ($linesArr | Where-Object { $_ -match '^##\s' }).Count
    $h3Count = ($linesArr | Where-Object { $_ -match '^###\s' }).Count
    $starCount = ([regex]::Matches($raw, "⭐")).Count
    $diamCount = ([regex]::Matches($raw, "◆")).Count
    $warnCount = ([regex]::Matches($raw, "⚠")).Count

    # 4. Статус
    $statusIcon = switch ($item.Status) {
        "OK"  { "✅ Готов" }
        "WIP" { "◐ В работе" }
        "BAS" { "🔄 Базовый — требует расширения" }
        default { "—" }
    }

    # 5. Связанные протоколы
    $relatedStr = ($item.Related | ForEach-Object { "``$_``" }) -join ", "

    # 6. Сборка блока
    $meta = @()
    $meta += ""
    $meta += "---"
    $meta += ""
    $meta += "## Метаданные"
    $meta += ""
    $meta += "- **Автор:** Agent-Nutri team"
    $meta += "- **Версия:** $($item.Ver)"
    $meta += "- **Кластер:** $($clusterNames[$item.Cluster])"
    $meta += "- **Создано:** $($item.Created) (Сессия $($item.SessC))"
    $meta += "- **Последнее обновление:** $($item.Updated) (Сессия $($item.SessU))"
    $meta += "- **Источник школы:** $($item.School)"
    $meta += "- **Связанные протоколы:** $relatedStr"
    $totalLines = ($linesArr.Count) + $meta.Count
    $meta += "- **Метрики:** $totalLines строк, $h2Count H2, $h3Count H3, ⭐$starCount / ◆$diamCount / ⚠️$warnCount"
    $meta += "- **Статус:** $statusIcon"
    $meta += ""
    $metaBlock = ($meta -join "`n")

    # 7. Финал
    $final = $raw + "`n" + $metaBlock

    Set-Content -Path $path -Value $final -Encoding UTF8 -NoNewline
    Write-Host ("  DONE: {0,-30} -> Cluster {1}, {2} H2, {3} H3, star={4} diam={5} warn={6}" -f $item.File, $item.Cluster, $h2Count, $h3Count, $starCount, $diamCount, $warnCount) -ForegroundColor Green
}

Write-Host ""
Write-Host "=== DONE ===" -ForegroundColor Cyan
Write-Host "Backups: *.backup_uniA"
Write-Host "Next: run scripts\audit_links.ps1 and visual verification"
