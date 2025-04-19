import asyncio
import websockets.sync.client
from fastapi import WebSocket
from app.logger import logger
from app.config import settings
import json


class VoiceService:
    def __init__(self, ws: WebSocket):
        self.ws = ws
        self.ws_url = (
            f"wss://{settings.host}{settings.ws_path}"
            f"?key={settings.google_api_key}"
        )

    async def handle(self):
        await self.ws.accept()
        try:
            async with websockets.connect(self.ws_url) as gem_ws:
                init_req = {
                    "setup": {
                        "model": "models/gemini-2.0-flash-exp",
                        "tools": [{"google_search": {}}]
                    }
                }
                await gem_ws.send(json.dumps(init_req))

                async def from_client_to_gemini():
                    async for msg in self.ws.iter_text():
                        await gem_ws.send(msg)

                async def from_gemini_to_client():
                    while True:
                        msg = await gem_ws.recv()
                        await self.ws.send_text(msg)

                await asyncio.gather(from_client_to_gemini(), from_gemini_to_client())
        except Exception as e:
            logger.error("VoiceService error: {}", e)
        finally:
            await self.ws.close()
