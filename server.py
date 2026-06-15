from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import pymysql
import pymysql.cursors
import json
import re
import threading
from ollama import chat
from pydantic import BaseModel
from typing import List

app = Flask(__name__, static_folder='.')
CORS(app)

# ── Configuração do banco ─────────────────────────────────────────────────────
DB_CONFIG = {
    'host':     'localhost',
    'user':     'root',
    'password': '',
    'database': 'SOul',
    'charset':  'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor,
}

def get_db():
    try:
        return pymysql.connect(**DB_CONFIG)
    except Exception as e:
        print(f'[DB] Erro de conexão: {e}')
        return None


# ── Matriz de pontuação determinística ───────────────────────────────────────
# Cada chave de SO mapeia pergunta → resposta → peso (0–3).
# Max por SO = 6 perguntas × 3 pontos = 18 pontos → normalizado para 0–100.

SCORING_MATRIX = {
    'windows': {
        '1q': {'daily': 2, 'work': 2, 'gaming': 3, 'study': 1, 'dev': 1, 'design': 1},
        '2q': {'yes': 3, 'no': 0},
        '3q': {'2009-2014': 0, '2015-2019': 2, '2020-2025': 3},
        '4q': {'yes': 1, 'no': 2},
        '5q': {'minimal': 3, 'moderate': 2, 'full': 0},
        '6q': {'low-willingness': 3, 'medium-willingness': 1, 'high-willingness': 0},
    },
    'macos': {
        '1q': {'daily': 1, 'work': 2, 'gaming': 0, 'study': 1, 'dev': 2, 'design': 3},
        '2q': {'yes': 3, 'no': 0},
        '3q': {'2009-2014': 0, '2015-2019': 1, '2020-2025': 3},
        '4q': {'yes': 2, 'no': 1},
        '5q': {'minimal': 2, 'moderate': 2, 'full': 0},
        '6q': {'low-willingness': 1, 'medium-willingness': 2, 'high-willingness': 1},
    },
    'ubuntu': {
        '1q': {'daily': 2, 'work': 2, 'gaming': 1, 'study': 2, 'dev': 3, 'design': 1},
        '2q': {'yes': 0, 'no': 3},
        '3q': {'2009-2014': 1, '2015-2019': 2, '2020-2025': 3},
        '4q': {'yes': 2, 'no': 1},
        '5q': {'minimal': 2, 'moderate': 3, 'full': 1},
        '6q': {'low-willingness': 1, 'medium-willingness': 3, 'high-willingness': 2},
    },
    'mint': {
        '1q': {'daily': 3, 'work': 1, 'gaming': 1, 'study': 2, 'dev': 1, 'design': 0},
        '2q': {'yes': 0, 'no': 3},
        '3q': {'2009-2014': 2, '2015-2019': 3, '2020-2025': 2},
        '4q': {'yes': 1, 'no': 2},
        '5q': {'minimal': 3, 'moderate': 2, 'full': 0},
        '6q': {'low-willingness': 3, 'medium-willingness': 2, 'high-willingness': 0},
    },
    'debian': {
        '1q': {'daily': 1, 'work': 2, 'gaming': 0, 'study': 2, 'dev': 3, 'design': 0},
        '2q': {'yes': 0, 'no': 3},
        '3q': {'2009-2014': 2, '2015-2019': 3, '2020-2025': 3},
        '4q': {'yes': 2, 'no': 1},
        '5q': {'minimal': 0, 'moderate': 2, 'full': 3},
        '6q': {'low-willingness': 0, 'medium-willingness': 2, 'high-willingness': 3},
    },
    'arch': {
        '1q': {'daily': 0, 'work': 1, 'gaming': 2, 'study': 1, 'dev': 3, 'design': 0},
        '2q': {'yes': 0, 'no': 3},
        '3q': {'2009-2014': 0, '2015-2019': 1, '2020-2025': 3},
        '4q': {'yes': 3, 'no': 0},
        '5q': {'minimal': 0, 'moderate': 0, 'full': 3},
        '6q': {'low-willingness': 0, 'medium-willingness': 0, 'high-willingness': 3},
    },
    'fedora': {
        '1q': {'daily': 1, 'work': 2, 'gaming': 1, 'study': 2, 'dev': 3, 'design': 1},
        '2q': {'yes': 0, 'no': 3},
        '3q': {'2009-2014': 0, '2015-2019': 2, '2020-2025': 3},
        '4q': {'yes': 2, 'no': 1},
        '5q': {'minimal': 1, 'moderate': 2, 'full': 3},
        '6q': {'low-willingness': 0, 'medium-willingness': 2, 'high-willingness': 3},
    },
    'popos': {
        '1q': {'daily': 1, 'work': 1, 'gaming': 3, 'study': 1, 'dev': 2, 'design': 2},
        '2q': {'yes': 0, 'no': 3},
        '3q': {'2009-2014': 0, '2015-2019': 2, '2020-2025': 3},
        '4q': {'yes': 2, 'no': 1},
        '5q': {'minimal': 2, 'moderate': 2, 'full': 1},
        '6q': {'low-willingness': 1, 'medium-willingness': 2, 'high-willingness': 2},
    },
    'zorin': {
        '1q': {'daily': 3, 'work': 1, 'gaming': 1, 'study': 2, 'dev': 0, 'design': 1},
        '2q': {'yes': 0, 'no': 3},
        '3q': {'2009-2014': 2, '2015-2019': 3, '2020-2025': 3},
        '4q': {'yes': 1, 'no': 2},
        '5q': {'minimal': 3, 'moderate': 1, 'full': 0},
        '6q': {'low-willingness': 3, 'medium-willingness': 2, 'high-willingness': 0},
    },
    'manjaro': {
        '1q': {'daily': 1, 'work': 1, 'gaming': 2, 'study': 1, 'dev': 2, 'design': 1},
        '2q': {'yes': 0, 'no': 3},
        '3q': {'2009-2014': 0, '2015-2019': 2, '2020-2025': 3},
        '4q': {'yes': 2, 'no': 1},
        '5q': {'minimal': 1, 'moderate': 2, 'full': 2},
        '6q': {'low-willingness': 0, 'medium-willingness': 2, 'high-willingness': 3},
    },
}

