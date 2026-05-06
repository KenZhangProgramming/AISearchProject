from langchain_core.documents import Document
from langchain_core.tools import tool
from langchain.agents import create_agent

from .deps import get_llm, get_vector_store

SYSTEM_PROMPT = (
    "You are a helpful banking assistant for the Bank AI Search application. "
    "Use the `search_bank_documents` tool to look up factual information "
    "from the bank's internal knowledge base before answering questions "
    "about products, fees, policies, or procedures. "
    "When you use retrieved information, cite the source titles inline "
    "using square brackets, e.g. [source-title]. "
    "If the tool returns nothing relevant, say you don't know rather than "
    "guessing."
)


@tool("search_bank_documents")
def search_bank_documents(query: str) -> str:
    """Search the bank's internal documents and return the most relevant chunks.

    Use this whenever the user asks about bank products, accounts, fees,
    procedures, or any factual banking information.
    """
    vs = get_vector_store()
    docs: list[Document] = vs.hybrid_search(query=query, k=4)
    if not docs:
        return "No relevant documents found."

    parts: list[str] = []
    for i, d in enumerate(docs, start=1):
        title = (
            d.metadata.get("title")
            or d.metadata.get("source")
            or d.metadata.get("metadata_storage_name")
            or f"doc-{i}"
        )
        parts.append(f"[{i}] {title}\n{d.page_content}")
    return "\n\n".join(parts)


def build_agent():
    return create_agent(
        model=get_llm(),
        tools=[search_bank_documents],
        system_prompt=SYSTEM_PROMPT,
    )
