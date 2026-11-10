// Informative fixtures for the draft native bindings.
Instance: study-42
InstanceOf: DISDICOMStudyIndex
Usage: #example
Title: "Illustrative draft DICOM study index"
Description: "Synthetic index selecting the two CT instances in the informative mixed FHIR and DICOM walkthrough."
* meta.versionId = "3"
* identifier.system = "urn:dicom:uid"
* identifier.value = "urn:oid:1.2.826.0.1.3680043.10.543.1001"
* status = #available
* subject.display = "Synthetic imaging subject"
* endpoint = Reference(https://index.example.org/fhir/Endpoint/wado-42/_history/1)
* series[0].uid = "1.2.826.0.1.3680043.10.543.1002"
* series[0].modality = http://dicom.nema.org/resources/ontology/DCM#CT
* series[0].instance[0].uid = "1.2.826.0.1.3680043.10.543.1003"
* series[0].instance[0].sopClass = urn:ietf:rfc:3986#urn:oid:1.2.840.10008.5.1.4.1.1.2
* series[0].instance[1].uid = "1.2.826.0.1.3680043.10.543.1004"
* series[0].instance[1].sopClass = urn:ietf:rfc:3986#urn:oid:1.2.840.10008.5.1.4.1.1.2

Instance: wado-42
InstanceOf: Endpoint
Usage: #example
Title: "Illustrative WADO-RS endpoint"
Description: "Synthetic WADO-RS service referenced by the informative DICOM study index."
* meta.versionId = "1"
* status = #active
* connectionType = http://terminology.hl7.org/CodeSystem/endpoint-connection-type#dicom-wado-rs
* payloadType[0].text = "DICOM Part 10 instance"
* payloadMimeType[0] = #application/dicom
* address = "https://pacs.example.org/dicomweb"

Instance: draft-cda-document-index
InstanceOf: DISCDADocumentIndex
Usage: #example
Title: "Illustrative draft CDA document index"
Description: "Synthetic index pointing to one version of a hosted CDA XML document in the informative draft binding."
* content[0].attachment.url = "https://documents.example.org/cda/doc-42/versions/1"
