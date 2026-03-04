# Assumptions & time windows (portfolio)

This project is presented as a **portfolio artifact**. Adapt these assumptions to your environment and clinical governance standards.

## Cohort
- Adult encounters (commonly age >= 18); age filtering may occur upstream depending on data availability.

## Therapy course grouping
- Courses are separated by gaps in administration dates (example: >2 days). See `01_vanco_first_and_last_dates.sql`.
- The AKI monitoring table focuses on the **first course of therapy**.

## Lab windows (examples)
- **Baseline (pre-dose):** labs prior to first dose timestamp (course 1), optionally within a lookback window.
- **First SCr near start:** within ±12 hours of first dose timestamp.
- **After-dose windows:** for single-course encounters, after first dose until discharge (or a defined end); for multi-course, after course 1 start and before course 2 start.

## Portability
- SQL dialect: scripts use functions like `CONVERT` and `PERCENTILE_CONT`. Adjust for your database (e.g., Postgres vs SQL Server vs Snowflake).
- Component codes: maintained only as examples—substitute your lab dictionary codes.
- Identifiers: `encounter_key` is a de-identified placeholder. Do not publish real encounter identifiers.
