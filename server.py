import subprocess
import os
import sys
import json
from flask import Flask, request, Response, send_from_directory
from flask_cors import CORS
import google.generativeai as genai

app = Flask(__name__, static_folder='build/web')
CORS(app, resources={r"/api/*": {"origins": ["http://localhost:5000", "http://127.0.0.1:5000", "https://*.replit.dev", "https://*.repl.co"]}})

GEMINI_API_KEY = os.environ.get('GEMINI_API_KEY', '')
MODEL_NAME = 'gemini-2.0-flash'
TEMPERATURE = 0.7
MAX_OUTPUT_TOKENS = 500

def add_security_headers(response):
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-Frame-Options'] = 'SAMEORIGIN'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
    response.headers['Cache-Control'] = 'no-store, no-cache, must-revalidate, max-age=0'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '0'
    response.headers['Content-Security-Policy'] = "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://www.gstatic.com; style-src 'self' 'unsafe-inline'; img-src 'self' data: blob:; font-src 'self' data: https://fonts.gstatic.com; connect-src 'self' https://*.replit.dev https://*.repl.co https://www.gstatic.com https://fonts.gstatic.com; frame-ancestors 'self'"
    return response

@app.after_request
def after_request(response):
    return add_security_headers(response)

@app.route('/api/chat', methods=['POST'])
def chat():
    if not GEMINI_API_KEY:
        return Response(
            json.dumps({'error': 'API key not configured'}),
            status=500,
            mimetype='application/json'
        )
    
    try:
        data = request.get_json()
        if not data:
            return Response(
                json.dumps({'error': 'Invalid JSON body'}),
                status=400,
                mimetype='application/json'
            )
        
        message = data.get('message', '')
        history = data.get('history', [])
        system_prompt = data.get('system_prompt', '')
        
        if not message:
            return Response(
                json.dumps({'error': 'Message is required'}),
                status=400,
                mimetype='application/json'
            )
        
        genai.configure(api_key=GEMINI_API_KEY)
        
        model_config = {
            'model_name': MODEL_NAME,
            'generation_config': genai.types.GenerationConfig(
                temperature=TEMPERATURE,
                max_output_tokens=MAX_OUTPUT_TOKENS,
            )
        }
        
        if system_prompt:
            model_config['system_instruction'] = system_prompt
        
        model = genai.GenerativeModel(**model_config)
        
        chat_history = []
        for msg in history:
            role = 'user' if msg.get('isUser', False) else 'model'
            content = msg.get('content', '')
            if content:
                chat_history.append({'role': role, 'parts': [content]})
        
        chat = model.start_chat(history=chat_history)
        
        def generate():
            try:
                response = chat.send_message(message, stream=True)
                for chunk in response:
                    if chunk.text:
                        yield f"data: {json.dumps({'text': chunk.text})}\n\n"
                yield "data: [DONE]\n\n"
            except Exception as e:
                yield f"data: {json.dumps({'error': str(e)})}\n\n"
        
        return Response(
            generate(),
            mimetype='text/event-stream',
            headers={
                'Cache-Control': 'no-cache',
                'Connection': 'keep-alive',
                'X-Accel-Buffering': 'no'
            }
        )
        
    except Exception as e:
        return Response(
            json.dumps({'error': str(e)}),
            status=500,
            mimetype='application/json'
        )

@app.route('/')
def serve_index():
    return send_from_directory(app.static_folder, 'index.html')

@app.route('/<path:path>')
def serve_static(path):
    if os.path.exists(os.path.join(app.static_folder, path)):
        return send_from_directory(app.static_folder, path)
    return send_from_directory(app.static_folder, 'index.html')

def build_flutter():
    print(f"API Key check: {'Found (' + str(len(GEMINI_API_KEY)) + ' chars)' if GEMINI_API_KEY else 'NOT FOUND'}")
    
    if not GEMINI_API_KEY:
        print("Warning: GEMINI_API_KEY not found, AI features will use mock responses")
    
    config_content = '''// Backend API configuration for Flutter web
// API key is securely stored on the server - never exposed to client

const String apiBaseUrl = '';
'''
    with open('lib/core/config/env_config.dart', 'w') as f:
        f.write(config_content)
    print("Generated env_config.dart (API key removed from client)")
    
    print("Building Flutter web app...")
    
    cmd = ['flutter', 'build', 'web']
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode != 0:
        print(f"Build failed: {result.stderr}")
        sys.exit(1)
    
    print("Build successful!")

if __name__ == '__main__':
    build_flutter()
    print(f"Starting secure Flask server on http://0.0.0.0:5000")
    app.run(host='0.0.0.0', port=5000, debug=False, threaded=True)
