# =============================================================================
# ebm_reformat.ps1  --  Autonomous EBM reformatter / migrator for Agent-Nutri Pro
# Version: v1.0  (2026-08-17)
# Standard: EBM v3.1  (project/EBM_STANDARD_v2.0.md)
# API:      NCBI PubMed E-utilities (esummary + efetch), uses $env:NCBI_API_KEY
#
# Назначение (RU): автономный скрипт аудита и миграции EBM-блоков в файлах
# references/methodology/*.md. Делает 90% работы без участия LLM: обнаруживает
# EBM-блоки трёх форматов (v1.1 inline, v2.1 короткий, v3.0/v3.1 полный),
# валидирует PMID против PubMed, определяет уровень доказательности и тип
# исхода, добавляет Safety/Currency-блоки и (в режиме apply) транзакционно
# переписывает файл в формат v3.1.
#
# РЕЖИМЫ
#   -Mode audit  (по умолчанию) — только проверка, отчёт без изменений файла.
#   -Mode dryrun — построить план миграции и diff, показать в отчёте, не писать.
#   -Mode apply  — применить изменения к файлу (Read->Apply->Validate->Write).
#
# ПРИМЕРЫ
#   powershell -ExecutionPolicy Bypass -File scripts\ebm_reformat.ps1 -File pancreas_health.md -Mode audit -Verbose
#   powershell -ExecutionPolicy Bypass -File scripts\ebm_reformat.ps1 -File thyroid_health.md -Mode dryrun -Verbose -Backup
#   powershell -ExecutionPolicy Bypass -File scripts\ebm_reformat.ps1 -File thyroid_health.md -Mode apply -Backup
# =============================================================================

param(
    [string]$File = '',                # имя файла в references/methodology/ или полный путь
    [string]$Mode = 'audit',           # audit | dryrun | apply
    [switch]$Backup,                   # бэкап перед apply (SHA256-проверка)
    [switch]$Verbose,                  # подробный вывод
    [switch]$NoCache                   # игнорировать кэш PubMed, запрашивать заново
)

$ErrorActionPreference = 'Stop'

# Ручная валидация параметров (не используем [Parameter]/[CmdletBinding],
# чтобы -Verbose оставался кастомным switch, а не common-параметром).
if (-not $File) { Write-Host '[ERROR] -File is required (e.g. -File pancreas_health.md)' -ForegroundColor Red; exit 1 }
if ($Mode -notin @('audit', 'dryrun', 'apply')) { Write-Host "[ERROR] -Mode must be audit|dryrun|apply (got '$Mode')" -ForegroundColor Red; exit 1 }

# --- Глифы через код-поинты (устойчивость к кодировке исходного .ps1) --------
# Не полагаемся на литеральные emoji в тексте скрипта: строим их из Unicode.
$script:G = @{
    Book  = [char]::ConvertFromUtf32(0x1F4DA)          # 📚
    Warn  = ([char]0x26A0) + ([char]0xFE0F)            # ⚠️
    Clock = [char]0x23F0                               # ⏰
    Link  = [char]::ConvertFromUtf32(0x1F517)          # 🔗
    Bolt  = [char]0x26A1                               # ⚡
}

# --- Пути (все относительные от корня репозитория) ---------------------------
$script:RepoRoot      = (Get-Location).Path
$script:MethodologyDir = 'references/methodology'
$script:DataFile      = 'data/critical_substances.json'
$script:CacheDir      = 'project/_temp/pubmed_cache'
$script:BackupDir     = 'project/_temp/migration_backups'
$script:ReportDir     = 'project/_temp/reformat_reports'
$script:Timestamp     = Get-Date -Format 'yyyy-MM-dd_HHmmss'
$script:DateStamp     = Get-Date -Format 'yyyy-MM-dd'
$script:Utf8Bom       = New-Object System.Text.UTF8Encoding($true)

foreach ($d in @($script:CacheDir, $script:BackupDir, $script:ReportDir)) {
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
}

# --- API-ключ и rate limit ---------------------------------------------------
if ($env:NCBI_API_KEY) {
    $script:ApiKeyParam  = "&api_key=$($env:NCBI_API_KEY)"
    $script:RateLimitMs  = 120                          # ~10 req/sec с ключом
    $script:ApiKeyStatus = 'NCBI API key detected (rate limit ~10 req/sec).'
} else {
    $script:ApiKeyParam  = ''
    $script:RateLimitMs  = 350                          # ~3 req/sec без ключа
    $script:ApiKeyStatus = 'WARNING: no NCBI_API_KEY. Public rate limit ~3 req/sec. Set $env:NCBI_API_KEY for speed.'
}

# --- Логирование -------------------------------------------------------------
function Write-Log {
    <#
    .SYNOPSIS
        Пишет строку в лог-файл и (по уровню) в консоль.
    #>
    param([string]$Message, [string]$Level = 'INFO')
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[$ts] [$Level] $Message"
    try { Add-Content -Path $script:LogFile -Value $line -Encoding UTF8 } catch { }
    switch ($Level) {
        'ERROR' { Write-Host $line -ForegroundColor Red }
        'WARN'  { Write-Host $line -ForegroundColor Yellow }
        'DEBUG' { if ($Verbose) { Write-Host $line -ForegroundColor DarkGray } }
        default { if ($Verbose) { Write-Host $line -ForegroundColor Gray } }
    }
}

