// Draft artifacts for proposed DICOM and CDA payload bindings.

// ── Native payload indexes ───────────────────────────────────────────────────

Profile: DISDICOMStudyIndex
Parent: ImagingStudy
Id: DIS-DICOMStudyIndex
Title: "DIS DICOM Study Index"
Description: "FHIR R4 index of the DICOM instances selected for a DIS input or result set. The study, series, and SOP Instance UIDs and the applicable WADO-RS endpoint locate the native instances."
* ^status = #draft
* identifier 1..*
* obeys dis-dicom-study-uid
* series 1..*
* series.instance 1..*
* series.endpoint ^comment = "Use an unambiguous WADO-RS endpoint for the series, falling back to the study-level WADO-RS endpoint when the series does not specify one."

Invariant: dis-dicom-study-uid
Description: "The index SHALL identify exactly one Study Instance UID using the urn:dicom:uid system and a urn:oid: value."
Severity: #error
Expression: "identifier.where(system = 'urn:dicom:uid').count() = 1 and identifier.where(system = 'urn:dicom:uid').value.startsWith('urn:oid:')"

Profile: DISCDADocumentIndex
Parent: DocumentReference
Id: DIS-CDADocumentIndex
Title: "DIS CDA Document Index"
Description: "FHIR R4 index of one native CDA document selected for a DIS input or result set. The attachment carries the original XML or identifies its retrieval endpoint."
* ^status = #draft
* status = #current
* content 1..1
* content.attachment.contentType 1..1
* content.attachment.contentType = #"application/xml"
* content.attachment obeys dis-payload-attachment-source
