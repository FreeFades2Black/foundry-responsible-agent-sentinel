# ==============================================================================
# RESPONSIBLE AI (RAI) CONTENT SAFETY & PROMPT SHIELD POLICY
# Resource: Microsoft.CognitiveServices/accounts/raiPolicies
# Architectural Purpose:
# Enforces automated safety barriers at the cloud model boundary before tokens reach
# or return from GPT-4o.
# ==============================================================================

# ------------------------------------------------------------------------------
# RAI POLICY RESOURCE (AZAPI)
# WHY: Custom RAI policies in Cognitive Services configure deep multi-category
#      blocking and Prompt Shield protection at the inference gateway.
# HOW: Configures Microsoft.DefaultV2 base policy in 'Blocking' mode with 10 explicit
#      content filters covering Hate, Sexual, Violence, SelfHarm, Jailbreak, and
#      IndirectAttack (Cross-Domain Prompt Injection / XPIA).
# ------------------------------------------------------------------------------
resource "azapi_resource" "custom_rai_policy" {
  type      = "Microsoft.CognitiveServices/accounts/raiPolicies@2024-10-01"
  name      = var.rai_policy_name
  parent_id = azurerm_cognitive_account.sentinel_ai.id

  body = jsonencode({
    properties = {
      basePolicyName = "Microsoft.DefaultV2"
      mode           = "Blocking"
      contentFilters = [
        # CONTROL: Hate Harm Mitigation (OWASP LLM01 / Safety Compliance)
        {
          name              = "Hate"
          blocking          = true
          enabled           = true
          severityThreshold = var.rai_severity_threshold
          source            = "Prompt"
        },
        {
          name              = "Hate"
          blocking          = true
          enabled           = true
          severityThreshold = var.rai_severity_threshold
          source            = "Completion"
        },

        # CONTROL: Sexual Content Filtering
        {
          name              = "Sexual"
          blocking          = true
          enabled           = true
          severityThreshold = var.rai_severity_threshold
          source            = "Prompt"
        },
        {
          name              = "Sexual"
          blocking          = true
          enabled           = true
          severityThreshold = var.rai_severity_threshold
          source            = "Completion"
        },

        # CONTROL: Violence Harm Mitigation (Clinical Safety & Public Harm)
        {
          name              = "Violence"
          blocking          = true
          enabled           = true
          severityThreshold = var.rai_severity_threshold
          source            = "Prompt"
        },
        {
          name              = "Violence"
          blocking          = true
          enabled           = true
          severityThreshold = var.rai_severity_threshold
          source            = "Completion"
        },

        # CONTROL: Self-Harm Prevention (Mandatory Zero-Harm Policy)
        {
          name              = "SelfHarm"
          blocking          = true
          enabled           = true
          severityThreshold = var.rai_severity_threshold
          source            = "Prompt"
        },
        {
          name              = "SelfHarm"
          blocking          = true
          enabled           = true
          severityThreshold = var.rai_severity_threshold
          source            = "Completion"
        },

        # CONTROL: Prompt Shield for Direct Jailbreaks (OWASP LLM01)
        # WHY: Stops "Do Anything Now" (DAN), developer mode bypasses, and role-reversal attacks.
        # HOW: Microsoft Content Safety Prompt Shield analyzes prompt semantics for adversarial intent.
        {
          name     = "Jailbreak"
          blocking = var.enable_prompt_shield
          enabled  = var.enable_prompt_shield
          source   = "Prompt"
        },

        # CONTROL: Prompt Shield for Indirect Attacks / XPIA (OWASP LLM01)
        # WHY: Blocks poisoned instructions hidden inside retrieved documents or 3rd-party payloads.
        # HOW: Scans retrieved knowledge context at model invocation time to neutralize Trojan directives.
        {
          name     = "IndirectAttack"
          blocking = var.enable_indirect_attack_filter
          enabled  = var.enable_indirect_attack_filter
          source   = "Prompt"
        }
      ]
    }
  })

  depends_on = [
    azurerm_cognitive_account.sentinel_ai
  ]
}
