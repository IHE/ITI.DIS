# Encryption-based reversible pseudonymization

Draft design for [issue #50](https://github.com/IHE/ITI.DIS/issues/50).

## Actor responsibilities

Add encryption as an optional way to generate patient business identifier pseudonyms under DIS-REVERSIBLE. The approved policy selects this method. A De-Identifier that supports the method applies it to the assigned identifiers and updates references that carry those business identifiers. The existing arrangements for Manager-managed hash mappings and Requester-supplied tables remain available. Reject a job that supplies a table and instructs DIS to generate encrypted patient pseudonyms.

When an assigned task generates encrypted patient pseudonyms, the De-Identifier returns the original-to-pseudonym identifier pairs to the Manager in the existing protected `generatedLookupTable` output. The same output applies to synchronous ITI-x3 and successful asynchronous ITI-x7 responses. The Manager validates the table against the assigned task and resolved scope, checks consistency across results, and retains the mappings before releasing the job result. The Manager uses the existing deployment-defined lookup workflow to resolve a pseudonym for an authorized caller. The Integrated actor performs the applicable duties internally.

The task authorization must cover disclosure of the generated mappings to the Manager. Authorization to receive the pseudonymized dataset does not by itself authorize that disclosure. The Manager withholds all output if a required mapping table is missing, invalid, unauthorized, or conflicts with another mapping. Tables and key material stay out of Requester-facing results, Provenance, logs, and errors.

## Cross-worker consistency

Independent De-Identifiers must produce identical pseudonyms for the same resolved patient identity within the same authorized linkage scope. When different source identifier pairs refer to the same patient, the deployment must first establish a common identity input through authorized identity resolution. The lookup table still records the original identifiers needed for resolution. If more than one original identifier pair maps to the same pseudonym, the Manager must be able to verify that those pairs belong to the same patient. Otherwise it fails the job.

The Manager validates the method and configuration selected by the approved policy. Before dispatch, it pins that configuration, the resolved scope, the key version, and the output identifier namespace for all assignments that must link, including retries. The De-Identifier deployment provisions the corresponding scope-specific key to each participating worker. A protected local cryptographic module can perform encryption without a network key service. The Manager needs only an opaque, non-secret key-version identifier. Deployments that need continuity across jobs must coordinate scope and key version across those jobs. Key rotation changes the pseudonym, so a deployment must keep the existing version for work that requires the same pseudonyms or migrate that linkage explicitly.

If the deployment also allows a De-Identifier to reverse an encrypted pseudonym, that action requires separate authorization. When the worker is authorized only to encrypt, provision access to an encryption operation that prevents key export and decryption. A worker holding the raw symmetric key can perform both operations.

## Candidate encryption suites

| Candidate | Intended use |
|---|---|
| AES-FF1 | First binding for receivers that require the original identifier alphabet and length. The approved policy selects the configuration for the identifier format. [NIST SP 800-38G](https://csrc.nist.gov/pubs/sp/800/38/g/upd1/final) |
| AES-SIV | Candidate when a receiver accepts a longer opaque identifier and needs authenticated decryption. [RFC 5297 §4](https://www.rfc-editor.org/rfc/rfc5297#section-4) |

FF1 preserves the configured alphabet and length. Prefixes, separators, and check digits require their own format rules. FF1 provides confidentiality and format preservation. A valid-looking output does not authenticate its origin or authorize its reversal. NIST's revision draft retains FF1 and removes FF3 and FF3-1. [NIST SP 800-38G Rev. 1 second public draft](https://csrc.nist.gov/pubs/sp/800/38/g/r1/2pd)

### Policy configuration for FF1

The approved de-identification policy selects the non-secret FF1 configuration, either by specifying it directly or by referencing an immutable version of a format definition. The configuration identifies the AES key size, ordered alphabet, supported lengths, rules for extracting and reconstructing formatted identifiers, exact tweak derivation, and output pseudonym namespace. A format definition must specify how it handles case, leading zeroes, literal characters, and check digits where applicable. The compiled execution plan carries the effective configuration or its pinned reference, the resolved scope, and the non-secret key-version identifier. Key material stays with the authorized deployment.

Independent De-Identifiers generating matching pseudonyms must use the same effective configuration, resolved identity input, key bytes, and tweak. The Manager checks support for the selected configuration before dispatch and pins it for retries. An unsupported configuration or an input outside the selected format causes a failure. When a configuration, scope, common identifier system, or key change would alter mappings, use a distinct output namespace or migrate the linkage explicitly before reusing the namespace.

Policy authors and implementers should follow [NIST SP 800-38G](https://csrc.nist.gov/pubs/sp/800/38/g/upd1/final) for FF1 and consult its [revision draft](https://csrc.nist.gov/pubs/sp/800/38/g/r1/2pd) for updated guidance, including the draft minimum domain of one million possible values. Count the values in the domain that the configured transformation actually encrypts. Fixed prefixes and separators do not increase it. Validate that the receiver can accept every possible output of the selected format.

### Ten-digit decimal example and interoperability vector

This example policy configuration uses forward AES-256, radix 10, and the ordered ASCII alphabet `0123456789`. It encrypts exactly ten digits with leading zeroes and publishes all ten output digits in `Identifier.value` under the configured `Identifier.system`. The receiver accepts any ten-digit output under that namespace. The example configuration identifier is `DIS-FF1-AES256-DECIMAL10-v1`.

For this example, derive the 32-byte tweak as SHA-256 of the compact UTF-8 serialization of the JSON array below. The array contains the configuration identifier, resolved scope type, scope identifier system and value, resolved common identifier system, and output pseudonym namespace in that order. Use the compact string-escaping rules in [Volume 3, Patient Identifier Pseudonymization](https://build.fhir.org/ig/IHE/ITI.DIS/branches/master/volume-3.html#3pxx123-patient-identifier-pseudonymization). Preserve the supplied strings exactly and pass the raw digest bytes to FF1.

Use public test key bytes `000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f` (hex) and this exact context array, with no trailing newline in the hashed input.

```json
["DIS-FF1-AES256-DECIMAL10-v1","source-institution","https://example.org/dis/scopes","cohort-01","https://example.org/mrn","https://example.org/dis/pseudonyms/cohort-01-v1"]
```

| Value | Expected result |
|---|---|
| SHA-256 tweak (hex) | `2f320550d509d115496dc7d13089c00ae25816a11b10724dc7752c0091c9cb97` |
| Resolved input identifier value | `0000000014` |
| Output `Identifier.system` | `https://example.org/dis/pseudonyms/cohort-01-v1` |
| Output `Identifier.value` | `0863301760` |

Run the vector with two independent De-Identifier implementations. Compare the exact output identifier pair and verify that an authorized decryptor recovers `0000000014`. Each worker should return the corresponding original-to-pseudonym pair in its protected lookup table for this fixture. The Manager should resolve the pseudonym through the table without using the key.

## Profile and conformance changes

| Surface | Proposed change |
|---|---|
| Volume 1 | Describe encryption-generated mappings under DIS-REVERSIBLE and the commitment to cross-worker consistency. |
| Volume 2 and OperationDefinition | Generalize the `generatedLookupTable` requirement from reversible hashing to approved generation methods. Apply the existing scope, protected delivery, validation, and release rules. |
| Volume 3 and schemas | Add an optional action for patient business identifier encryption, confined to reversible policies. Define the policy-selected FF1 parameters and their representation in the execution plan, along with the resolved scope and key version. Reuse DIS-LookupTable and its four mapping fields. Add the action to capability declarations without making it a mandatory core action. |
| Test Plan | Use independent implementations with the same synthetic identity, scope, and provisioned key version. Verify equal pseudonyms, preserved alphabet and length including leading zeroes, consistent references, task and retry consistency, protected mapping delivery in both response modes, and authorized Manager lookup. Verify rejection for absent authorization, an unavailable or incompatible key version, an unsupported FF1 configuration or an identifier outside the configured format, a missing lookup output, or conflicting mappings. Exercise at least one other approved identifier format, a changed configuration on retry, and different scope and key versions and test that keys and mappings are excluded from recipient-facing results. |
