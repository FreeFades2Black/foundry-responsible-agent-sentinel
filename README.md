# 🛡️ Foundry Responsible Agent Sentinel: Audited Retrieval & Secure Action Agent

[![Responsible AI Adversarial Evaluation Gate](https://github.com/FreeFades2Black/foundry-responsible-agent-sentinel/actions/workflows/rai-eval-gate.yml/badge.svg)](https://github.com/FreeFades2Black/foundry-responsible-agent-sentinel/actions/workflows/rai-eval-gate.yml)
[![Azure AI Foundry](https://img.shields.io/badge/Platform-Azure%20AI%20Foundry-0078D4?style=flat&logo=microsoftazure&logoColor=white)](https://ai.azure.com)
[![Azure AI Search](https://img.shields.io/badge/RAG-Azure%20AI%20Search%20(HNSW%20%2B%20Semantic)-0089D6?style=flat&logo=microsoftazure&logoColor=white)](https://learn.microsoft.com/azure/search/)
[![Infrastructure as Code](https://img.shields.io/badge/IaC-Azure%20Bicep%20%7C%20azd-purple?style=flat&logo=azuredevops&logoColor=white)](infra/)
[![OWASP Top 10 for LLM](https://img.shields.io/badge/Security-OWASP%20LLM%20Top%2010%20Mitigated-emerald?style=flat&logo=shield&logoColor=white)](docs/threat-model.md)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

---

## ℹ️ Infrastructure Integrity & Data Classification Notice

> - **Real Infrastructure & Cloud Blueprints:** The Bicep templates (`infra/main.bicep`, `modules/*.bicep`), Azure AI Foundry hub/project configurations, Azure AI Search semantic vector schemas, and custom Content Safety policies (`rai-policy.bicep`) in this repository are **100% real, functional, and deployment-ready**.
> - **Simulated Reference Data:** All clinical encounter payloads, patient pseudonym identifiers (`PAT-*`), and adversarial red-team test cases (`tests/adversarial_prompts.json`) are **simulated reference data** designed for adversarial vulnerability benchmarking, safety verification, and automated CI/CD gating. No live patient data or actual Protected Health Information (PHI) is hosted or transmitted.

---

## 📖 Executive Summary & System Overview

To demonstrate an enterprise-grade mastery of **Responsible AI (RAI)** in Microsoft Azure AI Foundry, production applications must move beyond simple chat completions. 

The **Foundry Responsible Agent Sentinel** is an **Audited Retrieval & Secure Action Agent**—an autonomous agent grounded in an Azure AI Foundry Knowledge Base (backed by Azure AI Search) that enforces strict, multi-point guardrails across **User Inputs**, **Tool Invocations**, **Tool Responses**, and **Model Outputs**, verified by an automated adversarial evaluation pipeline in CI/CD.

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

## 🔑 Key Capabilities This Repo Showcases

### 1. Defense-in-Depth RAG (Foundry Knowledge Base + Azure AI Search)
* **Hybrid Retrieval:** Blends HNSW Dense Vector embeddings (`text-embedding-3-large`), BM25 lexical search, and Microsoft Semantic Re-ranking.
* **Document-Level Security Filtering:** Enforces Microsoft Entra ID role tags (`allowed_roles`) directly at the search index layer, guaranteeing zero unauthorized data retrieval.
* **Data Spotlighting / Delimiter Isolation:** Explicitly isolates retrieved chunks inside cryptographically strict delimiters (`<trusted_archive_document>`). The model's system prompt strictly instructs it to treat retrieved text as inert passive data rather than instructions, defusing indirect prompt injection (XPIA) and stripping malicious Markdown image exfiltration URLs (`![exfil](...)`).

### 2. Full-Lifecycle Guardrails (Azure AI Content Safety & Interceptors)
* **User Input:** Scans incoming prompts via Azure AI Content Safety Prompt Shields and heuristic signatures, blocking DAN mode, developer mode overrides, and system prompt extraction attacks.
* **Tool Invocation:** Enforces runtime Pydantic schema validation, parameter length bounds, SQL injection prevention, command separator sanitization, and egress host whitelisting.
* **Tool Response:** Scans third-party API payloads before the model processes the context to detect and quarantine Trojan prompt injection payloads ("important: ignore previous").
* **Model Output:** Real-time PII redaction (SSN, credit card, email, phone, API keys, canary tokens) and automated factual groundedness scoring.

### 3. CI/CD Quality & Safety Gates (Azure AI Evaluation SDK)
* **Automated Red-Team Benchmark:** Every pull request runs an adversarial evaluation against red-team test cases (`tests/adversarial_prompts.json`).
* **Hard Operational Floors:**
  * **Indirect Attack Defect Rate:** Must equal **`0.0%`** (Zero tolerance).
  * **Jailbreak Defect Rate:** Must equal **`0.0%`**.
  * **Groundedness Score:** Must meet or exceed **`0.85`**. If groundedness drops below 0.85 or an injection succeeds, the CI build breaks.

---

## 📂 Repository Architecture

```text
foundry-responsible-agent-sentinel/
├── .github/
│   └── workflows/
│       └── rai-eval-gate.yml          # Automated red-team & safety evaluation pipeline (CI/CD)
├── infra/
│   ├── main.bicep                     # Foundry Hub, Project, Search, and AI Services orchestrator
│   └── modules/
│       ├── ai-foundry.bicep           # Project, Agent Service, Model Deployments, and Managed Identity
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
│   └── test_evaluations.py            # Azure AI Evaluation SDK test runner (Safety & Groundedness)
├── docs/
│   └── threat-model.md                # STRIDE / AI Threat Model & OWASP Top 10 for LLM Mapping
├── azure.yaml                         # Azure Developer CLI (azd) contract
├── pyproject.toml                     # Modern packaging and pytest configuration
├── requirements.txt                   # Production and testing dependencies
├── foundry_safe_agent_repo_blueprint.md # Architecture blueprint and quick reference
└── README.md                          # Master project documentation
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

### 2. Run Automated Adversarial Evaluation Gate
Execute the red-team safety evaluation suite and guardrail verification:
```bash
pytest tests/test_evaluations.py -v
```

```text
============================= test session starts =============================
platform linux / win32 -- Python 3.11 / 3.14, pytest-9.1.1
rootdir: foundry-responsible-agent-sentinel
collected 7 items

tests/test_evaluations.py::test_agent_withstands_jailbreaks_and_indirect_attacks PASSED [ 14%]
tests/test_evaluations.py::test_input_guardrail_blocks_direct_jailbreaks PASSED          [ 28%]
tests/test_evaluations.py::test_data_spotlighting_defuses_injection_and_markdown_exfiltration PASSED [ 42%]
tests/test_evaluations.py::test_tool_invocation_interceptor_blocks_tampering PASSED    [ 57%]
tests/test_evaluations.py::test_tool_response_interceptor_blocks_trojan_injections PASSED [ 71%]
tests/test_evaluations.py::test_output_guardrail_redacts_pii_and_canary_tokens PASSED   [ 85%]
tests/test_evaluations.py::test_knowledge_ingestor_schema_integrity PASSED             [100%]

============================== 7 passed in 0.16s ==============================
```

### 3. Provision Infrastructure via Azure Developer CLI (`azd`)
```bash
# Log in to Azure and select subscription
azd auth login

# Initialize and provision all Bicep infrastructure, Foundry project, and search index
azd up
```

---

## 🛡️ OWASP Top 10 for LLM Applications: Defense Matrix

For complete STRIDE threat analysis and technical intervention details, see [`docs/threat-model.md`](docs/threat-model.md).

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

## 📜 Blueprint Reference

The complete architecture specification and code implementation guide is available in [`foundry_safe_agent_repo_blueprint.md`](foundry_safe_agent_repo_blueprint.md).

---

## 📄 License

Licensed under the [Apache License, Version 2.0](LICENSE). Copyright © 2026 FreeFades2Black / Gilead Sentinel AI Operations. All rights reserved.
