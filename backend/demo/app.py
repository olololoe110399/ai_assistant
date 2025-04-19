import gradio as gr
from gradio_webrtc import WebRTC
from demo.gradio_stream_handler import GradioStreamHandler

def registry(
        name: str,
        token: str | None = None,
        **kwargs
):
    interface = gr.Blocks()
    with interface:
        with gr.Tabs():
            with gr.TabItem("Voice Chat"):
                gr.HTML(
                    """
                    <div style='text-align: left'>
                        <h1>Gemini API Voice Chat</h1>
                    </div>
                    """
                )
                gemini_handler = GradioStreamHandler()
                with gr.Row():
                    audio = WebRTC(label="Voice Chat",
                                   modality="audio", mode="send-receive")

                audio.stream(
                    gemini_handler,
                    inputs=[audio],
                    outputs=[audio],
                    time_limit=600,
                    concurrency_limit=10
                )
    return interface


if __name__ == "__main__":
    gr.load(
        name='gemini-2.0-flash-exp',
        src=registry,
    ).launch()
