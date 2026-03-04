# Anonymized schema (portfolio)

This portfolio project uses generalized table names to avoid employer/vendor-specific details. Replace these with your local equivalents.

## pharmacy.kcentra_admin
Represents medication administrations for Kcentra.

**Expected columns**
- `encounter_key` (string/int)
- `med_admin_key` (string/int) — medication administration identifier
- `med_order_key` (string/int) — medication order identifier (optional)
- `admin_dts` (datetime)
- `status_code` (string/int) — exclude “not given/canceled” rows
- `dose_amt` (numeric) — optional
- `dose_unit` (string) — optional

## ehr.event
Represents EHR “events” such as documented dosing/weight-based fields.

**Expected columns**
- `encounter_key`
- `event_code` / `event_display`
- `event_end_dts`
- `result_value` (string)
- `view_level_flag`
- `valid_until_dts`
- `result_status_code`

## ehr.lab_result
Normalized lab results table.

**Expected columns**
- `lab_result_key`
- `encounter_key`
- `component_code`
- `component_display`
- `result_dts`
- `value_numeric` (numeric or string convertible)
- `status_display` (e.g., Verified/Modified)

> If your environment stores labs as “events” instead, you can adapt the lab extraction queries accordingly.
