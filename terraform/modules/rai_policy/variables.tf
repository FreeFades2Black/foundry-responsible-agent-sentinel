variable "cognitive_account_id" {
  type        = string
  description = "Target Cognitive Services Account ID."
}

variable "rai_policy_name" {
  type        = string
  description = "Name of the custom RAI policy."
  default     = "eld-custom-guardrail"
}

variable "severity_threshold" {
  type        = string
  description = "Severity threshold for content safety filters."
  default     = "Medium"
}

variable "enable_prompt_shield" {
  type        = bool
  description = "Enable Prompt Shield for direct jailbreaks."
  default     = true
}

variable "enable_indirect_attack_filter" {
  type        = bool
  description = "Enable Prompt Shield for indirect attacks."
  default     = true
}
