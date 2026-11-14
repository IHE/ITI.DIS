# Encryption-based reversible pseudonymization

Draft design for [issue #50](https://github.com/IHE/ITI.DIS/issues/50).

## Actor responsibilities

Add encryption as an optional way to generate patient business identifier pseudonyms under DIS-REVERSIBLE. The approved policy selects this method. A De-Identifier that supports the method applies it to the assigned identifiers and updates references that carry those business identifiers. The existing arrangements for Manager-managed hash mappings and Requester-supplied tables remain available. Reject a job that supplies a table and instructs DIS to generate encrypted patient pseudonyms.

When an assigned task generates encrypted patient pseudonyms, the De-Identifier returns the original-to-pseudonym identifier pairs to the Manager in the existing protected `generatedLookupTable` output. The same output applies to synchronous ITI-x3 and successful asynchronous ITI-x7 responses. The Manager validates the table against the assigned task and resolved scope, checks consistency across results, and retains the mappings before releasing the job result. The Manager uses the existing deployment-defined lookup workflow to resolve a pseudonym for an authorized caller. The Integrated actor performs the applicable duties internally.

The task authorization must cover disclosure of the generated mappings to the Manager. Authorization to receive the pseudonymized dataset does not by itself authorize that disclosure. The Manager withholds all output if a required mapping table is missing, invalid, unauthorized, or conflicts with another mapping. Tables and key material stay out of Requester-facing results, Provenance, logs, and errors.

## Cross-worker consistency

Independent De-Identifiers must produce identical pseudonyms for the same resolved patient identity within the same authorized linkage scope. When different source identifier pairs refer to the same patient, the deployment must first establish a common identity input through authorized identity resolution. The lookup table still records the original identifiers needed for resolution. If more than one original identifier pair maps to the same pseudonym, the Manager must be able to verify that those pairs belong to the same patient. Otherwise it fails the job.

The Manager chooses a supported method and binds the resolved scope and a key version to the job before dispatch. The Manager uses the same scope, key version, and output identifier namespace across all tasks that must link, including retries. The De-Identifier deployment provisions the corresponding scope-specific key to each participating worker. A protected local cryptographic module can perform encryption without a network key service. The Manager needs only an opaque, non-secret key-version identifier. Deployments that need continuity across jobs must coordinate scope and key version across those jobs. Key rotation changes the pseudonym, so a deployment must keep the existing version for work that requires the same pseudonyms or migrate that linkage explicitly.

If the deployment also allows a De-Identifier to reverse an encrypted pseudonym, that action requires separate authorization. When the worker is authorized only to encrypt, provision access to an encryption operation that prevents key export and decryption. A worker holding the raw symmetric key can perform both operations.

## Candidate binding for review

Use deterministic authenticated encryption with [AES-SIV as specified in RFC 5297](https://www.rfc-editor.org/rfc/rfc5297#section-4). The candidate suite is `AEAD_AES_SIV_CMAC_512`. Scope and key selection require coordinated provisioning across deployments. The same input encrypted under the same key and context yields the same ciphertext, so matching ciphertexts disclose linkage within that scope.

For a published binding, specify one byte-level recipe and a shared test vector. The proposal is to reuse the salted-hash rules for compact JSON string escaping and UTF-8 encoding. The plaintext would be the JSON array of the resolved identity system and value. Associated data would be a single JSON array containing a distinct DIS encryption domain label, scope type, scope identifier system and value, and output pseudonym namespace. The output candidate is the full SIV followed by ciphertext, encoded as unpadded base64url in `Identifier.value`. The approved pseudonym namespace becomes `Identifier.system`. Check that the resulting identifier fits the supported payload and deployment constraints before release.

## Profile and conformance changes

| Surface | Proposed change |
|---|---|
| Volume 1 | Describe encryption-generated mappings under DIS-REVERSIBLE and the commitment to cross-worker consistency. |
| Volume 2 and OperationDefinition | Generalize the `generatedLookupTable` requirement from reversible hashing to approved generation methods. Apply the existing scope, protected delivery, validation, and release rules. |
| Volume 3 and schemas | Add an optional action for patient business identifier encryption, confined to reversible policies. Bind the deterministic suite, input encoding, resolved scope, key version, and output identifier. Reuse DIS-LookupTable and its four mapping fields. Add the action to capability declarations without making it a mandatory core action. |
| Test Plan | Use independent implementations with the same synthetic identity, scope, and provisioned key version. Verify equal pseudonyms and consistent references, task and retry consistency, protected mapping delivery in both response modes, and authorized Manager lookup. Verify rejection for absent authorization, an unavailable or incompatible key version, a missing lookup output, or conflicting mappings. Exercise different scope and key versions and test that keys and mappings are excluded from recipient-facing results. |
