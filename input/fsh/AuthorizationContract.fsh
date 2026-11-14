Alias: $DISAuthorizationPartyRole = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-authorization-party-role

CodeSystem: DISAuthorizationPartyRole
Id: dis-authorization-party-role
Title: "DIS Authorization Party Roles"
Description: "Organization roles displayed in a DIS Data Request Authorization Contract term."
* ^experimental = false
* ^caseSensitive = true
* ^content = #complete
* #requester "Authorized Requester"
* #result-recipient "Authorized result recipient"

Extension: DISApprovedPurpose
Id: dis-approved-purpose
Title: "DIS Approved Purpose"
Description: "The exact purpose IRI from the corresponding Agreement permission."
Context: Contract.term
* value[x] 1..1
* value[x] only uri
* value[x] obeys dis-absolute-iri

Extension: DISPurposeClassification
Id: dis-purpose-classification
Title: "DIS Purpose Classification"
Description: "One optional ISO/TS 14265:2024 classification of the corresponding Agreement permission's purpose."
Context: Contract.term
* value[x] 1..1
* value[x] only Coding
* valueCoding.system 1..1
* valueCoding.system = "https://www.iso.org/standard/83447.html" (exactly)
* valueCoding.version 1..1
* valueCoding.version = "2024" (exactly)
* valueCoding.code 1..1
* valueCoding.code obeys dis-purpose-classification-code

Invariant: dis-purpose-classification-code
Description: "The code is from ISO/TS 14265:2024 Table 1."
Severity: #error
Expression: "$this.matches('^[123][.][0-6]$|^4[.][0-3]$|^[567][.][0-2]$|^D4$')"

Extension: DISApprovedPolicyVersion
Id: dis-approved-policy-version
Title: "DIS Approved Policy Version"
Description: "The exact approved policy canonical and business version copied from the Agreement permission."
Context: Contract.term
* value[x] 1..1
* value[x] only canonical
* value[x] obeys dis-source-policy-version

Extension: DISPermissionValidity
Id: dis-permission-validity
Title: "DIS Permission Validity"
Description: "The inclusive lower and exclusive upper time bounds copied from the Agreement permission."
Context: Contract.term
* value[x] 0..0
* extension contains inclusiveStart 1..1 and exclusiveEnd 1..1
* extension[inclusiveStart].value[x] 1..1
* extension[inclusiveStart].value[x] only dateTime
* extension[exclusiveEnd].value[x] 1..1
* extension[exclusiveEnd].value[x] only dateTime
* obeys dis-permission-validity-order

Invariant: dis-permission-validity-order
Description: "The inclusive start precedes the exclusive end."
Severity: #error
Expression: "extension.where(url = 'inclusiveStart').value < extension.where(url = 'exclusiveEnd').value"

Profile: DISDataRequestAuthorizationContract
Parent: Contract
Id: DIS-DataRequestAuthorizationContract
Title: "DIS Data Request Authorization Contract"
Description: "Readable and searchable representation of one exact DIS Data Request Authorization Agreement revision."
* identifier 1..1
* identifier.system 1..1
* identifier.system = "urn:ietf:rfc:3986" (exactly)
* identifier.value 1..1
* identifier.value obeys dis-absolute-iri
* title 1..1
* authority 1..1
* authority only Reference(Organization)
* authority.identifier 1..1
* authority.identifier.system 1..1
* authority.identifier.system = "urn:ietf:rfc:3986" (exactly)
* authority.identifier.value 1..1
* authority.identifier.value obeys dis-absolute-iri
* rule 1..1
* rule.content[x] only Reference(DISDataRequestAuthorization)
* rule.content[x].reference 1..1
* rule.content[x].reference obeys dis-contract-agreement-reference
* applies 0..0
* term 1..*
* term.identifier 1..1
* term.identifier.system 1..1
* term.identifier.system = "urn:ietf:rfc:3986" (exactly)
* term.identifier.value 1..1
* term.identifier.value obeys dis-absolute-iri
* term.applies 0..0
* term.extension contains
    DISPermissionValidity named permissionValidity 1..1 and
    DISApprovedPurpose named approvedPurpose 1..1 and
    DISApprovedPolicyVersion named approvedPolicy 1..1 and
    DISPurposeClassification named purposeClassification 0..*
* term.group 0..0
* term.action 0..0
* term.offer.party 2..2
* term.offer.party ^slicing.discriminator.type = #pattern
* term.offer.party ^slicing.discriminator.path = "role"
* term.offer.party ^slicing.rules = #closed
* term.offer.party contains requester 1..1 and resultRecipient 1..1
* term.offer.party[requester].role = $DISAuthorizationPartyRole#requester
* term.offer.party[resultRecipient].role = $DISAuthorizationPartyRole#result-recipient
* term.offer.party.reference 1..1
* term.offer.party.reference only Reference(Organization)
* term.offer.party.reference.identifier 1..1
* term.offer.party.reference.identifier.system 1..1
* term.offer.party.reference.identifier.system = "urn:ietf:rfc:3986" (exactly)
* term.offer.party.reference.identifier.value 1..1
* term.offer.party.reference.identifier.value obeys dis-absolute-iri
* obeys dis-contract-permission-ids

Invariant: dis-contract-agreement-reference
Description: "Reference names the exact HTTPS DocumentReference version of the DIS Agreement."
Severity: #error
Expression: "$this.matches('^https://[^?# ]+/DocumentReference/[A-Za-z0-9.-]{1,64}/_history/[A-Za-z0-9.-]{1,64}$')"

Invariant: dis-contract-permission-ids
Description: "Each mirrored permission has a distinct identifier."
Severity: #error
Expression: "term.identifier.value.isDistinct()"
