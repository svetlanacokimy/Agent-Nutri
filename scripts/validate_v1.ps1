# validate_v1.ps1 — READ-ONLY валидатор knowledge base Agent-Nutri
# Основание: EBM_VALIDATION_SPEC.md (проверки C1-C6). ТОЛЬКО ЧТЕНИЕ.
# Код выхода: 0 = все PASS; 1 = есть хотя бы один FAIL.

$dir = "references\methodology"
$fails = 0
$warns = 0
$report = @()

Get-ChildItem "$dir\*.md" | Where-Object { $_.Name -notmatch "^_|^README" } | ForEach-Object {
    $name  = $_.Name
    $full  = $_.FullName
    $raw   = Get-Content $full -Raw -Encoding UTF8
    $lines = Get-Content $full -Encoding UTF8
    $issues = @()

    # C1 BOM
    $b = [System.IO.File]::ReadAllBytes($full)[0..2]
    if (-not ($b[0]-eq0xEF -and $b[1]-eq0xBB -and $b[2]-eq0xBF)) { $issues += "FAIL C1: нет BOM" }

    # C2 склейки
    $glue = ([regex]::Matches($raw, "[а-яёa-zА-ЯЁA-Z]\[EBM:")).Count
    if ($glue -gt 0) { $issues += "FAIL C2: склеек $glue" }

    # C3 осиротевшие + C6 незакрытые (перебор old-тегов)
    $orphan = 0; $unclosed = 0
    foreach ($ln in $lines) {
        $starts = [regex]::Matches($ln, "\[EBM:")
        foreach ($m in $starts) {
            $tail = $ln.Substring($m.Index)
            $close = $tail.IndexOf("]")
            if ($close -lt 0) { $unclosed++ ; continue }
            $tagBody = $tail.Substring(0, $close)
            if ($tagBody -notmatch "PMID:?\s*\d{5,9}") { $orphan++ }
        }
    }
    if ($orphan -gt 0)   { $issues += "FAIL C3: тегов без PMID $orphan" }
    if ($unclosed -gt 0) { $issues += "FAIL C6: незакрытых тегов $unclosed" }

    # C4 дубль PMID в ОДНОЙ строке (правило Р2)
    $dupLine = 0
    foreach ($ln in $lines) {
        $pm = [regex]::Matches($ln, "PMID:?\s*(\d{5,9})") | ForEach-Object { $_.Groups[1].Value }
        $d = ($pm | Group-Object | Where-Object { $_.Count -gt 1 }).Count
        if ($d -gt 0) { $dupLine += $d }
    }
    if ($dupLine -gt 0) { $issues += "FAIL C4: дублей PMID в одной строке $dupLine" }

    # C5 статус vs число тегов (WARN)
    $tags = ([regex]::Matches($raw, "\[EBM:")).Count + ([regex]::Matches($raw, "\*\*EBM\*\*")).Count
    # (WARN только информативно; порог 30)

    if ($issues.Count -gt 0) {
        $fails += ($issues | Where-Object { $_ -match "^FAIL" }).Count
        $report += "[$name] тегов=$tags"
        $issues | ForEach-Object { $report += "    $_" }
    }
}

"=== ВАЛИДАЦИЯ (spec C1-C6) ==="
if ($report.Count -eq 0) {
    "Все файлы прошли C1-C6. FAIL: 0."
} else {
    $report
}
""
"ИТОГО FAIL: $fails"
if ($fails -eq 0) { "ВЕРДИКТ: PASS (код 0) — база здорова, правки разрешены"; exit 0 }
else              { "ВЕРДИКТ: FAIL (код 1) — СТОП, устранить дефекты"; exit 1 }