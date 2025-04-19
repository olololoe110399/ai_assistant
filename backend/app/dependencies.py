from fastapi import WebSocket
from app.services.voice_service import VoiceService


async def get_voice_service(ws: WebSocket):
    return VoiceService(ws)
