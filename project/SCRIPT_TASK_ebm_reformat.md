З: разработка scripts/ebm_reformat.ps1 — автономный EBM-скрипт для миграции файлов методологии
Контекст
За две сессии (62-63) мы вручную мигрировали 2 из 57 файлов методологии через VS Code Agent:

pancreas_health.md (v1.1 → v3.0, 30 inline-тегов, 17 PMID)
intestinal_health.md (v2.1 → v3.1, 30 короткополных блоков, 24 PMID)
Работа однотипная и дорогая по токенам LLM (~40-50k на файл). Оставшиеся 55 файлов нужно обработать через автономный PowerShell-скрипт, который делает 90% работы без LLM. Стандарт формата — project/EBM_STANDARD_v2.0.md v3.1.

Задача
Разработать scripts/ebm_reformat.ps1 v1.0 — production-ready PowerShell-скрипт для аудита и миграции EBM-блоков в файлах references/methodology/\*.md.

Требования к скрипту
Параметры CLI
Copy.\scripts\ebm*reformat.ps1 -File <name.md> [-Mode <audit|dryrun|apply>] [-Backup] [-Verbose] [-NoCache]
-File — обязательный, имя файла в references/methodology/ (или полный путь).
-Mode audit (по умолчанию) — только проверка, отчёт без изменений.
-Mode dryrun — показать diff в отчёте без записи.
-Mode apply — применить изменения к файлу (после подтверждения при -Verbose).
-Backup — создать бэкап перед -Mode apply в project/\_temp/migration_backups/<file>\_pre-migration*<date>.md (SHA256-проверка).
-Verbose — подробный вывод действий.
-NoCache — принудительно запрашивать PubMed заново, не использовать кэш.
Функциональность

1. Обнаружение EBM-блоков (три формата):

CopyФормат v1.1 inline: [EBM: Author Year context]
Формат v2.1 короткий: > 📚 **EBM:** Author. Title. Journal Year;Vol:pages — RU. PMID: XXXX
Формат v3.0/v3.1: > 📚 **EBM** [Level ...] [outcome] > **Author FI, et al. YYYY.** ... > **Population:** ... > _Journal_ Vol(Issue):pages. PMID: [XXX](URL)
Regex-паттерны для каждого. При обнаружении: номер строки, формат, PMID (если есть), автор, год.

2. PubMed API-клиент:

Использовать $env:NCBI_API_KEY (если пуст — ошибка с рекомендацией).
esummary — получить metadata (Author, Year, Journal, Vol/Issue, Pages, DOI, PublicationType, PMC ID).
efetch — получить abstract XML (для population, sample size, follow-up).
Rate limit: 10 req/sec (с ключом), 3 req/sec (без).
Retry с exponential backoff при ошибках 429/500/503 (макс 3 попытки).
Timeout 30 сек на запрос. 3. Кэш PubMed:

Директория: project/\_temp/pubmed_cache/
Структура: <PMID>\_esummary.json, <PMID>\_efetch.xml, <PMID>\_pmc.xml (опционально).
При наличии кэша — использовать без API-вызова (кроме -NoCache).
Кэш общий для всех файлов методологии (переиспользование). 4. Определение Level по PublicationType:

Мэппинг из MeSH PublicationType (см. EBM_STANDARD_v2.0.md §3, §12):

Randomized Controlled Trial + double-blind → Level 1b, RCT, double-blind
Meta-Analysis → Level 1a, meta-analysis, N/A
Systematic Review → Level 1a, systematic review, N/A
Guideline / Practice Guideline / Consensus Development Conference → Level 5, guideline, N/A (или Level 1a если основан на SR)
Cohort Studies (из MeSH) → Level 2b, cohort, N/A
Case-Control Studies → Level 3b, case-control, N/A
Comparative Study (без RCT) → Level 2c, comparative, N/A
Review (без Systematic) → Level 5, narrative review, N/A
Case Reports → Level 4, case series, N/A
Journal Article (fallback) → Level 4, journal article, N/A
Дополнительный анализ title/abstract на keywords guideline, consensus, recommendations — override на Guideline (v3.1 §12.4).

5. Определение Outcome type:

Автоматическая эвристика по abstract keywords:

Ключи mortality, death, cancer, hospitalization, stroke, MI → hard
Ключи symptoms, quality of life, remission, pain, response rate → clinical
Ключи biomarker, serum level, HbA1c, CRP, microbiome diversity → surrogate
Для guideline → recommendation
Fallback → clinical (с пометкой [AUTO: verify] в отчёте) 6. Форматирование v3.1-блока:

