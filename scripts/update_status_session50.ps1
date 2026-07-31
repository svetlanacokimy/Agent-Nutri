# ============================================================================
# scripts/update_status_session50.ps1  (v2 — backtick-safe)
# Обновляет project/STATUS.md: Sessions 49-50, Этап F.1
# Идемпотентный: маркер <!-- STATUS_SESSION50_APPLIED -->
# ============================================================================

$ErrorActionPreference = "Stop"
$repoRoot = "C:\Users\ЗС\Agent-Nutri"
Set-Location $repoRoot

$statusPath = Join-Path $repoRoot "project\STATUS.md"
$marker = "<!-- STATUS_SESSION50_APPLIED -->"
$prevMarker = "<!-- STATUS_SESSION48_APPLIED -->"
$bt = [char]96  # backtick для безопасной вставки в here-strings

Write-Host "=== update_status_session50.ps1 (v2) ===" -ForegroundColor Cyan
Write-Host "Файл: $statusPath"

if (-not (Test-Path $statusPath)) {
    Write-Host "ОШИБКА: файл не найден" -ForegroundColor Red
    exit 1
}

# --- 1. Читаем файл ---
$content = [System.IO.File]::ReadAllText($statusPath, [System.Text.Encoding]::UTF8)
$origLen = $content.Length
Write-Host "Прочитано: $origLen символов"

# --- 2. Проверка идемпотентности ---
if ($content.Contains($marker)) {
    Write-Host "SKIP: маркер $marker уже присутствует." -ForegroundColor Yellow
    exit 0
}

# --- 3. Backup ---
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = "$statusPath.bak.$timestamp"
Copy-Item $statusPath $backupPath -Force
Write-Host "Backup: $backupPath" -ForegroundColor Green

# --- 4. Нормализация к LF ---
$content = $content -replace "`r`n", "`n"

# --- 5. БЛОК 1: "Текущее состояние" ---
# Строим искомый текст ЧЕРЕЗ ПЕРЕМЕННУЮ $bt (без литеральных backtick в here-string)
$oldHeader1 = "## 📌 Текущее состояние (на 2026-07-27)`n`n" +
              "**Ветка:** ${bt}copilot/build-v2-nutrition-agent-core${bt}`n" +
              "**Последнее событие:** Миграция базы знаний — Этап B2/B3 (создание 8 методичек + синхронизация реестров ${bt}SOURCES_INDEX.md${bt} и ${bt}_clusters.md${bt})."

$newHeader1 = "## 📌 Текущее состояние (на 2026-07-31)`n`n" +
              "**Ветка:** ${bt}main${bt} (ветка ${bt}copilot/build-v2-nutrition-agent-core${bt} замёржена через PR #2 и удалена в Session 49).`n" +
              "**Последнее событие:** Этап F.1 — EBM-обогащение ${bt}nutraceuticals.md${bt} (0 → 74 EBM-тега, §13 EBM Benchmark). Создана спецификация ${bt}project/EBM_STANDARD.md${bt} v1.0 и аудит-инструмент ${bt}scripts/audit_ebm_compliance.ps1${bt}."

if (-not $content.Contains($oldHeader1)) {
    Write-Host "ДИАГНОСТИКА: блок 'Текущее состояние' не найден дословно." -ForegroundColor Red
    Write-Host "Первые 500 символов файла (для сверки):" -ForegroundColor Yellow
    Write-Host $content.Substring(0, [Math]::Min(500, $content.Length))
    Write-Host ""
    Write-Host "Первые 500 символов искомой строки:" -ForegroundColor Yellow
    Write-Host $oldHeader1.Substring(0, [Math]::Min(500, $oldHeader1.Length))
    exit 1
}
$content = $content.Replace($oldHeader1, $newHeader1)
Write-Host "✓ Блок 1 (Текущее состояние) обновлён" -ForegroundColor Green

