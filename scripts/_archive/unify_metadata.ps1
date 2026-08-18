# scripts\unify_metadata.ps1
# Унификация шапок и блоков метаданных в файлах кластера 5 (ЖКТ)

$ErrorActionPreference = "Stop"
$methDir = "references\methodology"

# Карта данных по файлам
$plan = @(
    @{ File="liver_health.md";       Ver="2.0"; Created="2026-05-29"; SessC=12; Updated="2026-06-19"; SessU=28; Status="OK";  School="УРОК 4 (Печень) + УРОК 6 (Синдром Жильбера), Этап 2" }
    @{ File="intestinal_health.md";  Ver="2.0"; Created="2026-05-29"; SessC=12; Updated="2026-06-19"; SessU=28; Status="OK";  School="УРОК 4 (Кишечник), Этап 2 + расширения Session 28" }
    @{ File="gallbladder_health.md"; Ver="2.0"; Created="2026-06-04"; SessC=13; Updated="2026-06-19"; SessU=28; Status="OK";  School="УРОК 5 (Желчный пузырь), Этап 2" }
    @{ File="pancreas_health.md";    Ver="2.0"; Created="2026-06-04"; SessC=13; Updated="2026-06-19"; SessU=28; Status="OK";  School="УРОК 7 (Поджелудочная. Ферменты. Панкреатит. Глютен. Целиакия), Этап 2" }
    @{ File="gluten_celiac.md";      Ver="2.0"; Created="2026-06-05"; SessC=14; Updated="2026-06-19"; SessU=28; Status="BAS"; School="УРОК 2 (Этап 1) + УРОК 7 (Этап 2), раздел Глютен" }
    @{ File="colon_coprogram.md";    Ver="2.0"; Created="2026-06-09"; SessC=17; Updated="2026-06-19"; SessU=28; Status="OK";  School="УРОК 9 (Толстый кишечник. Копрограмма), Этап 2" }
    @{ File="sibo_sifo.md";          Ver="2.0"; Created="2026-06-09"; SessC=17; Updated="2026-06-19"; SessU=28; Status="WIP"; School="УРОК 8 (Тонкий кишечник. СИБР. СДК. Анализ по Осипову), Этап 2" }
    @{ File="stomach_health.md";     Ver="2.0"; Created="2026-06-10"; SessC=18; Updated="2026-06-19"; SessU=28; Status="OK";  School="УРОКИ 1-3 (Желудок. Гастрит. ГЭРБ. H.pylori), Этап 2" }
)

# Какие строки удалить между H1 и первым H2 (1-based индексы из вывода)
# Формат: имя файла -> массив диапазонов [start,end] (включительно), которые НЕ удаляем (сохраняем)
$keepLines = @{
    "stomach_health.md" = @(8)  # Центральный школьный тезис
}

Write-Host "=== UNIFY METADATA: cluster 5 ===" -ForegroundColor Cyan
Write-Host ""

