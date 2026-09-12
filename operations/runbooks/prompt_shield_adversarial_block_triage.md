# Operational Runbook: Azure AI Prompt Shield Adversarial Block Triage

**Severity:** P2 / Security Policy Triggered  
**Target Systems:** Azure AI Content Safety, Prompt Shield Gateway, Agent Sentinel

## Diagnostic Workflow
1. Check Azure Content Safety audit logs for blocked prompts:
   ```bash
   az cognitiveservices account show --name sentinel-safety-prod --query 'properties.endpoint'
   ```
2. Inspect blocked payload risk vector (Jailbreak, Indirect Injection, PII leakage):
   ```bash
   python -m tests.test_adversarial_eval --inspect-last-block
   ```
3. If legitimate clinical jargon caused a false positive:
   - Adjust Content Safety threshold in `terraform/rai_policy.tf` from `Strict` to `Medium`.
   - Re-run compliance tests:
     ```bash
     python -m pytest tests/test_terraform_compliance.py -v
     ```
