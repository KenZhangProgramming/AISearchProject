from fastapi import APIRouter, HTTPException
from langchain_core.messages import AIMessage, HumanMessage

from ..agent import build_agent
from ..schemas import ChatRequest, ChatResponse

router = APIRouter(prefix="/chat", tags=["chat"])

# The agent is built once at import time so the underlying LLM, embeddings
# and vector store clients are reused across requests.
_agent = build_agent()


@router.post("", response_model=ChatResponse)
async def chat(req: ChatRequest) -> ChatResponse:
    try:
        messages = [
            HumanMessage(t.content) if t.role == "user" else AIMessage(t.content)
            for t in req.history
        ]
        messages.append(HumanMessage(req.question))

        result = await _agent.ainvoke({"messages": messages})
        final = result["messages"][-1]
        answer = (
            final.content if isinstance(final.content, str) else str(final.content)
        )

        # Citation extraction from tool messages can be added later.
        return ChatResponse(answer=answer, citations=[])
    except Exception as exc:  # noqa: BLE001 - surface error detail to caller
        raise HTTPException(status_code=500, detail=str(exc)) from exc