MAX_SCORE = 18  # 6 perguntas × máx 3 pts

# Metadados de exibição (nome, ícone, cor, página) usados na resposta da API
OS_DISPLAY = {
    'windows': {
        'name': 'Windows', 'slug': 'windows', 'page': 'windows.html',
        'description': 'O sistema mais usado do mundo. Compatibilidade incomparável com jogos, '
                       'software corporativo e vasta gama de hardware.',
        'icon': 'fab fa-windows', 'color': '#0078D7',
        'gradient': 'linear-gradient(135deg,#0078D7,#004E8C)',
        'type': 'Microsoft',
        'features': ['Compatibilidade máxima', 'Ecossistema gaming', 'Interface familiar'],
    },
    'macos': {
        'name': 'macOS', 'slug': 'macos', 'page': 'macos.html',
        'description': 'O sistema da Apple: design refinado, excelente para criatividade '
                       'e desenvolvimento, integrado com iPhone e iPad.',
        'icon': 'fab fa-apple', 'color': '#888888',
        'gradient': 'linear-gradient(135deg,#111,#3a3a3a)',
        'type': 'Apple',
        'features': ['Design elegante', 'Ótimo para criatividade', 'Ecossistema Apple'],
    },
    'ubuntu': {
        'name': 'Ubuntu', 'slug': 'ubuntu', 'page': 'ubuntu.html',
        'description': 'O Linux mais popular. Amigável para iniciantes, poderoso para devs, '
                       'com vasta comunidade e repositório imenso.',
        'icon': 'fab fa-ubuntu', 'color': '#E95420',
        'gradient': 'linear-gradient(135deg,#E95420,#77216F)',
        'type': 'Linux',
        'features': ['Interface amigável', 'Grande comunidade', 'Perfeito para dev'],
    },
    'mint': {
        'name': 'Linux Mint', 'slug': 'mint', 'page': 'mint.html',
        'description': 'A transição mais suave para quem vem do Windows. Estável, leve '
                       'e completo desde o primeiro boot.',
        'icon': 'fas fa-leaf', 'color': '#87CF3E',
        'gradient': 'linear-gradient(135deg,#87CF3E,#5A9E22)',
        'type': 'Linux',
        'features': ['Visual familiar', 'Altamente estável', 'Pronto para uso'],
    },
    'debian': {
        'name': 'Debian', 'slug': 'debian', 'page': 'debian.html',
        'description': 'Estabilidade lendária. Base para metade das distros Linux. '
                       'Ideal para servidores e devs que priorizam confiabilidade.',
        'icon': 'fab fa-debian', 'color': '#A80030',
        'gradient': 'linear-gradient(135deg,#A80030,#6D001E)',
        'type': 'Linux',
        'features': ['Estabilidade lendária', 'Base do Ubuntu', 'Software 100% livre'],
    },
    'arch': {
        'name': 'Arch Linux', 'slug': 'arch', 'page': 'arch.html',
        'description': 'Controle total sobre cada componente. Instalação manual, '
                       'rolling release, AUR gigante. Você constrói do zero.',
        'icon': 'fab fa-linux', 'color': '#1793D1',
        'gradient': 'linear-gradient(135deg,#1793D1,#0F5F8F)',
        'type': 'Linux',
        'features': ['Controle total', 'AUR (repositório imenso)', 'Rolling release'],
    },
    'fedora': {
        'name': 'Fedora', 'slug': 'fedora', 'page': 'fedora.html',
        'description': 'Distribuição de ponta patrocinada pela Red Hat. Pacotes sempre '
                       'atualizados, foco em desenvolvedores e tecnologias emergentes.',
        'icon': 'fab fa-fedora', 'color': '#3C6EB4',
        'gradient': 'linear-gradient(135deg,#294172,#3C6EB4)',
        'type': 'Linux',
        'features': ['Pacotes de ponta', 'Red Hat ecosystem', 'Ideal para dev'],
    },
    'popos': {
        'name': 'Pop!_OS', 'slug': 'popos', 'page': 'popos.html',
        'description': 'Criado pela System76 para máximo desempenho em jogos e criação. '
                       'Driver Nvidia integrado e interface polida sem complicação.',
        'icon': 'fas fa-rocket', 'color': '#48B9C7',
        'gradient': 'linear-gradient(135deg,#48B9C7,#32878F)',
        'type': 'Linux',
        'features': ['Driver Nvidia nativo', 'Tiling window manager', 'Perfeito para gamers'],
    },
    'zorin': {
        'name': 'Zorin OS', 'slug': 'zorin', 'page': 'zorinos.html',
        'description': 'O Linux mais amigável para quem migra do Windows ou Mac. '
                       'Interface familiar, visual moderno, zero terminal necessário.',
        'icon': 'fas fa-desktop', 'color': '#15A6F0',
        'gradient': 'linear-gradient(135deg,#15A6F0,#0D7AB5)',
        'type': 'Linux',
        'features': ['Interface tipo Windows', 'Zero configuração', 'Ideal para iniciantes'],
    },
    'manjaro': {
        'name': 'Manjaro', 'slug': 'manjaro', 'page': 'manjaro.html',
        'description': 'O Arch Linux acessível. Rolling release, AUR, instalador gráfico. '
                       'Para quem quer poder sem a complexidade do Arch puro.',
        'icon': 'fas fa-gem', 'color': '#35BF5C',
        'gradient': 'linear-gradient(135deg,#35BF5C,#2A9948)',
        'type': 'Linux',
        'features': ['Baseado no Arch', 'Instalação simples', 'Rolling release + AUR'],
    },
}

