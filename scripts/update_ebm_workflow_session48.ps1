<#
.SYNOPSIS
  Обновляет project/EBM_WORKFLOW.md по итогам Session 48.
.NOTES
  Session 48, 2026-07-27
#>

$ErrorActionPreference = 'Stop'
$targetFile = 'project/EBM_WORKFLOW.md'
$marker = '<!-- WORKFLOW_SESSION48_APPLIED -->'

if (-not (Test-Path $targetFile)) {
    Write-Host "ОШИБКА: файл $targetFile не найден" -ForegroundColor Red
    exit 1
}

$content = Get-Content $targetFile -Raw -Encoding UTF8
$originalLength = $content.Length
Write-Host "Прочитано символов: $originalLength" -ForegroundColor Cyan

if ($content -match [regex]::Escape($marker)) {
    Write-Host "Файл уже обновлён. Выход." -ForegroundColor Yellow
    exit 0
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupFile = "$targetFile.bak.$timestamp"
Copy-Item $targetFile $backupFile -Force
Write-Host "Backup: $backupFile" -ForegroundColor Green

# ПАТЧ 1: Шапка
$patch1Regex = '(\*\*Создан:\*\* 2026-07-26 \(Session 40, после прототипа covid_pregnancy\.md\)\r?\n)'
$patch1New = "`$1**Обновлён:** 2026-07-27 (Session 48, финализация Этапа E — 8/8 методичек)`r`n"
if ($content -match $patch1Regex) {
    $content = [regex]::Replace($content, $patch1Regex, $patch1New)
    Write-Host "[Патч 1] Шапка обновлена" -ForegroundColor Green
} else {
    Write-Host "[Патч 1] Не найдено — ОШИБКА" -ForegroundColor Red
    exit 1
}

# ПАТЧ 2: Таблица порядка обработки
$newOrderBlock = @"
## Порядок обработки (актуальный по итогам Этапа E)

### Этап E — ✅ ЗАВЕРШЁН (8/8, Sessions 40–47)

| # | Файл | Статус | Сессия | Метрики |
|---|------|--------|--------|---------|
| 1 | covid_pregnancy.md | ✅ | Session 40 | ~800 строк, ~25 EBM-тегов |
| 2 | nervous_system.md | ✅ | Session 41 | ~900 строк, ~25 EBM-тегов |
| 3 | minerals.md | ✅ | Session 42 | 1376 строк, 30 EBM-тегов |
| 4 | vitamins.md | ✅ | Session 43 | 1776 строк, 29 EBM-тегов |
| 5 | hashimoto.md | ✅ | Session 44 | 624 строки, 24 EBM-тега |
| 6 | female_hormones.md | ✅ | Session 45 | 885 строк, 29 EBM-тегов |
| 7 | autoimmune_basics.md | ✅ | Session 46 | 1017 строк, 81 EBM-тег |
| 8 | thyroid_health.md | ✅ | Session 47 | 798 строк, 116 EBM-тегов |

**Итого:** ~8 200 строк, ~360 EBM-тегов, 16 коммитов без откатов.

### Этап F — ⏳ ЗАПЛАНИРОВАН (6 методичек)

| # | Файл | Приоритет |
|---|------|-----------|
| 1 | nutraceuticals.md | Высокий |
| 2 | joints_osteoporosis.md | Высокий |
| 3 | skin_hair_health.md | Средний |
| 4 | urogenital_infections.md | Средний |
| 5 | lymph_immune.md | Средний |
| 6 | menus.md | Низкий |

"@

$patch2Regex = '(?s)## Порядок обработки.*?(?=## После завершения)'
if ($content -match $patch2Regex) {
    $content = [regex]::Replace($content, $patch2Regex, $newOrderBlock)
    Write-Host "[Патч 2] Таблица заменена" -ForegroundColor Green
} else {
    Write-Host "[Патч 2] Не найдено — ОШИБКА" -ForegroundColor Red
    exit 1
}

# ПАТЧ 3: Раздел После завершения
$newAfterBlock = @"
## После завершения Этапа F

1. Merge в main — PR из ветки в main.
2. CI-валидатор EBM-маркеров.
3. Финальное обновление STATUS.md с покрытием 14/14.
4. Опционально: расширение до EBM-full (уровень 2 OCEBM).

_Этапы B3 и D закрыты в Session 48 (2026-07-27):_
- _B3 ✅ — коммит 3e241ab._
- _D ✅ N/A — задача признана фантомной (файлы NN_*.md не существуют)._

"@

$patch3Regex = '(?s)## После завершения.*?(?=## Ключевые пулы источников)'
if ($content -match $patch3Regex) {
    $content = [regex]::Replace($content, $patch3Regex, $newAfterBlock)
    Write-Host "[Патч 3] Раздел обновлён" -ForegroundColor Green
} else {
    Write-Host "[Патч 3] Не найдено — ОШИБКА" -ForegroundColor Red
    exit 1
}


# ПАТЧ 4: Секция Уроки Этапа E
$newLessonsBlock = @"
## Уроки Этапа E (Sessions 40–47)

### 1. Три формата метаданных

- Blockquote: > **Версия:** 1.0
- Plain list: - **Версия:** 2.0
- Отдельная секция ## Метаданные

Regex должен покрывать все три варианта.

### 2. Маркеры идемпотентности — обязательный паттерн

Каждый скрипт добавляет маркер вида EBM_ENRICHED_v1.1 или EBM_ENRICHED_v2.1. Повторный запуск проверяет маркер и выходит без изменений.

### 3. SKIP-замены 10–50 % — норма, не баг

Вариативность формулировок школы. Концепция покрывается через разделы EBM benchmark, таблицы расхождений, RCT. Не расширять regex — 15 точных OK лучше, чем 25 сомнительных.

### 4. Структурные аномалии — обрабатывать, не править

- nervous_system.md: дубликаты H2.
- autoimmune_basics.md строка 153: ложный H2.

Обходим regex-ами, исходник не трогаем.

### 5. Пять технических предохранителей

1. File exists check.
2. Unique anchors check.
3. Idempotency guard.
4. Order validation.
5. UTF-8 BOM + CRLF.

### 6. Реалистичный тайминг

30–50 мин на файл (не 60–90). Секрет — переиспользуемый каркас скрипта.

## Пулы источников — актуализация после Этапа E

### Эндокринология (кластер 4)

- Тиреоидные: ATA 2014 (Jonklaas), ATA 2017 Pregnancy, NICE NG145
- Селен и АИТ: Gärtner 2002, Toulis 2010, Wichman 2016
- АИТ и глютен: Krysiak 2018, Krysiak 2019
- PCOS: Monash/AE-PCOS 2023
- Менопауза: NAMS 2022, NICE NG23, NG73

### Микронутриенты (кластер 8)

- Референс: LPI Oregon State, NIH ODS
- Витамин D: Palacios 2019, Holick 2011, Manson 2019 VITAL
- Магний: Volpe 2013, deBaaij 2015
- Цинк: Hemilä 2017
- Железо: Peña-Rosas 2015, WHO 2016
- Селен: Rayman 2012, NIH ODS 2023

### Аутоиммунитет (кластер 3/9)

- AIP: Konijeti 2017, Abbott 2019
- Zonulin: Fasano 2011, Camilleri 2019
- Мимикрия: Kivity 2011, Rojas 2018
- Средиземноморская при РА: Sköldstam 2003
- Гайдлайны: EULAR RA 2022, ACR SLE 2019, ECCO IBD

"@

$patch4Regex = '(## Правила безопасности)'
if ($content -match $patch4Regex) {
    $content = [regex]::Replace($content, $patch4Regex, "$newLessonsBlock`$1")
    Write-Host "[Патч 4] Уроки Этапа E добавлены" -ForegroundColor Green
} else {
    Write-Host "[Патч 4] Правила безопасности не найдены — ОШИБКА" -ForegroundColor Red
    exit 1
}

# Маркер идемпотентности
$content = $content.TrimEnd() + "`r`n`r`n$marker`r`n"

# Нормализация CRLF
$content = $content -replace "`r`n", "`n"
$content = $content -replace "`n", "`r`n"

# Сохранение UTF-8 BOM
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path $targetFile).Path, $content, $utf8Bom)
Write-Host "Файл сохранён: UTF-8 BOM, CRLF" -ForegroundColor Green

