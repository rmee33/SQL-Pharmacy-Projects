/*
Project: Kcentra Flat Dosing Evaluation (Portfolio / De-identified)
Purpose: Compute the average documented weight-based dosing value per encounter.

Inputs (logical):
- sql/01_kcentra_weight_based_dosing.sql output (or an equivalent table/view)

Outputs:
- Result set with encounter_key and avg_weight_dose_value

Privacy note:
- Schema/table/column names are anonymized; logic preserved.
- No PHI is included in this repository.
*/

/*
If you materialize the output of 01 into a table/view (recommended), replace the CTE below with that object.
*/

WITH weight_dosing AS (
    -- Replace this CTE with: SELECT * FROM analytics.kcentra_weight_dosing;
    SELECT
        encounter_key,
        result_value_num
    FROM (
        -- Placeholder: point to your persisted extraction
        SELECT
            encounter_key,
            result_value_num
        FROM analytics.kcentra_weight_dosing  -- expected persisted object
    ) x
)
SELECT
    encounter_key,
    AVG(result_value_num) AS avg_weight_dose_value
FROM weight_dosing
GROUP BY encounter_key;
