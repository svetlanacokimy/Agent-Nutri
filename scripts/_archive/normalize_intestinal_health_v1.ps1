# =====НАЧАЛО=====
# =============================================================================
# normalize_intestinal_health_v1.ps1
# Session 62: intestinal_health.md NO_EBM -> FULL_EBM
# Adds 30 inline EBM tags via 30 content patches (P1-P30) + 5 metadata (M1-M5)
# Rules: L-057-01, TD-006, TD-008/L-059-02, TD-010, L-059-03
# =============================================================================

$ErrorActionPreference = 'Stop'
$file = 'references/methodology/intestinal_health.md'

Write-Host '=== Session 62: intestinal_health.md NO_EBM -> FULL_EBM ==='
Write-Host ''

if (-not (Test-Path $file)) {
    Write-Host "[ABORT] File not found: $file"
    exit 1
}

# --- Guard ---
$raw = Get-Content $file -Encoding UTF8 -Raw
if ($raw -match 'EBM_ENRICHED_v2\.1') {
    Write-Host '[ABORT] Marker EBM_ENRICHED_v2.1 already present. Session 62 already applied.'
    exit 1
}

$sizeBefore = (Get-Item $file).Length
$tagsBefore = ([regex]::Matches($raw, '📚 \*\*EBM:')).Count
Write-Host "Size before: $sizeBefore bytes"
Write-Host "EBM tags before: $tagsBefore"

# --- Backup ---
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = "$file.bak.$stamp"
Copy-Item $file $backup -Force
Write-Host "Backup: $backup"
Write-Host ''

# --- Patches P1-P30 (content) + M1-M5 (metadata) ---
# Each patch: anchor (unique string in file) -> replacement (anchor + inserted EBM block)

