import asyncio
import websockets.sync.client
from fastapi import WebSocket
from app.logger import logger
from app.config import settings
import json
from app.utils import draw_map
from app.tools.maps import map_fns


async def handle_tool_call(ws, tool_call, responses):
  """Process an incoming tool call request, returning a response."""
  logger.debug("<<< " + json.dumps(tool_call))
  for fc in tool_call['functionCalls']:

    if fc['name'] in responses:
      result_entry = responses[fc['name']]
      if callable(result_entry):
        result = result_entry(**fc['args'])
    else:
      result = {'string_value': 'ok'}
    msg = {
        'tool_response': {
            'function_responses': [{
                'id': fc['id'],
                'name': fc['name'],
                'response': {'result': result}
            }]
        }
    }
    payload = json.dumps(msg, ensure_ascii=False)   # ➜ str
    logger.debug(">>> " +  payload)                 # safe logging
    try:
        await ws.send_text(payload)                 # send as text
    except Exception as e:
        logger.error("Error sending tool response: {}", e)
        break


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
                        "tools": [
                            {'google_search': {}},
                            {'function_declarations': map_fns},
                        ],
                    }
                }
                await gem_ws.send(json.dumps(init_req))

                async def from_client_to_gemini():
                    async for msg in self.ws.iter_text():
                        await gem_ws.send(msg)

                async def from_gemini_to_client():
                    while True:
                        msg = await gem_ws.recv()
                        response = json.loads(msg.decode())
                        tool_calls = {
                            'draw_map': draw_map,
                        }
                        tool_call = response.pop('toolCall', None)
                        if tool_call:
                            await handle_tool_call(self.ws, tool_call, tool_calls)
                            continue
                        await self.ws.send_text(msg)

                await asyncio.gather(from_client_to_gemini(), from_gemini_to_client())
        except Exception as e:
            logger.error("VoiceService error: {}", e)
            await self.ws.close()