# Mapa inverso: nome legível → slug
_NAME_TO_SLUG = {info['name'].lower(): slug for slug, info in OS_DISPLAY.items()}


# ── Funções auxiliares ────────────────────────────────────────────────────────

def compute_deterministic_ranking(answers: dict) -> list[tuple[str, int]]:
    """Retorna lista (slug, score_pct) ordenada do maior para o menor."""
    scores = {}
    for slug, weights in SCORING_MATRIX.items():
        total = sum(
            weights.get(q, {}).get(ans, 0)
            for q, ans in answers.items()
        )
        scores[slug] = round((total / MAX_SCORE) * 100)
    return sorted(scores.items(), key=lambda x: x[1], reverse=True)


def call_ollama(answers: dict, ranking: list[tuple[str, int]]) -> dict | None:
    """Chama o Ollama com prompt estruturado. Retorna dict ou None em caso de falha."""
    top5 = [
        {'so': OS_DISPLAY[s]['name'], 'compatibilidade': f'{sc}%',
         'descricao': OS_DISPLAY[s]['description']}
        for s, sc in ranking[:5]
    ]

    label_map = {
        'daily': 'uso diário', 'work': 'trabalho', 'gaming': 'jogos',
        'study': 'estudos', 'dev': 'desenvolvimento', 'design': 'design/arte',
        'yes': 'sim', 'no': 'não',
        '2009-2014': '2009–2014', '2015-2019': '2015–2019', '2020-2025': '2020–2025',
        'minimal': 'pronto para uso', 'moderate': 'moderada', 'full': 'controle total',
        'low-willingness': 'baixa', 'medium-willingness': 'moderada', 'high-willingness': 'alta',
    }

    prompt = f"""Você é especialista em sistemas operacionais. Analise o perfil do usuário e valide o ranking.

Perfil do usuário:
- Objetivo principal: {label_map.get(answers.get('1q',''), answers.get('1q','?'))}
- Disposto a pagar pelo SO: {label_map.get(answers.get('2q',''), answers.get('2q','?'))}
- Ano do hardware: {label_map.get(answers.get('3q',''), answers.get('3q','?'))}
- Precisa de multitarefa avançada: {label_map.get(answers.get('4q',''), answers.get('4q','?'))}
- Nível de personalização desejado: {label_map.get(answers.get('5q',''), answers.get('5q','?'))}
- Disposição para aprender novo SO: {label_map.get(answers.get('6q',''), answers.get('6q','?'))}

Top-5 calculado por regras determinísticas:
{json.dumps(top5, ensure_ascii=False, indent=2)}

Analise se o ranking faz sentido para este perfil. Você pode reordenar se houver razão técnica clara.
Responda SOMENTE com JSON válido, sem markdown, neste formato exato:
{{"recomendado": "nome do SO", "ranking": ["1º SO", "2º SO", "3º SO"], "justificativa": "2-3 frases em português explicando a recomendação", "confianca": 85}}

"confianca" deve ser inteiro 0-100 representando sua certeza."""

    try:
        response = chat(
            messages=[{'role': 'user', 'content': prompt}],
            model='gemma4:latest',
            format='json',
        )
        raw = response.message.content.strip()
        raw = re.sub(r'```(?:json)?\s*', '', raw).strip('`').strip()
        data = json.loads(raw)

        if not all(k in data for k in ('recomendado', 'ranking', 'justificativa', 'confianca')):
            return None
        if not isinstance(data['ranking'], list) or not isinstance(data['confianca'], (int, float)):
            return None
        return data
    except Exception as e:
        print(f'[Ollama] Erro: {e}')
        return None