# --- Ввод/вывод файлов (UTF-8 BOM, сохранение line endings) ------------------
function Read-FileRaw {
    <#
    .SYNOPSIS
        Читает файл как UTF-8 и определяет тип переводов строк (CRLF/LF).
    #>
    param([string]$Path)
    $full = $Path
    if (-not [System.IO.Path]::IsPathRooted($full)) { $full = Join-Path $script:RepoRoot $Path }
    $text = [System.IO.File]::ReadAllText($full, (New-Object System.Text.UTF8Encoding($false)))
    $eol = if ($text -match "`r`n") { "`r`n" } else { "`n" }
    return [PSCustomObject]@{ Text = $text; Eol = $eol; FullPath = $full }
}

function Write-FileRaw {
    <#
    .SYNOPSIS
        Пишет текст в файл как UTF-8 with BOM, нормализуя переводы строк.
    #>
    param([string]$Path, [string]$Content, [string]$Eol = "`r`n")
    $full = $Path
    if (-not [System.IO.Path]::IsPathRooted($full)) { $full = Join-Path $script:RepoRoot $Path }
    $normalized = ($Content -replace "`r`n", "`n") -replace "`n", $Eol
    [System.IO.File]::WriteAllText($full, $normalized, $script:Utf8Bom)
}

function Get-Sha256 {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return $null }
    return (Get-FileHash -Path $Path -Algorithm SHA256).Hash
}

# --- PubMed API-клиент с кэшем ----------------------------------------------
function Invoke-PubMedRequest {
    <#
    .SYNOPSIS
        HTTP GET к PubMed с retry + exponential backoff (429/500/503), timeout 30s.
    .OUTPUTS
        Строка (raw content) или $null при постоянной ошибке.
    #>
    param([string]$Url)
    $maxRetries = 3
    for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
        try {
            Start-Sleep -Milliseconds $script:RateLimitMs
            Write-Log "GET $Url" 'DEBUG'
            $resp = Invoke-WebRequest -Uri $Url -TimeoutSec 30 -UseBasicParsing -ErrorAction Stop
            return [string]$resp.Content
        } catch {
            $status = $null
            try { $status = [int]$_.Exception.Response.StatusCode } catch { }
            $delay = [int][Math]::Pow(2, $attempt - 1)     # 1s, 2s, 4s
            Write-Log ("PubMed request failed (attempt {0}/{1}, status {2}): {3}. Retry in {4}s" -f $attempt, $maxRetries, $status, $_.Exception.Message, $delay) 'WARN'
            if ($attempt -lt $maxRetries) { Start-Sleep -Seconds $delay }
        }
    }
    Write-Log "PubMed request failed permanently: $Url" 'ERROR'
    return $null
}

function Get-PubMedSummary {
    <#
    .SYNOPSIS
        Возвращает esummary-объект по PMID (из кэша или из API).
    #>
    param([string]$Pmid)
    $cacheFile = Join-Path $script:CacheDir ("{0}_esummary.json" -f $Pmid)
    $content = $null
    if ((Test-Path $cacheFile) -and (-not $NoCache)) {
        Write-Log "Cache hit esummary $Pmid" 'DEBUG'
        $content = [System.IO.File]::ReadAllText($cacheFile, (New-Object System.Text.UTF8Encoding($false)))
    } else {
        $url = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=$Pmid&retmode=json$script:ApiKeyParam"
        $content = Invoke-PubMedRequest $url
        if ($content) { [System.IO.File]::WriteAllText($cacheFile, $content, (New-Object System.Text.UTF8Encoding($false))) }
    }
    if (-not $content) { return $null }
    try { $json = $content | ConvertFrom-Json } catch { Write-Log "esummary parse error $Pmid" 'ERROR'; return $null }
    if (-not $json.result) { return $null }
    $rec = $json.result.$Pmid
    if (-not $rec -or ($rec.PSObject.Properties.Name -contains 'error')) { return $null }

    $year = ''
    if ($rec.pubdate -and ($rec.pubdate -match '(\d{4})')) { $year = $matches[1] }
    $pubtypes = @()
    if ($rec.pubtype) { $pubtypes = @($rec.pubtype) }
    $pmcId = $null
    if ($rec.articleids) {
        foreach ($aid in $rec.articleids) { if ($aid.idtype -eq 'pmc') { $pmcId = $aid.value } }
    }
    $authors = @()
    if ($rec.authors) { foreach ($a in $rec.authors) { $authors += $a.name } }

    return [PSCustomObject]@{
        Pmid        = $Pmid
        SortAuthor  = $rec.sortfirstauthor
        AuthorCount = $authors.Count
        Authors     = $authors
        Year        = $year
        Title       = [string]$rec.title
        Journal     = [string]$rec.source            # abbreviated
        JournalFull = [string]$rec.fulljournalname
        Volume      = [string]$rec.volume
        Issue       = [string]$rec.issue
        Pages       = [string]$rec.pages
        PubTypes    = $pubtypes
        PmcId       = $pmcId
    }
}

function Get-PubMedAbstract {
    <#
    .SYNOPSIS
        Возвращает текст абстракта по PMID (efetch, из кэша или API).
    #>
    param([string]$Pmid)
    $cacheFile = Join-Path $script:CacheDir ("{0}_efetch.xml" -f $Pmid)
    $content = $null
    if ((Test-Path $cacheFile) -and (-not $NoCache)) {
        Write-Log "Cache hit efetch $Pmid" 'DEBUG'
        $content = [System.IO.File]::ReadAllText($cacheFile, (New-Object System.Text.UTF8Encoding($false)))
    } else {
        $url = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=$Pmid&rettype=abstract&retmode=xml$script:ApiKeyParam"
        $content = Invoke-PubMedRequest $url
        if ($content) { [System.IO.File]::WriteAllText($cacheFile, $content, (New-Object System.Text.UTF8Encoding($false))) }
    }
    if (-not $content) { return '' }
    # Извлекаем текст всех <AbstractText> из XML (без строгого XML-парсинга).
    $sb = New-Object System.Text.StringBuilder
    foreach ($m in [regex]::Matches($content, '(?s)<AbstractText[^>]*>(.*?)</AbstractText>')) {
        [void]$sb.Append(($m.Groups[1].Value -replace '<[^>]+>', ' ')).Append(' ')
    }
    return $sb.ToString()
}