# --- 6. БЛОК 2: "Последняя сессия" ---
$pattern2 = '(?s)## 🔄 Последняя сессия — 2026-07-27.*?(?=\n---\n\n## ➡️)'

$newBlock2 = @"
## 🔄 Последняя сессия — 2026-07-31 (Session 50, Этап F.1)

**Тема:** Старт Этапа F — EBM-обогащение ${bt}nutraceuticals.md${bt} + создание единой спецификации EBM-стандарта и инструмента аудита.

**Сделано:**

- **${bt}references/methodology/nutraceuticals.md${bt}**: 551 → 655 строк, 63 → 78 KB, **74 EBM-тега** (было 0). Добавлен §13 EBM Benchmark (4 подраздела: гайдлайны, RCT/мета-анализы, «школа vs EBM» на 8+ расхождений, красные зоны). Inline-теги в §3 (Родиола [EBM: Panossian 2010; Ishaque 2012 Cochrane], Мака [EBM: Gonzales 2014], Нони [EBM: West 2018]) и других секциях. Idempotency marker ${bt}<!-- EBM_ENRICHED_v1.1 -->${bt}. Backup: ${bt}nutraceuticals.md.bak.20260731-184520${bt}. Коммит ${bt}66d1a15${bt} (+542/−50).

- **${bt}scripts/ebm_enrich_nutraceuticals.ps1${bt}** (26 987 байт, UTF-8 BOM): идемпотентный EBM-lite enrichment по стандарту Sessions 40–47. 14 патчей применено, 6 SKIP.

- **${bt}project/EBM_STANDARD.md${bt}** v1.0 (18 969 байт, 308 строк, 12 секций): единая спецификация EBM-обогащения — состояния файлов (NO_EBM/PARTIAL_EBM/FULL_EBM), формат inline-тегов, обязательные структурные элементы, idempotency marker, метрики (≥30 тегов, ≥8 расхождений), стандарты PowerShell-скриптов, разрешённые/запрещённые источники, pre-commit чек-лист. Коммит ${bt}a8c8cb2${bt}.

- **${bt}scripts/audit_ebm_compliance.ps1${bt}**: аудит всех 53 контентных файлов ${bt}references/methodology/${bt} по 15 критериям EBM_STANDARD v1.0. Результат: **FULL_EBM: 4 (7.5 %)** (autoimmune_basics, minerals, nutraceuticals, thyroid_health), **PARTIAL_EBM: 9 (17 %)** (covid_pregnancy, female_hormones, gallbladder_health, hashimoto, joints_osteoporosis, nervous_system, pancreas_health, stress_adrenals, vitamins), **NO_EBM: 40 (75.5 %)**. Всего 435 EBM-тегов, 37 373 строки. Коммит ${bt}a8c8cb2${bt}.

**Технические уроки Session 50:**

- **Reality check важнее оптимизма.** До аудита предполагалось «6 файлов до FULL за 3–5 часов». Реальный аудит показал 40 файлов NO_EBM и 9 PARTIAL. Реальный объём Этапа F — 5–7 сессий.
- **Читать CLAUDE.md ДО работы.** Попытка создать параллельные документы (EBM_FACTORY.md, ETAPE_F_PLAN.md) без чтения существующей архитектуры — антипаттерн. Решение: используется существующая иерархия ROADMAP → STATUS → EBM_STANDARD → скрипты.
- **Единый блок кода = единая копия.** Правило проекта: скрипты и патчи присылаются одним PowerShell-блоком, не дробятся. Ручные правки поиском по файлу запрещены.
- **Backtick в PowerShell here-strings небезопасен.** Для литеральных обратных кавычек в @"..."@ использовать переменную ${bt}[char]96${bt}. Иначе строка не совпадёт с искомой при .Contains().

**Итого коммитов Session 50:** 2 (${bt}66d1a15${bt}, ${bt}a8c8cb2${bt}).

---

## 🔄 Session 49 — 2026-07-31 (закрытие миграции)

