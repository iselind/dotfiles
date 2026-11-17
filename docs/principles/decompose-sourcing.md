PRINCIPLE-OF-DECOMPOSITION-AND-SOURCING

1. GAP ANALYSIS PRECEDES IMPLEMENTATION
   - Before proposing code changes, identify: current state → desired state
   - List domain knowledge assumptions that would normally be model-implicit (e.g., "K8s manifests require resource limits per cluster policy")
   - Document these gaps as explicit prerequisites

2. AUTHORITY HIERARCHY FOR DOCUMENTATION LOOKUP
   Primary sources (internal):
     - /docs/methodology/*.md — SE workflow and patterns
     - /docs/principles/*.md — invocation context rules  
     - /patterns/*/*.yaml — manifest examples with inline doc references
   Secondary sources (external, cited in docs):
     - ISO/IEC/IEEE 12207:2017 software lifecycle processes
     - NIST SP 800-53 security controls for cloud infra
     - kubectl explain <resource> — schema documentation
     - SWEBOK (software engineering body of knowledge)
   Model must cite authoritative source when proposing implementation details

3. TESTABLE TASK DECOMPOSITION
   Break abstract objectives into:
     - Unit-sized changes (single file, single resource type)
     - Each with acceptance criteria
     - With verification commands where applicable
   Model should not proceed to next decomposition level until prior is verified

4. DOMAIN MAPPING BEFORE CODE REQUEST
   When task involves specific domain (k8s, terraform, Go microservices):
     - List relevant patterns from /patterns/* applicable to objective
     - Cite constraints or standards that govern the implementation (e.g., "cluster requires pod anti-affinity")
     - Only then request implementation code

Rationale: Models hallucinate domain details absent explicit sourcing. Document discipline prevents knowledge bloat while enabling dynamic lookup of relevant patterns.
