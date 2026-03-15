"""
rag_engine.py

Retrieval-Augmented Generation (RAG) engine powered by NVIDIA NIM / OpenAI-compatible
LLM endpoints and a local FAISS vector store.

The engine:
1. Embeds document chunks into a FAISS vector index.
2. Accepts user questions, retrieves the most relevant chunks, and
   synthesises an answer using a chat LLM.

Environment variables
---------------------
NVIDIA_API_KEY   – NVIDIA NIM API key (required when using NIM endpoints).
OPENAI_API_KEY   – OpenAI API key (used as fallback if NVIDIA_API_KEY is absent).
LLM_MODEL        – LLM model identifier (default: "meta/llama-3.1-8b-instruct").
EMBEDDING_MODEL  – Embedding model identifier
                   (default: "nvidia/nv-embedqa-e5-v5").
LLM_BASE_URL     – Base URL for the LLM API endpoint
                   (default: "https://integrate.api.nvidia.com/v1").
"""

import os
from typing import List, Optional

from langchain.schema import Document
from langchain.chains import RetrievalQA
from langchain.prompts import PromptTemplate
from langchain_community.vectorstores import FAISS

# ---------------------------------------------------------------------------
# Provider selection: prefer NVIDIA NIM; fall back to OpenAI.
# ---------------------------------------------------------------------------
_NVIDIA_API_KEY = os.getenv("NVIDIA_API_KEY", "")
_OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")

_LLM_MODEL = os.getenv("LLM_MODEL", "meta/llama-3.1-8b-instruct")
_EMBEDDING_MODEL = os.getenv("EMBEDDING_MODEL", "nvidia/nv-embedqa-e5-v5")
_LLM_BASE_URL = os.getenv("LLM_BASE_URL", "https://integrate.api.nvidia.com/v1")

# RAG prompt template
_RAG_PROMPT = PromptTemplate(
    input_variables=["context", "question"],
    template=(
        "You are a helpful AI assistant. Use the following document excerpts to "
        "answer the user's question.\n\n"
        "Context:\n{context}\n\n"
        "Question: {question}\n\n"
        "Answer:"
    ),
)


def _build_llm():
    """Instantiate the chat LLM (NVIDIA NIM or OpenAI fallback)."""
    if _NVIDIA_API_KEY:
        try:
            from langchain_nvidia_ai_endpoints import ChatNVIDIA  # type: ignore
            print(f"[RAGEngine] Using NVIDIA NIM endpoint: {_LLM_BASE_URL}")
            return ChatNVIDIA(
                model=_LLM_MODEL,
                nvidia_api_key=_NVIDIA_API_KEY,
                base_url=_LLM_BASE_URL,
                temperature=0.2,
                max_tokens=1024,
            )
        except ImportError:
            print(
                "[RAGEngine] WARNING: langchain-nvidia-ai-endpoints not installed. "
                "Falling back to OpenAI-compatible client."
            )

    # Fallback: OpenAI-compatible client pointed at NIM or public OpenAI
    from langchain_openai import ChatOpenAI  # type: ignore
    api_key = _NVIDIA_API_KEY or _OPENAI_API_KEY or "stub-key"
    base_url = _LLM_BASE_URL if _NVIDIA_API_KEY else None
    print(f"[RAGEngine] Using OpenAI-compatible LLM: {_LLM_MODEL}")
    return ChatOpenAI(
        model=_LLM_MODEL,
        api_key=api_key,
        base_url=base_url,
        temperature=0.2,
        max_tokens=1024,
    )


