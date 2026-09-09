"""
Enterprise Knowledge Base Ingestor for Azure AI Search
Supports hybrid retrieval (Vector + BM25 + Semantic Re-ranking) and Document-Level Security Filtering.
"""

import os
import re
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional


@dataclass
class DocumentChunk:
    chunk_id: str
    doc_id: str
    title: str
    content: str
    source_url: str
    security_classification: str = "RESTRICTED"
    allowed_roles: List[str] = field(default_factory=lambda: ["ClinicalAuditor", "SecurityOfficer"])
    embedding: Optional[List[float]] = None


class EnterpriseKnowledgeIngestor:
    """
    Manages chunking, embedding generation, and Azure AI Search index provisioning.
    Implements Defense-in-Depth RAG configuration.
    """

    DEFAULT_INDEX_NAME = "archive-of-eld-knowledge"

    def __init__(
        self,
        search_endpoint: Optional[str] = None,
        index_name: Optional[str] = None,
        chunk_size: int = 400,
        chunk_overlap: int = 50
    ):
        self.search_endpoint = search_endpoint or os.environ.get("AZURE_SEARCH_ENDPOINT", "https://sentinel-search.windows.net")
        self.index_name = index_name or os.environ.get("AZURE_SEARCH_INDEX_NAME", self.DEFAULT_INDEX_NAME)
        self.chunk_size = chunk_size
        self.chunk_overlap = chunk_overlap

    def chunk_text(self, text: str, doc_id: str, title: str, source_url: str, roles: Optional[List[str]] = None) -> List[DocumentChunk]:
        """
        Splits raw text into sliding window chunks with overlap.
        """
        words = re.findall(r"\S+", text)
        chunks = []
        step = max(1, self.chunk_size - self.chunk_overlap)

        if not words:
            return []

        for i in range(0, len(words), step):
            chunk_words = words[i:i + self.chunk_size]
            chunk_text = " ".join(chunk_words)
            chunk_id = f"{doc_id}-chunk-{len(chunks) + 1:04d}"

            chunk = DocumentChunk(
                chunk_id=chunk_id,
                doc_id=doc_id,
                title=title,
                content=chunk_text,
                source_url=source_url,
                allowed_roles=roles or ["ClinicalAuditor", "SecurityOfficer"]
            )
            chunks.append(chunk)

            if i + self.chunk_size >= len(words):
                break

        return chunks

    def generate_mock_embedding(self, text: str, dimensions: int = 1536) -> List[float]:
        """
        Deterministic mock embedding generator for offline testing and CI/CD pipelines.
        """
        import hashlib
        h = hashlib.sha256(text.encode("utf-8")).digest()
        # Derive pseudo-normalized floats
        embedding = []
        for i in range(dimensions):
            byte_val = h[i % len(h)]
            embedding.append(round((byte_val / 255.0) * 2 - 1, 6))
        return embedding

    def build_search_index_schema(self) -> Dict[str, Any]:
        """
        Defines the production Azure AI Search Index Schema with HNSW Vector Search,
        BM25 Analyzer, Semantic Configuration, and Entra ID Security Filter.
        """
        return {
            "name": self.index_name,
            "fields": [
                {"name": "chunk_id", "type": "Edm.String", "key": True, "searchable": False, "filterable": True},
                {"name": "doc_id", "type": "Edm.String", "searchable": False, "filterable": True},
                {"name": "title", "type": "Edm.String", "searchable": True, "filterable": True, "sortable": True},
                {"name": "content", "type": "Edm.String", "searchable": True, "filterable": False},
                {"name": "source_url", "type": "Edm.String", "searchable": False, "filterable": True},
                {"name": "security_classification", "type": "Edm.String", "filterable": True, "facetable": True},
                {"name": "allowed_roles", "type": "Collection(Edm.String)", "filterable": True, "searchable": False},
                {
                    "name": "content_vector",
                    "type": "Collection(Edm.Single)",
                    "searchable": True,
                    "dimensions": 1536,
                    "vectorSearchProfileName": "sentinelHnswProfile"
                }
            ],
            "vectorSearch": {
                "algorithms": [
                    {
                        "name": "sentinelHnswConfig",
                        "kind": "hnsw",
                        "parameters": {
                            "m": 4,
                            "efConstruction": 400,
                            "efSearch": 500,
                            "metric": "cosine"
                        }
                    }
                ],
                "profiles": [
                    {
                        "name": "sentinelHnswProfile",
                        "algorithmConfigurationName": "sentinelHnswConfig"
                    }
                ]
            },
            "semantic": {
                "configurations": [
                    {
                        "name": "sentinelSemanticConfig",
                        "prioritizedFields": {
                            "titleField": {"fieldName": "title"},
                            "contentFields": [{"fieldName": "content"}],
                            "keywordsFields": [{"fieldName": "security_classification"}]
                        }
                    }
                ]
            }
        }


def seed_reference_knowledge_base() -> List[DocumentChunk]:
    """Generates sample grounded knowledge base documents for testing and local verification."""
    sample_corpus = [
        {
            "doc_id": "ARCHIVE-ELD-001",
            "title": "Gilead Clinical Emergency Protocol - Ischemic Stroke Thrombolysis",
            "source_url": "https://clinical-vault.corp.local/protocols/stroke-thrombolysis.html",
            "text": (
                "Under Gilead Regional Health Stroke Care Protocols (Protocol ID: STROKE-2026-v4), "
                "intravenous Alteplase (0.9 mg/kg, max 90 mg) must be initiated within 4.5 hours of symptom onset. "
                "Tenecteplase (0.25 mg/kg, max 25 mg) is indicated as an alternative in large vessel occlusions. "
                "Absolute contraindications include active internal hemorrhage, intracranial neoplasm, and platelet count below 100,000/uL. "
                "All patient vitals and door-to-needle times must be logged to the audited emergency ledger."
            ),
            "roles": ["ClinicalAuditor", "EmergencyStaff"]
        },
        {
            "doc_id": "ARCHIVE-ELD-002",
            "title": "Gilead Zero-Trust Access Control & Security Token Governance",
            "source_url": "https://clinical-vault.corp.local/security/zero-trust-governance.html",
            "text": (
                "In accordance with Gilead Zero-Trust Architecture Directive SEC-801, "
                "no agent may execute external writes without dual cryptographic signoff. "
                "System canary tokens (CANARY-*) must never be echoed or persisted in unencrypted memory. "
                "Direct API access to patient records requires explicit patient pseudonymization and HIPAA Safe Harbor de-identification."
            ),
            "roles": ["SecurityOfficer", "SystemAdmin"]
        }
    ]

    ingestor = EnterpriseKnowledgeIngestor()
    all_chunks = []
    for doc in sample_corpus:
        chunks = ingestor.chunk_text(
            text=doc["text"],
            doc_id=doc["doc_id"],
            title=doc["title"],
            source_url=doc["source_url"],
            roles=doc["roles"]
        )
        for c in chunks:
            c.embedding = ingestor.generate_mock_embedding(c.content)
            all_chunks.append(c)

    return all_chunks


if __name__ == "__main__":
    chunks = seed_reference_knowledge_base()
    print(f"Successfully processed {len(chunks)} knowledge base chunks.")
    schema = EnterpriseKnowledgeIngestor().build_search_index_schema()
    print(f"Generated Azure AI Search schema for index: {schema['name']}")
