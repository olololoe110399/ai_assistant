from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends
from app.dependencies import get_voice_service

router = APIRouter()


@router.websocket("/ws/voice")
async def voice_ws(
    ws: WebSocket,
    svc=Depends(get_voice_service)
):
    await svc.handle()

