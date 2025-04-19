import asyncio
import pytest
from fastapi.testclient import TestClient
from app.main import app
import uvloop


def event_loop():
    asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest.fixture
def client():
    return TestClient(app)