foreach ($item in $plan) {
    $path = Join-Path $methDir $item.File
    if (-not (Test-Path $path)) {
        Write-Host "  MISS: $($item.File) (file not found)" -ForegroundColor Red
        continue
    }

    # 1. Backup
    Copy-Item $path "$path.backup_unify" -Force

    # 2. Read content as lines
    $lines = Get-Content $path -Encoding UTF8

    # 3. Find H1 (index 0) and first H2
    $firstH2 = -1
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^##\s') { $firstH2 = $i; break }
    }
    if ($firstH2 -lt 1) {
        Write-Host "  SKIP: $($item.File) (no H2 found)" -ForegroundColor Red
        continue
    }

    # 4. Extract: H1 + (lines to keep between H1 and firstH2) + body from firstH2
    $h1 = $lines[0]
    $keep = @()
    if ($keepLines.ContainsKey($item.File)) {
        foreach ($lineNum in $keepLines[$item.File]) {
            # lineNum 1-based, индекс массива = lineNum-1
            $keep += $lines[$lineNum - 1]
        }
    }
    $body = $lines[$firstH2..($lines.Count - 1)]

    # 5. Extract "Связанные протоколы" from old header (если есть)
    $related = ""
    for ($i = 1; $i -lt $firstH2; $i++) {
        $ln = $lines[$i]
        if ($ln -match 'Связанные протоколы:\*\*\s*(.+)$') {
            $related = $Matches[1].Trim()
            break
        }
    }

    # 6. Remove old "## Метаданные" block from body
    $bodyRaw = ($body -join "`n")
    # Удаляем от "---" + "## Метаданные" до конца, или просто "## Метаданные" до конца
    $bodyRaw = $bodyRaw -replace "(?ms)\r?\n?---\s*\r?\n## Метаданные.*$", ""
    $bodyRaw = $bodyRaw -replace "(?ms)\r?\n?## Метаданные.*$", ""
    $bodyRaw = $bodyRaw.TrimEnd()

    # 7. Count metrics
    $allLinesAfter = $bodyRaw -split "`n"
    # Считаем по итоговому файлу (H1 + keep + body)
    $totalLines = 1 + $keep.Count + ($allLinesAfter.Count)
    $h2Count = ($allLinesAfter | Where-Object { $_ -match '^##\s' }).Count
    $h3Count = ($allLinesAfter | Where-Object { $_ -match '^###\s' }).Count
    $starCount  = ([regex]::Matches($bodyRaw, "⭐")).Count
    $diamCount  = ([regex]::Matches($bodyRaw, "◆")).Count
    $warnCount  = ([regex]::Matches($bodyRaw, "⚠")).Count

    # 8. Status icon
    $statusIcon = switch ($item.Status) {
        "OK"  { "✅ Готов" }
        "WIP" { "◐ В работе" }
        "BAS" { "🔄 Базовый — требует расширения" }
        default { "—" }
    }

    # 9. Build metadata block
    $meta = @()
    $meta += ""
    $meta += "---"
    $meta += ""
    $meta += "## Метаданные"
    $meta += ""
    $meta += "- **Автор:** Agent-Nutri team"
    $meta += "- **Версия:** $($item.Ver)"
    $meta += "- **Кластер:** 5 (ЖКТ-расширение)"
    $meta += "- **Создано:** $($item.Created) (Сессия $($item.SessC))"
    $meta += "- **Последнее обновление:** $($item.Updated) (Сессия $($item.SessU))"
    $meta += "- **Источник школы:** $($item.School)"
    if ($related -ne "") {
        $meta += "- **Связанные протоколы:** $related"
    } else {
        $meta += "- **Связанные протоколы:** —"
    }
    $meta += "- **Метрики:** $totalLines строк, $h2Count H2, $h3Count H3, ⭐$starCount / ◆$diamCount / ⚠️$warnCount"
    $meta += "- **Статус:** $statusIcon"
    $meta += ""
    $metaBlock = ($meta -join "`n")

    # 10. Assemble final content
    $finalParts = @($h1)
    if ($keep.Count -gt 0) {
        $finalParts += ""
        $finalParts += $keep
    }
    $finalParts += ""
    $finalParts += $bodyRaw
    $finalParts += $metaBlock
    $final = ($finalParts -join "`n")

    # 11. Special: liver_health.md - вставить пометку про §§8-9 один раз после H1
    if ($item.File -eq "liver_health.md") {
        $note = "> **Примечание о нумерации:** параграфы §8 и §9 были удалены при реструктуризации (Сессия 26). По правилам ``_conventions.md`` стабильные H2-ID не переиспользуются после удаления — пропуск в нумерации допустим и сознателен."
        $final = $final.Replace($h1 + "`n", $h1 + "`n`n" + $note + "`n")
    }

    # 12. Write
    Set-Content -Path $path -Value $final -Encoding UTF8 -NoNewline
    Write-Host ("  DONE: {0,-25} -> {1} lines, {2} H2, {3} H3, star={4} diam={5} warn={6}" -f $item.File, $totalLines, $h2Count, $h3Count, $starCount, $diamCount, $warnCount) -ForegroundColor Green
}

Write-Host ""
Write-Host "=== DONE ===" -ForegroundColor Cyan
Write-Host "Backups saved as *.backup_unify"
Write-Host "Next: run scripts\audit_links.ps1 and verify files"
