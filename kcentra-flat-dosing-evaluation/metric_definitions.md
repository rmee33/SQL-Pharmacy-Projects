# Metric definitions & code mappings (portfolio)

The SQL references **component codes** as examples (common in EHR warehouses). In your environment, replace these codes with local mappings.

## Labs (examples)
- INR: `5103209`
- Hemoglobin (Hgb): `5103193`
- PT: `5103261`
- PTT: `5103265`
- AST: `5103009`
- ALT: `5102789`
- Creatinine (SCr): `2700655`
- Vitamin K (phytonadione): `2798478` (captured as an `ehr.event` in this example)

## Windows used in outcome table
These are configurable in `05_kcentra_outcome_metric.sql`:

- **Pre-dose labs:** most recent result **before** first Kcentra administration
- **Vitamin K post-dose:** first result within **0 to 4 hours** after first administration
- **INR post-dose:** first result within **30 minutes to 24 hours** after first administration
- **Hgb post-dose:** first result after first administration (no upper bound by default)

## Notes
- Status filters retain verified/modified results.
- String lab values with non-numeric symbols can be excluded or parsed based on local standards.
