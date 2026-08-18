# =============================================================================
# normalize_pancreas_health_v1.ps1  (v2 — фикс P6, убраны P10/P17)
# Session 58 — pancreas_health.md: NO_EBM -> FULL_EBM, +30 EBM tags
# Схема: Read -> Apply (30 patches + 5 metadata) -> Validate -> Write (L-053-01)
# Все якоря в single quotes (L-057-01)
# =============================================================================

$ErrorActionPreference = 'Stop'
$file = 'references/methodology/pancreas_health.md'

Write-Host "=== normalize_pancreas_health_v1.ps1 (v2) ===" -ForegroundColor Cyan
Write-Host "  Target: $file"
Write-Host ""

$raw = [System.IO.File]::ReadAllText((Resolve-Path $file), [System.Text.Encoding]::UTF8)

if ($raw -match '<!--\s*EBM_ENRICHED_v[\d.]+\s*-->') {
    Write-Host "[GUARD] Маркер EBM_ENRICHED уже присутствует — выход." -ForegroundColor Yellow
    exit 0
}

$sizeBefore = $raw.Length
$tagsBefore = ([regex]::Matches($raw, '\[EBM:')).Count
Write-Host "[INFO] Размер до: $sizeBefore chars, EBM-тегов: $tagsBefore" -ForegroundColor Gray

$ts = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = "$file.bak.$ts"
Copy-Item -Path $file -Destination $backup -Force
Write-Host "[BACKUP] $backup" -ForegroundColor Gray
Write-Host ""

$c = $raw
$applied = 0

function Apply-Patch {
    param([string]$Name, [string]$Old, [string]$New)
    if ($script:c.IndexOf($Old) -lt 0) { throw "[$Name] ANCHOR NOT FOUND: $($Old.Substring(0,[Math]::Min(80,$Old.Length)))..." }
    $script:c = $script:c.Replace($Old, $New)
    $script:applied++
    Write-Host "[OK] $Name" -ForegroundColor Green
}

# =============================================================================
# ПАТЧИ КОНТЕНТА (30 патчей = 30 EBM-тегов)
# =============================================================================

Apply-Patch 'P1 §1 Анатомия — Whitcomb 2019' `
    '## 1. Анатомия и физиология поджелудочной железы' `
    '## 1. Анатомия и физиология поджелудочной железы [EBM: Whitcomb 2019 NEJM]'

Apply-Patch 'P2 §2 Ферменты — DiMagno 1973' `
    '## 2. Десять панкреатических ферментов' `
    '## 2. Десять панкреатических ферментов [EBM: DiMagno 1973 NEJM]'

Apply-Patch 'P3 §3 Карта ЖКТ — Whitcomb 2019' `
    '## 3. Карта ферментов всего ЖКТ' `
    '## 3. Карта ферментов всего ЖКТ [EBM: Whitcomb 2019 NEJM]'

Apply-Patch 'P4 §4 Связки — Opie 1901' `
    '## 4. Связки ПЖ с другими органами' `
    '## 4. Связки ПЖ с другими органами [EBM: Opie 1901 common-channel theory]'

Apply-Patch 'P5 §4→§5 вставка — Tenner 2013' `
    '## 5. ⚠️ Восемь правил «прежде чем пить ферменты»' `
    '_Билиарный панкреатит — вторая по частоте причина острого панкреатита; механизм включает обструкцию сфинктера Одди камнем с рефлюксом жёлчи в панкреатический проток._ [EBM: Tenner 2013 ACG]

## 5. ⚠️ Восемь правил «прежде чем пить ферменты»'

Apply-Patch 'P6 §5 Правила — UEG Löhr 2017' `
    '## 5. ⚠️ Восемь правил «прежде чем пить ферменты»' `
    '## 5. ⚠️ Восемь правил «прежде чем пить ферменты» [EBM: UEG Löhr 2017 HaPanEU]'

