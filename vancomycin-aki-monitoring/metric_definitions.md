# Metric definitions (high level)

## Therapy course logic
A **therapy course** is derived by grouping distinct administration dates for each encounter. A new course begins when there is a gap of more than a configured number of days (see `01_vanco_first_and_last_dates.sql`).

## Baseline labs (pre-dose)
Pre-dose labs are selected relative to the **first vancomycin administration timestamp** for course 1, using the time windows described in `docs/assumptions_and_windows.md`.

### Baseline median (example)
`06_vanco_pre_medians.sql` demonstrates computing a per-encounter median baseline SCr using `PERCENTILE_CONT(0.5)`.

## First SCr within ±12h
`07_vanco_first_scr_24h.sql` selects the earliest SCr result within 12 hours before/after the first dose timestamp.

## Vancomycin level counts
`08_vanco_levels_counts.sql` counts pre/post levels for component code sets representing:
- Random (Rn)
- Peak (Pk)
- Trough (Tr)

> Replace these example component codes with your local lab dictionary mapping.

## Final AKI monitoring table
`09_vanco_aki_final.sql` combines:
- therapy timing
- consecutive task-day counts
- baseline labs / first SCr window
- level counts
- post-dose extrema (as implemented)
into a single encounter-level dataset suitable for downstream analysis.
