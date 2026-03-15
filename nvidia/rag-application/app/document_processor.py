"""
document_processor.py

Handles loading and splitting documents of types: PDF, TXT, and DOCX.
Supports chunking text into overlapping segments for better retrieval.
"""

import os
from typing import List

# LangChain community document loaders
from langchain_community.document_loaders import (
    PyPDFLoader,
    TextLoader,
    Docx2txtLoader,
    UnstructuredWordDocumentLoader,
)
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.schema import Document


SUPPORTED_EXTENSIONS = {
    ".pdf": "PDF",
    ".txt": "TXT",
    ".docx": "DOCX",
    ".doc": "DOC",
}


def load_document(file_path: str) -> List[Document]:
    """
    Load a document from a file path.

    Supported formats: PDF (.pdf), plain text (.txt), Word (.docx / .doc)

    Args:
        file_path: Absolute or relative path to the document file.

    Returns:
        A list of LangChain Document objects.

    Raises:
        ValueError: If the file extension is not supported.
        FileNotFoundError: If the file does not exist.
    """
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"File not found: {file_path}")

    _, ext = os.path.splitext(file_path)
    ext = ext.lower()

    if ext not in SUPPORTED_EXTENSIONS:
        raise ValueError(
            f"Unsupported file type '{ext}'. "
            f"Supported types: {', '.join(SUPPORTED_EXTENSIONS.keys())}"
        )

    print(f"[DocumentProcessor] Loading {SUPPORTED_EXTENSIONS[ext]} file: {file_path}")

    if ext == ".pdf":
        loader = PyPDFLoader(file_path)
    elif ext == ".txt":
        loader = TextLoader(file_path, encoding="utf-8")
    elif ext == ".docx":
        loader = Docx2txtLoader(file_path)
    elif ext == ".doc":
        loader = UnstructuredWordDocumentLoader(file_path)
    else:
        raise ValueError(f"Unsupported extension: {ext}")

    documents = loader.load()
    print(f"[DocumentProcessor] Loaded {len(documents)} page(s)/section(s).")
    return documents


def split_documents(
    documents: List[Document],
    chunk_size: int = 1000,
    chunk_overlap: int = 200,
) -> List[Document]:
    """
    Split documents into overlapping text chunks for vector indexing.

    Args:
        documents: List of LangChain Document objects.
        chunk_size: Maximum number of characters per chunk.
        chunk_overlap: Number of overlapping characters between adjacent chunks.

    Returns:
        A list of smaller Document chunks.
    """
    splitter = RecursiveCharacterTextSplitter(
        chunk_size=chunk_size,
        chunk_overlap=chunk_overlap,
        length_function=len,
        separators=["\n\n", "\n", " ", ""],
    )
    chunks = splitter.split_documents(documents)
    print(f"[DocumentProcessor] Split into {len(chunks)} chunk(s) "
          f"(chunk_size={chunk_size}, overlap={chunk_overlap}).")
    return chunks


def load_and_split(
    file_path: str,
    chunk_size: int = 1000,
    chunk_overlap: int = 200,
) -> List[Document]:
    """
    Convenience helper: load a document then split it into chunks.

    Args:
        file_path: Path to the document file.
        chunk_size: Maximum characters per chunk.
        chunk_overlap: Overlap characters between chunks.

    Returns:
        List of Document chunks ready for embedding.
    """
    docs = load_document(file_path)
    return split_documents(docs, chunk_size=chunk_size, chunk_overlap=chunk_overlap)
