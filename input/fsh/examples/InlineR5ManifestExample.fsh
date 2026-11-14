Instance: inline-r5-manifest-package
InstanceOf: DISManifestPackage
Title: "Inline R5 Manifest Package"
Description: "R4 collection with a manifest List and a payload wrapper carrying a serialized R5 Patient."
Usage: #example
* meta.profile[0] = Canonical(DISManifestPackage)
* type = #collection
* entry[0].fullUrl = "urn:uuid:64385609-ea68-4315-b178-b70ee276061c"
* entry[0].resource = inline-r5-resource-manifest
* entry[1].fullUrl = "urn:uuid:5adb0ea3-d321-496b-8685-63529cbe90e1"
* entry[1].resource = inline-r5-payload-wrapper

Instance: inline-r5-resource-manifest
InstanceOf: DISResourceManifest
Usage: #inline
* meta.profile[0] = Canonical(DISResourceManifest)
* status = #current
* mode = #snapshot
* entry[0].item.reference = "urn:uuid:5adb0ea3-d321-496b-8685-63529cbe90e1"

Instance: inline-r5-payload-wrapper
InstanceOf: DISPayloadWrapper
Title: "Inline R5 Payload Wrapper"
Description: "R4 DocumentReference with an attachment carrying a serialized R5 Patient."
Usage: #example
* meta.profile[0] = Canonical(DISPayloadWrapper)
* status = #current
* content[0].attachment.contentType = #"application/fhir+json; fhirVersion=5.0"
* content[0].attachment.data = "eyJyZXNvdXJjZVR5cGUiOiJQYXRpZW50IiwiaWQiOiJleGFtcGxlIn0="
