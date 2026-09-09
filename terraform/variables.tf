# ==============================================================================
# TERRAFORM INPUT VARIABLES: SENTINEL RESPONSIBLE AI CONTROLS
# Defines all configurable parameters with strict type constraints, defaults,
# and explanatory annotations for security compliance and governance review.
# ==============================================================================

variable "environment_name" {
  type        = string
  description = "Environment identifier (e.g., dev, stg, prod) used for resource naming and governance tagging."
  default     = "sentinel"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,16}$", var.environment_name))
    error_message = "The environment_name must be between 3 and 16 characters, lowercase alphanumeric with hyphens."
  }
}

variable "location" {
  type        = string
  description = "Target Azure primary region for AI Foundry, Search, and cognitive services. Standard: eastus2 or swedencentral for modern Foundry capacity."
  default     = "eastus2"
}

variable "rai_policy_name" {
  type        = string
  description = "Unique resource identifier name for the custom Content Safety and Prompt Shield policy."
  default     = "eld-custom-guardrail"
}

variable "rai_severity_threshold" {
  type        = string
  description = "Severity threshold for Azure AI Content Safety filters (Hate, Violence, Sexual, SelfHarm). Medium is standard; Low enforces strictest zero-tolerance."
  default     = "Medium"

  validation {
    condition     = contains(["Low", "Medium", "High"], var.rai_severity_threshold)
    error_message = "The rai_severity_threshold must be one of: Low, Medium, High."
  }
}

variable "enable_prompt_shield" {
  type        = bool
  description = "WHY: Defuses OWASP LLM01 (Prompt Injection). HOW: Activates Microsoft AI Content Safety Prompt Shields against direct jailbreaks, DAN modes, and role-reversal attacks."
  default     = true
}

variable "enable_indirect_attack_filter" {
  type        = bool
  description = "WHY: Defuses Cross-Domain Prompt Injection (XPIA). HOW: Scans retrieved knowledge chunks and blocks prompts that attempt system overrides embedded in context."
  default     = true
}

variable "search_sku" {
  type        = string
  description = "WHY: Semantic Re-ranking requires Standard SKU or above. HOW: Azure AI Search 'standard' provides SLA-backed HNSW vector search, BM25 text index, and Semantic Ranker."
  default     = "standard"

  validation {
    condition     = contains(["basic", "standard", "standard2", "standard3"], var.search_sku)
    error_message = "The search_sku must be basic, standard, standard2, or standard3."
  }
}

variable "enable_hbi_workspace" {
  type        = bool
  description = "WHY: High Business Impact (HBI) isolation for HIPAA compliance. HOW: Enforces customer data encryption at rest and restricts Microsoft telemetry collection."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Enterprise metadata tags for FinOps tracking, security auditing, and compliance verification."
  default = {
    Project               = "foundry-responsible-agent-sentinel"
    ArchitectureTier      = "Audited-Retrieval-Secure-Action-Agent"
    SecurityFramework     = "OWASP-LLM-Top-10-HITRUST-HIPAA"
    ProvisioningEngine    = "Terraform"
    Environment           = "Production"
    ResponsibleAIGoverned = "True"
  }
}