Apply-Patch 'P7 §6 Сладкое+жирное — Yadav 2013' `
    '## 6. ⚠️ Принцип «сладкое + жирное» — главный враг ПЖ' `
    '## 6. ⚠️ Принцип «сладкое + жирное» — главный враг ПЖ [EBM: Yadav 2013 Gastroenterology]'

Apply-Patch 'P8 §7 Ферменты — UEG 2017' `
    '## 7. ⚠️ Животные vs растительные ферменты' `
    '## 7. ⚠️ Животные vs растительные ферменты [EBM: UEG Löhr 2017 HaPanEU]'

Apply-Patch 'P9 §8 Дозировки — UEG 2017' `
    '## 8. Дозировки ферментов' `
    '## 8. Дозировки ферментов [EBM: UEG Löhr 2017 HaPanEU]'

# P10 УДАЛЁН (правило DiMagno 1977 покрыто через P24)

Apply-Patch 'P11 §9 Патогенез — Banks 2013 Atlanta' `
    '## 9. Панкреатит — определение и патогенез' `
    '## 9. Панкреатит — определение и патогенез [EBM: Banks 2013 Atlanta classification]'

Apply-Patch 'P12 §9→§10 вставка — Tenner 2013 критерии ОП' `
    '## 10. Шесть причин панкреатита' `
    '_Диагноз острого панкреатита ставится при наличии ≥2 из 3 критериев: типичная боль, липаза/амилаза >3× ВГН, характерные признаки на КТ/МРТ/УЗИ._ [EBM: Tenner 2013 ACG]

## 10. Шесть причин панкреатита'

Apply-Patch 'P13 §10 Причины — Yadav 2013' `
    '## 10. Шесть причин панкреатита' `
    '## 10. Шесть причин панкреатита [EBM: Yadav 2013 Gastroenterology]'

Apply-Patch 'P14 §10→§11 вставка — Tenner 2013 ЖКБ+алкоголь' `
    '## 11. Симптомы панкреатита' `
    '_ЖКБ и алкоголь — две доминирующие причины острого панкреатита (~70 % случаев в развитых странах)._ [EBM: Tenner 2013 ACG]

## 11. Симптомы панкреатита'

Apply-Patch 'P15 §11 Симптомы — IAP/APA 2013' `
    '## 11. Симптомы панкреатита' `
    '## 11. Симптомы панкреатита [EBM: IAP/APA 2013 evidence-based guidelines]'

Apply-Patch 'P16 §12 Лаб — Tenner 2013 липаза 3×' `
    '## 12. Лабораторная диагностика ПЖ — 7 показателей' `
    '## 12. Лабораторная диагностика ПЖ — 7 показателей [EBM: Tenner 2013 ACG (липаза >3× ВГН)]'

# P17 УДАЛЁН (порог эластазы-1 остаётся как фактическая уставка без тега)

Apply-Patch 'P18 §13 Лекарства — Frank 1999' `
    '## 13. ⚠️ Лекарства, искажающие результаты анализов' `
    '## 13. ⚠️ Лекарства, искажающие результаты анализов [EBM: Frank 1999 макроамилаземия]'

Apply-Patch 'P19 §14 ПЖ↔ИР — Wagner 2020' `
    '## 14. Связь ПЖ ↔ инсулинорезистентность' `
    '## 14. Связь ПЖ ↔ инсулинорезистентность [EBM: Wagner 2020 Nature Medicine]'

Apply-Patch 'P20 §15 Диета — IAP/APA 2013' `
    '## 15. Диетические рекомендации' `
    '## 15. Диетические рекомендации [EBM: IAP/APA 2013 (раннее энтеральное питание)]'

Apply-Patch 'P21 §16 Нутрицевтики — Uden 1990' `
    '## 16. Нутрицевтическая поддержка ПЖ' `
    '## 16. Нутрицевтическая поддержка ПЖ [EBM: Uden 1990 селен/антиоксиданты]'

