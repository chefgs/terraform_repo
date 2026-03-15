"""
main.py

Interactive CLI for the NVIDIA-powered RAG (Retrieval-Augmented Generation)
document assistant.

Usage
-----
  python main.py --file path/to/document.pdf
  python main.py --file doc.txt --save-index ./my_index
  python main.py --load-index ./my_index          # skip re-indexing

The user can then type questions at the prompt; type 'exit' or 'quit' to stop.
"""

import argparse
import sys
import os

from document_processor import load_and_split, SUPPORTED_EXTENSIONS
from rag_engine import RAGEngine


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="NVIDIA RAG Document Assistant – interact with your documents."
    )
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        "--file",
        metavar="FILE",
        help=(
            "Path to a document file to index. "
            f"Supported: {', '.join(SUPPORTED_EXTENSIONS.keys())}"
        ),
    )
    group.add_argument(
        "--load-index",
        metavar="INDEX_DIR",
        help="Path to a previously saved FAISS index directory (skips re-indexing).",
    )
    parser.add_argument(
        "--save-index",
        metavar="INDEX_DIR",
        default=None,
        help="Directory path where the FAISS index will be persisted after indexing.",
    )
    parser.add_argument(
        "--chunk-size",
        type=int,
        default=1000,
        help="Character chunk size for document splitting (default: 1000).",
    )
    parser.add_argument(
        "--chunk-overlap",
        type=int,
        default=200,
        help="Character overlap between adjacent chunks (default: 200).",
    )
    parser.add_argument(
        "--top-k",
        type=int,
        default=4,
        help="Number of document chunks retrieved per query (default: 4).",
    )
    return parser.parse_args()


def print_banner() -> None:
    print(
        "\n"
        "╔══════════════════════════════════════════════════════════════╗\n"
        "║        NVIDIA RAG Document Assistant  (powered by NIM)      ║\n"
        "║   Supports PDF · TXT · DOCX – Type 'exit' to quit           ║\n"
        "╚══════════════════════════════════════════════════════════════╝\n"
    )


def interactive_loop(engine: RAGEngine) -> None:
    """Run the read-eval-print loop for document Q&A."""
    print("\nDocument indexed and ready!  Ask your questions below.\n")
    while True:
        try:
            question = input("You: ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nGoodbye!")
            break

        if not question:
            continue
        if question.lower() in {"exit", "quit", "q"}:
            print("Goodbye!")
            break

        print("\nAssistant: ", end="", flush=True)
        try:
            answer = engine.query(question)
            print(answer)
        except Exception as exc:  # pragma: no cover
            print(f"[Error] {exc}")
        print()


def main() -> None:
    print_banner()
    args = parse_args()

    engine = RAGEngine(top_k=args.top_k)

    if args.load_index:
        # Load a pre-built index from disk
        index_path = os.path.abspath(args.load_index)
        engine.load_index(index_path)
    else:
        # Load, split, and index the provided document
        file_path = os.path.abspath(args.file)
        chunks = load_and_split(
            file_path,
            chunk_size=args.chunk_size,
            chunk_overlap=args.chunk_overlap,
        )
        engine.index_documents(chunks)

        # Optionally save the index for future sessions
        if args.save_index:
            save_path = os.path.abspath(args.save_index)
            os.makedirs(save_path, exist_ok=True)
            engine.save_index(save_path)

    interactive_loop(engine)


if __name__ == "__main__":
    main()
