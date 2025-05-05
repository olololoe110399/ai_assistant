# Gemini Voice Chat AI Assistant

**Gemini Voice Chat AI Assistant** is a cross-platform, real-time voice interaction system powered by FastAPI (backend) and Flutter (frontend). It enables voice communication with AI models (like Gemini), including the ability to handle map drawing via function calls.

## 🎥 Demo

https://github.com/user-attachments/assets/07cd046c-1a19-401b-aa84-5ced50de298a

[Link Youtube](https://youtube.com/shorts/zSvj73AFziU)


## Features

### 🔊 Voice AI Interaction

* Real-time two-way voice streaming.
* AI responses powered by Gemini API (Google's generative model).
* Map generation using Google Static Maps via tool calls.

### 🌐 Cross-Platform Flutter Client

* Android, iOS, macOS, Web, Windows, Linux.
* Uses `flutter_sound`, `permission_handler`, `provider`, and Agora SDK (optional).
* Built-in microphone permission and audio session management.

### ⚙️ Modular Backend

* Built with FastAPI + WebSockets.
* Tool invocation support (function-calling).
* Clean codebase with `routers`, `services`, and `tools` structure.

---

## Directory Structure

```
.
├── backend/                  # FastAPI backend
│   ├── app/               # Main backend logic (routers, services, config)
│   └── tests/             # Backend tests
├── frontend/                # Flutter app
    └── lib/                   # Dart sources
        ├── core/            # Config & utilities
        ├── features/        # Voice Chat feature
        └── rtc-sdk/         # Agora RTC integration (optional)
```

---

## Backend Setup (FastAPI)

### Requirements

```bash
python>=3.10
```

### Install & Run

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### Environment Variables

Create `.env` file in `backend/app/`:

```env
google_api_key=YOUR_GOOGLE_API_KEY
maps_api_key=YOUR_MAPS_API_KEY
```

### Docker (Optional)

```bash
cd backend
docker build -t gemini-voice .
docker run -p 8000:8000 gemini-voice
```

---

## Frontend Setup (Flutter)

### Requirements

* Flutter SDK (>=3.27.0)
* Dart SDK (>=3.7.2)

### Run

```bash
cd frontend
flutter pub get
flutter run
```

### Config WebSocket Endpoint

In `lib/core/config/voice_stream_config.dart`, update:

```dart
static const String wsUri = 'ws://<your-ip>:8000/ws/voice';
```

### Optional: FVM Support

If using FVM:

```bash
fvm install
fvm use
fvm flutter run
```

---

## How It Works

* `Flutter`: Records audio → sends PCM chunks via WebSocket.
* `FastAPI`: Streams chunks to Gemini → handles responses (text/audio/map).
* Gemini can trigger tools like `draw_map()` which returns a static Google Map.
* `Flutter`: Receives inline audio (base64 PCM) → plays it in real time.

---

## Development Notes

### Backend

* Tool calling handled in `voice_service.py`
* Map function declared in `tools/maps.py`
* WebSocket route: `/ws/voice`

### Frontend

* Audio pipeline: `audio_recorder_datasource` → `websocket_datasource` → `audio_player_datasource`
* Visual feedback: `Waveform` widget
* State management: `ChangeNotifier` via `VoiceChatProvider`

---

## Roadmap

* [x] Real-time voice streaming
* [x] Map rendering tool support
* [ ] Chat transcript history
* [ ] AI voice customization
* [ ] UI enhancements (e.g., animation, error states)

---

## License

MIT License

---

## Credits

* Powered by [FastAPI](https://fastapi.tiangolo.com/), [Flutter](https://flutter.dev/), [Google Gemini API](https://ai.google.dev), and [Agora SDK](https://www.agora.io/) (optional).

---

## Contact

Created by [@olololoe110399](https://github.com/olololoe110399) — feel free to reach out for collaboration or feedback!
