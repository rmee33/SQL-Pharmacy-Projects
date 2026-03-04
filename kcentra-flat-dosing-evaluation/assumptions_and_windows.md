# Assumptions & analytic notes

## Cohort
- Adult encounters (age logic not included in this portfolio version unless your warehouse stores DOB/age in the admin table).
- At least one Kcentra administration per encounter.

## Data quality guardrails
- Exclude administrations that are canceled/not-given via `status_code`.
- Keep only verified/modified lab results via `status_display`.
- Keep only valid EHR events via `valid_until_dts` and `result_status_code`.

## Reproducibility
These scripts are written in a SQL Server–friendly style (CTEs, `DATEADD`, `ROW_NUMBER`). Minor edits may be required for other warehouses (Snowflake/BigQuery/Postgres).
