# ==============================================================================
# MODULE: CUSTOM RESPONSIBLE AI (RAI) POLICY & PROMPT SHIELDS
# Architecture Rationale:
# Enforces native cloud-boundary blocking for content harms (Hate, Violence,
# Sexual, SelfHarm) and Microsoft Prompt Shields (Jailbreak, IndirectAttack / XPIA).
# ==============================================================================

resource "azapi_resource" "custom_rai_policy" {
  type      = "Microsoft.CognitiveServices/accounts/raiPolicies@2024-10-01"
  name      = var.rai_policy_name
  parent_id = var.cognitive_account_id

  body = jsonencode({
    properties = {
      basePolicyName = "Microsoft.DefaultV2"
      mode           = "Blocking"
      contentFilters = [
        # CONTROL: Hate Harm Mitigation
        {
          name              = "Hate"
          blocking          = true
          enabled           = true
          severityThreshold = var.severity_threshold
          source            = "Prompt"
        },
        {
          name              = "Hate"
          blocking          = true
          enabled           = true
          severityThreshold = var.severity_threshold
          source            = "Completion"
        },

        # CONTROL: Sexual Content Filtering
        {
          name              = "Sexual"
          blocking          = true
          enabled           = true
          severityThreshold = var.severity_threshold
          source            = "Prompt"
        },
        {
          name              = "Sexual"
          blocking          = true
          enabled           = true
          severityThreshold = var.severity_threshold
          source            = "Completion"
        },

        # CONTROL: Violence Harm Mitigation
        {
          name              = "Violence"
          blocking          = true
          enabled           = true
          severityThreshold = var.severity_threshold
          source            = "Prompt"
        },
        {
          name              = "Violence"
          blocking          = true
          enabled           = true
          severityThreshold = var.severity_threshold
          source            = "Completion"
        },

        # CONTROL: Self-Harm Prevention
        {
          name              = "SelfHarm"
          blocking          = true
          enabled           = true
          severityThreshold = var.severity_threshold
          source            = "Prompt"
        },
        {
          name              = "SelfHarm"
          blocking          = true
          enabled           = true
          severityThreshold = var.severity_threshold
          source            = "Completion"
        },

        # CONTROL: Prompt Shield for Direct Jailbreaks (OWASP LLM01)
        {
          name     = "Jailbreak"
          blocking = var.enable_prompt_shield
          enabled  = var.enable_prompt_shield
          source   = "Prompt"
        },

        # CONTROL: Prompt Shield for Indirect Attacks / XPIA (OWASP LLM01)
        {
          name     = "IndirectAttack"
          blocking = var.enable_indirect_attack_filter
          enabled  = var.enable_indirect_attack_filter
          source   = "Prompt"
        }
      ]
    }
  })
}
