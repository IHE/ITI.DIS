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
* #irreversible "No DIS-maintained reverse-mapping capability; does not guarantee prevention of identification"
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
Description: """
Transformation action codes from the DIS Phase 1 core action family.
Each action is a concrete, deterministic function with
well-defined parameters and testable output. Actions are classified by
their ISO/IEC 20889:2018 de-identification technique via the technique
property. Action design is informed by RSNA CTP DICOM Anonymizer
function patterns.
"""
* ^url = "https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-action"
* ^status = #active
* ^experimental = false
* ^property[+].code = #technique
* ^property[=].description = "ISO/IEC 20889:2018 de-identification technique implemented by this action"
* ^property[=].type = #code
* #remove "Remove the element entirely from the resource"
* #remove ^property[+].code = #technique
* #remove ^property[=].valueCode = #local-suppression
* #replace "Replace content with a fixed value or apply an authoritative reversible lookup mapping"
* #replace ^property[+].code = #technique
* #replace ^property[=].valueCode = #masking
* #replace ^property[+].code = #technique
* #replace ^property[=].valueCode = #pseudonymization
* #keep "Preserve the element unchanged in the de-identified output"
* #hash "Salted or unsalted digest under the execution plan."
* #hash ^property[+].code = #technique
* #hash ^property[=].valueCode = #hashing
* #truncate-date "Reduce date precision by truncating to year or year-month"
* #truncate-date ^property[+].code = #technique
* #truncate-date ^property[=].valueCode = #rounding
* #date-shift "Shift dates by a consistent per-patient offset under the declared date-shift capability"
* #date-shift ^property[+].code = #technique
* #date-shift ^property[=].valueCode = #noise-addition
* #round "Bin a numeric value to the nearest multiple of the step parameter"
* #round ^property[+].code = #technique
* #round ^property[=].valueCode = #rounding
* #truncate "Keep the first N characters of a string value"
* #truncate ^property[+].code = #technique
* #truncate ^property[=].valueCode = #generalization
* #redact "Remove the narrative content from a resource"
* #redact ^property[+].code = #technique
* #redact ^property[=].valueCode = #local-suppression


CodeSystem: DisIsoTechnique
Id: dis-iso-technique
Title: "ISO/IEC 20889 De-Identification Technique"
Description: """
De-identification technique codes from ISO/IEC 20889:2018 §9. Used as
the technique classification for DIS transformation actions. Phase 1
uses a subset; the full CodeSystem provides vocabulary for future phases.
"""
* ^url = "https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-iso-technique"
* ^status = #active
* ^experimental = false
* #local-suppression "Local suppression (ISO/IEC 20889 §9.3.3)"
* #masking "Masking (ISO/IEC 20889 §9.3.2)"
* #hashing "Hashing (ISO/IEC 20889 §9.4.3.3)"
* #pseudonymization "Pseudonymization — independent of attributes (ISO/IEC 20889 §9.4.3.2)"
* #generalization "Generalization (ISO/IEC 20889 §9.6)"
* #rounding "Rounding (ISO/IEC 20889 §9.6.2)"
* #noise-addition "Noise addition (ISO/IEC 20889 §9.7.2)"
* #scrubbing "Scrubbing — free-form text de-identification (ISO/IEC 20889 Annex C.4)"


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

CodeSystem: DisDocumentType
Id: dis-document-type
Title: "DIS Document Type"
Description: "Document types for identified DIS operational artifacts."
* ^url = "https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-document-type"
* ^status = #active
* ^experimental = false
* #lookup-table "DIS reversible lookup table"

CodeSystem: DisLinkageScopeType
Id: dis-linkage-scope-type
Title: "DIS Linkage Scope Type"
Description: "Authorized boundaries for consistent DIS pseudonyms."
* ^status = #draft
* ^caseSensitive = true
* ^content = #complete
* #job "Job"
* #source-institution "Source institution"
* #cross-community "Cross-community"

ValueSet: DisLinkageScopeTypeVS
Id: dis-linkage-scope-type-vs
Title: "DIS Linkage Scope Types"
Description: "Scope types for DIS policies and lookup tables."
* ^status = #draft
* include codes from system DisLinkageScopeType
