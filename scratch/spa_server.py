import http.server
import socketserver
import socket
import os
import sys

PORT = 8085
DIRECTORY = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'build', 'web'))
if not os.path.exists(DIRECTORY):
    DIRECTORY = r'c:\Users\BAPS\Desktop\application 2\build\web'

class SPALocalHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def do_GET(self):
        # Disable caching for development & handle SPA routing fallback
        path = self.translate_path(self.path)
        if not os.path.exists(path) and not '.' in os.path.basename(self.path):
            self.path = '/index.html'
        return super().do_GET()

    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        self.send_header('Clear-Site-Data', '"cache"')
        super().end_headers()

class DualStackServer(socketserver.TCPServer):
    address_family = socket.AF_INET6
    allow_reuse_address = True
    def server_bind(self):
        try:
            self.socket.setsockopt(socket.IPPROTO_IPV6, socket.IPV6_V6ONLY, 0)
        except Exception:
            pass
        return super().server_bind()

if __name__ == '__main__':
    try:
        httpd = DualStackServer(('::', PORT), SPALocalHandler)
    except Exception:
        socketserver.TCPServer.allow_reuse_address = True
        httpd = socketserver.TCPServer(("", PORT), SPALocalHandler)

    print(f"Serving SPA dual-stack at port {PORT} from {DIRECTORY}")
    try:
        httpd.serve_forever()
    finally:
        httpd.server_close()
