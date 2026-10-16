# EBM Migration State — реестр миграции legacy → v3.1

**Назначение:** единственный документ, фиксирующий сосуществование двух форматов EBM-разметки и очередь миграции. Отвечает на вопрос «почему в проекте два формата».

**Контракт (ACTIVE):** `project/EBM_STANDARD_v2.0.md` v3.1.
**Legacy-спецификация (SUPERSEDED):** `project/EBM_STANDARD.md` v1.0 — заморожена, применяется только к ещё не мигрированным файлам, напрямую НЕ редактируется.
**Источник истины по цифрам:** `scripts/ebm_audit_v2.ps1` (read-only, считает оба формата).

## Каноническая метрика (на 2026-10-16, Session 63)

- **EBM-единица = 1 тег-блок.** legacy и v3.1 эквивалентны (1 блок = 1 единица).
- **Порог FULL_EBM = >=30 блоков.** PMID считается справочно, в порог НЕ входит.
- **Итого:** 17 FULL_EBM файлов, 690 EBM-единиц = 629 legacy + 61 v3.1. PMID справочно: 207.

## Правило миграции

1. Миграция выполняется движком `scripts/ebm_engine.ps1` пофайлово (пилотами), НЕ массово.
2. `scripts/ebm_reformat.ps1` — сломан, НЕ запускать.
3. После каждой миграции: прогон `ebm_audit_v2.ps1` (должен быть INVARIANTS: clean OK), затем один коммит на файл.
4. Каждая рабочая сессия получает нумерованный заголовок в STATUS.md.

## Карта файлов

### Уже в v3.1 (2 файла)
| Файл | Блоки v3.1 | PMID | Статус |
|---|---|---|---|
| pancreas_health.md | 31 | 52 | MIGRATED_v3.0 (пилот #1, 2026-08-14) |
| intestinal_health.md | 30 | 59 | MIGRATED_v3.1 (пилот #2) |

### Legacy — очередь на миграцию v3.1 (15 файлов)
| Файл | Блоки legacy | Приоритет |
|---|---|---|
| thyroid_health.md | 99 | — |
| nutraceuticals.md | 74 | — |
| autoimmune_basics.md | 69 | — |
| vitamins.md | 43 | — |
| nervous_system.md | 36 | — |
| hashimoto.md | 34 | — |
| joints_osteoporosis.md | 33 | — |
| menopause.md | 31 | — |
| female_hormones.md | 30 | — |
| covid_pregnancy.md | 30 | — |
| stress_adrenals.md | 30 | — |
| minerals.md | 30 | — |
| liver_health.md | 30 | — |
| gallbladder_health.md | 30 | — |
| insulin_resistance.md | 30 | — |

### Прочее
| Файл | Состояние |
|---|---|
| ibd.md | NO_EBM (контент готов, EBM в очереди); не FULL, не считается |

## Решение Р1 (зафиксировано)

Уже обогащённые legacy-файлы остаются в старом формате; новое обогащение — в v3.1; массовая миграция legacy -> v3.1 отложена как отдельная задача (Session 64+). Legacy не ломаем.

<!-- EBM_MIGRATION_STATE_v1.0 | source: scripts/ebm_audit_v2.ps1 | 2026-10-16 -->