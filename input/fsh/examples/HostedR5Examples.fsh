Instance: hosted-r5-input
InstanceOf: DISResourceManifest
Usage: #example
Description: "R4 input List selecting a specific revision of a hosted R5 Observation."
* entry[0].item = Reference(https://source.example.org/fhir/r5/Observation/hosted-imaging-input/_history/3)
* entry[0].item.extension[targetFhirVersion].valueCode = #5.0

Instance: hosted-r5-result
InstanceOf: DISResultPackage
Usage: #example
Description: "R4 result package whose manifest and Provenance select the same hosted R5 output revision."
* entry[0].fullUrl = "urn:uuid:49922da2-8538-41be-9c7e-85e36874f445"
* entry[0].resource = hosted-r5-output
* entry[1].fullUrl = "urn:uuid:42a0d21a-76c7-4a42-bbb4-bcbb911cbabf"
* entry[1].resource = hosted-r5-evidence

Instance: hosted-r5-output
InstanceOf: DISResourceManifest
Usage: #inline
* id = "hosted-r5-output"
* entry[0].item = Reference(https://results.example.org/fhir/r5/Observation/hosted-imaging-output/_history/1)
* entry[0].item.extension[targetFhirVersion].valueCode = #5.0

Instance: hosted-r5-evidence
InstanceOf: DISEvidence
Usage: #inline
* id = "hosted-r5-evidence"
* target = Reference(https://results.example.org/fhir/r5/Observation/hosted-imaging-output/_history/1)
* target[0].extension[targetFhirVersion].valueCode = #5.0
* recorded = "2026-11-06T03:00:00Z"
* activity = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-activity#dis-task
* policy = "https://governance.example.org/fhir/Contract/hosted-imaging-subject-removal/_history/1"
* agent.type = http://terminology.hl7.org/CodeSystem/provenance-participant-type#performer
* agent.who.identifier.system = "https://dis.example.org/identifiers/worker"
* agent.who.identifier.value = "example-worker"
* extension[outcomeStatus].valueCode = #complete
* extension[ruleSet].valueString = "remove-direct-link"
* extension[reversibility].valueCode = #irreversible
* extension[validationStatus].valueCode = #valid
* extension[auditCorrelation].valueIdentifier.system = "https://dis.example.org/identifiers/audit"
* extension[auditCorrelation].valueIdentifier.value = "hosted-r5-imaging"
