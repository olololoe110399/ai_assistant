
import json
import numpy as np
import websockets.sync.client
from gradio_webrtc import StreamHandler

from demo.config import GeminiConfig
from audio_processor import AudioProcessor


class GradioStreamHandler(StreamHandler):
    def __init__(
            self,
            expected_layout="mono",
            output_sample_rate=24000,
            output_frame_size=480,
    ):
        super().__init__(
            expected_layout,
            output_sample_rate,
            output_frame_size,
            input_sample_rate=24000,
        )
        self.ws = None
        self.buffer = None
        self.config = GeminiConfig()
        self.proc = AudioProcessor()

    def copy(self):
        return GradioStreamHandler(
            expected_layout=self.expected_layout,
            output_sample_rate=self.output_sample_rate,
            output_frame_size=self.output_frame_size,
        )

    def _init_ws(self):
        try:
            self.ws = websockets.sync.client.connect(
                self.config.ws_url, timeout=3000)
        except Exception as e:
            print(f"Cannot connect to proxy: {e}")
            self.ws = None

    def receive(self, frame):
        if not self.ws:
            self._init_ws()
        if not self.ws:
            return

        _, array = frame
        array = array.squeeze()
        msg = self.proc.encode_audio(array, self.output_sample_rate)
        try:
            self.ws.send(json.dumps(msg))
        except Exception as e:
            print(f"Send error: {e}")
            self.ws = None

    def _drain_buffer(self):
        while self.buffer is not None and self.buffer.shape[-1] >= self.output_frame_size:
            chunk = self.buffer[: self.output_frame_size]
            self.buffer = self.buffer[self.output_frame_size:]
            yield (self.output_sample_rate, chunk.reshape(1, -1))

    def generator(self):
        while True:
            if not self.ws:
                yield None
                continue
            try:
                raw = self.ws.recv(timeout=30)
                msg = json.loads(raw)
                parts = msg.get("serverContent", {}).get(
                    "modelTurn", {}).get("parts", [])
                for p in parts:
                    data = p.get("inlineData", {}).get("data")
                    if data:
                        arr = self.proc.process_audio_response(data)
                        self.buffer = arr if self.buffer is None else np.concatenate(
                            (self.buffer, arr))
                        yield from self._drain_buffer()
            except Exception:
                yield None

    def emit(self):
        if not hasattr(self, "_gen"):
            self._gen = self.generator()
        try:
            return next(self._gen)
        except StopIteration:
            self.reset()
            return None

    def reset(self):
        if hasattr(self, "_gen"):
            del self._gen
        self.buffer = None

    def shutdown(self):
        if self.ws:
            self.ws.close()