Apply-Patch 'P22 §16→§17 вставка — Siriwardena 2007' `
    '## 17. ⚠️ Критические правила безопасности' `
    '_Антиоксидантная терапия при хроническом панкреатите (селен + витамины A/C/E + метионин) снижает болевой синдром в подгруппе алкогольного ХП, но эффект неоднозначен и не заменяет анальгезии._ [EBM: Siriwardena 2007 Gastroenterology]

## 17. ⚠️ Критические правила безопасности'

Apply-Patch 'P23 §19 EPI — UEG Löhr 2017' `
    '## 19. Экзокринная недостаточность ПЖ (EPI/PEI) ⭐' `
    '## 19. Экзокринная недостаточность ПЖ (EPI/PEI) ⭐ [EBM: UEG Löhr 2017 HaPanEU]'

Apply-Patch 'P24 §19→§20 вставка — DiMagno 1973 порог 10%' `
    '## 20. Ферментозаместительная терапия (PERT) ⭐⚠️' `
    '_Клинически значимая мальабсорбция жиров развивается при снижении секреции липазы ниже ~10 % от нормы (классическое правило DiMagno)._ [EBM: DiMagno 1973 NEJM]

## 20. Ферментозаместительная терапия (PERT) ⭐⚠️'

Apply-Patch 'P25 §20 PERT — UEG 2017' `
    '## 20. Ферментозаместительная терапия (PERT) ⭐⚠️' `
    '## 20. Ферментозаместительная терапия (PERT) ⭐⚠️ [EBM: UEG Löhr 2017 HaPanEU]'

Apply-Patch 'P26 §20→§21 вставка — Whitcomb 2019 дозы' `
    '## 21. Сахарный диабет 3c типа (панкреатогенный) ⭐' `
    '_Стартовая доза PERT — 40 000–50 000 ЕД липазы на основной приём пищи и 25 000 ЕД на перекус; коррекция по симптомам и коэффициенту абсорбции жиров._ [EBM: Whitcomb 2019 NEJM]

## 21. Сахарный диабет 3c типа (панкреатогенный) ⭐'

Apply-Patch 'P27 §21 Диабет 3c — Hardt 2008' `
    '## 21. Сахарный диабет 3c типа (панкреатогенный) ⭐' `
    '## 21. Сахарный диабет 3c типа (панкреатогенный) ⭐ [EBM: Hardt 2008 Diabetes Care]'

Apply-Patch 'P28 §21→§22 вставка — Ewald 2012 недооценка' `
    '## 22. Кисты ПЖ и IPMN ⚠️' `
    '_Диабет типа 3c (панкреатогенный) недооценён: до ~9 % всех случаев СД связаны с патологией ПЖ, но большинство ошибочно классифицированы как СД2._ [EBM: Ewald 2012 Diabetes Metab Res Rev]

## 22. Кисты ПЖ и IPMN ⚠️'

Apply-Patch 'P29 §22 Кисты — ACG 2018' `
    '## 22. Кисты ПЖ и IPMN ⚠️' `
    '## 22. Кисты ПЖ и IPMN ⚠️ [EBM: ACG 2018 + European evidence-based 2018]'

Apply-Patch 'P30 §23 AIP — Hamano 2001' `
    '## 23. Аутоиммунный панкреатит (AIP) ◆' `
    '## 23. Аутоиммунный панкреатит (AIP) ◆ [EBM: Hamano 2001 NEJM (IgG4)]'

Apply-Patch 'P31 §23→§24 вставка — ICDC 2011' `
    '## 24. ⚠️⚠️⚠️ Онконастороженность — рак ПЖ' `
    '_Диагноз AIP ставится по критериям ICDC 2011 (International Consensus Diagnostic Criteria): гистология, визуализация, серология IgG4, вовлечение других органов, ответ на стероиды._ [EBM: ICDC 2011]

## 24. ⚠️⚠️⚠️ Онконастороженность — рак ПЖ'

