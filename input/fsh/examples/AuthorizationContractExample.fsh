Instance: grouped-fhir-authorization-contract
InstanceOf: DISDataRequestAuthorizationContract
Usage: #example
Title: "UC-2 Data Request Authorization Contract"
Description: "Discovery and display of the exact Agreement revision for the two UC-2 payload sets."
* identifier.value = "https://governance.example.org/permits/grouped-fhir-permit/versions/2"
* title = "Multimodal research data preparation"
* authority.identifier.value = "https://governance.example.org/organizations/approval-authority"
* rule.contentReference = Reference(https://governance.example.org/fhir/DocumentReference/grouped-fhir-permit/_history/2)
* term[0].identifier.value = "https://governance.example.org/permits/grouped-fhir-permit/versions/2#patient-r4"
* term[0].extension[permissionValidity].extension[inclusiveStart].valueDateTime = "2026-01-01T00:00:00Z"
* term[0].extension[permissionValidity].extension[exclusiveEnd].valueDateTime = "2028-01-01T00:00:00Z"
* term[0].offer.text = "Approved scope https://governance.example.org/scopes/grouped-fhir-permit/patient-r4/versions/1"
* term[0].offer.party[requester].reference.identifier.value = "https://coordinator.example.org/organizations/requester"
* term[0].offer.party[resultRecipient].reference.identifier.value = "https://coordinator.example.org/organizations/requester"
* term[0].extension[approvedPurpose].valueUri = "https://governance.example.org/purposes/multimodal-research"
* term[0].extension[approvedPolicy].valueCanonical = "https://governance.example.org/policies/patient-name-removal|1.0"
* term[0].extension[purposeClassification][0].valueCoding.code = #4.2
* term[1].identifier.value = "https://governance.example.org/permits/grouped-fhir-permit/versions/2#imaging-report-r5"
* term[1].extension[permissionValidity].extension[inclusiveStart].valueDateTime = "2026-01-01T00:00:00Z"
* term[1].extension[permissionValidity].extension[exclusiveEnd].valueDateTime = "2028-01-01T00:00:00Z"
* term[1].offer.text = "Approved scope https://governance.example.org/scopes/grouped-fhir-permit/imaging-report-r5/versions/1"
* term[1].offer.party[requester].reference.identifier.value = "https://coordinator.example.org/organizations/requester"
* term[1].offer.party[resultRecipient].reference.identifier.value = "https://coordinator.example.org/organizations/requester"
* term[1].extension[approvedPurpose].valueUri = "https://governance.example.org/purposes/multimodal-research"
* term[1].extension[approvedPolicy].valueCanonical = "https://governance.example.org/policies/imaging-report-subject-removal|1.0"
* term[1].extension[purposeClassification][0].valueCoding.code = #4.2