# ВАЛИДАЦИЯ
Write-Host "`n=== ВАЛИДАЦИЯ ===" -ForegroundColor Cyan
$final = Get-Content $targetFile -Raw -Encoding UTF8
$bytes = [System.IO.File]::ReadAllBytes((Resolve-Path $targetFile).Path)
$hasBom = ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
$lines = ($final -split "`r`n").Count
$sizeKB = [math]::Round($bytes.Length / 1KB, 1)

$checks = @(
    @{ Name = 'Обновлён Session 48'; Ok = $final -match 'Обновлён:\*\* 2026-07-27' }
    @{ Name = 'Этап E завершён'; Ok = $final -match 'Этап E — ✅ ЗАВЕРШЁН' }
    @{ Name = 'thyroid_health в таблице'; Ok = $final -match 'thyroid_health\.md' }
    @{ Name = 'Этап F запланирован'; Ok = $final -match 'Этап F — ⏳ ЗАПЛАНИРОВАН' }
    @{ Name = 'Уроки Этапа E'; Ok = $final -match 'Уроки Этапа E' }
    @{ Name = '5 предохранителей'; Ok = $final -match 'Пять технических предохранителей' }
    @{ Name = 'Три формата метаданных'; Ok = $final -match 'Три формата метаданных' }
    @{ Name = 'Эндокринология кластер 4'; Ok = $final -match 'Эндокринология \(кластер 4\)' }
    @{ Name = 'Микронутриенты кластер 8'; Ok = $final -match 'Микронутриенты \(кластер 8\)' }
    @{ Name = 'Маркер идемпотентности'; Ok = $final -match [regex]::Escape($marker) }
    @{ Name = 'UTF-8 BOM'; Ok = $hasBom }
)

$allOk = $true
foreach ($c in $checks) {
    if ($c.Ok) { Write-Host "  OK $($c.Name)" -ForegroundColor Green }
    else { Write-Host "  FAIL $($c.Name)" -ForegroundColor Red; $allOk = $false }
}

Write-Host "`nСтрок: $lines, Размер: $sizeKB KB" -ForegroundColor Cyan
Write-Host "Изменение: $originalLength -> $($content.Length) символов" -ForegroundColor Cyan

if ($allOk) {
    Write-Host "`n=== ГОТОВО: EBM_WORKFLOW.md обновлён ===" -ForegroundColor Green
} else {
    Write-Host "`n=== ВНИМАНИЕ: не все проверки пройдены ===" -ForegroundColor Red
    Write-Host "Backup: $backupFile" -ForegroundColor Yellow
}
