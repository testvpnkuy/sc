import socks
import socket
import threading
from http.server import SimpleHTTPRequestHandler, HTTPServer

# ตั้งค่า SOCKS Proxy
socks.set_default_proxy(socks.SOCKS5, "127.0.0.1", 2082)
socket.socket = socks.socksocket

# สร้างเซิร์ฟเวอร์ HTTP
class ProxyHTTPRequestHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write(b"Hello, this is the SOCKS Proxy Server!")

def run(server_class=HTTPServer, handler_class=ProxyHTTPRequestHandler, port=8080):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print(f'Serving HTTP on port {port}...')
    httpd.serve_forever()

if __name__ == "__main__":
    run()
