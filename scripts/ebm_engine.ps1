# =============================================================================
# ebm_engine.ps1  --  Unified EBM Engine for Agent-Nutri Pro
# Version: v1.0
# Created: 2026-08-14
# Standard: EBM v3.0  (see project/EBM_STANDARD_v2.0.md)
# API: NCBI PubMed E-utilities (uses $env:NCBI_API_KEY if available)
#
# MODES
#   -Mode audit
#       Read-only scan of references/methodology/*.md.
#       Classifies every file into one of 4 categories:
#         NATIVE_v3.0 | MIGRATED_v3.0 | LEGACY_v1.1 | NO_EBM
#       Writes project/EBM_AUDIT.md and project/ebm_audit.json.
#
#   -Mode migrate -File <path> [-DryRun] [-Verbose]
#       Migrates a single LEGACY_v1.1 file (inline [EBM: Author Year] tags)
#       into v3.0 block-quote tags. Resolves each tag against PubMed, builds
#       a v3.0 tag skeleton, backs up the original, writes the file and a
#       MIGRATION_REPORT. -DryRun previews everything without touching files.
#
#   -Mode enrich -File <path> [-DryRun] [-Verbose]
#       Suggests EBM candidates for every H2 section of a NO_EBM file.
#       Writes ENRICHMENT_CANDIDATES report. Never modifies the target file
#       (apply pass is a separate future stage).
#
# EXAMPLES
#   powershell -ExecutionPolicy Bypass -File scripts\ebm_engine.ps1 -Mode audit
#   powershell -ExecutionPolicy Bypass -File scripts\ebm_engine.ps1 -Mode migrate -File references/methodology/pancreas_health.md -DryRun
#   powershell -ExecutionPolicy Bypass -File scripts\ebm_engine.ps1 -Mode enrich  -File references/methodology/menopause.md -DryRun
#
# FLAGS
#   -DryRun   preview only, no file writes for the target methodology file
#   -Verbose  detailed logging of every PubMed request/response
# =============================================================================

param(
    [string]$Mode = "audit",   # audit | migrate | enrich
    [string]$File = "",        # target file for migrate/enrich
    [switch]$DryRun,           # preview only, no changes
    [switch]$Verbose           # detailed logging
)

$ErrorActionPreference = 'Stop'

# --- Paths ---------------------------------------------------------------
$script:MethodologyDir = 'references/methodology'
$script:ReportMd       = 'project/EBM_AUDIT.md'
$script:ReportJson     = 'project/ebm_audit.json'
$script:TempDir        = 'project/_temp'
$script:BackupDir      = 'project/_archive/backups'
$script:Timestamp      = Get-Date -Format 'yyyyMMdd_HHmmss'
$script:Utf8Bom        = New-Object System.Text.UTF8Encoding($true)

if (-not (Test-Path $script:TempDir)) { New-Item -ItemType Directory -Path $script:TempDir -Force | Out-Null }
$script:LogFile = Join-Path $script:TempDir ("ebm_engine_{0}.log" -f $script:Timestamp)

# --- API key / rate limit -----------------------------------------------
if ($env:NCBI_API_KEY) {
    $script:ApiKeyParam = "&api_key=$($env:NCBI_API_KEY)"
    $script:RateLimitMs = 100
    $script:ApiKeyStatus = 'Using NCBI API Key (rate limit: 10 req/sec)'
} else {
    $script:ApiKeyParam = ""
    $script:RateLimitMs = 350
    $script:ApiKeyStatus = 'No API key found. Using public rate limit (3 req/sec). Migration will be ~3x slower.'
}

# =============================================================================
# Helpers
# =============================================================================

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[$ts] [$Level] $Message"
    try { Add-Content -Path $script:LogFile -Value $line -Encoding UTF8 } catch { }
    switch ($Level) {
        'ERROR' { Write-Host $line -ForegroundColor Red }
        'WARN'  { Write-Host $line -ForegroundColor Yellow }
        'DEBUG' { if ($Verbose) { Write-Host $line -ForegroundColor DarkGray } }
        default { Write-Host $Message }
    }
}

function Write-BomFile {
    param([string]$Path, [string]$Content)
    $full = $Path
    if (-not [System.IO.Path]::IsPathRooted($full)) {
        $full = Join-Path (Get-Location).Path $Path
    }
    $dir = Split-Path $full -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    [System.IO.File]::WriteAllText($full, $Content, $script:Utf8Bom)
}

function Read-Utf8File {
    param([string]$Path)
    $full = $Path
    if (-not [System.IO.Path]::IsPathRooted($full)) {
        $full = Join-Path (Get-Location).Path $Path
    }
    return [System.IO.File]::ReadAllText($full, (New-Object System.Text.UTF8Encoding($true)))
}

