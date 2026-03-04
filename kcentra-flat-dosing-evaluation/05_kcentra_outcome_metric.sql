/*
Project: Kcentra Flat Dosing Evaluation (Portfolio / De-identified)
Purpose: Produce an encounter-level outcomes dataset joining Kcentra utilization + pre/post labs + dosing metrics.

Inputs (logical):
- pharmacy.kcentra_admin, ehr.lab_result, ehr.event (optional), analytics.kcentra_weight_dosing (optional)

Outputs:
- Encounter-level result set suitable for BI/statistics (one row per encounter)

Privacy note:
- Schema/table/column names are anonymized; logic preserved.
- No PHI is included in this repository.
*/

/*
Parameter notes
- Adjust the windows below to match your clinical + operational definitions.
*/
DECLARE @inr_post_min_minutes int = 30;
DECLARE @inr_post_max_hours  int = 24;
DECLARE @vitk_post_max_hours int = 4;

WITH admin_base AS (
    SELECT
        a.encounter_key,
        a.med_admin_key,
        a.med_order_key,
        a.admin_dts,
        a.status_code,
        a.dose_amt,
        a.dose_unit
    FROM pharmacy.kcentra_admin a
    WHERE a.status_code <> '733'
),
first_admin AS (
    SELECT
        encounter_key,
        MIN(admin_dts) AS first_kcentra_admin_dts
    FROM admin_base
    GROUP BY encounter_key
),
admin_count AS (
    SELECT
        encounter_key,
        COUNT(*) AS kcentra_admin_count
    FROM admin_base
    GROUP BY encounter_key
),
-- Optional: average weight-based dosing value if you persist the extraction from script 01
avg_weight_dose AS (
    SELECT
        encounter_key,
        AVG(result_value_num) AS avg_weight_dose_value
    FROM analytics.kcentra_weight_dosing
    GROUP BY encounter_key
),
/* -------------------------
   Pre-dose labs: last result before first admin
--------------------------*/
pre_labs_ranked AS (
    SELECT
        lr.encounter_key,
        lr.component_code,
        lr.result_dts,
        TRY_CONVERT(float, lr.value_numeric) AS value_num,
        ROW_NUMBER() OVER (
            PARTITION BY lr.encounter_key, lr.component_code
            ORDER BY lr.result_dts DESC
        ) AS rn
    FROM ehr.lab_result lr
    INNER JOIN first_admin fa
        ON fa.encounter_key = lr.encounter_key
    WHERE lr.component_code IN ('5103209','5103193','5103261','5103265','5103009','5102789','2700655')
      AND lr.result_dts < fa.first_kcentra_admin_dts
      AND lr.status_display IN ('Auth (Verified)', 'Modified/Amended', 'Modified')
),
pre_labs AS (
    SELECT
        encounter_key,
        MAX(CASE WHEN component_code = '5103209' AND rn = 1 THEN value_num END) AS inr_pre_value,
        MAX(CASE WHEN component_code = '5103209' AND rn = 1 THEN result_dts END) AS inr_pre_dts,
        MAX(CASE WHEN component_code = '5103193' AND rn = 1 THEN value_num END) AS hgb_pre_value,
        MAX(CASE WHEN component_code = '5103193' AND rn = 1 THEN result_dts END) AS hgb_pre_dts,
        MAX(CASE WHEN component_code = '2700655' AND rn = 1 THEN value_num END) AS scr_pre_value,
        MAX(CASE WHEN component_code = '2700655' AND rn = 1 THEN result_dts END) AS scr_pre_dts,
        MAX(CASE WHEN component_code = '5103261' AND rn = 1 THEN value_num END) AS pt_pre_value,
        MAX(CASE WHEN component_code = '5103261' AND rn = 1 THEN result_dts END) AS pt_pre_dts,
        MAX(CASE WHEN component_code = '5103265' AND rn = 1 THEN value_num END) AS ptt_pre_value,
        MAX(CASE WHEN component_code = '5103265' AND rn = 1 THEN result_dts END) AS ptt_pre_dts,
        MAX(CASE WHEN component_code = '5102789' AND rn = 1 THEN value_num END) AS alt_pre_value,
        MAX(CASE WHEN component_code = '5102789' AND rn = 1 THEN result_dts END) AS alt_pre_dts,
        MAX(CASE WHEN component_code = '5103009' AND rn = 1 THEN value_num END) AS ast_pre_value,
        MAX(CASE WHEN component_code = '5103009' AND rn = 1 THEN result_dts END) AS ast_pre_dts
    FROM pre_labs_ranked
    GROUP BY encounter_key
),
/* -------------------------
   Post-dose labs: first result in windows
--------------------------*/
post_labs_ranked AS (
    SELECT
        lr.encounter_key,
        lr.component_code,
        lr.result_dts,
        TRY_CONVERT(float, lr.value_numeric) AS value_num,
        fa.first_kcentra_admin_dts,
        ROW_NUMBER() OVER (
            PARTITION BY lr.encounter_key, lr.component_code
            ORDER BY lr.result_dts ASC
        ) AS rn_any_post,
        ROW_NUMBER() OVER (
            PARTITION BY lr.encounter_key
            ORDER BY lr.result_dts ASC
        ) AS rn_inr_window
    FROM ehr.lab_result lr
    INNER JOIN first_admin fa
        ON fa.encounter_key = lr.encounter_key
    WHERE lr.component_code IN ('5103209','5103193')
      AND lr.result_dts > fa.first_kcentra_admin_dts
      AND lr.status_display IN ('Auth (Verified)', 'Modified/Amended', 'Modified')
),
inr_post_window AS (
    SELECT
        encounter_key,
        value_num AS inr_post_value,
        result_dts AS inr_post_dts
    FROM (
        SELECT
            encounter_key,
            value_num,
            result_dts,
            ROW_NUMBER() OVER (
                PARTITION BY encounter_key
                ORDER BY result_dts ASC
            ) AS rn
        FROM post_labs_ranked
        WHERE component_code = '5103209'
          AND result_dts >= DATEADD(minute, @inr_post_min_minutes, first_kcentra_admin_dts)
          AND result_dts <= DATEADD(hour,   @inr_post_max_hours,  first_kcentra_admin_dts)
    ) x
    WHERE rn = 1
),
hgb_first_post AS (
    SELECT
        encounter_key,
        value_num AS hgb_post_value,
        result_dts AS hgb_post_dts
    FROM (
        SELECT
            encounter_key,
            value_num,
            result_dts,
            ROW_NUMBER() OVER (
                PARTITION BY encounter_key
                ORDER BY result_dts ASC
            ) AS rn
        FROM post_labs_ranked
        WHERE component_code = '5103193'
    ) x
    WHERE rn = 1
),
vitk_first_within_4h AS (
    -- Vitamin K in this example is captured as an EHR event
    SELECT
        encounter_key,
        TRY_CONVERT(float, result_value) AS vitk_post_value,
        event_end_dts AS vitk_post_dts
    FROM (
        SELECT
            e.encounter_key,
            e.result_value,
            e.event_end_dts,
            ROW_NUMBER() OVER (
                PARTITION BY e.encounter_key
                ORDER BY e.event_end_dts ASC
            ) AS rn
        FROM ehr.event e
        INNER JOIN first_admin fa
            ON fa.encounter_key = e.encounter_key
        WHERE e.event_code = 2798478
          AND e.event_end_dts >= fa.first_kcentra_admin_dts
          AND e.event_end_dts <= DATEADD(hour, @vitk_post_max_hours, fa.first_kcentra_admin_dts)
          AND e.view_level_flag = 1
          AND e.valid_until_dts = '2100-12-31'
          AND e.result_status_code IN (25, 34, 35)
          AND e.result_value IS NOT NULL
    ) x
    WHERE rn = 1
),
first_admin_row AS (
    -- Keep the first administration row for context (dose, order key, etc.)
    SELECT
        a.*
    FROM (
        SELECT
            ab.*,
            ROW_NUMBER() OVER (
                PARTITION BY ab.encounter_key
                ORDER BY ab.admin_dts ASC
            ) AS rn
        FROM admin_base ab
    ) a
    WHERE rn = 1
)
SELECT
    far.encounter_key,
    far.med_admin_key,
    far.med_order_key,
    fa.first_kcentra_admin_dts,
    ac.kcentra_admin_count,

    awd.avg_weight_dose_value,

    pl.inr_pre_value,
    pl.inr_pre_dts,
    pl.hgb_pre_value,
    pl.hgb_pre_dts,
    pl.scr_pre_value,
    pl.scr_pre_dts,
    pl.pt_pre_value,
    pl.pt_pre_dts,
    pl.ptt_pre_value,
    pl.ptt_pre_dts,
    pl.alt_pre_value,
    pl.alt_pre_dts,
    pl.ast_pre_value,
    pl.ast_pre_dts,

    ipw.inr_post_value,
    ipw.inr_post_dts,
    hfp.hgb_post_value,
    hfp.hgb_post_dts,
    v4h.vitk_post_value,
    v4h.vitk_post_dts,

    far.dose_amt AS first_dose_amt,
    far.dose_unit AS first_dose_unit

FROM first_admin_row far
INNER JOIN first_admin fa
    ON fa.encounter_key = far.encounter_key
LEFT JOIN admin_count ac
    ON ac.encounter_key = far.encounter_key
LEFT JOIN avg_weight_dose awd
    ON awd.encounter_key = far.encounter_key
LEFT JOIN pre_labs pl
    ON pl.encounter_key = far.encounter_key
LEFT JOIN inr_post_window ipw
    ON ipw.encounter_key = far.encounter_key
LEFT JOIN hgb_first_post hfp
    ON hfp.encounter_key = far.encounter_key
LEFT JOIN vitk_first_within_4h v4h
    ON v4h.encounter_key = far.encounter_key;
