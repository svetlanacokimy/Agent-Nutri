<#
.SYNOPSIS
    Audit EBM compliance across all methodology files.
.DESCRIPTION
    Reads all references/methodology/*.md files and reports EBM enrichment status
    according to project/EBM_STANDARD.md v1.0.
    States: NO_EBM, PARTIAL_EBM, FULL_EBM.
.NOTES
    Author: Agent-Nutri team, 2026-07-31
    Version: 1.0
#>

$ErrorActionPreference = "Stop"
$methodologyDir = "references/methodology"
$excludeFiles = @("_clusters.md", "_template.md", "_conventions.md", "README.md")

if (-not (Test-Path $methodologyDir)) {
    Write-Host "ERROR: directory $methodologyDir not found" -ForegroundColor Red
    exit 1
}

$files = Get-ChildItem -Path $methodologyDir -Filter "*.md" -File |
         Where-Object { $_.Name -notin $excludeFiles } |
         Sort-Object Name

Write-Host ""
Write-Host "=== EBM COMPLIANCE AUDIT ===" -ForegroundColor Cyan
Write-Host "Directory: $methodologyDir"
Write-Host "Files to audit: $($files.Count)"
Write-Host "Standard: project/EBM_STANDARD.md v1.0"
Write-Host ""

$results = @()

foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    $lines = ($content -split "`n").Count
    $sizeKb = [Math]::Round($file.Length / 1KB, 1)

    $ebmTags = ([regex]::Matches($content, '\[EBM:')).Count
    $hasBenchmarkSection = $content -match '## §\d+\.\s*EBM [Bb]enchmark'
    $hasKeySources = $content -match '## Ключевые источники'
    $hasMarker = $content -match '<!--\s*EBM_ENRICHED_v'
    $hasMetadata = $content -match '## Метаданные'

    if ($hasMarker -and $ebmTags -ge 30) {
        $state = "FULL_EBM"
        $color = "Green"
    }
    elseif ($hasBenchmarkSection -or $hasKeySources) {
        $state = "PARTIAL_EBM"
        $color = "Yellow"
    }
    elseif ($ebmTags -gt 0) {
        $state = "PARTIAL_EBM"
        $color = "Yellow"
    }
    else {
        $state = "NO_EBM"
        $color = "Red"
    }

    $benchmarkNum = "-"
    if ($hasBenchmarkSection) {
        $m = [regex]::Match($content, '## §(\d+)\.\s*EBM [Bb]enchmark')
        if ($m.Success) { $benchmarkNum = "§" + $m.Groups[1].Value }
    }

    $results += [PSCustomObject]@{
        File          = $file.Name
        State         = $state
        Color         = $color
        EbmTags       = $ebmTags
        Benchmark     = $benchmarkNum
        HasMarker     = if ($hasMarker) { "yes" } else { "no" }
        HasMetadata   = if ($hasMetadata) { "yes" } else { "no" }
        Lines         = $lines
        SizeKb        = $sizeKb
    }
}

$col1 = 42
$col2 = 12
$col3 = 8
$col4 = 10
$col5 = 8
$col6 = 8
$col7 = 6
$col8 = 6

$header = ("File".PadRight($col1) + "State".PadRight($col2) + "EBM".PadRight($col3) + "Bench".PadRight($col4) + "Mark".PadRight($col5) + "Meta".PadRight($col6) + "Ln".PadRight($col7) + "KB")
Write-Host $header -ForegroundColor White
Write-Host ("-" * $header.Length) -ForegroundColor DarkGray

foreach ($r in $results) {
    $line = ($r.File.PadRight($col1) +
             $r.State.PadRight($col2) +
             ([string]$r.EbmTags).PadRight($col3) +
             $r.Benchmark.PadRight($col4) +
             $r.HasMarker.PadRight($col5) +
             $r.HasMetadata.PadRight($col6) +
             ([string]$r.Lines).PadRight($col7) +
             [string]$r.SizeKb)
    Write-Host $line -ForegroundColor $r.Color
}

Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
$full = ($results | Where-Object { $_.State -eq "FULL_EBM" }).Count
$partial = ($results | Where-Object { $_.State -eq "PARTIAL_EBM" }).Count
$none = ($results | Where-Object { $_.State -eq "NO_EBM" }).Count
$total = $results.Count

Write-Host "FULL_EBM:    $full / $total files ($([Math]::Round($full/$total*100,1))%)" -ForegroundColor Green
Write-Host "PARTIAL_EBM: $partial / $total files ($([Math]::Round($partial/$total*100,1))%)" -ForegroundColor Yellow
Write-Host "NO_EBM:      $none / $total files ($([Math]::Round($none/$total*100,1))%)" -ForegroundColor Red
Write-Host ""

$totalTags = ($results | Measure-Object -Property EbmTags -Sum).Sum
$totalLines = ($results | Measure-Object -Property Lines -Sum).Sum
Write-Host "Total EBM tags across all files: $totalTags"
Write-Host "Total lines across all files:    $totalLines"
Write-Host ""

$partialFiles = $results | Where-Object { $_.State -eq "PARTIAL_EBM" } | Select-Object -ExpandProperty File
$noneFiles = $results | Where-Object { $_.State -eq "NO_EBM" } | Select-Object -ExpandProperty File

if ($partialFiles.Count -gt 0) {
    Write-Host "PARTIAL_EBM files (need tag enrichment, keep existing structure):" -ForegroundColor Yellow
    foreach ($f in $partialFiles) { Write-Host "  - $f" }
    Write-Host ""
}

if ($noneFiles.Count -gt 0) {
    Write-Host "NO_EBM files (need full enrichment with new EBM Benchmark section):" -ForegroundColor Red
    foreach ($f in $noneFiles) { Write-Host "  - $f" }
    Write-Host ""
}

Write-Host "=== AUDIT COMPLETE ===" -ForegroundColor Cyan