Apply-Patch 'P32 §24 Рак ПЖ — Lowenfels 1993' `
    '## 24. ⚠️⚠️⚠️ Онконастороженность — рак ПЖ' `
    '## 24. ⚠️⚠️⚠️ Онконастороженность — рак ПЖ [EBM: Lowenfels 1993 NEJM (риск в ХП)]'

Write-Host ""
Write-Host "[INFO] Патчей контента применено: $applied (ожидалось 30)" -ForegroundColor Gray
Write-Host ""

# =============================================================================
# МЕТАДАННЫЕ (M1..M5)
# =============================================================================

Apply-Patch 'M1 Version 2.0 -> 2.1' `
    '- **Версия:** 2.0' `
    '- **Версия:** 2.1'

Apply-Patch 'M2 Last update -> Session 58' `
    '- **Последнее обновление:** 2026-06-19 (Сессия 28)' `
    '- **Последнее обновление:** 2026-08-06 (Сессия 58, EBM enrichment)'

Apply-Patch 'M3 Status -> FULL_EBM' `
    '- **Статус:** ✅ Готов' `
    '- **Статус:** ✅ Готов (FULL_EBM)'

Apply-Patch 'M4 Marker EBM_ENRICHED_v2.1' `
    '## Метаданные' `
    '<!-- EBM_ENRICHED_v2.1 -->
## Метаданные'

Apply-Patch 'M5 Changelog Session 58' `
    '- **Метрики:** 891 строк, 27 H2, 92 H3, ⭐44 / ◆30 / ⚠️60' `
    '- **Изменения Session 58 (2026-08-06):** NO_EBM → FULL_EBM, +30 inline EBM-тегов в 22 из 27 контентных H2-секций. Источники: Whitcomb 2019 NEJM, Banks 2013 (Atlanta), Tenner 2013 ACG, UEG Löhr 2017 HaPanEU, IAP/APA 2013, Yadav 2013, DiMagno 1973, Hardt 2008 + Ewald 2012 (СД 3c), Wagner 2020 Nat Med, Hamano 2001 + ICDC 2011 (AIP), ACG 2018 (кисты/IPMN), Lowenfels 1993 (рак ПЖ), Uden 1990 + Siriwardena 2007 (АО в ХП), Frank 1999 (макроамилаземия), Opie 1901 (общий канал).
- **Метрики:** 891 строк, 27 H2, 92 H3, ⭐44 / ◆30 / ⚠️60'

Write-Host ""

# =============================================================================
# ВАЛИДАЦИИ
# =============================================================================
Write-Host "=== ВАЛИДАЦИИ ===" -ForegroundColor Cyan

$tagsAfter = ([regex]::Matches($c, '\[EBM:')).Count