function Search-PubMed {
    <#
    .SYNOPSIS
        esearch по свободному запросу, возвращает список PMID (relevance).
    #>
    param([string]$Term, [int]$RetMax = 3)
    if (-not $script:SearchCache) { $script:SearchCache = @{} }
    if ($script:SearchCache.ContainsKey($Term)) { Write-Log "Cache hit esearch: $Term" 'DEBUG'; return $script:SearchCache[$Term] }
    $enc = [System.Uri]::EscapeDataString($Term)
    $url = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=$enc&retmax=$RetMax&sort=relevance&retmode=json$script:ApiKeyParam"
    $content = Invoke-PubMedRequest $url
    if (-not $content) { return @() }
    try { $json = $content | ConvertFrom-Json } catch { return @() }
    $ids = @()
    if ($json.esearchresult -and $json.esearchresult.idlist) { $ids = @($json.esearchresult.idlist) }
    $script:SearchCache[$Term] = $ids
    return $ids
}

# --- Классификаторы (Level / Outcome) ---------------------------------------
function Get-EBMLevel {
    <#
    .SYNOPSIS
        Определяет [Level, TYPE, blinding] по PublicationType и ключевым словам.
    #>
    param([string[]]$PubTypes, [string]$Title, [string]$Abstract)
    $pt = ($PubTypes -join ' | ').ToLower()
    $blob = ("$Title $Abstract").ToLower()

    # Guideline-детекция по нескольким источникам (v3.1 §12.4)
    $guideKeys = @('guideline', 'guidelines', 'consensus', 'recommendations', 'position statement', 'practice guideline')
    $isGuide = ($pt -match 'guideline|consensus development conference|practice guideline')
    if (-not $isGuide) {
        foreach ($k in $guideKeys) { if ($blob -match [regex]::Escape($k)) { $isGuide = $true; break } }
    }
    if ($isGuide) { return 'Level 5, guideline' }

    $blind = 'N/A'
    if ($blob -match 'double-blind|double blind') { $blind = 'double-blind' }
    elseif ($blob -match 'single-blind|single blind') { $blind = 'single-blind' }
    elseif ($blob -match 'open-label|open label') { $blind = 'open-label' }

    if ($pt -match 'meta-analysis') { return 'Level 1a, meta-analysis, N/A' }
    if ($pt -match 'systematic review') { return 'Level 1a, systematic review, N/A' }
    if ($pt -match 'randomized controlled trial') {
        if ($blind -eq 'double-blind') { return 'Level 1b, RCT, double-blind' }
        return "Level 1b, RCT, $blind"
    }
    if ($pt -match 'clinical trial') { return "Level 2b, clinical trial, $blind" }
    if ($pt -match 'cohort studies|cohort study') { return 'Level 2b, cohort, N/A' }
    if ($pt -match 'case-control') { return 'Level 3b, case-control, N/A' }
    if ($pt -match 'comparative study') { return 'Level 2c, comparative, N/A' }
    if ($pt -match 'case reports') { return 'Level 4, case series, N/A' }
    if ($pt -match 'review') { return 'Level 5, narrative review, N/A' }
    return 'Level 4, journal article, N/A'
}

function Get-EBMOutcome {
    <#
    .SYNOPSIS
        Эвристика типа исхода: hard / clinical / surrogate / recommendation.
    #>
    param([string]$Abstract, [string]$Level)
    if ($Level -match 'guideline') { return 'recommendation' }
    $a = $Abstract.ToLower()
    if ($a -match 'mortality|death|cancer|hospitali[sz]ation|stroke|myocardial infarction|fracture') { return 'hard' }
    if ($a -match 'symptom|quality of life|remission|pain|response rate|clinical improvement') { return 'clinical' }
    if ($a -match 'biomarker|serum level|hba1c|crp|microbiome diversity|antibod|cholesterol|glucose') { return 'surrogate' }
    return 'clinical'   # fallback, помечается [AUTO: verify] в отчёте
}

# --- Парсинг абстракта (population / dose / substance) -----------------------
function Get-PopulationString {
    <#
    .SYNOPSIS
        Извлекает описание популяции (n, follow-up) из абстракта. Без выдумок.
    #>
    param([string]$Abstract)
    if (-not $Abstract) { return 'n/a (n=n/a, follow-up=n/a)' }
    $n = 'n/a'
    if ($Abstract -match '(?i)\bn\s*=\s*(\d{1,7})') { $n = $matches[1] }
    elseif ($Abstract -match '(?i)(\d{1,6})\s+(patients|subjects|participants|adults|women|men|children)') { $n = $matches[1] }
    $follow = 'n/a'
    if ($Abstract -match '(?i)(\d{1,3}(?:\.\d+)?)\s*(weeks|months|years|days)\b') { $follow = "$($matches[1]) $($matches[2])" }
    $group = 'study population'
    if ($Abstract -match '(?i)\b(patients|adults|women|men|children|participants|subjects)\b') { $group = $matches[1] }
    return "$group (n=$n, follow-up=$follow)"
}