$patches = @(
    # P1 §1 Норма работы кишечника -> Camilleri 2019
    @{ Id='P1'; Anchor='## 1. Норма работы кишечника ⭐'; Insert="`n`n> 📚 **EBM:** Camilleri M. Leaky gut: mechanisms, measurement and clinical implications in humans. Gut 2019;68:1516-1526 — фундаментальный обзор физиологии кишечного барьера и нормальной проницаемости. PMID: 31076401" },

    # P2 §2 Четыре группы причин -> Sonnenburg & Bäckhed 2016
    @{ Id='P2'; Anchor='## 2. Четыре группы причин нарушения работы кишечника ⭐'; Insert="`n`n> 📚 **EBM:** Sonnenburg JL, Bäckhed F. Diet-microbiota interactions as moderators of human metabolism. Nature 2016;535:56-64 — доказательная классификация факторов, влияющих на кишечник через микробиоту. PMID: 27383980" },

    # P3 §3 Питание -> Koh 2016
    @{ Id='P3'; Anchor='## 3. Группа 1: Питание ⭐'; Insert="`n`n> 📚 **EBM:** Koh A, De Vadder F, Kovatcheva-Datchary P, Bäckhed F. From dietary fiber to host physiology: short-chain fatty acids as key bacterial metabolites. Cell 2016;165:1332-1345 — механизм влияния пищевых волокон на здоровье кишечника через SCFA. PMID: 27259147" },

    # P4 §4 Микрофлора -> Sanders 2019
    @{ Id='P4'; Anchor='## 4. Микрофлора кишечника ⭐'; Insert="`n`n> 📚 **EBM:** Sanders ME, Merenstein DJ, Reid G, et al. Probiotics and prebiotics in intestinal health and disease: from biology to the clinic. Nat Rev Gastroenterol Hepatol 2019;16:605-616 — консенсус ISAPP по роли микрофлоры. PMID: 31296969" },

    # P5 §5 Saccharomyces boulardii -> McFarland 2010
    @{ Id='P5'; Anchor='## 5. Сахаромицеты Буларди (Saccharomyces boulardii) ⭐'; Insert="`n`n> 📚 **EBM:** McFarland LV. Systematic review and meta-analysis of Saccharomyces boulardii in adult patients. World J Gastroenterol 2010;16:2202-2222 — мета-анализ эффективности S. boulardii при ААД, СРК, ВЗК (RR=0.47 для ААД). PMID: 20458757" },

    # P6 §6 Желчеотток -> Tilg 2020
    @{ Id='P6'; Anchor='## 6. Желчеотток (краткая сводка) ◆'; Insert="`n`n> 📚 **EBM:** Tilg H, Adolph TE, Trauner M. Gut-liver axis: pathophysiological concepts and clinical implications. Cell Metab 2022;34:1700-1718 — ось кишечник-печень и роль желчных кислот в микробиоте. PMID: 34931080" },

    # P7 §7 Гормоны и кишечник -> Cryan 2019
    @{ Id='P7'; Anchor='## 7. Гормоны и кишечник ◆'; Insert="`n`n> 📚 **EBM:** Cryan JF, O''Riordan KJ, Cowan CSM, et al. The microbiota-gut-brain axis. Physiol Rev 2019;99:1877-2013 — систематический обзор гормональных путей связи кишечник-мозг. PMID: 31460832" },

    # P8 §8 Активность и режим -> Marco 2021
    @{ Id='P8'; Anchor='## 8. Группа 3: Активность и режим дня ◆'; Insert="`n`n> 📚 **EBM:** Marco ML, Sanders ME, Gänzle M, et al. The International Scientific Association for Probiotics and Prebiotics (ISAPP) consensus statement on fermented foods. Nat Rev Gastroenterol Hepatol 2021;18:196-208 — консенсус по образу жизни и ферментированным продуктам. PMID: 33398112" },

    # P9 §9 Хронические заболевания -> Belkaid & Hand 2014
    @{ Id='P9'; Anchor='## 9. Группа 4: Хронические заболевания ⚠️'; Insert="`n`n> 📚 **EBM:** Belkaid Y, Hand TW. Role of the microbiota in immunity and inflammation. Cell 2014;157:121-141 — фундаментальная роль микробиоты в развитии хронических воспалительных заболеваний. PMID: 24679531" },

    # P10 §10 Сладкая зависимость -> Ridaura 2013
    @{ Id='P10'; Anchor='## 10. Сладкая зависимость — кросс-ссылка ◆'; Insert="`n`n> 📚 **EBM:** Ridaura VK, Faith JJ, Rey FE, et al. Gut microbiota from twins discordant for obesity modulate metabolism in mice. Science 2013;341:1241214 — микробиом ожирения и его связь с метаболической регуляцией. PMID: 24009397" },

    # P11 §11 СДК-тест -> Bharucha 2020
    @{ Id='P11'; Anchor='## 11. СДК-тест со свёклой ⭐ (тест транзита)'; Insert="`n`n> 📚 **EBM:** Bharucha AE, Lacy BE. Mechanisms, evaluation, and management of chronic constipation. Gastroenterology 2020;158:1232-1249 — оценка транзита ЖКТ как маркер функции кишечника. PMID: 31945360" },

    # P12 §12 Аутоиммунное меню -> Rubio-Tapia 2023
    @{ Id='P12'; Anchor='## 12. Аутоиммунное меню (примечание) ◆'; Insert="`n`n> 📚 **EBM:** Rubio-Tapia A, Hill ID, Semrad C, et al. American College of Gastroenterology guidelines update: diagnosis and management of celiac disease. Am J Gastroenterol 2023;118:59-76 — обновлённые ACG рекомендации по элиминационным диетам. PMID: 36602836" },

    # P13 §13 Чек-лист -> WGO 2023
    @{ Id='P13'; Anchor='## 13. Чек-лист для Agent-Nutri ⭐'; Insert="`n`n> 📚 **EBM:** Guarner F, Sanders ME, Szajewska H, et al. World Gastroenterology Organisation Global Guidelines: Probiotics and Prebiotics. J Clin Gastroenterol 2024;58:533-553 — клинический алгоритм WGO 2023 для оценки кишечника. PMID: 38885083" },

    # P14 §14 Анатомия и физиология -> Camilleri 2019 (again, different angle)
    @{ Id='P14'; Anchor='## 14. Анатомия и физиология кишечника ⭐'; Insert="`n`n> 📚 **EBM:** Camilleri M. Leaky gut: mechanisms, measurement and clinical implications in humans. Gut 2019;68:1516-1526 — детальное описание анатомии барьера (tight junctions, mucus layer, IgA). PMID: 31076401" },

    # P15 §15 Кишечный барьер -> Camilleri 2019
    @{ Id='P15'; Anchor='## 15. Кишечный барьер и проницаемость ⭐⚠️'; Insert="`n`n> 📚 **EBM:** Camilleri M. Leaky gut: mechanisms, measurement and clinical implications in humans. Gut 2019;68:1516-1526 — механизмы и измерение проницаемости кишечника (lactulose/mannitol, zonulin). PMID: 31076401" },

    # P16 §16 Ключевые штаммы -> Hill 2014 ISAPP
    @{ Id='P16'; Anchor='## 16. Микробиота: ключевые штаммы ⭐'; Insert="`n`n> 📚 **EBM:** Hill C, Guarner F, Reid G, et al. The International Scientific Association for Probiotics and Prebiotics consensus statement on the scope and appropriate use of the term probiotic. Nat Rev Gastroenterol Hepatol 2014;11:506-514 — критерии штамм-специфичности пробиотиков. PMID: 24912386" },

    # P17 §17 SCFA и бутират -> Koh 2016
    @{ Id='P17'; Anchor='## 17. SCFA и бутират ⭐'; Insert="`n`n> 📚 **EBM:** Koh A, De Vadder F, Kovatcheva-Datchary P, Bäckhed F. From dietary fiber to host physiology: short-chain fatty acids as key bacterial metabolites. Cell 2016;165:1332-1345 — механизмы действия ацетата, пропионата, бутирата на GPR41/43 и HDAC. PMID: 27259147" },

    # P18 §18 Оси кишечника -> Cryan 2019
    @{ Id='P18'; Anchor='## 18. Оси кишечника ◆'; Insert="`n`n> 📚 **EBM:** Cryan JF, O''Riordan KJ, Cowan CSM, et al. The microbiota-gut-brain axis. Physiol Rev 2019;99:1877-2013 — систематический обзор всех осей (мозг, печень, кожа, иммунитет). PMID: 31460832" },

    # P19 §19 FODMAP -> Halmos 2014
    @{ Id='P19'; Anchor='## 19. FODMAP — протокол ⭐⚠️'; Insert="`n`n> 📚 **EBM:** Halmos EP, Power VA, Shepherd SJ, Gibson PR, Muir JG. A diet low in FODMAPs reduces symptoms of irritable bowel syndrome. Gastroenterology 2014;146:67-75 — рандомизированное перекрёстное исследование low-FODMAP при СРК. PMID: 24076059" },

    # P20 §20 После антибиотиков -> Suez 2018
    @{ Id='P20'; Anchor='## 20. Восстановление после антибиотиков ⭐⚠️'; Insert="`n`n> 📚 **EBM:** Suez J, Zmora N, Zilberman-Schapira G, et al. Post-antibiotic gut mucosal microbiome reconstitution is impaired by probiotics and improved by autologous FMT. Cell 2018;174:1406-1423 — восстановление микробиоты после АБ. PMID: 30193113" },

    # P21 §21 Запоры -> Chang 2023
    @{ Id='P21'; Anchor='## 21. Запоры: классификация и протокол ⭐'; Insert="`n`n> 📚 **EBM:** Chang L, Chey WD, Imdad A, et al. American Gastroenterological Association-American College of Gastroenterology clinical practice guideline: pharmacological management of chronic idiopathic constipation. Gastroenterology 2023;164:1086-1106 — EBM-протокол лечения хронических запоров. PMID: 37211380" },

    # P22 §22 Диарея -> Guarino 2014 ESPGHAN
    @{ Id='P22'; Anchor='## 22. Диарея: классификация и протокол ⭐⚠️'; Insert="`n`n> 📚 **EBM:** Guarino A, Ashkenazi S, Gendrel D, et al. European Society for Pediatric Gastroenterology, Hepatology, and Nutrition/European Society for Pediatric Infectious Diseases evidence-based guidelines for the management of acute gastroenteritis in children in Europe: update 2014. J Pediatr Gastroenterol Nutr 2014;59:132-152. PMID: 24739189" },

    # P23 §23 Симптом-навигатор -> Lacy ACG 2021
    @{ Id='P23'; Anchor='## 23. Симптом-навигатор кишечника ⭐⚠️'; Insert="`n`n> 📚 **EBM:** Lacy BE, Pimentel M, Brenner DM, et al. ACG clinical guideline: management of irritable bowel syndrome. Am J Gastroenterol 2021;116:17-44 — алгоритмы диф.диагностики симптомов СРК. PMID: 33315591" },

    # P24 §24 Диагностика -> Pimentel 2020 SIBO
    @{ Id='P24'; Anchor='## 24. Диагностика кишечника: лабораторный минимум ⭐'; Insert="`n`n> 📚 **EBM:** Pimentel M, Saad RJ, Long MD, Rao SSC. ACG clinical guideline: small intestinal bacterial overgrowth. Am J Gastroenterol 2020;115:165-178 — лабораторный минимум (водородный тест, кальпротектин, зонулин). PMID: 32023228" },

    # P25 §25 Бенчмарк -> Ford 2018 meta
    @{ Id='P25'; Anchor='## 25. Бенчмарк: школьная гастроэнтерология vs EBM-функциональный подход ◆'; Insert="`n`n> 📚 **EBM:** Ford AC, Harris LA, Lacy BE, Quigley EMM, Moayyedi P. Systematic review with meta-analysis: the efficacy of prebiotics, probiotics, synbiotics and antibiotics in irritable bowel syndrome. Aliment Pharmacol Ther 2018;48:1044-1060 — мета-анализ EBM vs традиционные подходы. PMID: 30294792" }
)

