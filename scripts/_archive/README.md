# Архив одноразовых скриптов

Сюда перемещаются одноразовые скрипты завершённых сессий и заменённые движки.

## Правило

- Скрипты здесь **не запускать** — они относятся к завершённым сессиям и оставлены только для истории.
- Актуальные рабочие скрипты остаются в `scripts/`:
  - `ebm_engine.ps1` — единый EBM-движок (audit | migrate | enrich), заменил `ebm_audit.ps1`.
  - `sync_check.ps1` — проверка синхронизации с GitHub.

---

## Перемещено 2026-08-14 (Этап 2 — наведение порядка в scripts/)

**Одноразовые скрипты закрытия сессий (10 шт.):**

- `close_session53.ps1`
- `close_session54.ps1`
- `close_session55.ps1`
- `close_session56.ps1`
- `close_session57.ps1`
- `close_session58.ps1`
- `close_session59.ps1`
- `close_session60.ps1`
- `close_session61.ps1`
- `close_session62.ps1`

**Одноразовые скрипты EBM-обогащения (12 шт.):**

- `ebm_enrich_autoimmune_basics.ps1`
- `ebm_enrich_covid_pregnancy.ps1`
- `ebm_enrich_female_hormones.ps1`
- `ebm_enrich_hashimoto.ps1`
- `ebm_enrich_hashimoto_v2.ps1`
- `ebm_enrich_joints_osteoporosis.ps1`
- `ebm_enrich_joints_osteoporosis_v2.ps1`
- `ebm_enrich_minerals.ps1`
- `ebm_enrich_nervous_system.ps1`
- `ebm_enrich_nutraceuticals.ps1`
- `ebm_enrich_thyroid_health.ps1`
- `ebm_enrich_vitamins.ps1`
- `ebm_enrich_vitamins_v2.ps1`

**Заменённый движок (1 шт.):**

- `ebm_audit.ps1.legacy_before_v3_engine` — старый `scripts/ebm_audit.ps1`, заменён на `scripts/ebm_engine.ps1 -Mode audit` (4-категорная классификация v3.0).

**Итого перемещено:** 23 файла.

---

## НЕ перемещены (назначение требует уточнения — оставлены в `scripts/`)

Эти скрипты не входили в задание Этапа 2 и их назначение не подтверждено. Оставлены на месте до отдельного решения:

- `audit_ebm_compliance.ps1`, `audit_links.ps1`
- `fix_session52_status.ps1`, `fix_status_session55.ps1`
- `normalize_*_v1.ps1` / `normalize_*_v2.ps1` (covid_pregnancy, female_hormones, gallbladder_health, insulin_resistance, intestinal_health, liver_health, pancreas_health, stress_adrenals)
- `patch_sources_index.ps1`
- `unify_metadata.ps1`, `unify_metadata_v2.ps1`
- `update_*.ps1` (cluster_field, ebm_plan_session48, ebm_workflow_session48, playbook_L057, sources_index_session50, status_session48/50/51/52, tech_debt_and_lessons_s58, s58_tail, s59_tail)