function Get-DoseString {
    <#
    .SYNOPSIS
        Пытается извлечь дозу/режим из абстракта. Пусто, если не найдено.
    #>
    param([string]$Abstract)
    if (-not $Abstract) { return '' }
    if ($Abstract -match '(?i)(\d[\d\.,\-\s]*)\s*(mg|mcg|\u00b5g|g|iu|ml)\b(\s*(once|twice|three times|daily|per day|bid|tid|weekly))?') {
        return ($matches[0] -replace '\s+', ' ').Trim()
    }
    return ''
}

# --- Safety / Currency -------------------------------------------------------
function Get-CriticalSubstances {
    <#
    .SYNOPSIS
        Загружает справочник критичных веществ из data/critical_substances.json.
    #>
    $path = Join-Path $script:RepoRoot $script:DataFile
    if (-not (Test-Path $path)) { Write-Log "critical_substances.json not found at $path" 'WARN'; return @{} }
    $raw = [System.IO.File]::ReadAllText($path, (New-Object System.Text.UTF8Encoding($false)))
    return ($raw | ConvertFrom-Json).substances
}

function Get-SafetyForText {
    <#
    .SYNOPSIS
        Возвращает Safety-текст, если в тексте блока найден триггер критичного вещества.
    #>
    param([string]$Text, $Substances)
    $low = $Text.ToLower()
    foreach ($key in $Substances.PSObject.Properties.Name) {
        $s = $Substances.$key
        foreach ($trig in $s.triggers) {
            if ($low -match ('\b' + [regex]::Escape($trig.ToLower()))) {
                return [PSCustomObject]@{ Substance = $s.label; Safety = $s.safety }
            }
        }
    }
    return $null
}

function Get-CurrencyForText {
    <#
    .SYNOPSIS
        Возвращает Currency-текст, если статья старше 10 лет и тема быстро развивается.
    #>
    param([int]$Year, [string]$Text)
    if ($Year -le 0) { return $null }
    $ageThresholdYear = (Get-Date).Year - 10
    if ($Year -gt $ageThresholdYear) { return $null }
    $fastKeys = @('microbiome', 'microbiota', 'probiotic', 'biologic', 'gene therapy', 'immunotherapy', 'monoclonal', 'checkpoint', 'car-t')
    $low = $Text.ToLower()
    foreach ($k in $fastKeys) {
        if ($low -match [regex]::Escape($k)) {
            return "Published $Year - verify with more recent sources ($k is a fast-moving field)."
        }
    }
    return $null
}

# --- Обнаружение EBM-блоков (три формата) -----------------------------------
function Get-EBMBlocks {
    <#
    .SYNOPSIS
        Обнаруживает и парсит все EBM-блоки в тексте (v1.1 inline, v2.1, v3.x).
    .OUTPUTS
        Массив объектов-блоков с полями Format, StartLine, Pmid, Author, Year, Journal.
    #>
    param([string]$Text)
    $lines = $Text -split "`r?`n"
    $blocks = @()
    $book = $script:G.Book
    $idx = 0

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]

        # Формат v3.0/v3.1: > 📚 **EBM** [Level ...]
        if ($line -match ([regex]::Escape($book) + '\s*\*\*EBM\*\*\s*\[Level')) {
            $start = $i
            $blockLines = @()
            while ($i -lt $lines.Count -and $lines[$i] -match '^\s*>') { $blockLines += $lines[$i]; $i++ }
            $i--
            $raw = $blockLines -join "`n"
            $pmid = ''
            if ($raw -match 'PMID:\s*\[?(\d{6,9})') { $pmid = $matches[1] }
            $author = ''; $year = 0
            foreach ($bl in $blockLines) {
                if ($bl -match '^\s*>\s*\*\*(.+?)\s+(\d{4})[a-z]?\.\*\*') { $author = $matches[1].Trim(); $year = [int]$matches[2]; break }
            }
            $journal = ''
            foreach ($bl in $blockLines) {
                # журнал в italic: *Journal* или _Journal_, за ним обычно том (цифра)
                if ($bl -match '^\s*>\s*[\*_]([^\*_]+)[\*_]\s*\d') { $journal = $matches[1].Trim(); break }
                if ($bl -match '^\s*>\s*[\*_]([^\*_]+)[\*_]') { $journal = $matches[1].Trim() }
            }
            $isV31 = ($raw -match '(?m)^\s*>\s*\*\*RU:')
            $fmt = if ($isV31) { 'v3.1' } else { 'v3.0' }
            $idx++
            $blocks += [PSCustomObject]@{
                Index = $idx; Format = $fmt
                StartLine = $start + 1; EndLine = $i + 1
                Pmid = $pmid; Author = $author; Year = $year; Journal = $journal
                Context = ''; Raw = $raw
            }
            continue
        }

        # Формат v2.1 короткий: > 📚 **EBM:** ...
        if ($line -match ([regex]::Escape($book) + '\s*\*\*EBM:\*\*')) {
            $pmid = ''
            if ($line -match 'PMID:\s*\[?(\d{6,9})') { $pmid = $matches[1] }
            $author = ''; $year = 0
            if ($line -match 'EBM:\*\*\s*([^\.]+?)\.\s') { $author = $matches[1].Trim() }
            if ($line -match '(\d{4})') { $year = [int]$matches[1] }
            $idx++
            $blocks += [PSCustomObject]@{
                Index = $idx; Format = 'v2.1'
                StartLine = $i + 1; EndLine = $i + 1
                Pmid = $pmid; Author = $author; Year = $year; Journal = ''
                Context = ''; Raw = $line
            }
            continue
        }
    }

    # Формат v1.1 inline: [EBM: Author Year context]  (по всему тексту)
    foreach ($m in [regex]::Matches($Text, '\[EBM:\s*([^\]]+)\]')) {
        $inner = $m.Groups[1].Value.Trim()
        $author = ''; $year = 0; $context = $inner
        if ($inner -match '^(.+?)\s+(\d{4})\b(.*)$') {
            $author = $matches[1].Trim(); $year = [int]$matches[2]; $context = $matches[3].Trim()
        }
        # номер строки для inline-тега
        $before = $Text.Substring(0, $m.Index)
        $lineNo = ([regex]::Matches($before, "`n")).Count + 1
        $idx++
        $blocks += [PSCustomObject]@{
            Index = $idx; Format = 'v1.1'
            StartLine = $lineNo; EndLine = $lineNo
            Pmid = ''; Author = $author; Year = $year; Journal = ''
            Context = $context; Raw = $m.Value
        }
    }

    return $blocks
}