function Invoke-PubMed {
    param([string]$Url)
    $maxRetries = 3
    for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
        try {
            Write-Log "GET $Url" 'DEBUG'
            $resp = Invoke-RestMethod -Uri $Url -TimeoutSec 30 -ErrorAction Stop
            return $resp
        } catch {
            $delay = [int][Math]::Pow(2, $attempt - 1)   # 1s, 2s, 4s
            Write-Log ("PubMed request failed (attempt {0}/{1}): {2}. Retry in {3}s" -f $attempt, $maxRetries, $_.Exception.Message, $delay) 'WARN'
            if ($attempt -lt $maxRetries) { Start-Sleep -Seconds $delay }
        }
    }
    Write-Log "PubMed request failed permanently: $Url" 'ERROR'
    return $null
}

function Search-PubMed {
    param([string]$Term, [int]$RetMax = 5)
    $enc = [System.Uri]::EscapeDataString($Term)
    $url = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=$enc&retmax=$RetMax&sort=relevance&retmode=json$script:ApiKeyParam"
    Start-Sleep -Milliseconds $script:RateLimitMs
    $r = Invoke-PubMed $url
    if ($r -and $r.esearchresult -and $r.esearchresult.idlist) { return @($r.esearchresult.idlist) }
    return @()
}

function Get-PubMedSummaries {
    param([string[]]$Ids)
    $out = @()
    if (-not $Ids -or $Ids.Count -eq 0) { return $out }
    $idStr = ($Ids -join ',')
    $url = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=$idStr&retmode=json$script:ApiKeyParam"
    Start-Sleep -Milliseconds $script:RateLimitMs
    $r = Invoke-PubMed $url
    if (-not $r -or -not $r.result) { return $out }
    foreach ($uid in $r.result.uids) {
        $rec = $r.result.$uid
        if (-not $rec) { continue }

        # First author -> Vancouver "Surname I"
        $firstAuthor = ''
        if ($rec.sortfirstauthor) {
            $firstAuthor = $rec.sortfirstauthor
        } elseif ($rec.authors -and $rec.authors.Count -gt 0) {
            $firstAuthor = $rec.authors[0].name
        }

        # Year from pubdate ("2019 Mar" -> "2019")
        $year = ''
        if ($rec.pubdate -and ($rec.pubdate -match '(\d{4})')) { $year = $matches[1] }

        $journal = if ($rec.source) { $rec.source } elseif ($rec.fulljournalname) { $rec.fulljournalname } else { '' }

        $out += [PSCustomObject]@{
            Pmid        = $uid
            FirstAuthor = $firstAuthor
            AuthorCount = if ($rec.authors) { @($rec.authors).Count } else { 0 }
            Year        = $year
            Title       = $rec.title
            Journal     = $journal
            Volume      = $rec.volume
            Issue       = $rec.issue
            Pages       = $rec.pages
        }
    }
    return $out
}

function Get-PubMedAbstract {
    param([string]$Id)
    $url = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=$Id&rettype=abstract&retmode=text$script:ApiKeyParam"
    Start-Sleep -Milliseconds $script:RateLimitMs
    return Invoke-PubMed $url
}

function Get-PopulationHint {
    param([string]$AbstractText, [string]$Pmid)
    if (-not $AbstractText) { return "[MANUAL: extract from abstract PMID $Pmid]" }
    $n = $null
    if ($AbstractText -match '(?i)\bn\s*=\s*(\d{1,6})') { $n = $matches[1] }
    $group = $null
    if ($AbstractText -match '(?i)(\d{1,5})\s+(patients|subjects|participants|women|men|adults|children)') {
        $group = "$($matches[1]) $($matches[2])"
    }
    if ($n -and $group) { return "$group (n=$n, duration MANUAL)" }
    if ($n)     { return "[MANUAL: n=$n, extract cohort from abstract PMID $Pmid]" }
    if ($group) { return "$group [MANUAL: n and duration from abstract PMID $Pmid]" }
    return "[MANUAL: extract from abstract PMID $Pmid]"
}

function Get-Surname {
    param([string]$AuthorField)
    # legacy author can be "Whitcomb", "UEG Loehr", "IAP/APA" -> take last alpha word
    $words = @(($AuthorField -split '\s+') | Where-Object { $_ -match '\p{L}' })
    if ($words.Count -gt 0) { return [string]$words[-1] }
    return $AuthorField
}

