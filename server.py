import subprocess
import os
import sys
import json
import uuid
from datetime import datetime, timedelta
from functools import wraps
import time

from flask import Flask, request, Response, send_from_directory, jsonify
from flask_cors import CORS
import psycopg2
from psycopg2.extras import RealDictCursor
import google.generativeai as genai

app = Flask(__name__, static_folder='build/web')
CORS(app, resources={r"/api/*": {"origins": "*"}})

GEMINI_API_KEY = os.environ.get('GEMINI_API_KEY', '')
DATABASE_URL = os.environ.get('DATABASE_URL', '')
MODEL_NAME = 'gemini-2.0-flash'
TEMPERATURE = 0.7
MAX_OUTPUT_TOKENS = 500

rate_limit_store = {}
RATE_LIMIT_REQUESTS = 60
RATE_LIMIT_WINDOW = 60

def get_db():
    return psycopg2.connect(DATABASE_URL, cursor_factory=RealDictCursor)

def init_db():
    if not DATABASE_URL:
        print("Warning: DATABASE_URL not set, database features disabled")
        return
    try:
        conn = get_db()
        cur = conn.cursor()
        cur.execute('''
            CREATE TABLE IF NOT EXISTS users (
                id TEXT PRIMARY KEY,
                email TEXT,
                stripe_customer_id TEXT,
                stripe_subscription_id TEXT,
                is_premium BOOLEAN DEFAULT FALSE,
                created_at TIMESTAMP DEFAULT NOW()
            )
        ''')
        cur.execute('''
            CREATE TABLE IF NOT EXISTS meditation_sessions (
                id TEXT PRIMARY KEY,
                user_id TEXT REFERENCES users(id),
                meditation_id TEXT NOT NULL,
                duration_seconds INTEGER NOT NULL,
                completed_at TIMESTAMP DEFAULT NOW()
            )
        ''')
        cur.execute('''
            CREATE TABLE IF NOT EXISTS user_progress (
                id TEXT PRIMARY KEY,
                user_id TEXT UNIQUE REFERENCES users(id),
                total_minutes INTEGER DEFAULT 0,
                current_streak INTEGER DEFAULT 0,
                longest_streak INTEGER DEFAULT 0,
                sessions_completed INTEGER DEFAULT 0,
                last_session_date DATE
            )
        ''')
        cur.execute('''
            CREATE TABLE IF NOT EXISTS user_profiles (
                id TEXT PRIMARY KEY,
                user_id TEXT UNIQUE REFERENCES users(id),
                motivation TEXT DEFAULT 'toward',
                reference_style TEXT DEFAULT 'internal',
                thinking_style TEXT DEFAULT 'visual',
                interaction_count INTEGER DEFAULT 0,
                last_interaction TIMESTAMP,
                profile_data JSONB DEFAULT '{}'::jsonb,
                created_at TIMESTAMP DEFAULT NOW(),
                updated_at TIMESTAMP DEFAULT NOW()
            )
        ''')
        conn.commit()
        cur.close()
        conn.close()
        print("Database initialized successfully")
    except Exception as e:
        print(f"Database init error: {e}")

def rate_limit(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        ip = request.remote_addr
        now = time.time()
        if ip not in rate_limit_store:
            rate_limit_store[ip] = []
        rate_limit_store[ip] = [t for t in rate_limit_store[ip] if now - t < RATE_LIMIT_WINDOW]
        if len(rate_limit_store[ip]) >= RATE_LIMIT_REQUESTS:
            return jsonify({'error': 'Rate limit exceeded'}), 429
        rate_limit_store[ip].append(now)
        return f(*args, **kwargs)
    return decorated

def add_security_headers(response):
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
    response.headers['Cache-Control'] = 'no-store, no-cache, must-revalidate, max-age=0'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '0'
    response.headers['Content-Security-Policy'] = "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://www.gstatic.com; style-src 'self' 'unsafe-inline'; img-src 'self' data: blob:; font-src 'self' data: https://fonts.gstatic.com; connect-src 'self' https://*.replit.dev https://*.repl.co https://www.gstatic.com https://fonts.gstatic.com; frame-ancestors *"
    return response

@app.after_request
def after_request(response):
    return add_security_headers(response)

@app.route('/api/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok', 'timestamp': datetime.now().isoformat()})

@app.route('/api/users', methods=['POST'])
@rate_limit
def create_user():
    if not DATABASE_URL:
        return jsonify({'error': 'Database not configured'}), 500
    try:
        data = request.get_json() or {}
        user_id = data.get('id', str(uuid.uuid4()))
        email = data.get('email', '')
        
        conn = get_db()
        cur = conn.cursor()
        cur.execute('SELECT * FROM users WHERE id = %s', (user_id,))
        existing = cur.fetchone()
        if existing:
            cur.close()
            conn.close()
            return jsonify(dict(existing))
        
        cur.execute(
            'INSERT INTO users (id, email) VALUES (%s, %s) RETURNING *',
            (user_id, email)
        )
        user = cur.fetchone()
        cur.execute(
            'INSERT INTO user_progress (id, user_id) VALUES (%s, %s)',
            (str(uuid.uuid4()), user_id)
        )
        conn.commit()
        cur.close()
        conn.close()
        return jsonify(dict(user)), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/sessions', methods=['POST'])
