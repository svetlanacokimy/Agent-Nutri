# scripts/patch_sources_index.ps1
# Идемпотентный патчер SOURCES_INDEX.md
# Использует regex по коротким якорям — устойчиво к whitespace и невидимым символам.

$ErrorActionPreference = "Stop"
$file = "v2\SOURCES_INDEX.md"

if (-not (Test-Path $file)) {
    Write-Error "Файл не найден: $file. Запускай из корня репозитория."
    exit 1
}

$raw = Get-Content $file -Encoding UTF8 -Raw

# Определим стиль переноса строк в исходнике
$eol = if ($raw.Contains("`r`n")) { "`r`n" } else { "`n" }
Write-Host "EOL: $(if($eol -eq "`r`n"){'CRLF'}else{'LF'})"

# Нормализуем к LF на время работы
$c = $raw -replace "`r`n", "`n"
$hits = 0
$skip = 0

# Хелпер: заменить по regex, если ещё не заменено
function Patch-If {
    param(
        [string]$Name,
        [string]$MarkerRegex,   # уникальный маркер уже применённой правки (проверка идемпотентности)
        [string]$FindRegex,     # что искать
        [string]$Replacement    # на что менять (строка, не regex)
    )
    if ($script:c -match $MarkerRegex) {
        Write-Host "  [$Name] уже применено — пропускаю" -ForegroundColor Yellow
        $script:skip++
        return
    }
    if ($script:c -match $FindRegex) {
        $script:c = [regex]::Replace($script:c, $FindRegex, { param($m) $Replacement })
        Write-Host "  [$Name] OK" -ForegroundColor Green
        $script:hits++
    } else {
        Write-Host "  [$Name] НЕ НАЙДЕНО" -ForegroundColor Red
    }
}

# --- Правка 1: Кожа ---
Patch-If -Name "1. Кожа/волосы" `
  -MarkerRegex "skin_hair_health\.md" `
  -FindRegex '(## Кожа, волосы, ногти\n\n)(Выжимка: `references/07_hormones_skin_hair\.md`)' `
  -Replacement "`$1Протокол: ``references/methodology/skin_hair_health.md`` ⭐ (акне, розацеа, демодекоз, атопический дерматит, коллаген, выпадение волос, ногти — уроки 20, 24, 07)`n`$2 (DEPRECATED — частично мигрировал в Протокол)"

# --- Правка 2: вставить урогенитальные + лимфа перед "Нервная система" ---
Patch-If -Name "2. Урогенитальные+Лимфа (новые разделы)" `
  -MarkerRegex "urogenital_infections\.md" `
  -FindRegex '(Первичный: `text_extracted/УРОК 23\. Цистит\. Кандидоз\. Пигментация\.txt`\n\n---\n\n)(## Нервная система, стресс, сон, мигрень)' `
  -Replacement "`$1## Урогенитальные инфекции, кандидоз, пигментация`n`nПротокол: ``references/methodology/urogenital_infections.md`` ⭐ (цистит рецидивирующий/интерстициальный, кандидоз вагинальный/кишечный/системный, мелазма/хлоазма — урок 23, файл 07)`nПервичный: ``text_extracted/УРОК 23. Цистит. Кандидоз. Пигментация.txt```n`n---`n`n## Лимфатическая и иммунная системы`n`nПротокол: ``references/methodology/lymph_immune.md`` ⭐ (лимфостаз, дренаж, иммуноглобулины, Т/В-клетки, поддержка иммунитета — урок 24, файл 07)`nПервичный: ``text_extracted/УРОК 24. Выпадение волос. Лимфатическая и иммунная системы.txt```n`n---`n`n`$2"

