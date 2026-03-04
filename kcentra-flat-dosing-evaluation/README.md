# Kcentra Flat Dosing Evaluation (SQL Portfolio Project)

This project demonstrates how to build a **de-identified, encounter-level outcomes dataset** to evaluate dosing practice changes for **Kcentra (4-factor PCC)** using SQL.

> **Privacy / portfolio note:** The SQL in this repo uses **anonymized schema + table names** and **generic column names**. No PHI is included. Clinical concepts, time windows, and metric logic are preserved so the analytic approach is clear and transferable.

## Problem
When dosing practices change (e.g., weight-based dosing → simplified/flat dosing), pharmacy and clinical leaders need to evaluate:
- whether key labs move in the expected direction after administration
- whether dosing and utilization patterns change
- operational variation by service line / facility (optional)

## Approach
1. Define the cohort: adult encounters with Kcentra administrations.
2. Identify the **first administration** and **administration count** per encounter.
3. Extract relevant labs **before** the first administration (most recent result).
4. Extract relevant labs **after** the first administration (first result in clinically relevant windows).
5. Create a tidy, encounter-level **outcome metric table** for downstream BI/statistics.

## Scripts (recommended order)
1. `01_kcentra_weight_based_dosing.sql` — Extract weight-based dosing values (if captured as a clinical event).
2. `02_kcentra_avg_weight.sql` — Compute average weight-based dosing value per encounter.
3. `03_kcentra_labs_before.sql` — Extract candidate labs prior to first administration.
4. `04_kcentra_labs_after.sql` — Extract candidate labs after first administration.
5. `05_kcentra_outcome_metric.sql` — Produce the encounter-level outcomes table.

## Key metrics (examples)
- INR pre-dose (most recent) and post-dose (first between **30 minutes and 24 hours**)
- Hemoglobin (Hgb) pre-dose and first post-dose
- Creatinine, AST/ALT, PT/PTT pre-dose
- Vitamin K (phytonadione) post-dose (first within **4 hours**)
- Administration count
- Average “weight-based dosing” captured value (if available)

## What you can customize
- Component/code mappings (see `docs/metric_definitions.md`)
- Time windows (parameters in `05_kcentra_outcome_metric.sql`)
- Cohort constraints (age, inpatient only, indication, etc.)

## Folder structure
- `sql/` — SQL scripts
- `docs/` — schema + metric definitions and assumptions

