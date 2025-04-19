from fastapi import FastAPI
from app.routers import voice
from app.logger import logger

app = FastAPI(title="Gemini Voice Chat API")
app.include_router(voice.router)


@app.get("/")
async def root():
    return {"message": "Gemini Voice Chat API"}


if __name__ == "__main__":
    import uvicorn
    logger.info("Starting server on http://localhost:8000")
    uvicorn.run('app.main:app', host="0.0.0.0", port=8000)