# Logical schema (portfolio)

This project uses generalized table names to preserve logic while removing organization-specific identifiers.

## `pharmacy.vanco_iv_administrations`
Represents IV vancomycin administrations.

**Common fields used**
- `encounter_key` (string/int): de-identified encounter identifier
- `admin_ts` (datetime): administration timestamp
- `medication_key` (string/int): medication identifier
- `medication_name` (string): display name (optional)

## `ehr.lab_result`
Represents lab results (SCr, CrCl, vancomycin levels, etc.).

**Common fields used**
- `encounter_key`
- `component_code` (string): lab component code
- `component_name` (string): display name
- `result_ts` (datetime): specimen/result timestamp
- `result_value` (numeric): numeric value where applicable
- Additional validity/status fields may exist in your environment (e.g., canceled/invalidated flags)

## `pharmacy.workload_productivity`
Represents pharmacy workflow tasks (used here for vancomycin task completion).

**Common fields used**
- `encounter_key`
- `due_ts` (datetime)
- `task_code` (string)
- `status` (string)
- `event_tag` (string)
