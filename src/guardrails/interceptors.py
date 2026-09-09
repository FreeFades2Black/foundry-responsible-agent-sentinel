"""
Responsible AI Interceptors and Lifecycle Validation Hooks
Provides pre- and post-execution security boundaries across the agent lifecycle.
"""

import json
import re
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple


class GuardrailViolationException(Exception):
    """Raised when an interaction or tool invocation violates RAI guardrail policies."""

    def __init__(self, guardrail_stage: str, reason: str, details: Optional[Dict[str, Any]] = None):
        super().__init__(f"[{guardrail_stage.upper()}_VIOLATION] {reason}")
        self.guardrail_stage = guardrail_stage
        self.reason = reason
        self.details = details or {}


def load_policy_config() -> Dict[str, Any]:
    """Loads default RAI policy definitions from local JSON configuration."""
    config_path = Path(__file__).parent / "policies.json"
    if config_path.exists():
        with open(config_path, "r", encoding="utf-8") as f:
            return json.load(f)
    return {}


class InputGuardrailInterceptor:
    """Interceps user input prior to submission to Azure AI Foundry Agent / LLM."""

    def __init__(self, policies: Optional[Dict[str, Any]] = None):
        self.policies = policies or load_policy_config()
        self.jailbreak_signatures = [
            sig.lower()
            for sig in self.policies.get("prompt_shield", {}).get("jailbreak_signatures", [])
        ]

    def validate_user_input(self, prompt: str) -> str:
        """
        Scans input for direct jailbreaks, DAN prompts, and adversarial system overrides.
        Raises GuardrailViolationException if policy is breached.
        """
        if not prompt or not prompt.strip():
            raise GuardrailViolationException("input", "Prompt cannot be empty or whitespace.")

        lower_prompt = prompt.lower()

        # 1. Prompt Shield signature detection
        for sig in self.jailbreak_signatures:
            if sig in lower_prompt:
                raise GuardrailViolationException(
                    "input",
                    f"Adversarial prompt injection pattern detected: '{sig}'",
                    {"matched_signature": sig}
                )

        # 2. Heuristic check for role-reversal attack patterns
        suspicious_markers = [
            "system:",
            "<|im_start|>",
            "<|im_end|>",
            "[system override]",
            "ignore your safety filter",
        ]
        for marker in suspicious_markers:
            if marker in lower_prompt:
                raise GuardrailViolationException(
                    "input",
                    f"Disallowed system directive marker detected: '{marker}'",
                    {"matched_marker": marker}
                )

        return prompt.strip()


class ToolInvocationInterceptor:
    """Validates tool parameters, egress destinations, and prevents injection before dispatch."""

    def __init__(self, policies: Optional[Dict[str, Any]] = None):
        self.policies = policies or load_policy_config()
        tool_config = self.policies.get("tool_invocation_guardrails", {})
        self.allowed_hosts = set(tool_config.get("allowed_hosts", []))
        self.max_param_length = tool_config.get("parameter_max_string_length", 500)
        self.sql_patterns = [p.lower() for p in tool_config.get("disallowed_sql_patterns", [])]
        self.cmd_patterns = tool_config.get("disallowed_command_patterns", [])

    def validate_tool_call(self, tool_name: str, arguments: Dict[str, Any]) -> Dict[str, Any]:
        """
        Enforces parameter length bounds, injection pattern absence, and egress host whitelisting.
        """
        if not tool_name:
            raise GuardrailViolationException("tool_invocation", "Tool name cannot be empty.")

        for key, val in arguments.items():
            if isinstance(val, str):
                if len(val) > self.max_param_length:
                    raise GuardrailViolationException(
                        "tool_invocation",
                        f"Parameter '{key}' exceeds maximum permitted length of {self.max_param_length} characters.",
                        {"key": key, "length": len(val)}
                    )

                lower_val = val.lower()
                # SQL injection scanner
                for pattern in self.sql_patterns:
                    if pattern in lower_val:
                        raise GuardrailViolationException(
                            "tool_invocation",
                            f"Disallowed SQL pattern '{pattern}' detected in parameter '{key}'.",
                            {"key": key, "pattern": pattern}
                        )

                # Command injection & path traversal scanner
                for cmd_pat in self.cmd_patterns:
                    if cmd_pat in val:
                        raise GuardrailViolationException(
                            "tool_invocation",
                            f"Suspicious command separator or traversal '{cmd_pat}' detected in '{key}'.",
                            {"key": key, "pattern": cmd_pat}
                        )

            # Check network egress destination if present
            if key in ("endpoint", "host", "target_url") and isinstance(val, str):
                host_clean = val.split("://")[-1].split("/")[0].split(":")[0]
                if self.allowed_hosts and host_clean not in self.allowed_hosts:
                    raise GuardrailViolationException(
                        "tool_invocation",
                        f"Egress host '{host_clean}' is not in approved whitelist.",
                        {"host": host_clean, "allowed_hosts": list(self.allowed_hosts)}
                    )

        return arguments


