# ADR-0001: Data Spotlighting and Delimiter Isolation for Cross-Domain Prompt Injection (XPIA)

**Status:** Accepted  
**Date:** 2026-06-12  
**Lead Architect:** William Free Hall (Free) <whall4.wh@gmail.com>

## 1. Context & Operational Challenge
Autonomous clinical agents retrieving external EHR documents face Cross-Domain Prompt Injection Attacks (XPIA), where untrusted records contain adversarial instructions attempting to override system prompts or invoke unauthorized tools.

## 2. Options Considered
* **Option A: Naive Text Concatenation**
  - *Evaluation:* Injects raw document strings directly into prompt context; LLM cannot differentiate between system instructions and untrusted data payloads.
* **Option B: Data Spotlighting with Cryptographic Nonce Delimiters (`<trusted_archive_document nonce="...">`)**
  - *Evaluation:* Wraps retrieved documents in inert structural delimiters and instructs the model to treat content strictly as passive semantic data rather than executable instructions.

## 3. Decision & Trade-Off Accepted
We adopted **Option B (Data Spotlighting)**.  
**Trade-Off Accepted:** Adds minimal prompt token overhead (~25 tokens per chunk); guarantees strict boundary isolation between control instructions and data.