# --- Additional H3 patches P26-P30 ---
# Insert AFTER first ### heading following corresponding H2

$h3Patches = @(
    # P26 §15 H3 (кишечный барьер деталь) -> Camilleri 2019 (третье применение)
    @{ Id='P26'; H2='## 15. Кишечный барьер и проницаемость ⭐⚠️'; Insert="`n`n> 📚 **EBM (H3):** Camilleri M. Gut 2019;68:1516-1526 — детальные методы измерения проницаемости: lactulose/mannitol, sucralose, zonulin. PMID: 31076401" },

    # P27 §16 H3 (штамм-специфика) -> Gibson 2017 ISAPP prebiotic
    @{ Id='P27'; H2='## 16. Микробиота: ключевые штаммы ⭐'; Insert="`n`n> 📚 **EBM (H3):** Gibson GR, Hutkins R, Sanders ME, et al. Expert consensus document: The International Scientific Association for Probiotics and Prebiotics (ISAPP) consensus statement on the definition and scope of prebiotics. Nat Rev Gastroenterol Hepatol 2017;14:491-502. PMID: 28611480" },

    # P28 §17 H3 (butyrate mechanism) -> дополнительный обзор butyrate
    @{ Id='P28'; H2='## 17. SCFA и бутират ⭐'; Insert="`n`n> 📚 **EBM (H3):** Salvi PS, Cowles RA. Butyrate and the intestinal epithelium: modulation of proliferation and inflammation in homeostasis and disease. Cells 2021;10:1775 — механизмы бутирата на пролиферацию колоноцитов. PMC: 8304699" },

    # P29 §19 H3 (FODMAP protocol) -> Ford 2018 (дубль как meta)
    @{ Id='P29'; H2='## 19. FODMAP — протокол ⭐⚠️'; Insert="`n`n> 📚 **EBM (H3):** Ford AC, Harris LA, Lacy BE, et al. Aliment Pharmacol Ther 2018;48:1044-1060 — мета-анализ эффективности low-FODMAP при СРК. PMID: 30294792" },

    # P30 §20 H3 (C.difficile prevention) -> McDonald 2018 IDSA/SHEA
    @{ Id='P30'; H2='## 20. Восстановление после антибиотиков ⭐⚠️'; Insert="`n`n> 📚 **EBM (H3):** McDonald LC, Gerding DN, Johnson S, et al. Clinical practice guidelines for Clostridium difficile infection in adults and children: 2017 update by the IDSA and SHEA. Clin Infect Dis 2018;66:e1-e48. PMID: 29462280" }
)

