
The De-Identification Services (DIS) Profile provides a complete, testable interoperability specification for policy-governed de-identification of HL7 FHIR health data. It defines three actors -- De-ID Manager, De-Identifier, and De-Identification Requester -- four transactions (ITI-x1 Submit Job, ITI-x3 Submit Task, ITI-x4 Retrieve Job Output, and ITI-x7 Retrieve Task Output), a composable policy model, a minimum de-identification evidence baseline, and a FHIR payload binding (DIS-FHIR1).

DIS addresses the lack of a standard, interoperable workflow for how de-identification is requested, executed, validated, and delivered. It provides a governed, auditable path from authorization to delivery -- reducing reliance on manual processes and local one-off agreements. DIS starts after data request authorization has been established; it does not standardize permit lifecycle or data-request authorization.

<div markdown="1" class="stu-note">

| [Significant Changes, Open and Closed Issues](issues.html) |
{: .grid}

</div>

### Organization of This Guide

This guide is organized into the following sections:

1. Volume 1: Profiles
   1. [Introduction](volume-1.html)
   1. [Actors, Transactions, and Content Modules](volume-1.html#actors-and-transactions)
   1. [Actor Options](volume-1.html#actor-options)
   1. [Required Actor Groupings](volume-1.html#required-groupings)
   1. [Overview](volume-1.html#overview)
   1. [Security Considerations](volume-1.html#security-considerations)
   1. [Cross Profile Considerations](volume-1.html#other-grouping)
2. Volume 2: Transaction Detail
   1. [Submit Job \[ITI-x1\]](ITI-x1.html)
   1. [Submit Task \[ITI-x3\]](ITI-x3.html)
   1. [Retrieve Job Output \[ITI-x4\]](ITI-x4.html)
   1. [Retrieve Task Output \[ITI-x7\]](ITI-x7.html)
3. Volume 3: Content Modules
   1. [DIS-EXE1 Execution Plan](domain-ZZ.html)
   1. [De-ID Evidence](domain-ZZ.html#de-id-evidence)
4. Other
   1. [Changes to Other IHE Specifications](other.html)
   1. [Download and Analysis](download.html)
   1. [Test Plan](testplan.html)

See also the [Table of Contents](toc.html) and the index of [Artifacts](artifacts.html) defined as part of this implementation guide.

### Conformance Expectations

IHE uses the normative words: "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" according to [standards conventions](https://profiles.ihe.net/GeneralIntro/ch-E.html).

#### Must Support

The use of ```mustSupport``` in StructureDefinition profiles equivalent to the IHE use of **R2** as defined in [Appendix Z](https://profiles.ihe.net/ITI/TF/Volume2/ch-Z.html#z.10-profiling-conventions-for-constraints-on-fhir).

mustSupport of true - only has a meaning on items that are minimal cardinality of zero (0), and applies only to the source actor populating the data. The source actor shall populate the elements marked with MustSupport, if the concept is supported by the actor, a value exists, and security and consent rules permit.
The consuming actors should handle these elements being populated or being absent/empty.
Note that sometimes mustSupport will appear on elements with a minimal cardinality greater than zero (0), this is due to inheritance from a less constrained profile.
