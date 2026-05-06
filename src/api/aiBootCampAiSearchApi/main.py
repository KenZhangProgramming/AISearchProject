from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import get_settings
from .routes.chat import router as chat_router

settings = get_settings()

app = FastAPI(title="Bank AI Search API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=False,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
)

app.include_router(chat_router)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}