function Get-PubMedSurname {
    param([string]$SortFirstAuthor)
    # PubMed sortfirstauthor is "Surname II" -> surname is the FIRST word
    $words = @(($SortFirstAuthor -split '\s+') | Where-Object { $_ -match '\p{L}' })
    if ($words.Count -gt 0) { return [string]$words[0] }
    return $SortFirstAuthor
}

function Build-V3Tag {
    param($Summary, [string]$Context, [string]$PopulationHint)
    $author  = if ($Summary.FirstAuthor) { $Summary.FirstAuthor } else { 'Author' }
    $etal    = if ($Summary.AuthorCount -gt 1) { ', et al.' } else { '.' }
    $year    = if ($Summary.Year) { $Summary.Year } else { 'YYYY' }
    $pmid    = $Summary.Pmid
    $pop     = if ($PopulationHint) { $PopulationHint } else { "[MANUAL: extract from abstract PMID $pmid]" }

    $bib = "*$($Summary.Journal)*"
    if ($Summary.Volume) {
        $bib += " $($Summary.Volume)"
        if ($Summary.Issue) { $bib += "($($Summary.Issue))" }
        if ($Summary.Pages) { $bib += ":$($Summary.Pages)" }
    }
    $bib += "."

    $lines = @()
    $lines += "> 📚 **EBM** [Level ?, ?] [?]"
    $lines += "> **$author$etal $year.** $Context"
    $lines += "> **Population:** $pop"
    $lines += "> $bib PMID: [$pmid](https://pubmed.ncbi.nlm.nih.gov/$pmid)"
    return ($lines -join "`n")
}

# =============================================================================
# MODE: audit
# =============================================================================

