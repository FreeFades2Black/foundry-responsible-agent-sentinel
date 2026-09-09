"""
Knowledge Base Ingestion & Data Spotlighting Package
Provides secure RAG index management, hybrid search ingestion, and delimiter isolation.
"""

from .spotlight import (
    DataSpotlighter,
    DelimitedDocument,
    isolate_untrusted_rag_text,
)
from .ingest import (
    EnterpriseKnowledgeIngestor,
    DocumentChunk,
)

__all__ = [
    "DataSpotlighter",
    "DelimitedDocument",
    "isolate_untrusted_rag_text",
    "EnterpriseKnowledgeIngestor",
    "DocumentChunk",
]