**Тема:** Merge PR #2 в ${bt}main${bt}, удаление рабочей ветки, синхронизация локального репозитория.

**Сделано:**

- Merge PR #2 (${bt}copilot/build-v2-nutrition-agent-core${bt} → ${bt}main${bt}): 69 коммитов, 79 файлов, +26 515 / −6 584 строк. Merge commit ${bt}cf54b6e${bt}.
- Локальный ${bt}main${bt} fast-forward: ${bt}7c679e6${bt} → ${bt}cf54b6e${bt}.
- Удалена ветка ${bt}copilot/build-v2-nutrition-agent-core${bt} локально и на remote.

**Итого:** миграция базы знаний (Этапы A–E) полностью замёржена в ${bt}main${bt}.

$marker
"@

$m2 = [regex]::Match($content, $pattern2)
if (-not $m2.Success) {
    Write-Host "ОШИБКА: блок 'Последняя сессия' не найден regex-паттерном" -ForegroundColor Red
    exit 1
}
$content = $content.Replace($m2.Value, $newBlock2)
Write-Host "✓ Блок 2 (Последняя сессия) + Session 49 добавлены" -ForegroundColor Green

# --- 7. БЛОК 3: "Следующая сессия" ---
$pattern3 = '(?s)## ➡️ Следующая сессия — Этап F \(планирование\).*?(?=\n---\n## 📜)'

$newBlock3 = @"
## ➡️ Следующая сессия — Session 51 (Этап F.2)

**Контекст:** Этап F запущен. По данным ${bt}audit_ebm_compliance.ps1${bt} от 2026-07-31:
- **FULL_EBM (4/53):** autoimmune_basics, minerals, nutraceuticals, thyroid_health.
- **PARTIAL_EBM (9/53):** covid_pregnancy, female_hormones, gallbladder_health, hashimoto, joints_osteoporosis, nervous_system, pancreas_health, stress_adrenals, vitamins.
- **NO_EBM (40/53):** методологические/клиентские файлы, EBM в форме RCT неприменима.

**План Этапа F — довести 9 PARTIAL до FULL:**

1. ${bt}joints_osteoporosis.md${bt} (Session 51) — VITAL, LeBoff 2022, NOF 2022, GAIT 2006, FRAX.
2. ${bt}hashimoto.md${bt} (Session 52) — ATA/ETA 2013, Chaker 2017, Rayman 2019.
3. ${bt}vitamins.md${bt} (Session 53) — VITAL, IOM DRI, LactMed.
4. ${bt}female_hormones.md${bt}, ${bt}covid_pregnancy.md${bt}, ${bt}nervous_system.md${bt}, ${bt}pancreas_health.md${bt}, ${bt}stress_adrenals.md${bt}, ${bt}gallbladder_health.md${bt} — по мере готовности.

**Приоритет 1 (Session 51, ~60–90 мин):**

- EBM-обогащение ${bt}joints_osteoporosis.md${bt} по стандарту ${bt}EBM_STANDARD.md${bt} v1.0.
- Создать ${bt}scripts/ebm_enrich_joints_osteoporosis.ps1${bt} (5 патчей + §17 EBM Benchmark).
- Целевые метрики: +30–40 EBM-тегов, +150–200 строк, idempotency marker ${bt}EBM_ENRICHED_v1.1${bt}.
- Прогон ${bt}audit_ebm_compliance.ps1${bt} до и после — подтвердить PARTIAL → FULL.

**Приоритет 2 (инфраструктура, опционально):**

- Обобщить ${bt}update_status_session50.ps1${bt} → универсальный ${bt}scripts/update_status.ps1${bt}.
- Зафиксировать правила проекта в ${bt}learning/corrections.md${bt}: «единый блок кода = единая копия», «backtick-safe here-strings».

"@

$m3 = [regex]::Match($content, $pattern3)
if (-not $m3.Success) {
    Write-Host "ОШИБКА: блок 'Следующая сессия' не найден" -ForegroundColor Red
    exit 1
}
$content = $content.Replace($m3.Value, $newBlock3)
Write-Host "✓ Блок 3 (Следующая сессия) обновлён" -ForegroundColor Green

