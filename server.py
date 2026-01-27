import http.server
import socketserver
import subprocess
import os
import sys

def build_flutter():
    api_key = os.environ.get('GEMINI_API_KEY', '')
    
    if not api_key:
        print("Warning: GEMINI_API_KEY not found, AI features will use mock responses")
    
    print("Building Flutter web app...")
    
    cmd = ['flutter', 'build', 'web']
    if api_key:
        cmd.append(f'--dart-define=GEMINI_API_KEY={api_key}')
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode != 0:
        print(f"Build failed: {result.stderr}")
        sys.exit(1)
    
    print("Build successful!")

class NoCacheHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory='build/web', **kwargs)

    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()

PORT = 5000

class ReuseAddrTCPServer(socketserver.TCPServer):
    allow_reuse_address = True

if __name__ == '__main__':
    build_flutter()
    
    with ReuseAddrTCPServer(("0.0.0.0", PORT), NoCacheHTTPRequestHandler) as httpd:
        print(f"Serving Flutter Web at http://0.0.0.0:{PORT}")
        httpd.serve_forever()