# --- Валидация PMID против PubMed --------------------------------------------
function Normalize-Text {
    param([string]$S)
    if (-not $S) { return '' }
    return (($S.ToLower()) -replace '[^a-z0-9]', '')
}

function Test-PMID {
    <#
    .SYNOPSIS
        Сверяет автора/год/журнал блока с данными PubMed. Возвращает вердикт.
    #>
    param($Block, $Summary)
    if (-not $Summary) {
        return [PSCustomObject]@{ Pmid = $Block.Pmid; Verdict = 'NOT_FOUND'; Detail = 'esummary returned no data' }
    }
    $pubSurname = ''
    if ($Summary.SortAuthor) { $pubSurname = (($Summary.SortAuthor -split '\s+') | Where-Object { $_ -match '\p{L}' } | Select-Object -First 1) }
    $blockSurname = ''
    if ($Block.Author) { $blockSurname = (($Block.Author -split '[\s,]+') | Where-Object { $_ -match '\p{L}' } | Select-Object -First 1) }

    $authorMatch = ($blockSurname -and (Normalize-Text $blockSurname) -eq (Normalize-Text $pubSurname))
    $yearMatch = ($Block.Year -gt 0 -and [string]$Block.Year -eq [string]$Summary.Year)

    $jb = Normalize-Text $Block.Journal
    $js = Normalize-Text $Summary.Journal
    $jf = Normalize-Text $Summary.JournalFull
    $journalMatch = ($jb -and ($jb -eq $js -or $jb -eq $jf -or ($js -and $jb.Contains($js)) -or ($jf -and $jf.Contains($jb)) -or ($jb -and $js -and $js.Contains($jb))))

    $detail = "author[$blockSurname~$pubSurname]=$authorMatch year[$($Block.Year)~$($Summary.Year)]=$yearMatch journal=$journalMatch"
    $verdict = 'MATCH'
    if (-not $authorMatch -or -not $yearMatch) { $verdict = 'MISMATCH' }
    elseif (-not $journalMatch -and $Block.Journal) { $verdict = 'MATCH_JOURNAL_DIFF' }
    return [PSCustomObject]@{
        Pmid = $Block.Pmid; Verdict = $verdict; Detail = $detail
        PubAuthor = $pubSurname; PubYear = $Summary.Year; PubJournal = $Summary.JournalFull
        AuthorMatch = $authorMatch; YearMatch = $yearMatch; JournalMatch = $journalMatch
    }
}

# --- Форматирование v3.1-блока ----------------------------------------------
function Format-EBMv31Block {
    <#
    .SYNOPSIS
        Строит EBM-блок v3.1 из данных PubMed. Отсутствующее -> n/a (без выдумок).
    #>
    param($Summary, [string]$Level, [string]$Outcome, [string]$Dose, [string]$Population, [string]$Context, $Safety, $Currency)
    $book = $script:G.Book
    $surname = ''
    if ($Summary.SortAuthor) { $surname = $Summary.SortAuthor }
    $etal = if ($Summary.AuthorCount -gt 1) { ', et al.' } else { '.' }
    $year = if ($Summary.Year) { $Summary.Year } else { 'YYYY' }

    # Строка эффекта: для интервенционных работ доза+эффект, иначе findings.
    $effect = ''
    if ($Dose) { $effect = "$Dose. " }
    if ($Context) { $effect += $Context } else { $effect += ($Summary.Title -replace '\s+$', '') }

    $bib = "*$($Summary.JournalFull)*"
    if ($Summary.Volume) {
        $bib += " $($Summary.Volume)"
        if ($Summary.Issue) { $bib += "($($Summary.Issue))" }
        if ($Summary.Pages) { $bib += ":$($Summary.Pages)" }
    }
    $bib += "."

    $lines = @()
    $lines += "> $book **EBM** [$Level] [$Outcome]"
    $lines += "> **$surname$etal $year.** $effect"
    $lines += "> **Population:** $Population"
    $lines += "> $bib PMID: [$($Summary.Pmid)](https://pubmed.ncbi.nlm.nih.gov/$($Summary.Pmid))"
    if ($Safety)   { $lines += "> $($script:G.Warn) **Safety:** $($Safety.Safety)" }
    if ($Currency) { $lines += "> $($script:G.Clock) **Currency:** $Currency" }
    return ($lines -join "`n")
}

