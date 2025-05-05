
from app.config import settings
from app.logger import logger
from urllib.parse import urlencode

def draw_map(center, zoom, path: str = "", markers: list[str] = ()):
    logger.debug(f'MAPS: {center=} {zoom=} {path=} {markers=}')
    q = {
        'key': settings.maps_api_key,
        'size': '512x512',
        'center': center,
        'zoom': zoom,
    }

    if path:
        q['path'] = path

    qs = list(q.items())

    for marker in markers:
        qs.append(('markers', marker))

    url = f'https://maps.googleapis.com/maps/api/staticmap?{urlencode(qs)}'
    logger.debug(f"Map URL: {url}")

    return {
        'url': url,
        'width': 512,
        'height': 512,
        'format': 'png',
        'quality': 100,
        'type': 'image/png',
        'content': None,
    }
