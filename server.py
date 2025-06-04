from flask import Flask, request, jsonify, send_from_directory
from ollama import chat
from pydantic import BaseModel  # Importação adicionada
from typing import List  # Para tipagem de listas

app = Flask(__name__, static_folder='.')

class OSInfo(BaseModel):
    name: str
    description: str
    pros: List[str]  # Usando List do typing
    cons: List[str]
    best_for: str

@app.route('/ask_os', methods=['POST'])
def ask_os():
    data = request.get_json()
    
    if not data or 'message' not in data:
        return jsonify({'error': 'Missing "message" field'}), 400

    try:
        response = chat(
            messages=[{
                'role': 'user',
                'content': f"""Responda sobre sistemas operacionais com este formato JSON:
                {{
                    "name": "nome do SO",
                    "description": "descrição resumida",
                    "pros": ["vantagem 1", "vantagem 2"],
                    "cons": ["desvantagem 1", "desvantagem 2"],
                    "best_for": "melhor uso"
                }}
                Pergunta: {data['message']}"""
            }],
            model='gemma3:latest',
            format='json'
        )
        
        # Limpeza da resposta
        json_content = response.message.content
        json_content = json_content.replace('```json', '').replace('```', '').strip()
        
        os_info = OSInfo.model_validate_json(json_content)
        return jsonify(os_info.model_dump())

    except Exception as e:
        print(f"Error: {str(e)}")
        return jsonify({'error': 'Failed to process OS information'}), 500

@app.route('/')
def index():
    return send_from_directory('.', 'os.html')

if __name__ == '__main__':
    app.run(debug=True, port=5000)