# --- Оркестратор миграции (dryrun/apply) ------------------------------------
function Invoke-Migration {
    <#
    .SYNOPSIS
        Строит план миграции для legacy-блоков (v1.1/v2.1) -> v3.1.
        В dryrun только план; запись выполняется вызывающим кодом при apply.
    #>
    param($Blocks, $Substances)
    $plan = @()
    $legacy = @($Blocks | Where-Object { $_.Format -eq 'v1.1' -or $_.Format -eq 'v2.1' })
    foreach ($b in $legacy) {
        $pmid = $b.Pmid
        $source = 'existing PMID'
        $legacySurname = ''
        if ($b.Author) { $legacySurname = (($b.Author -split '[\s,/]+') | Where-Object { $_ -match '\p{L}' } | Select-Object -First 1) }

        if (-not $pmid) {
            # v1.1 без PMID -> esearch по автору[Author] + году[dp].
            # Контекстные слова НЕ добавляем в запрос: аббревиатуры/названия журналов
            # (напр. "ATA") сужают поиск до нуля. Точность обеспечивает валидационный шлюз ниже.
            $ctxWords = @(($b.Context -split '\s+') | Where-Object { $_ -match '^\p{L}{3,}$' } | Select-Object -First 3)
            $isOrg = ($b.Author -match '/' -or ($b.Author -cmatch '^[A-Z/]+$'))
            if ($isOrg) {
                $term = ("{0} {1} {2}" -f $b.Author, ($ctxWords -join ' '), $b.Year).Trim()
            } else {
                $term = "$legacySurname[Author] AND $($b.Year)[dp]"
            }
            Write-Log "esearch legacy tag: $term" 'DEBUG'
            $ids = @(Search-PubMed -Term $term -RetMax 1)
            if ($ids.Count -gt 0) { $pmid = $ids[0]; $source = "esearch candidate (AUTO: verify)" }
        }
        if (-not $pmid) {
            $plan += [PSCustomObject]@{ Block = $b; Pmid = ''; Verdict = 'MANUAL'; NewBlock = ''; Source = 'no candidate found' }
            continue
        }
        $sum = Get-PubMedSummary -Pmid $pmid
        if (-not $sum) {
            $plan += [PSCustomObject]@{ Block = $b; Pmid = $pmid; Verdict = 'MANUAL'; NewBlock = ''; Source = 'esummary failed' }
            continue
        }

        # Валидационный шлюз для AUTO-кандидатов: не выдумываем.
        # Кандидат принимается, только если совпадает автор ИЛИ год legacy-тега.
        if ($source -match 'AUTO') {
            $candSurname = ''
            if ($sum.SortAuthor) { $candSurname = (($sum.SortAuthor -split '\s+') | Where-Object { $_ -match '\p{L}' } | Select-Object -First 1) }
            $authOk = ($legacySurname -and (Normalize-Text $legacySurname) -eq (Normalize-Text $candSurname))
            $yearOk = ($b.Year -gt 0 -and [string]$b.Year -eq [string]$sum.Year)
            if (-not ($authOk -or $yearOk)) {
                $plan += [PSCustomObject]@{ Block = $b; Pmid = $pmid; Verdict = 'MANUAL'; NewBlock = ''; Source = "rejected candidate PMID $pmid (author '$candSurname' year $($sum.Year) != legacy '$legacySurname' $($b.Year))" }
                continue
            }
        }

        $abstract = Get-PubMedAbstract -Pmid $pmid
        $level = Get-EBMLevel -PubTypes $sum.PubTypes -Title $sum.Title -Abstract $abstract
        $outcome = Get-EBMOutcome -Abstract $abstract -Level $level
        $dose = Get-DoseString -Abstract $abstract
        $pop = Get-PopulationString -Abstract $abstract
        $context = if ($b.Context) { $b.Context } else { '' }
        $safety = Get-SafetyForText -Text ("$($b.Context) $($sum.Title) $abstract") -Substances $Substances
        $currency = Get-CurrencyForText -Year ([int]$sum.Year) -Text ("$($sum.Title) $abstract")
        $newBlock = Format-EBMv31Block -Summary $sum -Level $level -Outcome $outcome -Dose $dose -Population $pop -Context $context -Safety $safety -Currency $currency
        $plan += [PSCustomObject]@{ Block = $b; Pmid = $pmid; Verdict = 'PLANNED'; NewBlock = $newBlock; Source = $source; Safety = $safety; Currency = $currency }
    }
    return $plan
}

