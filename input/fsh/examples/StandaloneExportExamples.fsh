// UC-5 local export input, policy, result, and evidence.

Instance: standalone-export-evidence
InstanceOf: DISEvidence
Usage: #example
* target = Reference(https://export.example.org/fhir/Bundle/standalone-export-output)
* recorded = "2026-11-06T03:00:00Z"
* policy = "https://export.example.org/fhir/Library/standalone-export-policy/_history/1"
* activity = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-activity#dis-task
* agent.type = http://terminology.hl7.org/CodeSystem/provenance-participant-type#performer
* agent.who.identifier.system = "https://export.example.org/identifiers/actor"
* agent.who.identifier.value = "integrated-example"
* extension[outcomeStatus].valueCode = #complete
* extension[ruleSet].valueString = "local-name-removal"
* extension[reversibility].valueCode = #irreversible
* extension[validationStatus].valueCode = #valid
* extension[auditCorrelation].valueIdentifier.system = "https://export.example.org/identifiers/audit"
* extension[auditCorrelation].valueIdentifier.value = "standalone-export-01"

Instance: standalone-export-input
InstanceOf: Bundle
Usage: #example
* type = #document
* timestamp = "2026-11-06T03:00:00Z"
* identifier.system = "https://export.example.org/identifiers/document"
* identifier.value = "standalone-export-input"
* entry[0].fullUrl = "urn:uuid:5d5a1154-1d59-5a4f-911f-41a7a0ee1a20"
* entry[=].resource = standalone-export-input-composition
* entry[+].fullUrl = "urn:uuid:041bc48f-5116-5b21-8362-441f999c3a19"
* entry[=].resource = standalone-export-input-patient
* entry[+].fullUrl = "urn:uuid:475eba66-3f6c-5725-bac6-152e7f296017"
* entry[=].resource = standalone-export-input-author

Instance: standalone-export-output
InstanceOf: Bundle
Usage: #example
* type = #document
* timestamp = "2026-11-06T03:00:00Z"
* identifier.system = "https://export.example.org/identifiers/document"
* identifier.value = "standalone-export-output"
* entry[0].fullUrl = "urn:uuid:915a9497-df67-5353-a77f-8999a37835be"
* entry[=].resource = standalone-export-output-composition
* entry[+].fullUrl = "urn:uuid:0f97978f-263d-52d1-9843-bce384c4c27c"
* entry[=].resource = standalone-export-output-patient
* entry[+].fullUrl = "urn:uuid:db6cf0c2-4854-5930-a564-1d16875fd148"
* entry[=].resource = standalone-export-output-author

Instance: standalone-export-policy
InstanceOf: DISPolicy
Usage: #example
Title: "StandaloneExportPolicy"
* meta.versionId = "1"
* url = "https://export.example.org/fhir/Library/standalone-export-policy"
* version = "1.0"
* name = "StandaloneExportPolicy"
* status = #active
* type = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-library-type#dis-policy "De-identification policy (Semantic-Level or Syntax-Level rules)"
* date = "2026-11-06T03:00:00Z"
* publisher = "Example Clinical Service"
* effectivePeriod.start = "2026-01-01"
* effectivePeriod.end = "2026-12-31"
* identifier.system = "https://export.example.org/identifiers/policy"
* identifier.value = "standalone-export-policy"
* content.contentType = #application/vnd.ihe.dis.policy+json
* content.data = "eyJwb2xpY3lWZXJzaW9uIjoiMS4wIiwicmVwcmVzZW50YXRpb25MZXZlbCI6InN5bnRheCIsInJldmVyc2liaWxpdHlNb2RlIjoiaXJyZXZlcnNpYmxlIiwicGF5bG9hZEZhbWlseSI6ImZoaXIiLCJwYXlsb2FkVmVyc2lvbiI6IlI0IiwicnVsZVNldHMiOlt7InJ1bGVTZXRJZCI6ImxvY2FsLW5hbWUtcmVtb3ZhbCIsInJ1bGVzIjpbeyJydWxlSWQiOiJyZW1vdmUtbmFtZSIsInRhcmdldCI6IlBhdGllbnQubmFtZSIsImFjdGlvbiI6InJlbW92ZSJ9XX1dfQ=="

Instance: standalone-export-input-author
InstanceOf: Organization
Usage: #inline
* id = "standalone-export-input-author"
* name = "Example Clinical Service"

Instance: standalone-export-input-composition
InstanceOf: Composition
Usage: #inline
* id = "standalone-export-input-composition"
* status = #final
* type = http://loinc.org#18842-5
* subject = Reference(urn:uuid:041bc48f-5116-5b21-8362-441f999c3a19)
* date = "2026-11-06T03:00:00Z"
* author = Reference(urn:uuid:475eba66-3f6c-5725-bac6-152e7f296017)
* title = "Synthetic discharge summary"
* section.title = "Patient summary"
* section.text.status = #generated
* section.text.div = "<div xmlns=\"http://www.w3.org/1999/xhtml\"><p>Synthetic patient summary.</p></div>"
* section.entry = Reference(urn:uuid:041bc48f-5116-5b21-8362-441f999c3a19)

Instance: standalone-export-input-patient
InstanceOf: Patient
Usage: #inline
* id = "standalone-export-input-patient"
* active = true
* name.family = "Synthetic"

Instance: standalone-export-output-author
InstanceOf: Organization
Usage: #inline
* id = "standalone-export-output-author"
* name = "Example Clinical Service"

Instance: standalone-export-output-composition
InstanceOf: Composition
Usage: #inline
* id = "standalone-export-output-composition"
* status = #final
* type = http://loinc.org#18842-5
* subject = Reference(urn:uuid:0f97978f-263d-52d1-9843-bce384c4c27c)
* date = "2026-11-06T03:00:00Z"
* author = Reference(urn:uuid:db6cf0c2-4854-5930-a564-1d16875fd148)
* title = "Synthetic discharge summary"
* section.title = "Patient summary"
* section.text.status = #generated
* section.text.div = "<div xmlns=\"http://www.w3.org/1999/xhtml\"><p>Synthetic patient summary.</p></div>"
* section.entry = Reference(urn:uuid:0f97978f-263d-52d1-9843-bce384c4c27c)

Instance: standalone-export-output-patient
InstanceOf: Patient
Usage: #inline
* id = "standalone-export-output-patient"
* active = true
