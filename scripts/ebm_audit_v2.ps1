#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$Root          = 'references\methodology',
    [int]   $FullThreshold = 30,
    [switch]$FailOnViolation
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RX_LEGACY  = '\[EBM:'
$RX_V31     = '(?m)^>.*\*\*EBM\*\*'
$RX_PMID    = 'PMID'
$RX_MARKER  = 'EBM_ENRICHED|MIGRATED_v'
$RX_DEF_WORD = '[\u0430-\u044f\u0451a-z]\[EBM:[^\]]*\][\u0430-\u044f\u0451a-z]'
$RX_DEF_NEST = '\[EBM:[^\]]*\[EBM:'

if (-not (Test-Path $Root)) { Write-Error "Not found: $Root"; exit 2 }

$rows = @(); $violations = @()
Get-ChildItem (Join-Path $Root '*.md') | Where-Object { $_.Name -notlike '_*' } | ForEach-Object {
    $name = $_.Name
    $c    = Get-Content $_.FullName -Encoding UTF8 -Raw
    $legacy = ([regex]::Matches($c, $RX_LEGACY)).Count
    $v31    = ([regex]::Matches($c, $RX_V31)).Count
    $pmid   = ([regex]::Matches($c, $RX_PMID)).Count
    $total  = $legacy + $v31

    $fmt = if ($legacy -gt 0 -and $v31 -gt 0) {'HYBRID'} elseif ($v31 -gt 0) {'v3.1'} elseif ($legacy -gt 0) {'legacy'} else {'-'}
    $marker = [bool]([regex]::IsMatch($c, $RX_MARKER))
    $status = if ($c -match 'MIGRATED_v3') {'v3.1'} elseif ($c -match 'FULL_EBM') {'FULL'} elseif ($c -match 'PARTIAL') {'PARTIAL'} elseif ($c -match 'NO_EBM') {'NO'} else {'-'}
    $defWord = ([regex]::Matches($c, $RX_DEF_WORD)).Count
    $defNest = ([regex]::Matches($c, $RX_DEF_NEST)).Count

    $flags = @()
    if (($status -eq 'FULL' -or $status -eq 'v3.1') -and $total -eq 0) { $flags += 'STATUS_BUT_NO_TAGS' }
    if ($total -ge $FullThreshold -and -not $marker) { $flags += 'TAGS_BUT_NO_MARKER' }
    if ($defWord -gt 0) { $flags += "DEFECT_WORD:$defWord" }
    if ($defNest -gt 0) { $flags += "DEFECT_NEST:$defNest" }
    $flagStr = if ($flags.Count) { ($flags -join ';') } else { '' }
    if ($flags.Count) { $violations += "$name -> $flagStr" }

    $markerStr = if ($marker) {'yes'} else {'no'}
    $fullStr   = if ($total -ge $FullThreshold) {'FULL'} else {''}

    if ($total -gt 0 -or $status -ne '-') {
        $rows += [PSCustomObject]@{
            File=$name; Legacy=$legacy; V31=$v31; Total=$total; PMID=$pmid
            Format=$fmt; Marker=$markerStr; Status=$status; Full=$fullStr; Flag=$flagStr
        }
    }
}
Write-Output '=== EBM AUDIT v2 — metric: BLOCKS (legacy + v3.1) ==='
$rows | Sort-Object Total -Descending | Format-Table -AutoSize
$enriched = @($rows | Where-Object { $_.Total -ge $FullThreshold })
$sumBlocks = ($rows | Measure-Object Total -Sum).Sum
$sumLegacy = ($rows | Measure-Object Legacy -Sum).Sum
$sumV31    = ($rows | Measure-Object V31 -Sum).Sum
$sumPmid   = ($rows | Measure-Object PMID -Sum).Sum
Write-Output ''
Write-Output '=== SUMMARY (single source of truth) ==='
Write-Output ("FULL_EBM files (>= {0} blocks) : {1}" -f $FullThreshold, $enriched.Count)
Write-Output ("TOTAL EBM-units (BLOCKS)       : {0}  <-- canonical metric" -f $sumBlocks)
Write-Output ("  legacy [EBM:]                 : {0}" -f $sumLegacy)
Write-Output ("  v3.1 blockquote               : {0}" -f $sumV31)
Write-Output ("PMID mentions (reference only) : {0}" -f $sumPmid)
Write-Output ''
if ($violations.Count -eq 0) { Write-Output '=== INVARIANTS: clean OK ==='; exit 0 }
else { Write-Output ("=== INVARIANTS: VIOLATIONS ({0}) ===" -f $violations.Count); $violations | ForEach-Object { Write-Output "  - $_" }; if ($FailOnViolation) { exit 1 } }