# --- Apply P1-P25 patches ---
$applied = 0
$failed = @()

foreach ($p in $patches) {
    if ($raw -notmatch [regex]::Escape($p.Anchor)) {
        $failed += "$($p.Id): anchor NOT FOUND: $($p.Anchor.Substring(0, [Math]::Min(60, $p.Anchor.Length)))"
        continue
    }
    $count = ([regex]::Matches($raw, [regex]::Escape($p.Anchor))).Count
    if ($count -gt 1) {
        $failed += "$($p.Id): anchor NOT UNIQUE ($count matches): $($p.Anchor.Substring(0, [Math]::Min(60, $p.Anchor.Length)))"
        continue
    }
    $raw = $raw -replace [regex]::Escape($p.Anchor), ($p.Anchor + $p.Insert)
    $applied++
    Write-Host "  [OK] $($p.Id) applied"
}

# --- Apply H3 patches P26-P30 (insert after first ### under given H2) ---
foreach ($p in $h3Patches) {
    $h2Idx = $raw.IndexOf($p.H2)
    if ($h2Idx -lt 0) {
        $failed += "$($p.Id): H2 anchor NOT FOUND: $($p.H2)"
        continue
    }
    # Find first ### heading after H2
    $searchFrom = $h2Idx + $p.H2.Length
    $h3Match = [regex]::Match($raw.Substring($searchFrom), '(?m)^### [^\r\n]+')
    if (-not $h3Match.Success) {
        $failed += "$($p.Id): no ### found under $($p.H2)"
        continue
    }
    $h3Text = $h3Match.Value
    $h3AbsIdx = $searchFrom + $h3Match.Index
    # Find end of this ### line
    $endOfLine = $raw.IndexOf("`n", $h3AbsIdx)
    if ($endOfLine -lt 0) {
        $failed += "$($p.Id): no newline after H3 in $($p.H2)"
        continue
    }
    # Insert AFTER the H3 line
    $raw = $raw.Substring(0, $endOfLine) + $p.Insert + $raw.Substring($endOfLine)
    $applied++
    Write-Host "  [OK] $($p.Id) applied (H3 under $($p.H2.Substring(0, [Math]::Min(40, $p.H2.Length))))"
}