# --- Правка 3: Нервная ---
Patch-If -Name "3. Нервная" `
  -MarkerRegex "methodology/nervous_system\.md" `
  -FindRegex '(## Нервная система, стресс, сон, мигрень\n\n)(Выжимка: `references/08_autoimmune_neuro\.md`)' `
  -Replacement "`$1Протокол: ``references/methodology/nervous_system.md`` ⭐ (ВНС, ось HPA, кортизол, сон, мигрень, тревога/депрессия — уроки 25, 08)`n`$2 (DEPRECATED — частично мигрировал в Протокол)"

# --- Правка 4: Меню ---
Patch-If -Name "4. Меню" `
  -MarkerRegex "methodology/menus\.md" `
  -FindRegex '(Протокол: `references/methodology/nutrition_principles\.md` ⭐ \(КЩБ[^\n]+\n)(Выжимка: `references/02_nutrition_basics\.md`[^\n]*\n)(Выжимка: `references/12_menus\.md`)(\n)' `
  -Replacement "`$1Протокол: ``references/methodology/menus.md`` ⭐ (7 типов лечебных меню: безмолочное, вегетарианское, АИП, антипаразитарное, 1300 ккал, при запорах/диарее, при СД/ИР)`n`$2`$3 (остаётся как источник шаблонов меню)`$4"

# --- Правка 5: Нутрицевтики ---
Patch-If -Name "5. Нутрицевтики" `
  -MarkerRegex "methodology/nutraceuticals\.md" `
  -FindRegex '(## Нутрицевтики \(БАД\): описания, показания, дозировки\n\n)(Выжимка: `references/09_nutraceuticals\.md`)(\n)' `
  -Replacement "`$1Протокол: ``references/methodology/nutraceuticals.md`` ⭐ (классификация, безопасность, взаимодействия с лекарствами, запреты при АИЗ/беременности, красные флаги — урок 28, файл 09)`n`$2 (остаётся активным как справочник по конкретным БАД)`$3"

# --- Правка 6: COVID ---
Patch-If -Name "6. COVID" `
  -MarkerRegex "methodology/covid_pregnancy\.md" `
  -FindRegex '(## COVID, подготовка к беременности\n\n)(Первичный: `text_extracted/УРОК 27\.[^`]+`\n)\(нет отдельной выжимки в references/ — нет в базе, требует досдачи или Категория C\)' `
  -Replacement "`$1Протокол: ``references/methodology/covid_pregnancy.md`` ⭐ (постковидный синдром, лабораторная панель, восстановление; прегравидарная подготовка — 3 стадии, лабпанель ♀/♂, MTHFR, спермограмма — уроки 27, 08)`n`$2"

# --- Правка 7: Пересчёт единиц ---
Patch-If -Name "7. Пересчёт единиц" `
  -MarkerRegex "methodology/tables/unit_conversions\.md" `
  -FindRegex '(## Пересчёт единиц измерения\n\n)Выжимка: `references/unit_conversions\.md`\n\(специализированный файл только для пересчётных коэффициентов\)' `
  -Replacement "`$1Таблица: ``references/methodology/tables/unit_conversions.md`` ⭐ (12 таблиц пересчёта: глюкоза, липиды, гормоны, витамины, минералы, ферменты, гематология; клинические примеры, red-flags, чек-лист)"

Write-Host ""
Write-Host "=== Итого: применено $hits, пропущено (уже сделано) $skip, из 7 ===" -ForegroundColor Cyan

if ($hits -gt 0) {
    # Возвращаем исходный стиль EOL
    $c = $c -replace "`n", $eol
    $utf8bom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText((Resolve-Path $file).Path, $c, $utf8bom)
    Write-Host "Файл записан: $file" -ForegroundColor Green
    Write-Host "Строк: $((Get-Content $file -Encoding UTF8).Count)"
    Write-Host "KB: $([math]::Round((Get-Item $file).Length/1KB,1))"
} elseif ($skip -eq 7) {
    Write-Host "Все правки уже применены ранее — файл не менялся." -ForegroundColor Yellow
} else {
    Write-Host "Ни одна правка не применилась. Проверь якоря вручную." -ForegroundColor Red
    exit 2
}
