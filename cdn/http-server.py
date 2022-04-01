# -*- coding: utf-8 -*-
# test on python 3.4 ,python of lower version  has different module organization.
import http.server
import socketserver

PORT = 8080


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory="s3_bucket", **kwargs)


Handler.extensions_map = {
    ".manifest": "text/cache-manifest",
    ".html": "text/html",
    ".tmpl": "text/html",
    ".png": "image/png",
    ".jpg": "image/jpg",
    ".svg": "image/svg+xml",
    ".css": "text/css",
    ".js": "application/x-javascript",
    "": "application/octet-stream",
}

httpd = socketserver.TCPServer(("", PORT), Handler)

print("serving at port", PORT)
httpd.serve_forever()
