
import base64
import numpy as np

class AudioProcessor:
    @staticmethod
    def encode_audio(data, sample_rate):
        encoded = base64.b64encode(data.tobytes()).decode("utf-8")
        return {
            "realtimeInput": {
                "mediaChunks": [
                    {"mimeType": f"audio/pcm;rate={sample_rate}", "data": encoded}
                ]
            }
        }

    @staticmethod
    def process_audio_response(data):
        audio = base64.b64decode(data)
        return np.frombuffer(audio, dtype=np.int16)
