from pydantic import Field

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    google_api_key: str = Field(alias='google_api_key')
    host: str = "generativelanguage.googleapis.com"
    model: str = "models/gemini-2.0-flash-exp"
    ws_path: str = "/ws/google.ai.generativelanguage.v1alpha.GenerativeService.BidiGenerateContent"

    model_config = SettingsConfigDict(env_file=".env")


settings = Settings()  # singleton
