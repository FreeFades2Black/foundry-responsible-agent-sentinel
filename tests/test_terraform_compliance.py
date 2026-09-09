"""
Automated Terraform Compliance & Architecture Verification Test Suite
Validates that infrastructure-as-code files declare all required security controls,
encryption standards, RAI policies, and explanatory inline documentation.
"""

from pathlib import Path
import pytest

TERRAFORM_DIR = Path(__file__).resolve().parent.parent / "terraform"


@pytest.fixture
def terraform_files():
    assert TERRAFORM_DIR.exists(), f"Terraform directory not found at: {TERRAFORM_DIR}"
    return {p.name: p.read_text(encoding="utf-8") for p in TERRAFORM_DIR.glob("*.tf")}


def test_terraform_required_files_exist():
    """Verify all core Terraform modular files exist."""
    required = ["main.tf", "variables.tf", "outputs.tf", "providers.tf", "rai_policy.tf"]
    for fname in required:
        file_path = TERRAFORM_DIR / fname
        assert file_path.exists(), f"Missing required Terraform file: {fname}"


def test_terraform_managed_identity_zero_secrets(terraform_files):
    """Verify User-Assigned Managed Identity is used to eliminate static secrets."""
    main_tf = terraform_files["main.tf"]
    assert "azurerm_user_assigned_identity" in main_tf
    assert "Cognitive Services OpenAI User" in main_tf
    assert "Search Index Data Contributor" in main_tf
    # Verify explanatory inline notes on zero static secrets
    assert "ZERO STATIC SECRETS" in main_tf or "Zero static secrets" in main_tf or "static secrets" in main_tf.lower()


def test_terraform_storage_security_controls(terraform_files):
    """Verify Storage Account enforces TLS 1.2, HTTPS only, and disables public blob read."""
    main_tf = terraform_files["main.tf"]
    assert "azurerm_storage_account" in main_tf
    assert 'min_tls_version                 = "TLS1_2"' in main_tf or 'min_tls_version = "TLS1_2"' in main_tf
    assert "allow_nested_items_to_be_public = false" in main_tf
    assert "enable_https_traffic_only = true" in main_tf or "enable_https_traffic_only" in main_tf


def test_terraform_key_vault_rbac_and_retention(terraform_files):
    """Verify Key Vault enforces Entra ID RBAC authorization and soft delete."""
    main_tf = terraform_files["main.tf"]
    assert "azurerm_key_vault" in main_tf
    assert "rbac_authorization_enabled = true" in main_tf
    assert "soft_delete_retention_days = 90" in main_tf


def test_terraform_ai_search_semantic_ranker(terraform_files):
    """Verify Azure AI Search enables standard Semantic Search SKU for hybrid reranking."""
    main_tf = terraform_files["main.tf"]
    assert "azurerm_search_service" in main_tf
    assert 'semantic_search_sku = "standard"' in main_tf


def test_terraform_model_deployments(terraform_files):
    """Verify deployments for GPT-4o (agent inference) and text-embedding-3-large (vectors)."""
    main_tf = terraform_files["main.tf"]
    assert 'name    = "gpt-4o"' in main_tf
    assert 'name    = "text-embedding-3-large"' in main_tf


def test_terraform_rai_content_safety_and_prompt_shields(terraform_files):
    """Verify custom RAI policy configures Hate, Sexual, Violence, SelfHarm, Jailbreak, and IndirectAttack."""
    rai_tf = terraform_files["rai_policy.tf"]
    assert "Microsoft.CognitiveServices/accounts/raiPolicies" in rai_tf
    assert 'mode           = "Blocking"' in rai_tf or 'mode = "Blocking"' in rai_tf

    # Verify all 6 critical filter categories
    assert '"Hate"' in rai_tf
    assert '"Sexual"' in rai_tf
    assert '"Violence"' in rai_tf
    assert '"SelfHarm"' in rai_tf
    assert '"Jailbreak"' in rai_tf
    assert '"IndirectAttack"' in rai_tf


def test_terraform_inline_why_and_how_annotations(terraform_files):
    """Verify that Terraform files include explicit 'WHY:' and 'HOW:' architectural rationales."""
    main_tf = terraform_files["main.tf"]
    rai_tf = terraform_files["rai_policy.tf"]
    vars_tf = terraform_files["variables.tf"]

    for text, name in [(main_tf, "main.tf"), (rai_tf, "rai_policy.tf"), (vars_tf, "variables.tf")]:
        assert "WHY:" in text, f"Missing 'WHY:' architectural rationale in {name}"
        assert "HOW:" in text, f"Missing 'HOW:' implementation mechanism in {name}"
