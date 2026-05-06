# Bank AI Search API

FastAPI + LangChain backend that answers banking questions by querying the
Azure AI Search knowledge base over an Azure OpenAI chat model.

## Prerequisites

- Python 3.11+
- Azure CLI (`az login` performed locally)
- Your AAD identity must have:
  - **Cognitive Services OpenAI User** on the AI Foundry resource
  - **Search Index Data Reader** on the Azure AI Search service

## Setup

From this folder (`src/api/aiBootCampAiSearchApi`):

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
# then edit .env with the correct deployment names and index name
az login
```

## Run

```powershell
uvicorn main:app --reload --port 8000
```

The dev server listens on `http://localhost:8000`. The Vite frontend
proxies `/api/*` to it (see `vite.config.ts`).

## Smoke test

```powershell
curl http://localhost:8000/health
curl -X POST http://localhost:8000/chat `
  -H "Content-Type: application/json" `
  -d '{"question":"What documents do you have about checking accounts?"}'
```

## Field names

The vector store in `deps.py` assumes the index has fields named `chunk`
(text) and `text_vector` (vector). If your Knowledge Base generated
different field names, open the index in the Azure portal and update
`content_key` / `vector_key` accordingly.