def build_ranked_list(ordered_slugs: list[str], score_map: dict) -> list[dict]:
    """Monta a lista de SOs para a resposta, enriquecida com metadados."""
    seen = set()
    result = []
    for slug in ordered_slugs:
        if slug in OS_DISPLAY and slug not in seen:
            seen.add(slug)
            result.append({**OS_DISPLAY[slug], 'score': score_map.get(slug, 0)})
    return result


# ── Endpoint: recomendação principal ─────────────────────────────────────────

@app.route('/recommend', methods=['POST'])
def recommend():
    body = request.get_json(silent=True)
    if not body or 'answers' not in body:
        return jsonify({'error': 'Campo "answers" obrigatório'}), 400

    answers  = body['answers']
    user_id  = body.get('userId')

    # 1. Pontuação determinística
    ranking   = compute_deterministic_ranking(answers)
    score_map = dict(ranking)

    # 2. Refinamento via Ollama (timeout 10 s)
    ai_result     = None
    result_holder = [None]

    def _ollama():
        result_holder[0] = call_ollama(answers, ranking)

    t = threading.Thread(target=_ollama, daemon=True)
    t.start()
    t.join(timeout=10)
    ai_result = result_holder[0]

    # 3. Montar resposta final
    if ai_result:
        fonte        = 'ai'
        recomendado  = ai_result['recomendado']
        justificativa = ai_result['justificativa']
        confianca    = int(ai_result.get('confianca', 0))

        ai_slugs = [_NAME_TO_SLUG.get(n.lower()) for n in ai_result.get('ranking', [])]
        ai_slugs = [s for s in ai_slugs if s]
        det_slugs = [s for s, _ in ranking if s not in ai_slugs]
        ordered_slugs = ai_slugs + det_slugs
    else:
        fonte         = 'deterministic'
        top_slug      = ranking[0][0] if ranking else 'ubuntu'
        recomendado   = OS_DISPLAY[top_slug]['name']
        justificativa = ('Recomendação baseada em critérios técnicos: objetivo de uso, '
                         'compatibilidade de hardware, custo, personalização e curva de aprendizado.')
        confianca     = score_map.get(top_slug, 0)
        ordered_slugs = [s for s, _ in ranking]

    ranked_list = build_ranked_list(ordered_slugs, score_map)

    # 4. Persistir no histórico (se usuário logado e banco disponível)
    if user_id:
        db = get_db()
        if db:
            try:
                with db.cursor() as cur:
                    cur.execute(
                        """INSERT INTO historico_recomendacoes
                           (usuario_id, respostas_json, so_recomendado, ranking_json,
                            justificativa, fonte, confianca)
                           VALUES (%s, %s, %s, %s, %s, %s, %s)""",
                        (user_id,
                         json.dumps(answers, ensure_ascii=False),
                         recomendado,
                         json.dumps([r['name'] for r in ranked_list[:5]], ensure_ascii=False),
                         justificativa, fonte, confianca)
                    )
                db.commit()
            except Exception as e:
                print(f'[DB] Erro ao salvar histórico: {e}')
            finally:
                db.close()

    return jsonify({
        'recomendado':  recomendado,
        'ranking':      ranked_list,
        'justificativa': justificativa,
        'fonte':        fonte,
        'confianca':    confianca,
    })