$checks = @(
    @{ Name = 'EBM tags count == 30';                      Test = { $tagsAfter -eq 30 } },
    @{ Name = 'Маркер EBM_ENRICHED_v2.1 вставлен';         Test = { $c -match '<!--\s*EBM_ENRICHED_v2\.1\s*-->' } },
    @{ Name = 'Версия 2.1 присутствует';                   Test = { $c -match '\*\*Версия:\*\*\s*2\.1' } },
    @{ Name = 'Версия 2.0 удалена';                        Test = { -not ($c -match '\*\*Версия:\*\*\s*2\.0') } },
    @{ Name = 'Session 58 в LAST_UPDATED';                 Test = { $c -match 'Сессия 58' } },
    @{ Name = 'Сессия 28 удалена';                         Test = { -not ($c -match 'Последнее обновление:\*\*\s*2026-06-19') } },
    @{ Name = 'Статус FULL_EBM';                           Test = { $c -match 'Статус:\*\*\s*✅ Готов \(FULL_EBM\)' } },
    @{ Name = 'Changelog Session 58 присутствует';         Test = { $c -match 'Изменения Session 58' } },
    @{ Name = 'Whitcomb 2019 цитируется';                  Test = { $c -match '\[EBM: Whitcomb 2019' } },
    @{ Name = 'Banks 2013 Atlanta цитируется';             Test = { $c -match '\[EBM: Banks 2013 Atlanta' } },
    @{ Name = 'Tenner 2013 ACG цитируется';                Test = { $c -match '\[EBM: Tenner 2013 ACG' } },
    @{ Name = 'UEG Löhr 2017 цитируется';                  Test = { $c -match '\[EBM: UEG Löhr 2017' } },
    @{ Name = 'IAP/APA 2013 цитируется';                   Test = { $c -match '\[EBM: IAP/APA 2013' } },
    @{ Name = 'Yadav 2013 цитируется';                     Test = { $c -match '\[EBM: Yadav 2013' } },
    @{ Name = 'DiMagno 1973 цитируется';                   Test = { $c -match '\[EBM: DiMagno 1973' } },
    @{ Name = 'Hardt 2008 цитируется';                     Test = { $c -match '\[EBM: Hardt 2008' } },
    @{ Name = 'Ewald 2012 цитируется';                     Test = { $c -match '\[EBM: Ewald 2012' } },
    @{ Name = 'Wagner 2020 цитируется';                    Test = { $c -match '\[EBM: Wagner 2020' } },
    @{ Name = 'Hamano 2001 цитируется';                    Test = { $c -match '\[EBM: Hamano 2001' } },
    @{ Name = 'ICDC 2011 цитируется';                      Test = { $c -match '\[EBM: ICDC 2011' } },
    @{ Name = 'ACG 2018 цитируется';                       Test = { $c -match '\[EBM: ACG 2018' } },
    @{ Name = 'Lowenfels 1993 цитируется';                 Test = { $c -match '\[EBM: Lowenfels 1993' } },
    @{ Name = 'Opie 1901 цитируется';                      Test = { $c -match '\[EBM: Opie 1901' } },
    @{ Name = 'Uden 1990 цитируется';                      Test = { $c -match '\[EBM: Uden 1990' } },
    @{ Name = 'Siriwardena 2007 цитируется';               Test = { $c -match '\[EBM: Siriwardena 2007' } },
    @{ Name = 'Frank 1999 цитируется';                     Test = { $c -match '\[EBM: Frank 1999' } },
    @{ Name = 'Блок Метаданные не разрушен';               Test = { $c -match '## Метаданные' } },
    @{ Name = 'Дисклеймер сохранён';                       Test = { $c -match '### Дисклеймер' } },
    @{ Name = 'Размер вырос (>= +2500 chars)';             Test = { ($c.Length - $sizeBefore) -ge 2500 } }
)

$failed = 0
foreach ($chk in $checks) {
    if (& $chk.Test) {
        Write-Host "  [OK] $($chk.Name)" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $($chk.Name)" -ForegroundColor Red
        $failed++
    }
}

if ($failed -gt 0) {
    Write-Host ""
    Write-Host "[ABORT] $failed валидаций провалено — файл НЕ записан. Backup: $backup" -ForegroundColor Red
    exit 1
}

Write-Host ""

# =============================================================================
# ЗАПИСЬ (UTF-8 BOM)
# =============================================================================
$enc = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path $file), $c, $enc)

$sizeAfter = $c.Length
Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "  File:      $file"
Write-Host "  Backup:    $backup"
Write-Host "  Size:      $sizeBefore -> $sizeAfter (delta +$($sizeAfter - $sizeBefore))"
Write-Host "  EBM tags:  $tagsBefore -> $tagsAfter (+$($tagsAfter - $tagsBefore))"
Write-Host "  Version:   2.0 -> 2.1"
Write-Host "  Status:    NO_EBM -> FULL_EBM"
Write-Host "  Patches:   $applied (30 контент + 5 метаданных)"
Write-Host "  Checks:    $($checks.Count)/$($checks.Count) OK"
Write-Host ""
Write-Host "=== DONE ===" -ForegroundColor Green