function Invoke-AuditMode {
    Write-Host '=== EBM Engine v1.0 :: AUDIT ===' -ForegroundColor Cyan
    Write-Host ("[INFO] {0}" -f $script:ApiKeyStatus)
    Write-Log "AUDIT started" 'INFO'

    if (-not (Test-Path $script:MethodologyDir)) {
        Write-Log "Directory not found: $($script:MethodologyDir)" 'ERROR'
        exit 1
    }

    $files = Get-ChildItem -Path $script:MethodologyDir -Filter '*.md' -File | Sort-Object Name
    Write-Host "Found $($files.Count) methodology files"
    Write-Host ''

    $results = @()
    $counter = 0
    foreach ($f in $files) {
        $counter++
        Write-Host ("[{0,2}/{1}] {2}" -f $counter, $files.Count, $f.Name)
        $raw = Read-Utf8File $f.FullName
        $lineCount = ($raw -split "`n").Count

        # H2 headings
        $h2Matches = [regex]::Matches($raw, '(?m)^##\s+(.+)$')
        $h2Count = $h2Matches.Count
        $h2List = @()
        foreach ($m in $h2Matches) { $h2List += $m.Groups[1].Value.Trim() }

        # Tag counts
        $allBlockquote = ([regex]::Matches($raw, '📚 \*\*EBM')).Count
        $v3WithLevel   = ([regex]::Matches($raw, '📚 \*\*EBM\*\* \[Level')).Count
        $legacyInline  = ([regex]::Matches($raw, '\[EBM:')).Count
        $popLines      = ([regex]::Matches($raw, '\*\*Population:\*\*')).Count
        $totalTags     = $allBlockquote + $legacyInline

        # Markers
        $hasNativeMarker   = ($raw -match 'EBM_ENRICHED_v3\.0')
        $hasMigratedMarker = ($raw -match 'EBM_MIGRATED_v3\.0_from_v1\.1')
        $legacyMigrated = $null
        if ($raw -match 'Legacy tags migrated:\s*(\d+)') { $legacyMigrated = [int]$matches[1] }

        # PMIDs
        $pmidMatches = [regex]::Matches($raw, 'PMID[:\s]+(\d{6,9})')
        $pmids = @()
        foreach ($m in $pmidMatches) { $pmids += $m.Groups[1].Value }
        $uniquePmids = @($pmids | Sort-Object -Unique)

        # Classification (4 categories)
        $category = 'NO_EBM'
        if ($hasMigratedMarker) {
            $category = 'MIGRATED_v3.0'
        } elseif ($hasNativeMarker -or ($v3WithLevel -gt 0 -and $popLines -gt 0)) {
            $category = 'NATIVE_v3.0'
        } elseif ($legacyInline -gt 0 -or $allBlockquote -gt 0) {
            $category = 'LEGACY_v1.1'
        } elseif ($v3WithLevel -gt 0) {
            $category = 'NATIVE_v3.0'
        }

        # Detected legacy sub-format (informational)
        $format = ''
        if ($legacyInline -gt 0 -and $allBlockquote -gt 0) { $format = 'mixed (inline v1.1 + blockquote)' }
        elseif ($legacyInline -gt 0) { $format = 'inline v1.1 [EBM: ...]' }
        elseif ($v3WithLevel -gt 0)  { $format = 'blockquote v3.0 [Level ...]' }
        elseif ($allBlockquote -gt 0){ $format = 'blockquote v2.1 (no Level/Population)' }
        else { $format = 'none' }

        # Anomalies
        $anomalies = @()
        if ($totalTags -gt 0 -and $uniquePmids.Count -eq 0) {
            $anomalies += "has $totalTags EBM tag(s) but 0 PMID"
        }
        if (($category -eq 'NATIVE_v3.0' -or $category -eq 'MIGRATED_v3.0') -and $uniquePmids.Count -lt $totalTags -and $totalTags -gt 0) {
            $ratio = [Math]::Round(($uniquePmids.Count / $totalTags) * 100, 0)
            if ($ratio -lt 60) { $anomalies += "v3.0 file but PMID coverage low: $($uniquePmids.Count)/$totalTags ($ratio%)" }
        }
        if ($hasNativeMarker -and $legacyInline -gt 0) {
            $anomalies += "v3.0 marker present but $legacyInline legacy inline tag(s) remain"
        }
        if ($allBlockquote -gt 0 -and $v3WithLevel -eq 0 -and $legacyInline -eq 0) {
            $anomalies += "blockquote tags present but none in v3.0 [Level ...] format (v2.1 legacy, needs migration)"
        }

        $results += [PSCustomObject]@{
            File            = $f.Name
            SizeBytes       = $f.Length
            Lines           = $lineCount
            H2              = $h2Count
            H2List          = $h2List
            TotalTags       = $totalTags
            BlockquoteTags  = $allBlockquote
            V3LevelTags     = $v3WithLevel
            LegacyInline    = $legacyInline
            PopulationLines = $popLines
            UniquePmids     = $uniquePmids.Count
            Pmids           = $uniquePmids
            Category        = $category
            Format          = $format
            Anomalies       = $anomalies
        }
    }

    Write-Host ''
    Write-Host '=== Aggregating ==='

    $total    = $results.Count
    $native   = @($results | Where-Object { $_.Category -eq 'NATIVE_v3.0' })
    $migrated = @($results | Where-Object { $_.Category -eq 'MIGRATED_v3.0' })
    $legacy   = @($results | Where-Object { $_.Category -eq 'LEGACY_v1.1' })
    $noEbm    = @($results | Where-Object { $_.Category -eq 'NO_EBM' })
    $anomalyFiles = @($results | Where-Object { $_.Anomalies.Count -gt 0 })
    $totalTags = ($results | Measure-Object -Property TotalTags -Sum).Sum

    function Pct($n) { if ($total -gt 0) { [Math]::Round(($n / $total) * 100, 1) } else { 0 } }

    Write-Host ''
    Write-Host 'Category        Count   %' -ForegroundColor Cyan
    Write-Host ('NATIVE_v3.0   {0,6}  {1,5}' -f $native.Count,   (Pct $native.Count))
    Write-Host ('MIGRATED_v3.0 {0,6}  {1,5}' -f $migrated.Count, (Pct $migrated.Count))
    Write-Host ('LEGACY_v1.1   {0,6}  {1,5}' -f $legacy.Count,   (Pct $legacy.Count))
    Write-Host ('NO_EBM        {0,6}  {1,5}' -f $noEbm.Count,    (Pct $noEbm.Count))
    Write-Host ('TOTAL         {0,6}' -f $total)
    Write-Host ''
    Write-Host "Total EBM tags: $totalTags   Files with anomalies: $($anomalyFiles.Count)"
    Write-Host ''

    if ($anomalyFiles.Count -gt 0) {
        Write-Host '--- Anomalies ---' -ForegroundColor Yellow
        foreach ($r in ($anomalyFiles | Sort-Object File)) {
            Write-Host ("  {0}" -f $r.File) -ForegroundColor Yellow
            foreach ($a in $r.Anomalies) { Write-Host "     - $a" }
        }
        Write-Host ''
    }

    # --- Build EBM_AUDIT.md ---
    $now = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $md = @()
    $md += '# EBM Audit Report (v3.0 classification)'
    $md += ''
    $md += "**Generated:** $now"
    $md += "**Engine:** ``scripts/ebm_engine.ps1`` (mode: audit)"
    $md += "**Scanned directory:** ``$($script:MethodologyDir)``"
    $md += "**Total files:** $total"
    $md += ''
    $md += '---'
    $md += ''
    $md += '## Summary'
    $md += ''
    $md += '| Category | Count | % |'
    $md += '|---|---|---|'
    $md += ('| NATIVE_v3.0 | {0} | {1}% |' -f $native.Count,   (Pct $native.Count))
    $md += ('| MIGRATED_v3.0 | {0} | {1}% |' -f $migrated.Count, (Pct $migrated.Count))
    $md += ('| LEGACY_v1.1 | {0} | {1}% |' -f $legacy.Count,   (Pct $legacy.Count))
    $md += ('| NO_EBM | {0} | {1}% |' -f $noEbm.Count,    (Pct $noEbm.Count))
    $md += ('| **TOTAL** | **{0}** | 100% |' -f $total)
    $md += ''
    $md += "- **Total EBM tags:** $totalTags"
    $md += "- **Files with anomalies:** $($anomalyFiles.Count)"
    $md += ''
    $md += '---'
    $md += ''

    $sections = @(
        @{ Name = 'NATIVE_v3.0';   Items = $native },
        @{ Name = 'MIGRATED_v3.0'; Items = $migrated },
        @{ Name = 'LEGACY_v1.1';   Items = $legacy }
    )
    foreach ($sec in $sections) {
        $md += "## $($sec.Name) files"
        $md += ''
        if ($sec.Items.Count -eq 0) {
            $md += '_(none)_'
        } else {
            foreach ($r in ($sec.Items | Sort-Object File)) {
                $mark = if ($r.Anomalies.Count -gt 0) { ' ⚠️' } else { '' }
                $md += ("- ``{0}`` — {1} tags, {2} PMIDs, {3} H2, format: {4}{5}" -f $r.File, $r.TotalTags, $r.UniquePmids, $r.H2, $r.Format, $mark)
            }
        }
        $md += ''
        $md += '---'
        $md += ''
    }

    $md += '## NO_EBM files (enrichment candidates)'
    $md += ''
    if ($noEbm.Count -eq 0) {
        $md += '_(none)_'
    } else {
        foreach ($r in ($noEbm | Sort-Object -Property H2 -Descending)) {
            $md += ("- ``{0}`` — {1} H2, {2} lines" -f $r.File, $r.H2, $r.Lines)
        }
    }
    $md += ''
    $md += '---'
    $md += ''
    $md += '## Anomalies'
    $md += ''
    if ($anomalyFiles.Count -eq 0) {
        $md += '_(none)_'
    } else {
        foreach ($r in ($anomalyFiles | Sort-Object File)) {
            $md += "### ``$($r.File)``"
            foreach ($a in $r.Anomalies) { $md += "- ⚠️ $a" }
            $md += ''
        }
    }
    $md += '---'
    $md += ''
    $md += "_Report generated by ``scripts/ebm_engine.ps1 -Mode audit``_"

    $mdText = ($md -join "`n")
    Write-BomFile -Path $script:ReportMd -Content $mdText
    Write-Host "  Written: $($script:ReportMd)"

    # --- Build ebm_audit.json ---
    $jsonObj = [PSCustomObject]@{
        generated  = $now
        engine     = 'ebm_engine.ps1'
        mode       = 'audit'
        scannedDir = $script:MethodologyDir
        summary    = [PSCustomObject]@{
            total        = $total
            native_v3    = $native.Count
            migrated_v3  = $migrated.Count
            legacy_v11   = $legacy.Count
            no_ebm       = $noEbm.Count
            totalTags    = $totalTags
            anomalyCount = $anomalyFiles.Count
        }
        files = $results
    }
    $jsonText = ($jsonObj | ConvertTo-Json -Depth 8)
    Write-BomFile -Path $script:ReportJson -Content $jsonText
    Write-Host "  Written: $($script:ReportJson)"
    Write-Host ''
    Write-Host '=== AUDIT complete ===' -ForegroundColor Green
    Write-Log "AUDIT complete: native=$($native.Count) migrated=$($migrated.Count) legacy=$($legacy.Count) noebm=$($noEbm.Count)" 'INFO'
}

