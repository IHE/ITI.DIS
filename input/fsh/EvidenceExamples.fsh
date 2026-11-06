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
* insert EvidenceExampleEntry(Patient.address, remove, R03)
* insert EvidenceExampleEntry(Patient.telecom, remove, R04)
* insert EvidenceExampleEntry(Patient.birthDate, date-shift, R05)
* insert EvidenceExampleEntry(Patient.photo, remove, R06)
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
* identifier[0].system = "urn:example:subject"
// Derived with the public seed in Volume 3, scope hospital-lab-project-2026 and key version 1.
* identifier[0].value = "fec7ac7f9887a63b789b201fbe41fdd153c6438838179c2ac7f82b3f2c6bd4ab"
* birthDate = "1985-04-23"
