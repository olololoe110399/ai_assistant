from app.config import settings


def test_settings_loaded():
    assert settings.google_api_key, "google_api_key không được load"
    assert settings.host == "generativelanguage.googleapis.com"
    assert settings.model.startswith("models/")
    assert settings.ws_path.startswith("/ws/")
