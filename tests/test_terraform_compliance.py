"""
Automated Terraform Compliance & Architecture Verification Test Suite
Validates that infrastructure-as-code files declare all required security controls,
encryption standards, RAI policies, and explanatory inline documentation across
all modular Azure components.
"""

from pathlib import Path
import pytest

TERRAFORM_DIR = Path(__file__).resolve().parent.parent / "terraform"
MODULES_DIR = TERRAFORM_DIR / "modules"


@pytest.fixture
def terraform_code():
    assert TERRAFORM_DIR.exists(), f"Terraform directory not found at: {TERRAFORM_DIR}"
    # Read all .tf files recursively
    all_tf = {}
    for p in TERRAFORM_DIR.rglob("*.tf"):
        rel_path = str(p.relative_to(TERRAFORM_DIR)).replace("\\", "/")
        all_tf[rel_path] = p.read_text(encoding="utf-8")
    return all_tf


def test_terraform_modules_and_root_files_exist():
    """Verify all core Terraform modular files and directories exist."""
    required_roots = ["main.tf", "variables.tf", "outputs.tf", "providers.tf"]
    for fname in required_roots:
        assert (TERRAFORM_DIR / fname).exists(), f"Missing required root Terraform file: {fname}"

    expected_modules = [
        "networking",
        "security_identity",
        "ai_foundry",
        "ai_search",
        "rai_policy",
    ]
    for mod in expected_modules:
        mod_dir = MODULES_DIR / mod
        assert mod_dir.exists(), f"Missing required Terraform module directory: {mod}"
        assert (mod_dir / "main.tf").exists(), f"Missing main.tf in module {mod}"
        assert (mod_dir / "variables.tf").exists(), f"Missing variables.tf in module {mod}"
        assert (mod_dir / "outputs.tf").exists(), f"Missing outputs.tf in module {mod}"


def test_terraform_vnet_and_microsegmentation(terraform_code):
    """Verify Virtual Network and microsegmentation NSG rules exist."""
    net_tf = terraform_code["modules/networking/main.tf"]
    assert "azurerm_virtual_network" in net_tf
    assert "snet-ai-foundry" in net_tf
    assert "snet-ai-search" in net_tf
    assert "snet-data" in net_tf
    assert "azurerm_network_security_group" in net_tf
    assert "DenyInternetInbound" in net_tf


def test_terraform_managed_identity_zero_secrets(terraform_code):
    """Verify User-Assigned Managed Identity is used to eliminate static secrets."""
    sec_tf = terraform_code["modules/security_identity/main.tf"]
    foundry_tf = terraform_code["modules/ai_foundry/main.tf"]
    search_tf = terraform_code["modules/ai_search/main.tf"]

    assert "azurerm_user_assigned_identity" in sec_tf
    assert "Cognitive Services OpenAI User" in foundry_tf
    assert "Search Index Data Contributor" in search_tf


def test_terraform_storage_security_controls(terraform_code):
    """Verify Storage Account enforces TLS 1.2, HTTPS only, and disables public blob read."""
    sec_tf = terraform_code["modules/security_identity/main.tf"]
    assert "min_tls_version" in sec_tf and "TLS1_2" in sec_tf
    assert "allow_nested_items_to_be_public = false" in sec_tf
    assert "https_traffic_only_enabled" in sec_tf or "enable_https_traffic_only" in sec_tf


def test_terraform_key_vault_rbac_and_retention(terraform_code):
    """Verify Key Vault enforces Entra ID RBAC authorization and soft delete."""
    sec_tf = terraform_code["modules/security_identity/main.tf"]
    assert "azurerm_key_vault" in sec_tf
    assert "rbac_authorization_enabled = true" in sec_tf
    assert "soft_delete_retention_days = 90" in sec_tf


def test_terraform_ai_search_semantic_ranker(terraform_code):
    """Verify Azure AI Search enables standard Semantic Search SKU for hybrid reranking."""
    search_tf = terraform_code["modules/ai_search/main.tf"]
    assert "azurerm_search_service" in search_tf
    assert 'semantic_search_sku         = "standard"' in search_tf or 'semantic_search_sku = "standard"' in search_tf


def test_terraform_model_deployments(terraform_code):
    """Verify deployments for GPT-4o (agent inference) and text-embedding-3-large (vectors)."""
    foundry_tf = terraform_code["modules/ai_foundry/main.tf"]
    assert 'name    = "gpt-4o"' in foundry_tf
    assert 'name    = "text-embedding-3-large"' in foundry_tf


def test_terraform_rai_content_safety_and_prompt_shields(terraform_code):
    """Verify custom RAI policy configures Hate, Sexual, Violence, SelfHarm, Jailbreak, and IndirectAttack."""
    rai_tf = terraform_code["modules/rai_policy/main.tf"]
    assert "Microsoft.CognitiveServices/accounts/raiPolicies" in rai_tf
    assert 'mode           = "Blocking"' in rai_tf or 'mode = "Blocking"' in rai_tf

    # Verify all 6 critical filter categories
    assert '"Hate"' in rai_tf
    assert '"Sexual"' in rai_tf
    assert '"Violence"' in rai_tf
    assert '"SelfHarm"' in rai_tf
    assert '"Jailbreak"' in rai_tf
    assert '"IndirectAttack"' in rai_tf


def test_terraform_inline_why_and_how_annotations(terraform_code):
    """Verify that Terraform files include explicit 'WHY:' and 'HOW:' architectural rationales."""
    main_tf = terraform_code["main.tf"]
    vars_tf = terraform_code["variables.tf"]

    # At root level:
    assert "WHY:" in vars_tf, "Missing 'WHY:' in variables.tf"
    assert "HOW:" in vars_tf, "Missing 'HOW:' in variables.tf"
    assert "Architectural Purpose:" in main_tf or "Architecture Rationale:" in main_tf