# ── Endpoint: favoritos ───────────────────────────────────────────────────────

@app.route('/favorites/<int:user_id>', methods=['GET'])
def get_favorites(user_id):
    db = get_db()
    if not db:
        return jsonify({'error': 'Banco indisponível'}), 503
    try:
        with db.cursor() as cur:
            cur.execute(
                """SELECT s.slug FROM favoritos f
                   JOIN so s ON s.id = f.so_id
                   WHERE f.usuario_id = %s""",
                (user_id,)
            )
            slugs = [row['slug'] for row in cur.fetchall()]
        return jsonify({'favorites': slugs})
    except Exception as e:
        print(f'[DB] Erro ao buscar favoritos: {e}')
        return jsonify({'error': 'Erro interno'}), 500
    finally:
        db.close()


@app.route('/favorites', methods=['POST'])
def add_favorite():
    body = request.get_json(silent=True) or {}
    user_id = body.get('userId')
    slug    = body.get('slug')
    if not user_id or not slug:
        return jsonify({'error': 'userId e slug obrigatórios'}), 400

    db = get_db()
    if not db:
        return jsonify({'error': 'Banco indisponível'}), 503
    try:
        with db.cursor() as cur:
            cur.execute('SELECT id FROM so WHERE slug = %s', (slug,))
            row = cur.fetchone()
            if not row:
                return jsonify({'error': 'SO não encontrado'}), 404
            so_id = row['id']
            cur.execute(
                'INSERT IGNORE INTO favoritos (usuario_id, so_id) VALUES (%s, %s)',
                (user_id, so_id)
            )
        db.commit()
        return jsonify({'ok': True})
    except Exception as e:
        print(f'[DB] Erro ao adicionar favorito: {e}')
        return jsonify({'error': 'Erro interno'}), 500
    finally:
        db.close()