class ToolResponseInterceptor:
    """Scans tool return values for poisoned content, prompt overrides, or excessive size."""

    def __init__(self, policies: Optional[Dict[str, Any]] = None):
        self.policies = policies or load_policy_config()
        resp_config = self.policies.get("tool_response_guardrails", {})
        self.max_bytes = resp_config.get("max_response_bytes", 1048576)
        self.disallowed_phrases = [
            p.lower() for p in resp_config.get("disallowed_instruction_phrases", [])
        ]

    def scan_response(self, tool_name: str, payload: Any) -> Any:
        """
        Ensures third-party API payload does not contain hidden Trojan instructions.
        """
        payload_str = json.dumps(payload) if isinstance(payload, (dict, list)) else str(payload)

        if len(payload_str.encode("utf-8")) > self.max_bytes:
            raise GuardrailViolationException(
                "tool_response",
                f"Tool '{tool_name}' returned payload exceeding size limit ({len(payload_str)} bytes).",
                {"size_bytes": len(payload_str)}
            )

        lower_str = payload_str.lower()
        for phrase in self.disallowed_phrases:
            if phrase in lower_str:
                raise GuardrailViolationException(
                    "tool_response",
                    f"Tool response contains indirect prompt injection Trojan: '{phrase}'",
                    {"tool_name": tool_name, "phrase": phrase}
                )

        return payload


class OutputGuardrailInterceptor:
    """Sanitizes model completions, redacts PII, prevents canary leakage, and scores groundedness."""

    def __init__(self, policies: Optional[Dict[str, Any]] = None):
        self.policies = policies or load_policy_config()
        self.pii_patterns = {
            name: re.compile(regex_str, re.IGNORECASE)
            for name, regex_str in self.policies.get("pii_redaction_patterns", {}).items()
        }
        self.min_groundedness = self.policies.get("evaluation_thresholds", {}).get(
            "minimum_groundedness", 0.85
        )

    def redact_pii(self, text: str) -> Tuple[str, List[Dict[str, str]]]:
        """
        Redacts sensitive tokens (SSN, credit card, API keys, canary tokens) with safe placeholders.
        """
        sanitized = text
        redacted_events = []

        for pii_type, pattern in self.pii_patterns.items():
            matches = list(pattern.finditer(sanitized))
            for match in reversed(matches):
                start, end = match.span()
                placeholder = f"[REDACTED_{pii_type.upper()}]"
                sanitized = sanitized[:start] + placeholder + sanitized[end:]
                redacted_events.append({"type": pii_type, "redacted_placeholder": placeholder})

        return sanitized, redacted_events

    def verify_groundedness_heuristic(self, response: str, context: Optional[str]) -> float:
        """
        Computes factual groundedness score (0.0 - 1.0) against context.
        """
        if not context or not context.strip():
            return 1.0

        stopwords = {
            "the", "and", "is", "in", "of", "to", "for", "with", "that", "this",
            "are", "was", "be", "by", "as", "at", "from", "on", "it", "or", "an", "under",
            "has", "had", "have", "not", "but", "all", "any", "been", "must", "can"
        }
        response_tokens = set(re.findall(r"\b[A-Za-z0-9_-]{3,}\b", response.lower())) - stopwords
        context_tokens = set(re.findall(r"\b[A-Za-z0-9_-]{3,}\b", context.lower())) - stopwords

        if not response_tokens:
            return 1.0

        overlap = response_tokens.intersection(context_tokens)
        overlap_ratio = len(overlap) / len(response_tokens)

        # Scale and normalize: If key entities / content words match context, map to calibrated score
        if overlap_ratio >= 0.40:
            normalized_score = min(1.0, 0.85 + (overlap_ratio - 0.40) * 0.25)
        else:
            normalized_score = overlap_ratio * 1.5

        return round(normalized_score, 2)


class SentinelGuardrailPipeline:
    """Complete 4-point guardrail pipeline coordinating all interceptors."""

    def __init__(self, policies: Optional[Dict[str, Any]] = None):
        self.policies = policies or load_policy_config()
        self.input_interceptor = InputGuardrailInterceptor(self.policies)
        self.tool_invocation_interceptor = ToolInvocationInterceptor(self.policies)
        self.tool_response_interceptor = ToolResponseInterceptor(self.policies)
        self.output_interceptor = OutputGuardrailInterceptor(self.policies)

    def process_input(self, user_prompt: str) -> str:
        return self.input_interceptor.validate_user_input(user_prompt)

    def process_tool_invocation(self, tool_name: str, args: Dict[str, Any]) -> Dict[str, Any]:
        return self.tool_invocation_interceptor.validate_tool_call(tool_name, args)

    def process_tool_response(self, tool_name: str, response: Any) -> Any:
        return self.tool_response_interceptor.scan_response(tool_name, response)

    def process_output(self, raw_output: str, context: Optional[str] = None) -> Dict[str, Any]:
        sanitized_text, redactions = self.output_interceptor.redact_pii(raw_output)
        groundedness = self.output_interceptor.verify_groundedness_heuristic(sanitized_text, context)

        if groundedness < self.output_interceptor.min_groundedness and context:
            raise GuardrailViolationException(
                "output_groundedness",
                f"Model response groundedness score ({groundedness}) is below required floor ({self.output_interceptor.min_groundedness}).",
                {"groundedness": groundedness, "min_required": self.output_interceptor.min_groundedness}
            )

        return {
            "output": sanitized_text,
            "redactions": redactions,
            "groundedness_score": groundedness,
            "passed": True
        }
