# Audit cross-references in references/methodology
$methDir = "references\methodology"
$files = Get-ChildItem "$methDir\*.md" | Where-Object { $_.Name -notlike "*.backup*" -and $_.Name -notlike "_*" }
$fileH2Map = @{}
foreach ($f in $files) {
    $h2 = @()
    foreach ($line in (Get-Content $f.FullName -Encoding UTF8)) {
        if ($line -match '^##\s+(\d+)\.') { $h2 += [int]$Matches[1] }
    }
    $fileH2Map[$f.Name] = $h2
}
$knownFiles = @($fileH2Map.Keys)
$broken = @()
$total = 0
foreach ($f in $files) {
    $content = Get-Content $f.FullName -Encoding UTF8
    for ($i = 0; $i -lt $content.Count; $i++) {
        $line = $content[$i]
        foreach ($tf in $knownFiles) {
            if (-not $line.Contains($tf)) { continue }
            $idx = $line.IndexOf($tf)
            $after = $line.Substring($idx + $tf.Length)
            if ($after.Length -gt 200) { $after = $after.Substring(0,200) }
            $matches2 = [regex]::Matches($after, '(?:§|раздел\w*)\s*([\d,\s\-–]+)')
            foreach ($m in $matches2) {
                $nums = $m.Groups[1].Value
                foreach ($part in $nums -split '[,\s]+') {
                    if ($part -match '^(\d+)[\-–](\d+)$') {
                        for ($n=[int]$Matches[1]; $n -le [int]$Matches[2]; $n++) {
                            $total++
                            if ($fileH2Map[$tf] -notcontains $n) { $broken += "$($f.Name):$($i+1) -> $tf §$n" }
                        }
                    } elseif ($part -match '^\d+$') {
                        $n = [int]$part; $total++
                        if ($fileH2Map[$tf] -notcontains $n) { $broken += "$($f.Name):$($i+1) -> $tf §$n" }
                    }
                }
            }
        }
    }
}
Write-Host "=== AUDIT RESULT ===" -ForegroundColor Cyan
Write-Host "Total: $total"
Write-Host "Broken: $($broken.Count)"
if ($broken.Count -gt 0) { $broken | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow } }
