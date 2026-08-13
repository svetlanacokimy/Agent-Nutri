# =====НАЧАЛО=====
# =============================================================================
# ebm_audit.ps1
# Read-only audit of all methodology files in references/methodology/
# Produces:
#   - project/EBM_AUDIT.md   (human-readable report)
#   - project/ebm_audit.json (machine-readable data)
# =============================================================================

$ErrorActionPreference = 'Stop'

$methodologyDir = 'references/methodology'
$reportMd = 'project/EBM_AUDIT.md'
$reportJson = 'project/ebm_audit.json'

Write-Host '=== EBM Audit v1.0 ==='
Write-Host ''

if (-not (Test-Path $methodologyDir)) {
    Write-Host "[ABORT] Directory not found: $methodologyDir"
    exit 1
}

# --- Collect all .md files ---
$files = Get-ChildItem -Path $methodologyDir -Filter '*.md' -File | Sort-Object Name
Write-Host "Found $($files.Count) methodology files"
Write-Host ''

# --- Analyze each file ---
$results = @()
$counter = 0

foreach ($f in $files) {
    $counter++
    Write-Host ("[{0,2}/{1}] {2}" -f $counter, $files.Count, $f.Name)

    $raw = Get-Content $f.FullName -Encoding UTF8 -Raw
    $lines = Get-Content $f.FullName -Encoding UTF8
    $lineCount = $lines.Count
    $sizeBytes = $f.Length

    # H2 / H3 counts
    $h2Count = ([regex]::Matches($raw, '(?m)^## ')).Count
    $h3Count = ([regex]::Matches($raw, '(?m)^### ')).Count

    # EBM tags (multiple formats: 📚 **EBM** or 📚 EBM: or > 📚 **EBM:**)
    $ebmTagsV21 = ([regex]::Matches($raw, '📚 \*\*EBM')).Count
    $ebmTagsLegacy = ([regex]::Matches($raw, '\[EBM:')).Count
    $ebmTags = $ebmTagsV21 + $ebmTagsLegacy
    if ($ebmTags -eq 0) {
        # Fallback: try plain "📚 EBM:" without bold
        $ebmTagsV21 = ([regex]::Matches($raw, '📚 \*\*EBM')).Count; $ebmTagsLegacy = ([regex]::Matches($raw, '\[EBM:')).Count; $ebmTags = $ebmTagsV21 + $ebmTagsLegacy
    }

    # Marker EBM_ENRICHED_v*
    $markerVersion = $null
    if ($raw -match 'EBM_ENRICHED_v(\d+\.\d+)') {
        $markerVersion = $matches[1]
    }

    # Metadata: Версия
    $version = $null
    if ($raw -match '(?m)^-\s*\*\*Версия:\*\*\s*([\d\.]+)') { $version = $matches[1] }
    elseif ($raw -match '(?m)^-\s*Версия:\s*([\d\.]+)') { $version = $matches[1] }

    # Metadata: Статус
    $status = $null
    if ($raw -match '(?m)^-\s*\*\*Статус:\*\*\s*([^\r\n]+)') { $status = $matches[1].Trim() }
    elseif ($raw -match '(?m)^-\s*Статус:\s*([^\r\n]+)') { $status = $matches[1].Trim() }

    # Metadata: Кластер
    $cluster = $null
    if ($raw -match '(?m)^-\s*\*\*Кластер:\*\*\s*([^\r\n]+)') { $cluster = $matches[1].Trim() }
    elseif ($raw -match '(?m)^-\s*Кластер:\s*([^\r\n]+)') { $cluster = $matches[1].Trim() }

    # Metadata: Последнее обновление
    $lastUpdated = $null
    if ($raw -match '(?m)^-\s*\*\*Последнее обновление:\*\*\s*([^\r\n]+)') { $lastUpdated = $matches[1].Trim() }
    elseif ($raw -match '(?m)^-\s*Последнее обновление:\s*([^\r\n]+)') { $lastUpdated = $matches[1].Trim() }

    # Benchmark section
    $hasBenchmark = ($raw -match '(?im)^## .*[Бб]enchmark|[Бб]енчмарк')

    # PMIDs (unique)
    $pmidMatches = [regex]::Matches($raw, 'PMID[:\s]+(\d{6,9})')
    $pmids = @()
    foreach ($m in $pmidMatches) { $pmids += $m.Groups[1].Value }
    $uniquePmids = @($pmids | Sort-Object -Unique)

    # Category
    $category = 'NO_EBM'
    if ($ebmTags -ge 25 -and $markerVersion) {
        $category = 'FULL_EBM'
    } elseif ($ebmTags -ge 5) {
        $category = 'PARTIAL_EBM'
    }

    # Density (tags per H2)
    $density = 0
    if ($h2Count -gt 0) {
        $density = [Math]::Round(($ebmTags / $h2Count) * 100, 1)
    }

    # Anomaly flags
    $anomalies = @()
    if ($markerVersion -and -not $version) {
        $anomalies += 'marker present but no version in metadata'
    }
    if ($markerVersion -and $version -and $markerVersion -ne $version) {
        $anomalies += "marker version ($markerVersion) != metadata version ($version)"
    }
    if ($category -eq 'FULL_EBM' -and $status -and $status -notmatch 'FULL_EBM') {
        $anomalies += "status in metadata does not mention FULL_EBM: '$status'"
    }
    if ($ebmTags -ge 25 -and -not $markerVersion) {
        $anomalies += "has $ebmTags tags but no EBM_ENRICHED_v marker"
    }
    if ($ebmTags -gt 0 -and $ebmTags -lt 5) {
        $anomalies += "few EBM tags ($ebmTags) — orphan/incomplete enrichment"
    }
    if ($uniquePmids.Count -lt $ebmTags -and $ebmTags -gt 0) {
        $ratio = [Math]::Round(($uniquePmids.Count / $ebmTags) * 100, 0)
        if ($ratio -lt 60) {
            $anomalies += "PMID diversity low: $($uniquePmids.Count) unique / $ebmTags tags ($ratio%)"
        }
    }

    $entry = [PSCustomObject]@{
        File = $f.Name
        SizeBytes = $sizeBytes
        Lines = $lineCount
        H2 = $h2Count
        H3 = $h3Count
        EbmTags = $ebmTags
        MarkerVersion = $markerVersion
        MetadataVersion = $version
        Status = $status
        Cluster = $cluster
        LastUpdated = $lastUpdated
        HasBenchmark = $hasBenchmark
        UniquePmids = $uniquePmids.Count
        Pmids = $uniquePmids
        Category = $category
        Density = $density
        Anomalies = $anomalies
    }
    $results += $entry
}

Write-Host ''
Write-Host '=== Aggregating stats ==='

$total = $results.Count
$fullEbm = @($results | Where-Object { $_.Category -eq 'FULL_EBM' })
$partialEbm = @($results | Where-Object { $_.Category -eq 'PARTIAL_EBM' })
$noEbm = @($results | Where-Object { $_.Category -eq 'NO_EBM' })

$totalTags = ($results | Measure-Object -Property EbmTags -Sum).Sum
$totalLines = ($results | Measure-Object -Property Lines -Sum).Sum
$totalBytes = ($results | Measure-Object -Property SizeBytes -Sum).Sum

# All PMIDs (frequency)
$allPmids = @{}
foreach ($r in $results) {
    foreach ($pmid in $r.Pmids) {
        if ($allPmids.ContainsKey($pmid)) {
            $allPmids[$pmid] += @($r.File)
        } else {
            $allPmids[$pmid] = @($r.File)
        }
    }
}
$duplicatedPmids = @($allPmids.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 } | Sort-Object { $_.Value.Count } -Descending)

# Anomalies
$anomalyCount = ($results | Where-Object { $_.Anomalies.Count -gt 0 }).Count

Write-Host ("  FULL_EBM: {0}/{1} ({2}%)" -f $fullEbm.Count, $total, [Math]::Round(($fullEbm.Count/$total)*100, 1))
Write-Host ("  PARTIAL_EBM: {0}/{1} ({2}%)" -f $partialEbm.Count, $total, [Math]::Round(($partialEbm.Count/$total)*100, 1))
Write-Host ("  NO_EBM: {0}/{1} ({2}%)" -f $noEbm.Count, $total, [Math]::Round(($noEbm.Count/$total)*100, 1))
Write-Host "  Total EBM tags: $totalTags"
Write-Host "  Total lines: $totalLines"
Write-Host "  Total bytes: $totalBytes"
Write-Host "  Unique PMIDs: $($allPmids.Count)"
Write-Host "  Duplicated PMIDs (used in 2+ files): $($duplicatedPmids.Count)"
Write-Host "  Files with anomalies: $anomalyCount"
Write-Host ''

# =============================================================================
# Build EBM_AUDIT.md (human-readable)
# =============================================================================
Write-Host '=== Writing EBM_AUDIT.md ==='

$now = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

$md = @()
$md += '# EBM Audit Report'
$md += ''
$md += "**Generated:** $now"
$md += "**Scanned directory:** ``$methodologyDir``"
$md += "**Total files:** $total"
$md += ''
$md += '---'
$md += ''
$md += '## Summary'
$md += ''
$md += ("- **FULL_EBM:** {0}/{1} files ({2}%)" -f $fullEbm.Count, $total, [Math]::Round(($fullEbm.Count/$total)*100, 1))
$md += ("- **PARTIAL_EBM:** {0}/{1} files ({2}%)" -f $partialEbm.Count, $total, [Math]::Round(($partialEbm.Count/$total)*100, 1))
$md += ("- **NO_EBM:** {0}/{1} files ({2}%)" -f $noEbm.Count, $total, [Math]::Round(($noEbm.Count/$total)*100, 1))
$md += "- **Total EBM tags:** $totalTags"
$md += "- **Total methodology lines:** $totalLines"
$md += "- **Total size:** $totalBytes bytes ($([Math]::Round($totalBytes/1024, 1)) KB)"
$md += "- **Unique PMIDs across corpus:** $($allPmids.Count)"
$md += "- **Files with anomalies:** $anomalyCount"
$md += ''
$md += '---'
$md += ''
$md += '## FULL_EBM files'
$md += ''
foreach ($r in ($fullEbm | Sort-Object File)) {
    $anomalyMark = if ($r.Anomalies.Count -gt 0) { ' ⚠️' } else { '' }
    $md += ("- ``{0}`` — {1} tags, {2} H2, marker v{3}, {4} PMIDs, density {5}%{6}" -f $r.File, $r.EbmTags, $r.H2, $r.MarkerVersion, $r.UniquePmids, $r.Density, $anomalyMark)
}
$md += ''
$md += '---'
$md += ''
$md += '## PARTIAL_EBM files'
$md += ''
if ($partialEbm.Count -eq 0) {
    $md += '_(none — corpus fully split between FULL_EBM and NO_EBM)_'
} else {
    foreach ($r in ($partialEbm | Sort-Object -Property EbmTags -Descending)) {
        $md += ("- ``{0}`` — {1} tags, {2} H2, {3} PMIDs, density {4}%" -f $r.File, $r.EbmTags, $r.H2, $r.UniquePmids, $r.Density)
    }
}
$md += ''
$md += '---'
$md += ''
$md += '## NO_EBM files (priority candidates for enrichment)'
$md += ''
$md += 'Sorted by H2 count descending (more sections = richer for EBM):'
$md += ''
foreach ($r in ($noEbm | Sort-Object -Property H2 -Descending)) {
    $benchmark = if ($r.HasBenchmark) { ' [Benchmark ✓]' } else { '' }
    $md += ("- ``{0}`` — {1} H2, {2} H3, {3} lines, cluster: {4}{5}" -f $r.File, $r.H2, $r.H3, $r.Lines, $(if ($r.Cluster) { $r.Cluster } else { 'unknown' }), $benchmark)
}
$md += ''
$md += '---'
$md += ''
$md += '## Anomalies (require attention)'
$md += ''
$anomalyFiles = @($results | Where-Object { $_.Anomalies.Count -gt 0 } | Sort-Object File)
if ($anomalyFiles.Count -eq 0) {
    $md += '_(no anomalies detected — all metadata consistent)_'
} else {
    foreach ($r in $anomalyFiles) {
        $md += "### ``$($r.File)``"
        foreach ($a in $r.Anomalies) {
            $md += "- ⚠️ $a"
        }
        $md += ''
    }
}
$md += ''
$md += '---'
$md += ''
$md += '## PMID reuse (cross-file citations)'
$md += ''
if ($duplicatedPmids.Count -eq 0) {
    $md += '_(no PMID reused across files)_'
} else {
    $md += "**$($duplicatedPmids.Count) PMIDs cited in 2+ files** (top 15):"
    $md += ''
    $topDup = $duplicatedPmids | Select-Object -First 15
    foreach ($kv in $topDup) {
        $md += "- **PMID $($kv.Key)** — cited in $($kv.Value.Count) files: ``$($kv.Value -join '`, `')``"
    }
}
$md += ''
$md += '---'
$md += ''
$md += '## Cluster distribution'
$md += ''
$byCluster = $results | Group-Object -Property Cluster | Sort-Object Name
foreach ($grp in $byCluster) {
    $clusterName = if ($grp.Name) { $grp.Name } else { '(no cluster)' }
    $md += "### Cluster: $clusterName"
    $md += ''
    $md += "- Files: $($grp.Count)"
    $full = @($grp.Group | Where-Object { $_.Category -eq 'FULL_EBM' }).Count
    $partial = @($grp.Group | Where-Object { $_.Category -eq 'PARTIAL_EBM' }).Count
    $no = @($grp.Group | Where-Object { $_.Category -eq 'NO_EBM' }).Count
    $md += "- FULL_EBM: $full, PARTIAL_EBM: $partial, NO_EBM: $no"
    $md += ''
    foreach ($r in ($grp.Group | Sort-Object File)) {
        $md += "  - ``$($r.File)`` — $($r.Category), $($r.EbmTags) tags"
    }
    $md += ''
}
$md += '---'
$md += ''
$md += "_Report generated by ``scripts/ebm_audit.ps1``_"

# Write MD file (UTF-8 with BOM)
$mdText = $md -join "`n"
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path (Split-Path $reportMd)).Path + '\' + (Split-Path $reportMd -Leaf), $mdText, $utf8Bom)
Write-Host "  Written: $reportMd ($([System.Text.Encoding]::UTF8.GetByteCount($mdText)) bytes)"

# =============================================================================
# Build ebm_audit.json (machine-readable)
# =============================================================================
Write-Host '=== Writing ebm_audit.json ==='

$jsonObj = [PSCustomObject]@{
    generated = $now
    scannedDir = $methodologyDir
    summary = [PSCustomObject]@{
        total = $total
        fullEbm = $fullEbm.Count
        partialEbm = $partialEbm.Count
        noEbm = $noEbm.Count
        totalTags = $totalTags
        totalLines = $totalLines
        totalBytes = $totalBytes
        uniquePmids = $allPmids.Count
        anomalyCount = $anomalyCount
    }
    files = $results
    pmidReuse = @($duplicatedPmids | ForEach-Object {
        [PSCustomObject]@{
            pmid = $_.Key
            count = $_.Value.Count
            files = $_.Value
        }
    })
}
$jsonText = $jsonObj | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText((Resolve-Path (Split-Path $reportJson)).Path + '\' + (Split-Path $reportJson -Leaf), $jsonText, $utf8Bom)
Write-Host "  Written: $reportJson ($([System.Text.Encoding]::UTF8.GetByteCount($jsonText)) bytes)"

Write-Host ''
Write-Host '=== SUCCESS ==='
Write-Host "Audit complete. Review reports:"
Write-Host "  - $reportMd (human-readable)"
Write-Host "  - $reportJson (machine-readable)"
Write-Host ''
Write-Host 'Key findings to review:'
Write-Host "  - $anomalyCount files with anomalies"
if ($partialEbm.Count -gt 0) {
    Write-Host "  - $($partialEbm.Count) PARTIAL_EBM files (easy wins — bring to FULL_EBM)"
}
Write-Host "  - $($noEbm.Count) NO_EBM files remaining"
# =====КОНЕЦ=====