@rate_limit
def log_session():
    if not DATABASE_URL:
        return jsonify({'error': 'Database not configured'}), 500
    try:
        data = request.get_json()
        if not data:
            return jsonify({'error': 'Invalid JSON'}), 400
        
        user_id = data.get('userId')
        meditation_id = data.get('meditationId')
        duration = data.get('durationSeconds', 0)
        
        if not user_id or not meditation_id:
            return jsonify({'error': 'userId and meditationId required'}), 400
        
        conn = get_db()
        cur = conn.cursor()
        
        session_id = str(uuid.uuid4())
        cur.execute(
            'INSERT INTO meditation_sessions (id, user_id, meditation_id, duration_seconds) VALUES (%s, %s, %s, %s)',
            (session_id, user_id, meditation_id, duration)
        )
        
        today = datetime.now().date()
        cur.execute('SELECT * FROM user_progress WHERE user_id = %s', (user_id,))
        progress = cur.fetchone()
        
        if progress:
            minutes_to_add = duration // 60
            new_total = (progress['total_minutes'] or 0) + minutes_to_add
            new_sessions = (progress['sessions_completed'] or 0) + 1
            
            last_date = progress['last_session_date']
            current_streak = progress['current_streak'] or 0
            longest_streak = progress['longest_streak'] or 0
            
            if last_date:
                if last_date == today - timedelta(days=1):
                    current_streak += 1
                elif last_date != today:
                    current_streak = 1
            else:
                current_streak = 1
            
            if current_streak > longest_streak:
                longest_streak = current_streak
            
            cur.execute('''
                UPDATE user_progress 
                SET total_minutes = %s, sessions_completed = %s, 
                    current_streak = %s, longest_streak = %s, last_session_date = %s
                WHERE user_id = %s
            ''', (new_total, new_sessions, current_streak, longest_streak, today, user_id))
        
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({'success': True, 'sessionId': session_id})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/progress/<user_id>', methods=['GET'])
@rate_limit
def get_progress(user_id):
    if not DATABASE_URL:
        return jsonify({'totalMinutes': 0, 'currentStreak': 0, 'sessionsCompleted': 0})
    try:
        conn = get_db()
        cur = conn.cursor()
        cur.execute('SELECT * FROM user_progress WHERE user_id = %s', (user_id,))
        progress = cur.fetchone()
        cur.close()
        conn.close()
        
        if progress:
            return jsonify({
                'totalMinutes': progress['total_minutes'] or 0,
                'currentStreak': progress['current_streak'] or 0,
                'longestStreak': progress['longest_streak'] or 0,
                'sessionsCompleted': progress['sessions_completed'] or 0
            })
        return jsonify({'totalMinutes': 0, 'currentStreak': 0, 'sessionsCompleted': 0})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/subscription/<user_id>', methods=['GET'])
@rate_limit
def get_subscription(user_id):
    if not DATABASE_URL:
        return jsonify({'isSubscribed': False, 'plan': 'free'})
    try:
        conn = get_db()
        cur = conn.cursor()
        cur.execute('SELECT is_premium, stripe_subscription_id FROM users WHERE id = %s', (user_id,))
        user = cur.fetchone()
        cur.close()
        conn.close()
        
        if user and user['is_premium']:
            return jsonify({'isSubscribed': True, 'plan': 'premium'})
        return jsonify({'isSubscribed': False, 'plan': 'free'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/products', methods=['GET'])
def get_products():
    return jsonify({
        'products': [
            {
                'id': 'free',
                'name': 'Free',
                'description': 'Basic meditations',
                'price': 0,
                'interval': None
            },
            {
                'id': 'premium_monthly',
                'name': 'Premium Monthly',
                'description': 'Full access to all content',
                'price': 999,
                'interval': 'month'
            },
            {
                'id': 'premium_annual',
                'name': 'Premium Annual',
                'description': 'Best value - save 33%',
                'price': 7999,
                'interval': 'year'
            }
        ]
    })

@app.route('/api/chat', methods=['POST'])
@rate_limit
def chat():
    if not GEMINI_API_KEY:
        return jsonify({'error': 'API key not configured'}), 500
    
    try:
        data = request.get_json()
        if not data:
            return jsonify({'error': 'Invalid JSON body'}), 400
        
        message = data.get('message', '')
        history = data.get('history', [])
        system_prompt = data.get('system_prompt', '')
        
        if not message:
            return jsonify({'error': 'Message is required'}), 400
        
        if len(message) > 2000:
            return jsonify({'error': 'Message too long (max 2000 chars)'}), 400
        
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
        for msg in history[-10:]:
            role = 'user' if msg.get('isUser', False) else 'model'
            content = msg.get('content', '')
            if content:
                chat_history.append({'role': role, 'parts': [content]})
        
        chat_session = model.start_chat(history=chat_history)
        
        def generate():
            try:
                response = chat_session.send_message(message, stream=True)
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
        return jsonify({'error': str(e)}), 500

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
    print(f"Database: {'Connected' if DATABASE_URL else 'NOT CONFIGURED'}")
    
    config_content = '''const String apiBaseUrl = '';
'''
    os.makedirs('lib/core/config', exist_ok=True)
    with open('lib/core/config/env_config.dart', 'w') as f:
        f.write(config_content)
    print("Generated env_config.dart")
    
    print("Building Flutter web app...")
    result = subprocess.run(['flutter', 'build', 'web', '--no-tree-shake-icons'], capture_output=True, text=True)
    
    if result.returncode != 0:
        print(f"Build failed: {result.stderr}")
        sys.exit(1)
    
    print("Build successful!")

if __name__ == '__main__':
    build_flutter()
    init_db()
    print(f"Starting MindFlow server on http://0.0.0.0:5000")
    app.run(host='0.0.0.0', port=5000, debug=False, threaded=True)
