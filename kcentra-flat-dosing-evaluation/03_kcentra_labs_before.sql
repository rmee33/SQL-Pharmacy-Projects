/*
Project: Kcentra Flat Dosing Evaluation (Portfolio / De-identified)
Purpose: Extract candidate lab results prior to first Kcentra administration (pre-dose context).

Inputs (logical):
- ehr.lab_result, ehr.event (optional for Vitamin K), pharmacy.kcentra_admin

Outputs:
- Row-level lab result set for encounters prior to first administration

Privacy note:
- Schema/table/column names are anonymized; logic preserved.
- No PHI is included in this repository.
*/

WITH first_admin AS (
    SELECT
        a.encounter_key,
        MIN(a.admin_dts) AS first_kcentra_admin_dts
    FROM pharmacy.kcentra_admin a
    WHERE a.status_code <> '733'
    GROUP BY a.encounter_key
),
labs_pre AS (
    SELECT
        lr.lab_result_key,
        lr.encounter_key,
        lr.component_code,
        lr.component_display,
        lr.result_dts,
        lr.value_numeric
    FROM ehr.lab_result lr
    INNER JOIN first_admin fa
        ON fa.encounter_key = lr.encounter_key
    WHERE lr.component_code IN (
        '5103209', -- INR
        '5103193', -- Hgb
        '5103261', -- PT
        '5103265', -- PTT
        '5103009', -- AST
        '5102789', -- ALT
        '2700655'  -- Creatinine
    )
      AND lr.result_dts < fa.first_kcentra_admin_dts
      AND lr.status_display IN ('Auth (Verified)', 'Modified/Amended', 'Modified')
),
vitk_pre AS (
    -- Example Vitamin K captured as an EHR event instead of a normalized lab_result row.
    SELECT
        CAST(e.event_id AS varchar(255)) AS lab_result_key,
        e.encounter_key,
        CAST(e.event_code AS varchar(255)) AS component_code,
        e.event_display AS component_display,
        e.event_end_dts AS result_dts,
        e.result_value AS value_numeric
    FROM ehr.event e
    INNER JOIN first_admin fa
        ON fa.encounter_key = e.encounter_key
    WHERE e.event_code = 2798478           -- Vitamin K / phytonadione (example)
      AND e.event_end_dts < fa.first_kcentra_admin_dts
      AND e.view_level_flag = 1
      AND e.valid_until_dts = '2100-12-31'
      AND e.result_status_code IN (25, 34, 35)
      AND e.result_value IS NOT NULL
)
SELECT * FROM labs_pre
UNION ALL
SELECT * FROM vitk_pre;
