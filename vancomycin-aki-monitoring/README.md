# Vancomycin AKI Monitoring (SQL)

Portfolio SQL project demonstrating an inpatient pharmacy analytics workflow to build an encounter-level dataset for assessing acute kidney injury (AKI) risk/status among **adult IV vancomycin** patients.

> This repository version is **de-identified and generalized**. Schema/table names are anonymized; logic is preserved. No PHI is included.

## Problem
Clinical and pharmacy stakeholders need a reproducible way to:
- Define **courses of therapy** for IV vancomycin
- Establish baseline kidney function (e.g., **SCr**) and track changes after therapy start
- Quantify monitoring behavior (e.g., **vancomycin levels drawn**, pharmacy task completion)
- Produce a single, analysis-ready table to support quality / safety monitoring and performance improvement

## What’s included

### SQL (recommended order)
1. `01_vanco_first_and_last_dates.sql` — identify first/last administrations and therapy courses  
2. `02_vanco_consecutive_task_days.sql` — consecutive days of completed pharmacy tasks  
3. `03_vanco_labs_before.sql` — labs of interest prior to first dose (course 1)  
4. `04_vanco_labs_after_single_course.sql` — labs after first dose for single-course encounters  
5. `05_vanco_labs_after_multi_course.sql` — labs after course 1 and before course 2 (multi-course)  
6. `06_vanco_pre_medians.sql` — baseline (pre-dose) median labs (e.g., SCr)  
7. `07_vanco_first_scr_24h.sql` — first SCr within ±12h of first dose  
8. `08_vanco_levels_counts.sql` — counts of random/peak/trough levels pre/post first dose  
9. `09_vanco_aki_final.sql` — final encounter-level AKI monitoring table (course 1)

### Docs
- `docs/schema.md` — logical input tables/fields used in this portfolio version
- `docs/metric_definitions.md` — key metrics and component code conventions
- `docs/assumptions_and_windows.md` — time windows, cohort assumptions, and portability notes

## Key metrics (examples)
- First/last vancomycin administration timestamps (course 1)
- Consecutive days of vancomycin-related pharmacy tasks completed
- Baseline (pre-dose) SCr and median baseline labs
- First SCr within ±12 hours of therapy start
- Counts of vancomycin levels (random / peak / trough) drawn pre/post therapy start
- Post-dose SCr / CrCl extrema and related timestamps (as implemented in the final script)

## Tools & techniques demonstrated
- Therapy course grouping with date gap logic
- Time-windowed lab extraction and “closest/first” result selection with window functions
- Metric table design suitable for BI/statistical analysis
- Modular SQL organization with documented dependencies

## Privacy & portability
- Component codes are retained as examples. Replace with your local lab dictionary mapping as needed.
- All table/schema names are generalized (e.g., `ehr.lab_result`, `pharmacy.vanco_iv_administrations`).
- Remove or adapt any environment-specific functions (e.g., `CONVERT`, `PERCENTILE_CONT`) based on your SQL dialect.