# =============================================================================
# MODE: migrate
# =============================================================================

function Invoke-MigrateMode {
    param([string]$TargetFile)

    Write-Host '=== EBM Engine v1.0 :: MIGRATE ===' -ForegroundColor Cyan
    Write-Host ("[INFO] {0}" -f $script:ApiKeyStatus)
    if ($DryRun) { Write-Host '[INFO] DRY RUN — no files will be modified' -ForegroundColor Yellow }
    Write-Log "MIGRATE started: $TargetFile (DryRun=$DryRun)" 'INFO'

    if (-not $TargetFile -or -not (Test-Path $TargetFile)) {
        Write-Log "Target file not found: $TargetFile" 'ERROR'
        exit 1
    }

    $fileName = Split-Path $TargetFile -Leaf
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
    $content  = Read-Utf8File $TargetFile
    $lines    = $content -split "`n"

    # Robust legacy regex: author (may be multi-word / org) + 4-digit year + optional trailing text
    $legacyRegex = '\[EBM:\s*([^\]]+?)\s+(\d{4})(?:[^\]]*)?\]'
    $matchesAll = [regex]::Matches($content, $legacyRegex)
    Write-Host "Found $($matchesAll.Count) legacy inline EBM tag(s)"
    Write-Log "Legacy tags found: $($matchesAll.Count)" 'INFO'

    if ($matchesAll.Count -eq 0) {
        Write-Host '[WARN] No legacy [EBM: ...] tags found. Nothing to migrate.' -ForegroundColor Yellow
        Write-Log "No legacy tags; aborting migrate." 'WARN'
        return
    }

    $transforms = @()   # each: RawTag, Author, Year, Context, Candidates, Resolved, V3Tag, Status
    $lineNumberMap = @{}
    for ($i = 0; $i -lt $lines.Count; $i++) {
        foreach ($m in [regex]::Matches($lines[$i], $legacyRegex)) {
            $lineNumberMap[$m.Value] = $i + 1
        }
    }

    $autoCount = 0
    $manualCount = 0
    $idx = 0
    foreach ($m in $matchesAll) {
        $idx++
        $rawTag = $m.Value
        $author = $m.Groups[1].Value.Trim()
        $year   = $m.Groups[2].Value
        $surname = Get-Surname $author

        # Context = line that hosts the tag, cleaned of markdown heading + the tag itself
        $lineNo = if ($lineNumberMap.ContainsKey($rawTag)) { $lineNumberMap[$rawTag] } else { 0 }
        $ctxLine = if ($lineNo -gt 0) { $lines[$lineNo - 1] } else { '' }
        $context = ($ctxLine -replace [regex]::Escape($rawTag), '').Trim()
        $context = ($context -replace '^#+\s*', '') -replace '^\d+\.\s*', ''
        $context = $context.Trim()
        if (-not $context) { $context = '[MANUAL: original context]' }

        Write-Host ("[{0,2}/{1}] [EBM: {2} {3}] (line {4})" -f $idx, $matchesAll.Count, $author, $year, $lineNo)

        # Query PubMed. Field-tagged query is far more precise than free text.
        $ids = Search-PubMed -Term ("{0}[Author] AND {1}[pdat]" -f $surname, $year) -RetMax 10
        if (-not $ids -or $ids.Count -eq 0) {
            # Fallback to free-text query for non-person authors (guideline bodies etc.)
            $ids = Search-PubMed -Term ("{0} {1}" -f $surname, $year) -RetMax 10
        }
        $summaries = Get-PubMedSummaries -Ids $ids

        # Resolve: candidate whose FIRST-author surname & year both match exactly
        $exact = @($summaries | Where-Object {
            $_.Year -eq $year -and ((Get-PubMedSurname $_.FirstAuthor).ToLower() -eq $surname.ToLower())
        })

        $status = 'MANUAL'
        $resolved = $null
        $v3Tag = ''
        if ($exact.Count -eq 1) {
            $resolved = $exact[0]
            $status = 'AUTO'
            $autoCount++
            $popHint = "[MANUAL: extract from abstract PMID $($resolved.Pmid)]"
            $abs = Get-PubMedAbstract -Id $resolved.Pmid
            if ($abs) { $popHint = Get-PopulationHint -AbstractText ([string]$abs) -Pmid $resolved.Pmid }
            $v3Tag = Build-V3Tag -Summary $resolved -Context $context -PopulationHint $popHint
            Write-Host ("        -> AUTO  PMID $($resolved.Pmid)  $($resolved.FirstAuthor) $($resolved.Year)") -ForegroundColor Green
        } else {
            $manualCount++
            Write-Host ("        -> MANUAL ($($summaries.Count) candidate(s))") -ForegroundColor Yellow
        }

        $transforms += [PSCustomObject]@{
            Index      = $idx
            RawTag     = $rawTag
            Author     = $author
            Year       = $year
            Line       = $lineNo
            Context    = $context
            Candidates = $summaries
            Resolved   = $resolved
            V3Tag      = $v3Tag
            Status     = $status
        }
    }

    Write-Host ''
    Write-Host ("Resolved automatically: $autoCount   Require manual review: $manualCount") -ForegroundColor Cyan
    Write-Log "MIGRATE resolved auto=$autoCount manual=$manualCount" 'INFO'

    # --- Write MIGRATION_REPORT ---
    $tag = if ($DryRun) { 'DRYRUN' } else { $script:Timestamp }
    $reportPath = Join-Path $script:TempDir ("MIGRATION_REPORT_{0}_{1}.md" -f $baseName, $tag)
    $r = @()
    $r += "# Migration Report — $fileName"
    $r += ''
    $r += "**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $r += "**Mode:** migrate$(if ($DryRun) { ' (DRY RUN)' } else { '' })"
    $r += "**Target:** ``$TargetFile``"
    $r += "**Legacy tags found:** $($matchesAll.Count)"
    $r += "**Auto-resolved:** $autoCount   **Manual review:** $manualCount"
    $r += ''
    $r += '---'
    $r += ''
    foreach ($t in $transforms) {
        $r += "## [$($t.Index)] ``$($t.RawTag)``  (line $($t.Line)) — **$($t.Status)**"
        $r += ''
        $r += "- **Author/Year parsed:** $($t.Author) / $($t.Year)"
        $r += "- **Context:** $($t.Context)"
        if ($t.Status -eq 'AUTO' -and $t.Resolved) {
            $r += "- **Resolved PMID:** [$($t.Resolved.Pmid)](https://pubmed.ncbi.nlm.nih.gov/$($t.Resolved.Pmid))"
            $r += ''
            $r += '**Proposed v3.0 tag:**'
            $r += ''
            $r += '```'
            $r += $t.V3Tag
            $r += '```'
        } else {
            $r += "- **Candidates (need manual pick):**"
            if ($t.Candidates.Count -eq 0) {
                $r += "  - _(no PubMed candidates found)_"
            } else {
                foreach ($c in $t.Candidates) {
                    $r += ("  - PMID [{0}](https://pubmed.ncbi.nlm.nih.gov/{0}) — {1} {2}. {3}" -f $c.Pmid, $c.FirstAuthor, $c.Year, $c.Title)
                }
            }
        }
        $r += ''
        $r += '---'
        $r += ''
    }
    Write-BomFile -Path $reportPath -Content ($r -join "`n")
    Write-Host "  Report: $reportPath"

    # --- Apply changes (only if not DryRun) ---
    if ($DryRun) {
        Write-Host '[INFO] DRY RUN — target file untouched.' -ForegroundColor Yellow
        Write-Log "MIGRATE dry run complete." 'INFO'
        return
    }

    # Backup original
    $backupPath = Join-Path $script:BackupDir ("{0}.bak.{1}_pre_v3_migration" -f $fileName, $script:Timestamp)
    if (-not (Test-Path $script:BackupDir)) { New-Item -ItemType Directory -Path $script:BackupDir -Force | Out-Null }
    Write-BomFile -Path $backupPath -Content $content
    Write-Host "  Backup: $backupPath"
    Write-Log "Backup written: $backupPath" 'INFO'

    # Rebuild file line-by-line: strip resolved inline tags, insert v3 blockquote after host line
    $newLines = New-Object System.Collections.Generic.List[string]
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $curLine = $lines[$i]
        $insertBlocks = @()
        foreach ($t in $transforms) {
            if ($t.Status -eq 'AUTO' -and $t.Line -eq ($i + 1) -and $curLine.Contains($t.RawTag)) {
                $curLine = ($curLine -replace ('\s*' + [regex]::Escape($t.RawTag)), '')
                $insertBlocks += $t.V3Tag
            }
        }
        $newLines.Add($curLine)
        foreach ($blk in $insertBlocks) {
            $newLines.Add('')
            foreach ($bl in ($blk -split "`n")) { $newLines.Add($bl) }
        }
    }

    $newContent = ($newLines -join "`n")
    $newContent = $newContent.TrimEnd() + "`n`n---`n`n" +
                  "<!-- EBM_MIGRATED_v3.0_from_v1.1 -->`n" +
                  "<!-- Legacy tags migrated: $autoCount. Manual review required: $manualCount tags. -->`n"
    Write-BomFile -Path $TargetFile -Content $newContent
    Write-Host "  Written: $TargetFile" -ForegroundColor Green
    Write-Log "MIGRATE applied: migrated=$autoCount manual=$manualCount" 'INFO'
}