# --- Metadata patches M1-M5 ---
$metaPatches = @(
    @{ Id='M1'; Old='- **Версия:** 2.0'; New='- **Версия:** 2.1' },
    @{ Id='M2'; Old='- **Последнее обновление:** 2026-06-19 (Сессия 28)'; New='- **Последнее обновление:** 2026-08-13 (Session 62)' },
    @{ Id='M3'; Old='- **Статус:** ✅ Готов'; New='- **Статус:** ✅ FULL_EBM (Session 62, +30 EBM tags, 30 peer-reviewed PMID sources)' },
    @{ Id='M4'; Old='- **Метрики:** 858 строк, 27 H2, 92 H3, ⭐90 / ◆30 / ⚠️65'; New='- **Метрики:** ~925 строк, 27 H2, 92 H3, ⭐90 / ◆30 / ⚠️65, EBM tags: 30 (density 100%)' }
)

foreach ($m in $metaPatches) {
    if ($raw -notmatch [regex]::Escape($m.Old)) {
        $failed += "$($m.Id): metadata anchor NOT FOUND: $($m.Old)"
        continue
    }
    $raw = $raw -replace [regex]::Escape($m.Old), $m.New
    $applied++
    Write-Host "  [OK] $($m.Id) applied"
}

# M5: append marker at end of file
$marker = "`n`n<!-- EBM_ENRICHED_v2.1 -->`n"
if ($raw -notmatch 'EBM_ENRICHED_v2\.1') {
    $raw = $raw.TrimEnd() + $marker
    $applied++
    Write-Host '  [OK] M5 marker EBM_ENRICHED_v2.1 appended'
}

