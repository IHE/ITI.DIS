// DIS CodeSystems and ValueSets

// ── CodeSystems ──────────────────────────────────────────────────────────────

CodeSystem: DisLibraryType
Id: dis-library-type
Title: "DIS Library Type"
Description: "Codes classifying the type of DIS Library artifact: de-identification policy or execution plan."
* ^url = "https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-library-type"
* ^status = #active
* ^experimental = false
* #dis-policy "De-identification policy (Semantic-Level or Syntax-Level rules)"
* #dis-execution-plan "Execution plan (payload-specific compiled rules)"


CodeSystem: DisActivity
Id: dis-activity
Title: "DIS Activity"
Description: "Activity codes recorded in DIS Provenance evidence resources."
* ^url = "https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-activity"
* ^status = #active
* ^experimental = false
* #dis-task "DIS De-Identification Task"


CodeSystem: DisOutcomeStatus
Id: dis-outcome-status
Title: "DIS Outcome Status"
Description: "Overall outcome status of a DIS de-identification task."
* ^url = "https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-outcome-status"
* ^status = #active
* ^experimental = false
* #complete "De-identification task completed successfully"
* #error "De-identification task failed"


CodeSystem: DisReversibility
Id: dis-reversibility
Title: "DIS Reversibility"
Description: "Reversibility state of de-identification transformations applied in a task."
* ^url = "https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-reversibility"
* ^status = #active
* ^experimental = false
* #irreversible "Transformation cannot be reversed"
* #reversible "Transformation can be reversed with access to the identity table"


CodeSystem: DisValidationStatus
Id: dis-validation-status
Title: "DIS Validation Status"
Description: "Validation result for de-identified output produced by a DIS task."
* ^url = "https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-validation-status"
* ^status = #active
* ^experimental = false
* #valid "Output passed validation"
* #invalid "Output failed validation"


CodeSystem: DisTransformationOutcome
Id: dis-transformation-outcome
Title: "DIS Transformation Outcome"
Description: "Per-element outcome codes recorded in the DIS transformation summary."
* ^url = "https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-transformation-outcome"
* ^status = #active
* ^experimental = false
* #applied "Action was applied to the element"
* #skipped "Element was not present in the resource"
* #error "Action failed for this element"


CodeSystem: DisAction
Id: dis-action
Title: "DIS Transformation Action"
Description: "Transformation action codes from the DIS Phase 1 core action family."
* ^url = "https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-action"
* ^status = #active
* ^experimental = false
* #suppress "Remove the element entirely from the resource"
* #pseudonymize "Replace with a deterministic pseudonym derived from seed material and the input value"
* #generalize "Reduce the precision of the value"
* #date-shift "Shift all dates by a consistent per-patient offset derived from seed material"
* #mask "Replace the value with a fixed mask string"
* #redact-narrative "Remove or sanitize the narrative content"
* #cryptographic-hash "Replace with a one-way cryptographic hash of the value"
* #perturb "Add noise to a numeric value"


// ── ValueSets ────────────────────────────────────────────────────────────────

ValueSet: DisOutcomeStatusVS
Id: dis-outcome-status-vs
Title: "DIS Outcome Status Value Set"
Description: "Outcome status codes for a DIS de-identification task."
* ^url = "https://profiles.ihe.net/ITI/DIS/ValueSet/dis-outcome-status-vs"
* ^status = #active
* ^experimental = false
* include codes from system DisOutcomeStatus


ValueSet: DisReversibilityVS
Id: dis-reversibility-vs
Title: "DIS Reversibility Value Set"
Description: "Reversibility state codes for DIS de-identification transformations."
* ^url = "https://profiles.ihe.net/ITI/DIS/ValueSet/dis-reversibility-vs"
* ^status = #active
* ^experimental = false
* include codes from system DisReversibility


ValueSet: DisValidationStatusVS
Id: dis-validation-status-vs
Title: "DIS Validation Status Value Set"
Description: "Validation result codes for de-identified output produced by a DIS task."
* ^url = "https://profiles.ihe.net/ITI/DIS/ValueSet/dis-validation-status-vs"
* ^status = #active
* ^experimental = false
* include codes from system DisValidationStatus


ValueSet: DisTransformationOutcomeVS
Id: dis-transformation-outcome-vs
Title: "DIS Transformation Outcome Value Set"
Description: "Per-element outcome codes for the DIS transformation summary."
* ^url = "https://profiles.ihe.net/ITI/DIS/ValueSet/dis-transformation-outcome-vs"
* ^status = #active
* ^experimental = false
* include codes from system DisTransformationOutcome


ValueSet: DisActionVS
Id: dis-action-vs
Title: "DIS Transformation Action Value Set"
Description: "Transformation action codes from the DIS core action family."
* ^url = "https://profiles.ihe.net/ITI/DIS/ValueSet/dis-action-vs"
* ^status = #active
* ^experimental = false
* include codes from system DisAction
