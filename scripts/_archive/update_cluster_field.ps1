# Session 29: Update Кластер field in 17 methodology files
# Maps old cluster numbers to new canonical numbering (_clusters.md)

$mapping = @{
    'digestion_basics.md'    = @{ Num = 1; Name = 'Основы питания и пищеварения' }
    'nutrition_basics.md'    = @{ Num = 1; Name = 'Основы питания и пищеварения' }
    'nutrition_principles.md'= @{ Num = 1; Name = 'Основы питания и пищеварения' }
    'stomach_health.md'      = @{ Num = 2; Name = 'ЖКТ (верхний и нижний отделы)' }
    'intestinal_health.md'   = @{ Num = 2; Name = 'ЖКТ (верхний и нижний отделы)' }
    'colon_coprogram.md'     = @{ Num = 2; Name = 'ЖКТ (верхний и нижний отделы)' }
    'sibo_sifo.md'           = @{ Num = 2; Name = 'ЖКТ (верхний и нижний отделы)' }
    'gluten_celiac.md'       = @{ Num = 2; Name = 'ЖКТ (верхний и нижний отделы)' }
    'liver_health.md'        = @{ Num = 3; Name = 'Гепато-билиарно-панкреатическая система' }
    'gallbladder_health.md'  = @{ Num = 3; Name = 'Гепато-билиарно-панкреатическая система' }
    'pancreas_health.md'     = @{ Num = 3; Name = 'Гепато-билиарно-панкреатическая система' }
    'thyroid_health.md'      = @{ Num = 4; Name = 'Эндокринология: щитовидная железа' }
    'insulin_resistance.md'  = @{ Num = 5; Name = 'Эндокринология: метаболизм и углеводы' }
    'female_hormones.md'     = @{ Num = 6; Name = 'Эндокринология: женское здоровье' }
    'menopause.md'           = @{ Num = 6; Name = 'Эндокринология: женское здоровье' }
    'mastopathy.md'          = @{ Num = 6; Name = 'Эндокринология: женское здоровье' }
    'stress_adrenals.md'     = @{ Num = 7; Name = 'Стресс и надпочечники' }
}

$root = 'references\methodology'
$report = @()

foreach ($file in $mapping.Keys) {
    $path = Join-Path $root $file
    if (-not (Test-Path $path)) {
        Write-Host "SKIP (not found): $file" -ForegroundColor Yellow
        continue
    }

    $backup = "$path.backup_sess29"
    Copy-Item $path $backup -Force

    $lines = Get-Content $path -Encoding UTF8
    $newNum  = $mapping[$file].Num
    $newName = $mapping[$file].Name
    $newLine = "- **Кластер:** $newNum ($newName)"

    $changed = $false
    $oldLine = ''
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^\s*-\s*\*\*Кластер:\*\*\s+\d+') {
            $oldLine = $lines[$i]
            if ($oldLine -ne $newLine) {
                $lines[$i] = $newLine
                $changed = $true
            }
            break
        }
    }

    if ($changed) {
        Set-Content $path -Value $lines -Encoding UTF8
        $report += [PSCustomObject]@{
            File = $file
            Old  = $oldLine.Trim()
            New  = $newLine
            Status = 'UPDATED'
        }
    } else {
        Remove-Item $backup
        $report += [PSCustomObject]@{
            File = $file
            Old  = $oldLine.Trim()
            New  = $newLine
            Status = 'NO CHANGE'
        }
    }
}

Write-Host ''
Write-Host '=== UPDATE REPORT ===' -ForegroundColor Cyan
$report | Format-Table -AutoSize -Wrap
$updated = ($report | Where-Object { $_.Status -eq 'UPDATED' }).Count
$nochange = ($report | Where-Object { $_.Status -eq 'NO CHANGE' }).Count
Write-Host "Updated: $updated | No change: $nochange | Total: $($report.Count)" -ForegroundColor Green
