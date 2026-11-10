// These NamingSystems describe synthetic example namespaces.
RuleSet: SyntheticLookupNamingSystem(name, uri)
* name = "{name}"
* status = #draft
* kind = #identifier
* date = "2026-11-11"
* uniqueId[0].type = #uri
* uniqueId[0].value = "{uri}"
* uniqueId[0].preferred = true

Instance: example-lookup-table-identifiers
InstanceOf: NamingSystem
Usage: #example
Title: "Synthetic lookup table identifiers"
Description: "Synthetic namespace identifying the lookup tables used in the DIS examples."
* insert SyntheticLookupNamingSystem(ExampleLookupTableIdentifiers, urn:example:lookup-table)

Instance: example-lookup-content-versions
InstanceOf: NamingSystem
Usage: #example
Title: "Synthetic lookup table content versions"
Description: "Synthetic namespace identifying the content versions of lookup tables used in the DIS examples."
* insert SyntheticLookupNamingSystem(ExampleLookupContentVersions, urn:example:lookup-content-version)

Instance: example-trial-linkage-scopes
InstanceOf: NamingSystem
Usage: #example
Title: "Synthetic trial linkage scopes"
Description: "Synthetic namespace identifying linkage scopes used in the DIS trial lookup examples."
* insert SyntheticLookupNamingSystem(ExampleTrialLinkageScopes, https://trial.example/identifiers/linkage-scope)
