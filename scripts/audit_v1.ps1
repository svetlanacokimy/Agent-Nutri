# audit_v1.ps1 — READ-ONLY аудитор состояния knowledge base Agent-Nutri
# Соответствует ARCHITECTURE_PLAN.md, приоритет П0 (Перепись).
# ВНУТРИ ТОЛЬКО ЧТЕНИЕ. Ни одной команды записи. Файлы не меняются.

$dir = "references\methodology"
$rows = @()
$allPmids = @{}

Get-ChildItem "$dir\*.md" | Where-Object { $_.Name -notmatch "^_|^README" } | ForEach-Object {
    $name = $_.Name
    $raw  = Get-Content $_.FullName -Raw -Encoding UTF8

    # Подсчёт тегов обоих форматов
    $old = ([regex]::Matches($raw, "\[EBM:")).Count
    $new = ([regex]::Matches($raw, "\*\*EBM\*\*")).Count
    $total = $old + $new

    # Формат
    if     ($old -gt 0 -and $new -gt 0) { $fmt = "MIXED" }
    elseif ($new -gt 0)                 { $fmt = "new" }
    elseif ($old -gt 0)                 { $fmt = "old" }
    else                                { $fmt = "none" }

    # Статус по порогу 30
    if     ($total -ge 30) { $status = "FULL" }
    elseif ($total -gt 0)  { $status = "PARTIAL" }
    else                   { $status = "NO_EBM" }

    # Все PMID в файле
    $pmids = [regex]::Matches($raw, "PMID:?\s*(\d{5,9})") | ForEach-Object { $_.Groups[1].Value }
    foreach ($p in $pmids) {
        if ($allPmids.ContainsKey($p)) { $allPmids[$p] += ",$name" } else { $allPmids[$p] = $name }
    }

    # Дубли PMID внутри одного файла
    $dupInFile = ($pmids | Group-Object | Where-Object { $_.Count -gt 1 }).Count

    # Дефект: тег вплотную к букве (склейка)
    $glued = ([regex]::Matches($raw, "[а-яёa-zА-ЯЁA-Z]\[EBM:")).Count

    # BOM
    $b = [System.IO.File]::ReadAllBytes($_.FullName)[0..2]
    $bom = if ($b[0]-eq0xEF -and $b[1]-eq0xBB -and $b[2]-eq0xBF) { "OK" } else { "NO" }

    $rows += [PSCustomObject]@{
        Файл=$name; Статус=$status; Формат=$fmt; Тегов=$total; Склейки=$glued; ДублиВФайле=$dupInFile; BOM=$bom
    }
}

"=== КАРТА СОСТОЯНИЯ ==="
$rows | Sort-Object Тегов -Descending | Format-Table -AutoSize

"=== СВОДКА ==="
"Файлов всего:     " + $rows.Count
"FULL (>=30):      " + ($rows | Where-Object {$_.Статус -eq "FULL"}).Count
"PARTIAL (1-29):   " + ($rows | Where-Object {$_.Статус -eq "PARTIAL"}).Count
"NO_EBM (0):       " + ($rows | Where-Object {$_.Статус -eq "NO_EBM"}).Count
"Формат old:       " + ($rows | Where-Object {$_.Формат -eq "old"}).Count
"Формат new:       " + ($rows | Where-Object {$_.Формат -eq "new"}).Count
"Формат MIXED:     " + ($rows | Where-Object {$_.Формат -eq "MIXED"}).Count
"Файлов со склейками: " + ($rows | Where-Object {$_.Склейки -gt 0}).Count
"Файлов без BOM:      " + ($rows | Where-Object {$_.BOM -eq "NO"}).Count

"=== PMID, встречающиеся в НЕСКОЛЬКИХ файлах (потенциальные дубли) ==="
$crossDup = $allPmids.GetEnumerator() | Where-Object { $_.Value -match "," }
if ($crossDup) { $crossDup | ForEach-Object { "PMID $($_.Key): $($_.Value)" } } else { "нет" }
"=== КОНЕЦ АУДИТА (файлы не изменялись) ==="