# --- 8. История сессий: добавить Sessions 49 и 50 ---
$historyAnchor = "- **Сессия 47** (EBM Этап E 8/8, 2026-07-27)"
$newHistoryLines = "- **Session 50** (Этап F.1, 2026-07-31): ${bt}nutraceuticals.md${bt} 0 → 74 EBM-тегов, +150 строк, §13 EBM Benchmark. Создан ${bt}EBM_STANDARD.md${bt} v1.0 (308 строк). Создан ${bt}audit_ebm_compliance.ps1${bt} — карта состояний 53 файлов: 4 FULL / 9 PARTIAL / 40 NO_EBM. Коммиты ${bt}66d1a15${bt}, ${bt}a8c8cb2${bt}. 🎉 **Этап F запущен.**`n" +
                    "- **Session 49** (закрытие миграции, 2026-07-31): Merge PR #2 (69 коммитов, +26 515 / −6 584) в ${bt}main${bt}. Merge commit ${bt}cf54b6e${bt}. Ветка ${bt}copilot/build-v2-nutrition-agent-core${bt} удалена. 🎉 **Этапы A–E замёржены в main.**`n" +
                    $historyAnchor

if (-not $content.Contains($historyAnchor)) {
    Write-Host "ОШИБКА: якорь 'Сессия 47' не найден" -ForegroundColor Red
    exit 1
}
$content = $content.Replace($historyAnchor, $newHistoryLines)
Write-Host "✓ История: Sessions 49 и 50 добавлены" -ForegroundColor Green

# --- 9. Маркер: старый → новый ---
if ($content.Contains($prevMarker)) {
    $content = $content.Replace($prevMarker, $marker)
    Write-Host "✓ Маркер: $prevMarker → $marker" -ForegroundColor Green
} elseif (-not $content.TrimEnd().EndsWith($marker)) {
    $content = $content.TrimEnd() + "`n`n$marker`n"
    Write-Host "✓ Маркер добавлен: $marker" -ForegroundColor Green
}

# --- 10. CRLF ---
$content = $content -replace "`n", "`r`n"

# --- 11. Пишем UTF-8 BOM ---
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($statusPath, $content, $utf8Bom)

# --- 12. Валидация ---
$newLen = $content.Length
$newLines = ($content -split "`r`n").Count
$bytes = [System.IO.File]::ReadAllBytes($statusPath)
$hasBom = $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
$hasMarker = $content.Contains($marker)
$hasSession49 = $content.Contains("Session 49")
$hasSession50 = $content.Contains("Session 50")
$hasEbmStandard = $content.Contains("EBM_STANDARD.md")

Write-Host ""
Write-Host "=== ВАЛИДАЦИЯ ===" -ForegroundColor Cyan
Write-Host "Длина: $origLen → $newLen (Δ $($newLen - $origLen))"
Write-Host "Строк: $newLines"
Write-Host "UTF-8 BOM: $hasBom" -ForegroundColor $(if ($hasBom) { "Green" } else { "Red" })
Write-Host "Маркер v50: $hasMarker" -ForegroundColor $(if ($hasMarker) { "Green" } else { "Red" })
Write-Host "Session 49: $hasSession49" -ForegroundColor $(if ($hasSession49) { "Green" } else { "Red" })
Write-Host "Session 50: $hasSession50" -ForegroundColor $(if ($hasSession50) { "Green" } else { "Red" })
Write-Host "EBM_STANDARD.md: $hasEbmStandard" -ForegroundColor $(if ($hasEbmStandard) { "Green" } else { "Red" })

Write-Host ""
Write-Host "=== ГОТОВО ===" -ForegroundColor Cyan
Write-Host "Backup: $backupPath"
Write-Host "Проверка: git --no-pager diff --stat project/STATUS.md"