# =============================================================================
# MODE: enrich
# =============================================================================

function Invoke-EnrichMode {
    param([string]$TargetFile)

    Write-Host '=== EBM Engine v1.0 :: ENRICH ===' -ForegroundColor Cyan
    Write-Host ("[INFO] {0}" -f $script:ApiKeyStatus)
    if ($DryRun) { Write-Host '[INFO] DRY RUN — target file will not be modified' -ForegroundColor Yellow }
    Write-Log "ENRICH started: $TargetFile (DryRun=$DryRun)" 'INFO'

    if (-not $TargetFile -or -not (Test-Path $TargetFile)) {
        Write-Log "Target file not found: $TargetFile" 'ERROR'
        exit 1
    }

    $fileName = Split-Path $TargetFile -Leaf
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
    $content  = Read-Utf8File $TargetFile

    $h2Matches = [regex]::Matches($content, '(?m)^##\s+(.+)$')
    $headings = @()
    foreach ($m in $h2Matches) {
        $h = $m.Groups[1].Value.Trim()
        # skip meta / references sections
        if ($h -match '(?i)метаданные|источники|references|литература') { continue }
        $headings += $h
    }
    Write-Host "Found $($headings.Count) H2 section(s) to enrich"
    Write-Log "H2 sections for enrichment: $($headings.Count)" 'INFO'

    $rows = @()
    $idx = 0
    foreach ($h in $headings) {
        $idx++
        # clean heading -> query
        $q = ($h -replace '[⭐⚠️🔴🟢📚]', '') -replace '^\d+\.?\s*', ''
        $q = $q.Trim()
        Write-Host ("[{0,2}/{1}] {2}" -f $idx, $headings.Count, $q)
        $ids = Search-PubMed -Term $q -RetMax 3
        $summaries = Get-PubMedSummaries -Ids $ids
        $cands = @()
        foreach ($c in $summaries) {
            $cands += ("PMID [{0}](https://pubmed.ncbi.nlm.nih.gov/{0}) — {1} {2}. {3}" -f $c.Pmid, $c.FirstAuthor, $c.Year, $c.Title)
        }
        while ($cands.Count -lt 3) { $cands += '_(none)_' }
        Write-Host ("        -> {0} candidate(s)" -f $summaries.Count) -ForegroundColor Green
        $rows += [PSCustomObject]@{ Section = $h; C1 = $cands[0]; C2 = $cands[1]; C3 = $cands[2] }
    }

    $tag = if ($DryRun) { 'DRYRUN' } else { $script:Timestamp }
    $reportPath = Join-Path $script:TempDir ("ENRICHMENT_CANDIDATES_{0}_{1}.md" -f $baseName, $tag)
    $r = @()
    $r += "# Enrichment Candidates — $fileName"
    $r += ''
    $r += "**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $r += "**Mode:** enrich$(if ($DryRun) { ' (DRY RUN)' } else { '' })"
    $r += "**Target:** ``$TargetFile``"
    $r += "**H2 sections:** $($headings.Count)"
    $r += ''
    $r += '> NOTE: file is NOT modified. Review candidates, then run the apply pass (future stage).'
    $r += ''
    $r += '---'
    $r += ''
    $r += '| # | H2 section | Candidate 1 | Candidate 2 | Candidate 3 |'
    $r += '|---|---|---|---|---|'
    $n = 0
    foreach ($row in $rows) {
        $n++
        $sec = ($row.Section -replace '\|', '\|')
        $c1 = ($row.C1 -replace '\|', '\|')
        $c2 = ($row.C2 -replace '\|', '\|')
        $c3 = ($row.C3 -replace '\|', '\|')
        $r += ("| {0} | {1} | {2} | {3} | {4} |" -f $n, $sec, $c1, $c2, $c3)
    }
    $r += ''
    $r += '---'
    $r += ''
    $r += "_Report generated by ``scripts/ebm_engine.ps1 -Mode enrich``_"
    Write-BomFile -Path $reportPath -Content ($r -join "`n")
    Write-Host "  Report: $reportPath"
    Write-Host '[INFO] Target file untouched (enrich only proposes candidates).' -ForegroundColor Yellow
    Write-Log "ENRICH complete: $($headings.Count) sections." 'INFO'
}

# =============================================================================
# Dispatch
# =============================================================================

Write-Log "ebm_engine v1.0 start | mode=$Mode file=$File dryrun=$DryRun verbose=$Verbose" 'INFO'

switch ($Mode.ToLower()) {
    'audit'   { Invoke-AuditMode }
    'migrate' { Invoke-MigrateMode -TargetFile $File }
    'enrich'  { Invoke-EnrichMode  -TargetFile $File }
    default   {
        Write-Host "[ERROR] Unknown mode: $Mode. Use: audit | migrate | enrich" -ForegroundColor Red
        exit 1
    }
}

Write-Host ''
Write-Host "Log: $($script:LogFile)" -ForegroundColor DarkGray

# EBM_ENGINE_v1_APPLIED