@app.route('/favorites', methods=['DELETE'])
def remove_favorite():
    body = request.get_json(silent=True) or {}
    user_id = body.get('userId')
    slug    = body.get('slug')
    if not user_id or not slug:
        return jsonify({'error': 'userId e slug obrigatórios'}), 400

    db = get_db()
    if not db:
        return jsonify({'error': 'Banco indisponível'}), 503
    try:
        with db.cursor() as cur:
            cur.execute(
                """DELETE f FROM favoritos f
                   JOIN so s ON s.id = f.so_id
                   WHERE f.usuario_id = %s AND s.slug = %s""",
                (user_id, slug)
            )
        db.commit()
        return jsonify({'ok': True})
    except Exception as e:
        print(f'[DB] Erro ao remover favorito: {e}')
        return jsonify({'error': 'Erro interno'}), 500
    finally:
        db.close()


# ── Endpoint: histórico de recomendações ─────────────────────────────────────

@app.route('/history/<int:user_id>', methods=['GET'])
def get_history(user_id):
    db = get_db()
    if not db:
        return jsonify({'error': 'Banco indisponível'}), 503
    try:
        with db.cursor() as cur:
            cur.execute(
                """SELECT id, so_recomendado, ranking_json, justificativa,
                          fonte, confianca, criado_em
                   FROM historico_recomendacoes
                   WHERE usuario_id = %s
                   ORDER BY criado_em DESC
                   LIMIT 20""",
                (user_id,)
            )
            rows = cur.fetchall()
        for r in rows:
            if r.get('criado_em'):
                r['criado_em'] = r['criado_em'].isoformat()
        return jsonify({'history': rows})
    except Exception as e:
        print(f'[DB] Erro ao buscar histórico: {e}')
        return jsonify({'error': 'Erro interno'}), 500
    finally:
        db.close()


# ── Endpoint: chatbot O.S.C.A.R. (mantido) ───────────────────────────────────

class OSInfo(BaseModel):
    name:        str
    description: str
    pros:        List[str]
    cons:        List[str]
    best_for:    str


@app.route('/ask_os', methods=['POST'])
def ask_os():
    body = request.get_json(silent=True)
    if not body or 'message' not in body:
        return jsonify({'error': 'Campo "message" obrigatório'}), 400

    try:
        response = chat(
            messages=[{
                'role': 'user',
                'content': (
                    'Responda sobre sistemas operacionais com este formato JSON exato:\n'
                    '{"name":"nome do SO","description":"descrição resumida",'
                    '"pros":["vantagem 1","vantagem 2"],'
                    '"cons":["desvantagem 1","desvantagem 2"],'
                    '"best_for":"melhor uso"}\n'
                    f'Pergunta: {body["message"]}'
                ),
            }],
            model='gemma4:latest',
            format='json',
        )
        raw = response.message.content
        raw = raw.replace('```json', '').replace('```', '').strip()
        os_info = OSInfo.model_validate_json(raw)
        return jsonify(os_info.model_dump())
    except Exception as e:
        print(f'[Ollama] Erro em /ask_os: {e}')
        return jsonify({'error': 'Falha ao processar informação do SO'}), 500


# ── Arquivos estáticos ────────────────────────────────────────────────────────

@app.route('/')
def index():
    return send_from_directory('.', 'index.html')

@app.route('/<path:filename>')
def serve_static(filename):
    return send_from_directory('.', filename)


if __name__ == '__main__':
    app.run(debug=True, port=5000)