# --- Генерация отчёта --------------------------------------------------------
function Write-Report {
    <#
    .SYNOPSIS
        Пишет markdown-отчёт о прогоне в project/_temp/reformat_reports/.
    #>
    param([string]$FileName, [string]$RunMode, $Blocks, $Validations, $Plan, [string]$FileStatus, [int]$UniquePmids, $Anomalies, [string]$ReportPath)
    $book = $script:G.Book
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("# EBM reformat report - $FileName")
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine("- File: ``$FileName``")
    [void]$sb.AppendLine("- Mode: **$RunMode**")
    [void]$sb.AppendLine("- Date: $($script:Timestamp)")
    [void]$sb.AppendLine("- File EBM status (header): $FileStatus")
    [void]$sb.AppendLine("- Standard: EBM v3.1")
    [void]$sb.AppendLine('')

    # Summary
    $byFormat = $Blocks | Group-Object Format | ForEach-Object { "$($_.Name)=$($_.Count)" }
    [void]$sb.AppendLine('## Summary')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine("- Blocks detected: **$($Blocks.Count)**")
    [void]$sb.AppendLine("- Formats: $([string]::Join(', ', $byFormat))")
    [void]$sb.AppendLine("- Unique PMIDs: **$UniquePmids**")
    if ($Validations) {
        $ok = @($Validations | Where-Object { $_.Verdict -eq 'MATCH' -or $_.Verdict -eq 'MATCH_JOURNAL_DIFF' }).Count
        $bad = @($Validations | Where-Object { $_.Verdict -eq 'MISMATCH' -or $_.Verdict -eq 'NOT_FOUND' }).Count
        [void]$sb.AppendLine("- PMID validation: **$ok MATCH**, **$bad MISMATCH/NOT_FOUND**")
    }
    [void]$sb.AppendLine('')

    # Per-block table
    [void]$sb.AppendLine('## Per-block')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('| # | Line | Format | PMID | Author | Year | Verdict |')
    [void]$sb.AppendLine('|---|------|--------|------|--------|------|---------|')
    foreach ($b in $Blocks) {
        $v = 'OK'
        if ($b.Format -eq 'v1.1') { $v = 'NEEDS_UPDATE (legacy inline)' }
        elseif ($b.Format -eq 'v2.1') { $v = 'NEEDS_UPDATE (v2.1 short)' }
        elseif (-not $b.Pmid) { $v = 'NO_PMID' }
        else {
            $val = $Validations | Where-Object { $_.Pmid -eq $b.Pmid } | Select-Object -First 1
            if ($val) { $v = $val.Verdict }
        }
        $auth = ($b.Author -replace '\|', '/')
        [void]$sb.AppendLine("| $($b.Index) | $($b.StartLine) | $($b.Format) | $($b.Pmid) | $auth | $($b.Year) | $v |")
    }
    [void]$sb.AppendLine('')

    # PMID validation detail
    if ($Validations -and $Validations.Count -gt 0) {
        [void]$sb.AppendLine('## PMID validation')
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine('| PMID | Verdict | PubMed author | PubMed year | Detail |')
        [void]$sb.AppendLine('|------|---------|---------------|-------------|--------|')
        foreach ($val in $Validations) {
            [void]$sb.AppendLine("| $($val.Pmid) | $($val.Verdict) | $($val.PubAuthor) | $($val.PubYear) | $($val.Detail) |")
        }
        [void]$sb.AppendLine('')
    }

    # Migration plan (dryrun/apply)
    if ($Plan -and $Plan.Count -gt 0) {
        [void]$sb.AppendLine('## Migration plan')
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine('| # | Line | Old format | Candidate PMID | Source | Verdict |')
        [void]$sb.AppendLine('|---|------|-----------|----------------|--------|---------|')
        foreach ($p in $Plan) {
            [void]$sb.AppendLine("| $($p.Block.Index) | $($p.Block.StartLine) | $($p.Block.Format) | $($p.Pmid) | $($p.Source) | $($p.Verdict) |")
        }
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine('### Proposed v3.1 blocks')
        [void]$sb.AppendLine('')
        foreach ($p in $Plan) {
            if ($p.NewBlock) {
                [void]$sb.AppendLine("**Block #$($p.Block.Index) (line $($p.Block.StartLine)), old: ``$($p.Block.Raw -replace '\|','/')``**")
                [void]$sb.AppendLine('')
                [void]$sb.AppendLine('```markdown')
                [void]$sb.AppendLine($p.NewBlock)
                [void]$sb.AppendLine('```')
                [void]$sb.AppendLine('')
            }
        }
    }

    # Anomalies
    [void]$sb.AppendLine('## Anomalies / manual review required')
    [void]$sb.AppendLine('')
    if ($Anomalies -and $Anomalies.Count -gt 0) {
        foreach ($a in $Anomalies) { [void]$sb.AppendLine("- $a") }
    } else {
        [void]$sb.AppendLine('- none')
    }
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine("EBM_REFORMAT_${RunMode}_v1_APPLIED")

    Write-FileRaw -Path $ReportPath -Content ($sb.ToString()) -Eol "`r`n"
}

# =============================================================================
# MAIN
# =============================================================================
function Resolve-TargetFile {
    param([string]$Name)
    if ([System.IO.Path]::IsPathRooted($Name) -and (Test-Path $Name)) { return $Name }
    $candidate = Join-Path (Join-Path $script:RepoRoot $script:MethodologyDir) $Name
    if (Test-Path $candidate) { return $candidate }
    $candidate2 = Join-Path $script:RepoRoot $Name
    if (Test-Path $candidate2) { return $candidate2 }
    return $null
}

$baseName = [System.IO.Path]::GetFileNameWithoutExtension($File)
$script:LogFile = Join-Path $script:ReportDir ("{0}_{1}_{2}.log" -f $baseName, $Mode, $script:Timestamp)
$reportPath = Join-Path $script:ReportDir ("{0}_{1}_{2}.md" -f $baseName, $Mode, $script:Timestamp)

Write-Host "=== EBM Reformat v1.0 :: $($Mode.ToUpper()) ===" -ForegroundColor Cyan
Write-Host "[INFO] $($script:ApiKeyStatus)"
Write-Log "Run start: File=$File Mode=$Mode Backup=$Backup NoCache=$NoCache" 'INFO'

$target = Resolve-TargetFile -Name $File
if (-not $target) {
    Write-Log "File not found: $File (looked in $script:MethodologyDir and repo root)" 'ERROR'
    exit 1
}
Write-Host "[INFO] Target: $target"

$fileData = Read-FileRaw -Path $target
$text = $fileData.Text

# Статус файла из шапки
$fileStatus = 'UNKNOWN'
if ($text -match '(?m)EBM Status:\s*(\S+)') { $fileStatus = $matches[1] }
elseif ($text -match 'MIGRATED_v3\.\d') { $fileStatus = 'MIGRATED_v3.x' }

# Обнаружение блоков
$blocks = @(Get-EBMBlocks -Text $text)
Write-Host "[INFO] EBM blocks detected: $($blocks.Count)"
Write-Log "Blocks detected: $($blocks.Count)" 'INFO'

$substances = Get-CriticalSubstances