def _build_embeddings():
    """Instantiate the embedding model (NVIDIA NIM or OpenAI fallback)."""
    if _NVIDIA_API_KEY:
        try:
            from langchain_nvidia_ai_endpoints import NVIDIAEmbeddings  # type: ignore
            print(f"[RAGEngine] Using NVIDIA embedding model: {_EMBEDDING_MODEL}")
            return NVIDIAEmbeddings(
                model=_EMBEDDING_MODEL,
                nvidia_api_key=_NVIDIA_API_KEY,
            )
        except ImportError:
            print(
                "[RAGEngine] WARNING: langchain-nvidia-ai-endpoints not installed. "
                "Falling back to OpenAI embeddings."
            )

    from langchain_openai import OpenAIEmbeddings  # type: ignore
    api_key = _OPENAI_API_KEY or "stub-key"
    print("[RAGEngine] Using OpenAI embeddings (text-embedding-ada-002).")
    return OpenAIEmbeddings(api_key=api_key)


class RAGEngine:
    """
    Document-grounded question-answering engine.

    Usage
    -----
    engine = RAGEngine()
    engine.index_documents(chunks)   # embed and store
    answer = engine.query("What is the main topic?")
    """

    def __init__(self, top_k: int = 4) -> None:
        """
        Args:
            top_k: Number of document chunks to retrieve per query.
        """
        self.top_k = top_k
        self._vector_store: Optional[FAISS] = None
        self._qa_chain = None

        self._embeddings = _build_embeddings()
        self._llm = _build_llm()

    def index_documents(self, chunks: List[Document]) -> None:
        """
        Embed document chunks and build (or replace) the FAISS vector store.

        Args:
            chunks: Pre-split Document objects from document_processor.
        """
        if not chunks:
            raise ValueError("No document chunks provided for indexing.")

        print(f"[RAGEngine] Building FAISS index from {len(chunks)} chunk(s)…")
        self._vector_store = FAISS.from_documents(chunks, self._embeddings)

        retriever = self._vector_store.as_retriever(
            search_type="similarity",
            search_kwargs={"k": self.top_k},
        )
        self._qa_chain = RetrievalQA.from_chain_type(
            llm=self._llm,
            chain_type="stuff",
            retriever=retriever,
            chain_type_kwargs={"prompt": _RAG_PROMPT},
            return_source_documents=True,
        )
        print("[RAGEngine] Index built and QA chain ready.")

    def query(self, question: str) -> str:
        """
        Answer a question grounded in the indexed documents.

        Args:
            question: Natural-language question string.

        Returns:
            Answer string synthesised by the LLM.

        Raises:
            RuntimeError: If documents have not been indexed yet.
        """
        if self._qa_chain is None:
            raise RuntimeError(
                "No documents indexed. Call index_documents() before querying."
            )

        result = self._qa_chain({"query": question})
        answer = result.get("result", "").strip()
        sources = result.get("source_documents", [])

        if sources:
            source_refs = set()
            for doc in sources:
                src = doc.metadata.get("source", "")
                page = doc.metadata.get("page", "")
                ref = f"{src}" + (f" (page {page})" if page != "" else "")
                if ref:
                    source_refs.add(ref)
            if source_refs:
                answer += "\n\n[Sources: " + "; ".join(sorted(source_refs)) + "]"

        return answer

    def save_index(self, path: str) -> None:
        """Persist the FAISS index to disk for reuse between sessions."""
        if self._vector_store is None:
            raise RuntimeError("No index to save. Call index_documents() first.")
        self._vector_store.save_local(path)
        print(f"[RAGEngine] Index saved to: {path}")

    def load_index(self, path: str) -> None:
        """Load a previously saved FAISS index from disk."""
        self._vector_store = FAISS.load_local(
            path,
            self._embeddings,
            allow_dangerous_deserialization=True,
        )
        retriever = self._vector_store.as_retriever(
            search_type="similarity",
            search_kwargs={"k": self.top_k},
        )
        self._qa_chain = RetrievalQA.from_chain_type(
            llm=self._llm,
            chain_type="stuff",
            retriever=retriever,
            chain_type_kwargs={"prompt": _RAG_PROMPT},
            return_source_documents=True,
        )
        print(f"[RAGEngine] Index loaded from: {path}")
