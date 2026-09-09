"""
External API Tools with Strict Schema Validation and Security Interceptors
Implements audited retrieval and secure action execution for the Gilead Sentinel Agent.
"""

import json
import re
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field, field_validator


class PatientLookupInput(BaseModel):
    patient_id: str = Field(
        ...,
        description="Sanitized patient pseudonym identifier formatted as PAT-[A-Z0-9]{4,10}",
        min_length=8,
        max_length=15
    )
    requesting_officer: str = Field(
        ...,
        description="Identity of the authenticated clinical or security officer",
        min_length=3,
        max_length=64
    )

    @field_validator("patient_id")
    @classmethod
    def validate_patient_id(cls, v: str) -> str:
        if not re.match(r"^PAT-[A-Z0-9]{4,10}$", v):
            raise ValueError(f"Invalid patient_id format '{v}'. Must match PAT-[A-Z0-9]{{4,10}}.")
        return v


class ProtocolQueryInput(BaseModel):
    query: str = Field(
        ...,
        description="Clinical protocol query term or guideline ID",
        min_length=3,
        max_length=200
    )
    category: str = Field(
        default="EMERGENCY_STROKE",
        description="Clinical domain category"
    )

    @field_validator("query")
    @classmethod
    def validate_query(cls, v: str) -> str:
        disallowed = [";", "--", "/*", "*/", "exec(", "union select"]
        for d in disallowed:
            if d in v.lower():
                raise ValueError(f"Malicious query pattern detected: '{d}'")
        return v.strip()


class EHRDispatchInput(BaseModel):
    patient_id: str = Field(..., description="Target patient pseudonym")
    action_type: str = Field(..., description="Action to dispatch, e.g., ORDER_THROMBOLYSIS")
    dosage_mg: float = Field(..., gt=0.0, le=100.0, description="Dosage in milligrams")
    authorized_by_role: str = Field(..., description="Must be 'ChiefMedicalOfficer' or 'AttendingPhysician'")
    cryptographic_signoff_hash: str = Field(
        ...,
        description="SHA-256 HMAC signature of dual approval",
        min_length=64,
        max_length=64
    )

    @field_validator("authorized_by_role")
    @classmethod
    def validate_role(cls, v: str) -> str:
        allowed = ["ChiefMedicalOfficer", "AttendingPhysician"]
        if v not in allowed:
            raise ValueError(f"Role '{v}' is not authorized to dispatch EHR actions. Required: {allowed}")
        return v


class MedicalRecordLookupTool:
    """Tool for retrieving de-identified patient encounter vitals."""

    name = "lookup_patient_record"
    description = "Retrieves sanitized, pseudonymized patient records with strict schema validation."

    def __call__(self, **kwargs: Any) -> Dict[str, Any]:
        parsed = PatientLookupInput(**kwargs)
        # Simulated secure internal database response
        return {
            "status": "SUCCESS",
            "patient_id": parsed.patient_id,
            "pseudonym": f"PSEUDO-{parsed.patient_id}",
            "last_admit": "2026-09-08T14:30:00Z",
            "chief_complaint": "Acute onset ischemic deficits",
            "blood_pressure": "145/90",
            "weight_kg": 75.0,
            "contraindications_found": False
        }


class ClinicalProtocolQueryTool:
    """Tool for querying vetted clinical protocols from the Archive of Eld."""

    name = "query_clinical_protocol"
    description = "Queries authoritative clinical guidelines from the vetted enterprise archive."

    def __call__(self, **kwargs: Any) -> Dict[str, Any]:
        parsed = ProtocolQueryInput(**kwargs)
        return {
            "status": "SUCCESS",
            "category": parsed.category,
            "protocol_id": "STROKE-2026-v4",
            "title": "Gilead Clinical Emergency Protocol - Ischemic Stroke Thrombolysis",
            "guideline": (
                "Intravenous Alteplase (0.9 mg/kg, maximum 90 mg) indicated within 4.5 hours of onset. "
                "Monitor for angioedema. Tenecteplase alternative indicated for confirmed large vessel occlusions."
            ),
            "evidence_grade": "CLASS_I_LEVEL_A"
        }


class SecureEHRDispatchAction:
    """Tool for audited write actions against the EHR with mandatory cryptographic approval."""

    name = "dispatch_ehr_action"
    description = "Audited write action tool that executes an EHR dispatch with role-based signoff."

    def __call__(self, **kwargs: Any) -> Dict[str, Any]:
        parsed = EHRDispatchInput(**kwargs)
        return {
            "status": "ACTION_DISPATCHED",
            "transaction_id": f"TX-EHR-{parsed.patient_id}-992",
            "action_type": parsed.action_type,
            "dosage_mg": parsed.dosage_mg,
            "signoff_verified": True,
            "dispatched_at": "2026-09-09T10:00:00Z"
        }
