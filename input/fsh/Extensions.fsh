// DIS Extensions on Provenance

Extension: DisOutcomeStatusExt
Id: dis-outcome-status
Title: "DIS Outcome Status"
Description: "Overall outcome status of the de-identification task. Recorded in the evidence Provenance resource."
* ^url = "https://profiles.ihe.net/ITI/DIS/StructureDefinition/dis-outcome-status"
* ^status = #active
* ^context[+].type = #element
* ^context[=].expression = "Provenance"
* value[x] 1..1
* value[x] only code
* valueCode from DisOutcomeStatusVS (required)


Extension: DisRulesetExt
Id: dis-ruleset
Title: "DIS RuleSet"
Description: "Identifier of the ruleSet that produced this evidence record."
* ^url = "https://profiles.ihe.net/ITI/DIS/StructureDefinition/dis-ruleset"
* ^status = #active
* ^context[+].type = #element
* ^context[=].expression = "Provenance"
* value[x] 1..1
* value[x] only string


Extension: DisReversibilityExt
Id: dis-reversibility
Title: "DIS Reversibility"
Description: "Reversibility state of the de-identification transformations applied in the task."
* ^url = "https://profiles.ihe.net/ITI/DIS/StructureDefinition/dis-reversibility"
* ^status = #active
* ^context[+].type = #element
* ^context[=].expression = "Provenance"
* value[x] 1..1
* value[x] only code
* valueCode from DisReversibilityVS (required)


Extension: DisValidationStatusExt
Id: dis-validation-status
Title: "DIS Validation Status"
Description: "Validation result for the de-identified output produced by the task."
* ^url = "https://profiles.ihe.net/ITI/DIS/StructureDefinition/dis-validation-status"
* ^status = #active
* ^context[+].type = #element
* ^context[=].expression = "Provenance"
* value[x] 1..1
* value[x] only code
* valueCode from DisValidationStatusVS (required)


Extension: DisAuditCorrelationExt
Id: dis-audit-correlation
Title: "DIS Audit Correlation"
Description: "Identifier linking this evidence record to the ATNA audit trail."
* ^url = "https://profiles.ihe.net/ITI/DIS/StructureDefinition/dis-audit-correlation"
* ^status = #active
* ^context[+].type = #element
* ^context[=].expression = "Provenance"
* value[x] 1..1
* value[x] only Identifier


Extension: DisTransformationSummaryExt
Id: dis-transformation-summary
Title: "DIS Transformation Summary"
Description: "Summary of per-element transformation actions applied during the de-identification task. Each entry records the FHIRPath target, action applied, outcome, and the originating rule identifier."
* ^url = "https://profiles.ihe.net/ITI/DIS/StructureDefinition/dis-transformation-summary"
* ^status = #active
* ^context[+].type = #element
* ^context[=].expression = "Provenance"
* value[x] 0..0
* extension contains entry 0..*
* extension[entry] ^short = "Transformation summary entry"
* extension[entry] ^definition = "Records the action applied to a single element during the de-identification task."
* extension[entry].value[x] 0..0
* extension[entry].extension contains
    targetPath 1..1 and
    action 1..1 and
    outcome 1..1 and
    ruleId 0..1
* extension[entry].extension[targetPath].value[x] only string
* extension[entry].extension[targetPath] ^short = "FHIRPath expression identifying the transformed element"
* extension[entry].extension[action].value[x] only code
* extension[entry].extension[action].valueCode from DisActionVS (required)
* extension[entry].extension[action] ^short = "Action code applied to the element"
* extension[entry].extension[outcome].value[x] only code
* extension[entry].extension[outcome].valueCode from DisTransformationOutcomeVS (required)
* extension[entry].extension[outcome] ^short = "Outcome of the action for this element"
* extension[entry].extension[ruleId].value[x] only string
* extension[entry].extension[ruleId] ^short = "Execution plan rule identifier that triggered this action"

// Non-secret scope metadata for protected lookup-table documents.
Extension: DisIdentityLinkageScopeExt
Id: dis-identity-linkage-scope
Title: "DIS Identity Linkage Scope"
Description: "Type and non-secret identifier of the authorized linkage scope."
* ^url = "https://profiles.ihe.net/ITI/DIS/StructureDefinition/dis-identity-linkage-scope"
* ^status = #active
* ^context[+].type = #element
* ^context[=].expression = "DocumentReference"
* value[x] 0..0
* extension contains scopeType 1..1 and scopeIdentifier 1..1
* extension[scopeType].value[x] 1..1
* extension[scopeType].value[x] only code
* extension[scopeType].valueCode from DisLinkageScopeTypeVS (required)
* extension[scopeIdentifier].value[x] 1..1
* extension[scopeIdentifier].value[x] only Identifier
* extension[scopeIdentifier].valueIdentifier.system 1..1
* extension[scopeIdentifier].valueIdentifier.value 1..1

Extension: DisPolicyEvidenceUri
Id: dis-policy-evidence-uri
Title: "DIS Policy Evidence URI"
Description: "Absolute URI identifying the exact approved policy version to record in task Provenance."
* ^status = #draft
* ^context[0].type = #element
* ^context[0].expression = "RelatedArtifact"
* value[x] 1..1
* value[x] only uri
* valueUri obeys dis-absolute-policy-evidence-uri

Invariant: dis-absolute-policy-evidence-uri
Description: "The policy evidence URI is absolute and is not a canonical reference with a literal version separator."
Severity: #error
Expression: "$this.matches('^[A-Za-z][A-Za-z0-9+.-]*:[^|]+$')"

Extension: DisValidatedStageExt
Id: dis-validated-stage
Title: "DIS Validated Stage"
Description: "Identifies one validated ruleSet in an assigned stage and its position in policy order."
* ^status = #draft
* ^context[+].type = #element
* ^context[=].expression = "Provenance"
* value[x] 0..0
* extension 3..3
* extension ^slicing.rules = #closed
* extension contains
    sequence 1..1 and
    stageId 1..1 and
    ruleSetId 1..1
* extension[sequence].value[x] 1..1
* extension[sequence].value[x] only positiveInt
* extension[stageId].value[x] 1..1
* extension[stageId].value[x] only string
* extension[ruleSetId].value[x] 1..1
* extension[ruleSetId].value[x] only string
