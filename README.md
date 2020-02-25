# HomeBus Wyze Camera

This is a simple Ruby program which reads a still image from a Wyze camera running Dafang Hacks firmware, and, if successful, publishes the base64-encoded image as well as its MIME type to HomeBus.

## Configuration

Configure a `.env` file:
```
CAMERA_URL=https://CAMERA-IP-OR-NAME/cgi-bin/currentpic.cgi
CAMERA_USERNAME=(firmware default root)
CAMERA_PASSWORD=camera password (firmware default ismart12)
CAMERA_LOCATION=unique location name
```
