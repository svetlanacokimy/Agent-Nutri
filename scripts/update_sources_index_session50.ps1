# ============================================================================
# scripts/update_sources_index_session50.ps1
# Добавляет секцию "EBM-обогащение методичек" в v2/SOURCES_INDEX.md
# Идемпотентный: маркер <!-- SOURCES_INDEX_EBM_APPLIED_v50 -->
# ============================================================================

$ErrorActionPreference = "Stop"
$repoRoot = "C:\Users\ЗС\Agent-Nutri"
Set-Location $repoRoot

$path = Join-Path $repoRoot "v2\SOURCES_INDEX.md"
$marker = "<!-- SOURCES_INDEX_EBM_APPLIED_v50 -->"
$bt = [char]96  # backtick для безопасной вставки

Write-Host "=== update_sources_index_session50.ps1 ===" -ForegroundColor Cyan
Write-Host "Файл: $path"

if (-not (Test-Path $path)) {
    Write-Host "ОШИБКА: файл не найден" -ForegroundColor Red
    exit 1
}

# --- 1. Читаем ---
$content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
$origLen = $content.Length
Write-Host "Прочитано: $origLen символов"

# --- 2. Идемпотентность ---
if ($content.Contains($marker)) {
    Write-Host "SKIP: маркер $marker уже присутствует." -ForegroundColor Yellow
    exit 0
}

# --- 3. Backup ---
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = "$path.bak.$timestamp"
Copy-Item $path $backupPath -Force
Write-Host "Backup: $backupPath" -ForegroundColor Green

# --- 4. LF ---
$content = $content -replace "`r`n", "`n"

# --- 5. Новая секция: якорь — заголовок "Темы, которых нет в базе" ---
$anchor = "## Темы, которых нет в базе (требуют досдачи или относятся к Категории B/C)"

if (-not $content.Contains($anchor)) {
    Write-Host "ОШИБКА: якорь не найден: $anchor" -ForegroundColor Red
    exit 1
}

# Собираем новую секцию через $bt (без литеральных backtick)
$newSection = @"
## EBM-обогащение методичек (стандарт доказательной медицины)

**Спецификация:** ${bt}project/EBM_STANDARD.md${bt} v1.0 (2026-07-31, Session 50) — единый стандарт EBM-обогащения: состояния файлов (NO_EBM / PARTIAL_EBM / FULL_EBM), формат inline-тегов ${bt}[EBM: Author Year]${bt}, обязательные структурные элементы (EBM Benchmark §, idempotency marker ${bt}<!-- EBM_ENRICHED_v1.1 -->${bt}, метаданные v2.0), целевые метрики (≥30 тегов, ≥8 «школа vs EBM» расхождений, ≥15 источников), pre-commit чек-лист.

**Аудит-инструмент:** ${bt}scripts/audit_ebm_compliance.ps1${bt} — прогон по всем 53 контентным файлам ${bt}references/methodology/*.md${bt} по 15 критериям стандарта. Выводит карту состояний + сводную статистику (тегов, строк, файлов).

**Текущая карта состояний (2026-07-31, Session 50):**

- **FULL_EBM — 4 файла (7.5 %):** ${bt}autoimmune_basics.md${bt}, ${bt}minerals.md${bt}, ${bt}nutraceuticals.md${bt}, ${bt}thyroid_health.md${bt}.
- **PARTIAL_EBM — 9 файлов (17 %):** ${bt}covid_pregnancy.md${bt}, ${bt}female_hormones.md${bt}, ${bt}gallbladder_health.md${bt}, ${bt}hashimoto.md${bt}, ${bt}joints_osteoporosis.md${bt}, ${bt}nervous_system.md${bt}, ${bt}pancreas_health.md${bt}, ${bt}stress_adrenals.md${bt}, ${bt}vitamins.md${bt}.
- **NO_EBM — 40 файлов (75.5 %):** в основном методологические и клиентские файлы, где EBM в форме RCT неприменима (интервью с клиентом, мотивационное интервью, этика, шаблоны меню, антипаразитарные протоколы без RCT-базы).
- **Всего:** 435 EBM-тегов, 37 373 строки методологии.

**Плановые скрипты Этапа F (обогащение PARTIAL → FULL):**

- ${bt}scripts/ebm_enrich_nutraceuticals.ps1${bt} ✅ (Session 50, 74 тега).
- ${bt}scripts/ebm_enrich_joints_osteoporosis.ps1${bt} ⏳ (Session 51).
- ${bt}scripts/ebm_enrich_hashimoto.ps1${bt} ⏳ (Session 52).
- ${bt}scripts/ebm_enrich_vitamins.ps1${bt} ⏳ (Session 53).
- Остальные 5 PARTIAL — по мере готовности.

**Приоритет для агента при цитировании:** файлы FULL_EBM > PARTIAL_EBM > NO_EBM. При выборе источника рекомендации указывать EBM-тег дословно (например, ${bt}[EBM: Manson 2019 VITAL]${bt}) и уровень доказательности (OCEBM 1–5).

---

$anchor
"@

# --- 6. Вставляем секцию перед якорем + маркер в конец файла ---
$content = $content.Replace($anchor, $newSection)
$content = $content.TrimEnd() + "`n`n$marker`n"

Write-Host "✓ Секция 'EBM-обогащение методичек' добавлена перед 'Темы, которых нет в базе'" -ForegroundColor Green
Write-Host "✓ Маркер добавлен: $marker" -ForegroundColor Green

# --- 7. CRLF + BOM ---
$content = $content -replace "`n", "`r`n"
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($path, $content, $utf8Bom)

# --- 8. Валидация ---
$newLen = $content.Length
$newLines = ($content -split "`r`n").Count
$bytes = [System.IO.File]::ReadAllBytes($path)
$hasBom = $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
$hasMarker = $content.Contains($marker)
$hasStandard = $content.Contains("EBM_STANDARD.md")
$hasAudit = $content.Contains("audit_ebm_compliance.ps1")
$hasFullList = $content.Contains("FULL_EBM — 4")
$hasPartialList = $content.Contains("PARTIAL_EBM — 9")

Write-Host ""
Write-Host "=== ВАЛИДАЦИЯ ===" -ForegroundColor Cyan
Write-Host "Длина: $origLen → $newLen (Δ $($newLen - $origLen))"
Write-Host "Строк: $newLines"
Write-Host "UTF-8 BOM: $hasBom" -ForegroundColor $(if ($hasBom) { "Green" } else { "Red" })
Write-Host "Маркер: $hasMarker" -ForegroundColor $(if ($hasMarker) { "Green" } else { "Red" })
Write-Host "EBM_STANDARD.md упомянут: $hasStandard" -ForegroundColor $(if ($hasStandard) { "Green" } else { "Red" })
Write-Host "audit_ebm_compliance.ps1 упомянут: $hasAudit" -ForegroundColor $(if ($hasAudit) { "Green" } else { "Red" })
Write-Host "FULL_EBM список: $hasFullList" -ForegroundColor $(if ($hasFullList) { "Green" } else { "Red" })
Write-Host "PARTIAL_EBM список: $hasPartialList" -ForegroundColor $(if ($hasPartialList) { "Green" } else { "Red" })

Write-Host ""
Write-Host "=== ГОТОВО ===" -ForegroundColor Cyan
Write-Host "Backup: $backupPath"
Write-Host "Проверка: git --no-pager diff --stat v2/SOURCES_INDEX.md"
