/*
Project: Kcentra Flat Dosing Evaluation (Portfolio / De-identified)
Purpose: Extract documented weight-based dosing values (if captured as an EHR event) for encounters with Kcentra administrations.

Inputs (logical):
- ehr.event, pharmacy.kcentra_admin

Outputs:
- Result set with encounter_key, event timestamp, and numeric dosing value

Privacy note:
- Schema/table/column names are anonymized; logic preserved.
- No PHI is included in this repository.
*/

WITH kcentra_encounters AS (
    SELECT DISTINCT
        a.encounter_key
    FROM pharmacy.kcentra_admin a
    WHERE a.status_code <> '733'  -- example: exclude 'not given/canceled' (update to your local codes)
),
weight_dosing_events AS (
    SELECT
        e.encounter_key,
        e.event_code,
        e.event_display,
        e.event_end_dts,
        TRY_CONVERT(float, e.result_value) AS result_value_num
    FROM ehr.event e
    INNER JOIN kcentra_encounters k
        ON k.encounter_key = e.encounter_key
    WHERE e.event_code = 4154123            -- example: "Weight Dosing" event code (update locally)
      AND e.view_level_flag = 1
      AND e.valid_until_dts = '2100-12-31'
      AND e.result_status_code IN (25, 34, 35)  -- verified/modified (update locally)
      AND e.result_value IS NOT NULL
      AND LEN(e.result_value) > 0
      AND e.result_value NOT LIKE '%<%'
      AND e.result_value NOT LIKE '%>%'
      AND e.result_value NOT LIKE '%see%'
)
SELECT
    encounter_key,
    event_code,
    event_display,
    event_end_dts,
    result_value_num
FROM weight_dosing_events
WHERE result_value_num IS NOT NULL;
