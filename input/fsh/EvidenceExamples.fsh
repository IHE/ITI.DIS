RuleSet: EvidenceExampleEntry(path, action, ruleId)
* extension[transformationSummary].extension[entry][+].extension[targetPath].valueString = "{path}"
* extension[transformationSummary].extension[entry][=].extension[action].valueCode = #{action}
* extension[transformationSummary].extension[entry][=].extension[outcome].valueCode = #applied
* extension[transformationSummary].extension[entry][=].extension[ruleId].valueString = "{ruleId}"

Instance: dis-evidence-uc3-001
InstanceOf: DISEvidence
Usage: #example
Title: "Clinical pathology order de-identification evidence"
Description: "Evidence for a completed synchronous pseudonymization task in Use Case 3."
* extension[outcomeStatus].valueCode = #complete
* extension[ruleSet].valueString = "direct-identifiers"
* extension[reversibility].valueCode = #reversible
* extension[validationStatus].valueCode = #valid
* extension[auditCorrelation].valueIdentifier.system = "https://hospital.example.org/systems/dis-audit"
* extension[auditCorrelation].valueIdentifier.value = "audit-corr-20261104-001"
* insert EvidenceExampleEntry(Patient.identifier, hash, R01)
* insert EvidenceExampleEntry(Patient.name, remove, R02)
* target[0] = Reference(pseudonym-abc123)
* recorded = "2026-11-04T10:30:00Z"
* policy[0] = "https://hospital.example.org/dis/policies/hospital-lab-pseudonymization/1.0"
* activity = DisActivity#dis-task "DIS De-Identification Task"
* agent[0].type = http://terminology.hl7.org/CodeSystem/provenance-participant-type#performer
* agent[0].who.identifier.system = "https://hospital.example.org/systems/de-identifiers"
* agent[0].who.identifier.value = "de-identifier-01"

Instance: pseudonym-abc123
InstanceOf: Patient
Usage: #example
Title: "Pseudonymized patient for the evidence example"
Description: "Synthetic output Patient referenced by the Use Case 3 Provenance example."
* identifier[0].system = "https://hospital.example.org/identifiers/pseudonym"
// Derived with the public salted SHA-256 test vector in Volume 3.
* identifier[0].value = "8162610a149e7b6700513fa3f0ceff46328e2b584fd3d351e4d5c2775a42ff0c"