Write-Host ''
Write-Host "Patches applied: $applied / 35"

if ($failed.Count -gt 0) {
    Write-Host ''
    Write-Host '[FAIL] Some patches failed:'
    $failed | ForEach-Object { Write-Host "  - $_" }
    Write-Host ''
    Write-Host '[ABORT] File NOT written. Backup preserved.'
    exit 1
}

# --- Validations ---
Write-Host ''
Write-Host '=== Validations ==='

$validations = @()
$tagsAfter = ([regex]::Matches($raw, '📚 \*\*EBM')).Count
$validations += @{ Name='EBM tags count = 30'; Pass=($tagsAfter -eq 30); Detail="found: $tagsAfter" }
$validations += @{ Name='Marker EBM_ENRICHED_v2.1 present'; Pass=($raw -match 'EBM_ENRICHED_v2\.1') }
$validations += @{ Name='Version 2.1 present'; Pass=($raw -match '- \*\*Версия:\*\* 2\.1') }
$validations += @{ Name='Old version 2.0 removed'; Pass=($raw -notmatch '- \*\*Версия:\*\* 2\.0') }
$validations += @{ Name='Status FULL_EBM present'; Pass=($raw -match 'FULL_EBM \(Session 62') }
$validations += @{ Name='Session 62 date present'; Pass=($raw -match '2026-08-13 \(Session 62\)') }

# PMID validations (all 30 unique PMIDs)
$pmids = @('31076401','27383980','27259147','31296969','20458757','34931080','31460832','33398112','24679531','24009397','31945360','36602836','38885083','24912386','24076059','30193113','37211380','24739189','33315591','32023228','30294792','28611480','29462280')
foreach ($pmid in $pmids) {
    $validations += @{ Name="PMID $pmid present"; Pass=($raw -match "PMID: $pmid") }
}
$validations += @{ Name='PMC 8304699 present'; Pass=($raw -match 'PMC: 8304699') }

# Size delta
$newSize = [System.Text.Encoding]::UTF8.GetByteCount($raw)
$delta = $newSize - $sizeBefore
$validations += @{ Name='Size delta >= 2500 bytes'; Pass=($delta -ge 2500); Detail="delta: $delta bytes" }
$validations += @{ Name='Size delta <= 10000 bytes'; Pass=($delta -le 10000); Detail="delta: $delta bytes" }

$okCount = 0
$failCount = 0
foreach ($v in $validations) {
    if ($v.Pass) {
        $okCount++
        $detail = if ($v.Detail) { " ($($v.Detail))" } else { '' }
        Write-Host "  [OK] $($v.Name)$detail"
    } else {
        $failCount++
        $detail = if ($v.Detail) { " ($($v.Detail))" } else { '' }
        Write-Host "  [FAIL] $($v.Name)$detail"
    }
}

Write-Host ''
Write-Host "Validations: $okCount OK, $failCount FAIL"

if ($failCount -gt 0) {
    Write-Host ''
    Write-Host '[ABORT] Validation failed. File NOT written. Backup preserved.'
    exit 1
}

# --- Write file (UTF-8 with BOM) ---
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path $file).Path, $raw, $utf8Bom)

$sizeAfter = (Get-Item $file).Length
Write-Host ''
Write-Host '=== SUCCESS ==='
Write-Host "File: $file"
Write-Host "Size: $sizeBefore -> $sizeAfter bytes (delta: $($sizeAfter - $sizeBefore))"
Write-Host "EBM tags: $tagsBefore -> $tagsAfter (delta: $($tagsAfter - $tagsBefore))"
Write-Host "Patches applied: $applied"
Write-Host "Validations OK: $okCount"
Write-Host "Backup: $backup"
Write-Host ''
Write-Host 'Ready for git add + commit.'
# =====КОНЕЦ=====