Шаблон (строго по EBM_STANDARD v3.1 §3):

Copy> 📚 **EBM** [Level X, TYPE, blinding] [outcome]

> **Surname FI, et al. YYYY.** Краткое описание находки (для guideline/review) ИЛИ Substance form, dose: effect vs comparator (для RCT).
> **Population:** description (n=X, follow-up=Y).
> _Journal_ Vol(Issue):pages. PMID: [XXXXXXXX](https://pubmed.ncbi.nlm.nih.gov/XXXXXXXX)
> Vancouver-автор: первый автор + , et al. (для ≥3 авторов) + YYYY..

Substance/Dose — только для интервенционных RCT (парсинг abstract на паттерны mg, μg, IU, BID, TID, daily, weeks).

Population — парсинг abstract на паттерны n=, N =, patients, subjects, participants, follow-up, weeks, months, years.

RU-контекст — если в исходном v2.1-блоке был — RU. с комментарием, сохранить как отдельную строку > **RU:** <текст> перед PMID.

7. Safety-блоки:

Справочник критичных веществ — отдельный JSON data/critical_substances.json (создать при первом запуске, если нет):

Copy{
"selenium": {"triggers": ["selenium", "selenomethionine"], "safety": "Upper limit 400 μg/day (IOM). Chronic overdose → selenosis, alopecia, GI symptoms."},
"iodine": {"triggers": ["iodine", "iodide", "potassium iodide"], "safety": "..."},
"iron": {"triggers": ["iron", "ferrous"], "safety": "..."},
"vitamin_a": {...},
"saccharomyces_boulardii": {"triggers": ["S. boulardii", "Saccharomyces boulardii"], "safety": "Contraindicated in critically ill, immunocompromised patients, and those with central venous catheters — risk of fungemia (case reports). Not recommended for children under 2 years without medical supervision."},
...
}
Начальный список (10-15 веществ) — из EBM_STANDARD v3.1 §5. Скрипт при обнаружении substance triggers в блоке автоматически добавляет ⚠️ **Safety:** <text> из JSON.

8. Currency-блоки:

Автоматически добавлять ⏰ **Currency:** Published YYYY — verify with more recent sources. для статей старше 10 лет если тема быстро развивающаяся: microbiome, probiotics, biologics, gene therapy, immunotherapy (список keywords в скрипте).

9. Проверка PMID (валидация):

Для каждого PMID в файле:

Существует ли (esummary возвращает данные).
Совпадает ли Author, Year, Journal из блока с данными PubMed.
При MISMATCH — помечать в отчёте, не менять автоматически (это решение нутрициолога). 10. Режим -Mode apply:

Транзакционно: сначала собрать все замены в память, потом записать одним Set-Content (сохранение UTF-8 BOM + оригинальные line endings CRLF/LF).
Обязательно бэкап (даже без -Backup, минимум в \_temp/).
Обновление шапки файла: метаданные MIGRATED_v3.1, дата, счётчики.
Обновление секции References в конце файла (все уникальные PMID).
Если Prettier/автоформатёры вмешиваются — блокировать через .editorconfig marker или откатывать и переприменять. 11. Отчёт:

Файл project/_temp/reformat_reports/<file>_<mode>\_<date>.md:

Summary: файл, режим, дата, статистика (N блоков обнаружено, форматы, статус).
Per-block table: #, Line, Old format, PMID, Author, Verdict (OK / NEEDS*UPDATE / MISMATCH / SKIP).
PMID validation: таблица MATCH / MISMATCH.
Safety additions: список веществ, где добавлен Safety.
Currency additions: список статей с добавленным Currency.
Anomalies: MISMATCH, NO_PMID, NO_ABSTRACT, критические Safety.
Diff summary (для dryrun/apply): +N / -M строк, изменение байт.
Manual review required: список пунктов для нутрициолога (K1/K2/Skip решения).
Marker: EBM_REFORMAT*<mode>\_v1_APPLIED. 12. Логирование:

Все действия в project/_temp/reformat_reports/<file>_<mode>\_<date>.log.
Формат: [YYYY-MM-DD HH:mm:ss] [LEVEL] message.
Levels: INFO, WARN, ERROR.
Архитектура скрипта
Модули (внутри одного файла .ps1):

Get-EBMBlocks — обнаружение и парсинг всех форматов.
Get-PubMedData — API-клиент с кэшем.
Get-EBMLevel / Get-EBMOutcome — определение по PublicationType/MeSH/keywords.
Format-EBMv31Block — генерация нового блока.
Add-SafetyBlock — добавление Safety по справочнику.
Add-CurrencyBlock — добавление Currency по возрасту статьи.
Test-PMID — валидация PMID против PubMed.
Invoke-Migration — оркестратор apply-режима с транзакцией.
Write-Report — генерация markdown-отчёта.
Write-Log — логирование.
Правила разработки
PowerShell 5.1+ совместимость (не PowerShell Core 7+ only).
UTF-8 with BOM для всех выводов.
CRLF line endings (Windows).
Идемпотентность: повторный запуск -Mode apply на уже мигрированный файл = 0 изменений.
Не удалять не-EBM контент (заголовки, текст, таблицы, списки).
Не выдумывать данные: если данных нет в PubMed — n/a, никаких гипотез.
Все paths — относительные от корня репо.
Комментарии кода на русском (для нутрициолога-владельца), функции и переменные на английском.
Function help для каждой функции (<# .SYNOPSIS ... #>).
Задача 1 — Разработать скрипт
Создай scripts/ebm_reformat.ps1 v1.0 согласно спецификации выше.

Задача 2 — Создать справочник critical_substances.json
Создай data/critical_substances.json с начальным списком 15 веществ из EBM_STANDARD v3.1 §5 (селен, йод, железо, цинк, витамины A/D/E/K, B6, DHEA, мелатонин, ашваганда, куркумин, S. boulardii, определённые Lactobacillus).

Задача 3 — Тестовый прогон на pancreas_health.md (audit-режим)
Запусти .\scripts\ebm_reformat.ps1 -File pancreas_health.md -Mode audit -Verbose.

Ожидаемый результат:

30 EBM-блоков обнаружены как v3.0/v3.1 (все PASS).
Отчёт: 30 блоков, 0 нарушений, 17 уникальных PMID, все MATCH.
Файл не тронут.
Задача 4 — Тестовый прогон на intestinal_health.md (audit-режим)
Аналогично: 30 блоков v3.1, 24 уникальных PMID, все MATCH.

Задача 5 — Тестовый dry-run на третьем файле
Выбери файл из references/methodology/ (кроме pancreas и intestinal), у которого статус NO_EBM (например, thyroid_health.md или любой legacy-файл со статусом LEGACY_v1.1).

Запусти .\scripts\ebm_reformat.ps1 -File <name>.md -Mode dryrun -Verbose -Backup.

Ожидаемый результат:

Обнаружены EBM-блоки (или их отсутствие).
Отчёт с планом миграции.
Файл не изменён.
Если файл NO_EBM — скрипт должен корректно отработать пустой случай (0 блоков) с рекомендацией использовать --enrich режим (пометить в TECH_DEBT для v1.1).

Задача 6 — Финальный отчёт в чат
Выведи:

Список созданных/изменённых файлов с размерами:
scripts/ebm*reformat.ps1 (ожидается 30-50 KB)
data/critical_substances.json
project/\_temp/reformat_reports/*.md (3 отчёта аудит/аудит/dryrun)
project/\_temp/reformat*reports/*.log (3 лога)
Результаты 3 тестовых прогонов (сводки).
git status --short — ожидается: new scripts/ebm_reformat.ps1, new data/critical_substances.json; остальное в \_temp/ (gitignored).
Обнаруженные ограничения / edge cases для v1.1.
Рекомендации по дальнейшему улучшению (запись в TECH_DEBT).
Инструкция для нутрициолога: как запускать скрипт на оставшихся 55 файлах.
Жёсткие правила
Не изменять файлы в references/methodology/, clients/, стандарты, PROJECT_MAP.md, TECH_DEBT.md, AGENT.md, CLAUDE.md.
Не выполнять git add / commit / push.
Скрипт должен быть самодостаточным (не зависеть от других скриптов проекта).
Использовать существующий ebm_engine.ps1 только как reference (не наследовать код).
Definition of Done
✅ Скрипт создан, синтаксически корректен, запускается без ошибок.
✅ 3 тестовых прогона выполнены, отчёты сгенерированы.
✅ На двух готовых файлах (pancreas, intestinal) скрипт показывает 100% PASS.
✅ На третьем файле скрипт корректно обнаруживает legacy-формат или NO_EBM.
✅ Справочник critical_substances.json создан.
✅ Скрипт готов к запуску нутрициологом без участия LLM.
