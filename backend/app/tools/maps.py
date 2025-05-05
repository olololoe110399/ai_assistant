map_fns = [
    {
        'name': 'draw_map',
        'description': 'Render a Google Maps static map using the specified parameters. No information is returned.',
        'parameters': {
                'type': 'OBJECT',
                'properties': {
                    'center': {
                        'type': 'STRING',
                        'description': 'Location to center the map. It can be a lat,lng pair (e.g. 40.714728,-73.998672), or a string address of a location (e.g. Berkeley,CA).',
                    },
                    'zoom': {
                        'type': 'NUMBER',
                        'description': 'Google Maps zoom level. 1 is the world, 20 is zoomed in to building level. Integer only. Level 11 shows about a 15km radius. Level 9 is about 30km radius.'
                    },
                    'path': {
                        "type": "STRING",
                        'description': """The path parameter defines a set of one or more locations connected by a path to overlay on the map image. The path parameter takes set of value assignments (path descriptors) of the following format:

path=pathStyles|pathLocation1|pathLocation2|... etc.

Note that both path points are separated from each other using the pipe character (|). Because both style information and point information is delimited via the pipe character, style information must appear first in any path descriptor. Once the Maps Static API server encounters a location in the path descriptor, all other path parameters are assumed to be locations as well.

Path styles
The set of path style descriptors is a series of value assignments separated by the pipe (|) character. This style descriptor defines the visual attributes to use when displaying the path. These style descriptors contain the following key/value assignments:

weight: (optional) specifies the thickness of the path in pixels. If no weight parameter is set, the path will appear in its default thickness (5 pixels).
color: (optional) specifies a color either as a 24-bit (example: color=0xFFFFCC) or 32-bit hexadecimal value (example: color=0xFFFFCCFF), or from the set {black, brown, green, purple, yellow, blue, gray, orange, red, white}.

When a 32-bit hex value is specified, the last two characters specify the 8-bit alpha transparency value. This value varies between 00 (completely transparent) and FF (completely opaque). Note that transparencies are supported in paths, though they are not supported for markers.

fillcolor: (optional) indicates both that the path marks off a polygonal area and specifies the fill color to use as an overlay within that area. The set of locations following need not be a "closed" loop; the Maps Static API server will automatically join the first and last points. Note, however, that any stroke on the exterior of the filled area will not be closed unless you specifically provide the same beginning and end location.
geodesic: (optional) indicates that the requested path should be interpreted as a geodesic line that follows the curvature of the earth. When false, the path is rendered as a straight line in screen space. Defaults to false.
Some example path definitions:

Thin blue line, 50% opacity: path=color:0x0000ff80|weight:1
Solid red line: path=color:0xff0000ff|weight:5
Solid thick white line: path=color:0xffffffff|weight:10
These path styles are optional. If default attributes are desired, you may skip defining the path attributes; in that case, the path descriptor's first "argument" will consist instead of the first declared point (location).

Path points
In order to draw a path, the path parameter must also be passed two or more points. The Maps Static API will then connect the path along those points, in the specified order. Each pathPoint is denoted in the pathDescriptor separated by the | (pipe) character.
""",
                    },
                    'markers': {
                        "type": "ARRAY",
                        "items": {
                            "type": "STRING"
                        },
                        # Copied from https://developers.google.com/maps/documentation/maps-static/start#Markers
                        'description': """The markers parameter defines a set of one or more markers (map pins) at a set of locations. Each marker defined within a single markers declaration must exhibit the same visual style; if you wish to display markers with different styles, you will need to supply multiple markers parameters with separate style information.

The markers parameter takes set of value assignments (marker descriptors) of the following format:

markers=markerStyles|markerLocation1| markerLocation2|... etc.

The set of markerStyles is declared at the beginning of the markers declaration and consists of zero or more style descriptors separated by the pipe character (|), followed by a set of one or more locations also separated by the pipe character (|).

Because both style information and location information is delimited via the pipe character, style information must appear first in any marker descriptor. Once the Maps Static API server encounters a location in the marker descriptor, all other marker parameters are assumed to be locations as well.

Marker styles
The set of marker style descriptors is a series of value assignments separated by the pipe (|) character. This style descriptor defines the visual attributes to use when displaying the markers within this marker descriptor. These style descriptors contain the following key/value assignments:

size: (optional) specifies the size of marker from the set {tiny, mid, small}. If no size parameter is set, the marker will appear in its default (normal) size.
color: (optional) specifies a 24-bit color (example: color=0xFFFFCC) or a predefined color from the set {black, brown, green, purple, yellow, blue, gray, orange, red, white}.

Note that transparencies (specified using 32-bit hex color values) are not supported in markers, though they are supported for paths.

label: (optional) specifies a single uppercase alphanumeric character from the set {A-Z, 0-9}. (The requirement for uppercase characters is new to this version of the API.) Note that default and mid sized markers are the only markers capable of displaying an alphanumeric-character parameter. tiny and small markers are not capable of displaying an alphanumeric-character.
""",
                    }
                },
            "required": [
                    "center",
                    "zoom",
                ]

        },
    },
]