# Уникальные PMID
$uniquePmids = @($blocks | Where-Object { $_.Pmid } | ForEach-Object { $_.Pmid } | Sort-Object -Unique)
Write-Host "[INFO] Unique PMIDs: $($uniquePmids.Count)"

$anomalies = @()
if ($blocks.Count -eq 0) {
    $anomalies += "NO_EBM: no EBM blocks found. Use the enrich workflow (ebm_engine.ps1 -Mode enrich) to add tags from scratch. Logged for TECH_DEBT (v1.1 --enrich mode)."
}

# --- Валидация PMID (для всех блоков с PMID) ---
$validations = @()
if ($uniquePmids.Count -gt 0) {
    Write-Host "[INFO] Validating $($uniquePmids.Count) PMIDs against PubMed..."
    foreach ($pmid in $uniquePmids) {
        $sum = Get-PubMedSummary -Pmid $pmid
        $refBlock = $blocks | Where-Object { $_.Pmid -eq $pmid } | Select-Object -First 1
        $val = Test-PMID -Block $refBlock -Summary $sum
        $validations += $val
        Write-Log "PMID $pmid -> $($val.Verdict) :: $($val.Detail)" 'INFO'
        if ($val.Verdict -eq 'MISMATCH') { $anomalies += "PMID $pmid MISMATCH: $($val.Detail)" }
        if ($val.Verdict -eq 'NOT_FOUND') { $anomalies += "PMID $pmid NOT_FOUND in PubMed" }
    }
}

# --- Плейн миграции (dryrun/apply) ---
$plan = @()
$legacyCount = @($blocks | Where-Object { $_.Format -eq 'v1.1' -or $_.Format -eq 'v2.1' }).Count
if (($Mode -eq 'dryrun' -or $Mode -eq 'apply') -and $legacyCount -gt 0) {
    Write-Host "[INFO] Building migration plan for $legacyCount legacy block(s)..."
    $plan = @(Invoke-Migration -Blocks $blocks -Substances $substances)
    foreach ($p in $plan) {
        if ($p.Verdict -eq 'MANUAL') { $anomalies += "Block #$($p.Block.Index) (line $($p.Block.StartLine)): MANUAL - $($p.Source)" }
        if ($p.Source -match 'AUTO') { $anomalies += "Block #$($p.Block.Index): candidate PMID $($p.Pmid) from esearch - [AUTO: verify]" }
    }
}

# --- Safety-подсказки для audit (информационно) ---
foreach ($b in ($blocks | Where-Object { $_.Format -eq 'v3.0' -or $_.Format -eq 'v3.1' })) {
    $s = Get-SafetyForText -Text $b.Raw -Substances $substances
    if ($s -and ($b.Raw -notmatch [regex]::Escape($script:G.Warn))) {
        $anomalies += "Block #$($b.Index) mentions '$($s.Substance)' but has no Safety line - review."
    }
}

# --- APPLY: транзакционная запись (Read -> Apply -> Validate -> Write) -------
if ($Mode -eq 'apply') {
    if ($legacyCount -eq 0) {
        Write-Host "[INFO] No legacy blocks to migrate. File is already v3.x. Idempotent: 0 changes." -ForegroundColor Green
        Write-Log "APPLY: idempotent, 0 legacy blocks." 'INFO'
    } else {
        # Бэкап (обязателен для apply)
        $backupPath = Join-Path $script:BackupDir ("{0}_pre-migration_{1}.md" -f $baseName, $script:DateStamp)
        Copy-Item -Path $target -Destination $backupPath -Force
        $srcHash = Get-Sha256 $target
        $bkHash = Get-Sha256 $backupPath
        if ($srcHash -ne $bkHash) { Write-Log "Backup SHA256 mismatch! Aborting." 'ERROR'; exit 2 }
        Write-Log "Backup OK ($backupPath), SHA256=$srcHash" 'INFO'

        # === APPLY (in-memory) ===
        $newText = $text
        $applied = 0
        foreach ($p in $plan) {
            if ($p.Verdict -eq 'PLANNED' -and $p.NewBlock) {
                $newText = $newText.Replace($p.Block.Raw, $p.NewBlock)
                $applied++
            }
        }
        # === VALIDATE ===
        $validationPassed = $true
        $newBlocksCheck = @(Get-EBMBlocks -Text $newText)
        $remainingLegacy = @($newBlocksCheck | Where-Object { $_.Format -eq 'v1.1' -or $_.Format -eq 'v2.1' }).Count
        if ($applied -eq 0) { $validationPassed = $false; Write-Log "VALIDATE: nothing applied." 'ERROR' }
        # === WRITE ===
        if ($validationPassed) {
            Write-FileRaw -Path $target -Content $newText -Eol $fileData.Eol
            Write-Host "[OK] Applied $applied block(s). Remaining legacy: $remainingLegacy." -ForegroundColor Green
            Write-Log "WRITE OK: applied=$applied remainingLegacy=$remainingLegacy" 'INFO'
        } else {
            Write-Host "[ABORT] Validation failed, file NOT written. Backup intact." -ForegroundColor Red
            Write-Log "WRITE skipped: validation failed." 'ERROR'
        }
    }
}

# --- Отчёт ---
Write-Report -FileName ([System.IO.Path]::GetFileName($target)) -RunMode $Mode -Blocks $blocks -Validations $validations -Plan $plan -FileStatus $fileStatus -UniquePmids $uniquePmids.Count -Anomalies $anomalies -ReportPath $reportPath

Write-Host ''
Write-Host "[DONE] Report: $reportPath" -ForegroundColor Cyan
Write-Host "[DONE] Log:    $($script:LogFile)" -ForegroundColor Cyan
Write-Log "Run complete." 'INFO'
