# SOul

SOul é uma aplicação web que recomenda o sistema operacional ideal com base em um questionário respondido pelo usuário. A recomendação usa uma lógica híbrida: pontuação determinística por regras + refinamento via IA local (Ollama).

---

## Funcionalidades

- Quiz de 6 perguntas que analisa objetivo, hardware, custo e preferências
- Lógica de pontuação determinística (matriz de pesos por SO e resposta)
- Refinamento e justificativa via IA local (Ollama / gemma4)
- Fallback automático para regras se a IA estiver indisponível
- Top 3 sistemas mais compatíveis exibidos no resultado, com badge "Melhor escolha"
- 10 sistemas operacionais cobertos, cada um com página dedicada e screenshots reais
- Favoritos persistidos no MySQL (sincronizados via API Flask)
- Chatbot O.S.C.A.R. para perguntas livres sobre SOs
- Autenticação com PHP + MySQL
- Tema claro/escuro, responsivo
- Termos de Uso e Política de Privacidade (LGPD)

---

## Sistemas Operacionais Suportados

| SO | Perfil principal |
|---|---|
| Windows | Gaming, software corporativo, iniciante |
| macOS | Criatividade, design, ecossistema Apple |
| Ubuntu | Iniciante Linux, dev, uso geral |
| Linux Mint | Migração do Windows, hardware antigo |
| Debian | Servidor, estabilidade, dev experiente |
| Arch Linux | Power user, controle total, rolling |
| Fedora | Dev moderno, Red Hat ecosystem |
| Pop!_OS | Gaming Linux, design, GPU dedicada |
| Zorin OS | Iniciante absoluto, migração Windows/Mac |
| Manjaro | Arch acessível, rolling + AUR |

---

## Arquitetura

```
soul/
├── server.py          # Flask: /recommend, /favorites, /history, /ask_os
├── SOul.sql           # Schema + seeds (banco SOul)
├── shared.js          # Auth, favoritos, sync com backend, tema
├── styles.css         # Design system (tema claro/escuro, componentes)
│
├── index.html         # Página inicial
├── os.html            # Catálogo de SOs (10 cards) + chat O.S.C.A.R.
├── test.html          # Intro do quiz
├── test1-6.html       # 6 perguntas do quiz
├── testresult.html    # Resultado: chama /recommend, exibe top 3 + justificativa IA
├── favorites.html     # Favoritos (sincroniza com banco via /favorites)
├── about.html         # Sobre o projeto
├── login.html         # Tela de login
├── signup.html        # Tela de cadastro
├── terms.html         # Termos de Uso
├── privacy.html       # Política de Privacidade (LGPD)
│
├── ubuntu.html        # Páginas de detalhe com screenshots reais (10 SOs)
├── macos.html
├── arch.html
├── windows.html
├── debian.html
├── mint.html
├── fedora.html
├── popos.html
├── zorinos.html
├── manjaro.html
│
├── login.php          # Auth login (PHP + MySQL)
├── cadastro.php       # Auth cadastro (PHP + MySQL)
│
└── scripts/
    └── screenshots.py # Captura automática de telas com Playwright
```

### Fluxo de recomendação

```
Quiz (6 respostas) → POST /recommend
                      ├─ Pontuação determinística (matriz Python)
                      ├─ Chama Ollama (timeout 10 s)
                      │   └─ JSON: {recomendado, ranking, justificativa, confianca}
                      ├─ [fallback] se Ollama falhar → usa ranking determinístico
                      ├─ Salva em historico_recomendacoes (se logado)
                      └─ Retorna top 3 do ranking + justificativa + fonte (ai | deterministic)
```

### Schema do banco (SOul)

```
usuario              — id, email, senha, nome, data_reg, tema
fabricante           — id, nome, site, pais, descricao, ano
so                   — id, nome, slug, pagina, descricao, fabricante_id
uso                  — id, nome
uso_so               — uso_id, so_id, nota (1-6)
favoritos            — usuario_id, so_id, criado_em
historico_recomendacoes — id, usuario_id, respostas_json, so_recomendado,
                          ranking_json, justificativa, fonte, confianca, criado_em
```

---

## Pré-requisitos

- Python 3.11+
- MySQL 8.0+
- PHP 8.0+ com extensão `mysqli` (para auth)
- Ollama instalado localmente
- Modelo `gemma4:latest` baixado no Ollama

---

## Passo a passo de execução

### 1. Clone o repositório

```bash
git clone https://github.com/ltcmnk/soul.git
cd soul
```

### 2. Crie e ative o ambiente virtual Python

```bash
python -m venv .venv
source .venv/bin/activate      # macOS / Linux
.venv\Scripts\activate         # Windows
```

### 3. Instale as dependências Python

```bash
pip install flask flask-cors pydantic ollama pymysql
```

### 4. Suba o Ollama e baixe o modelo

```bash
ollama serve                   # deixe rodando em terminal separado
ollama pull gemma4             # baixa o modelo (pode demorar na 1ª vez)
```

Para usar outro modelo, edite a variável `model` nas chamadas `chat()` em `server.py`.

### 5. Importe o banco de dados

```bash
mysql -u root -p < SOul.sql
```

O script cria o banco `SOul`, todas as tabelas e seeds dos 10 SOs.

Se suas credenciais do MySQL forem diferentes de `root` / senha vazia, edite:
- `server.py` → dicionário `DB_CONFIG`
- `login.php` e `cadastro.php` → variáveis `$dbuser` e `$dbpass`

### 6. Suba o servidor PHP (para autenticação)

Opção A — PHP built-in server:
```bash
php -S localhost:8080
```
Neste caso, altere as chamadas em `fetch.js` de `login.php`/`cadastro.php` para `http://localhost:8080/login.php` etc.

Opção B — XAMPP / MAMP: copie a pasta para `htdocs` e acesse pelo Apache normalmente.

### 7. Rode o Flask

```bash
python server.py
```

Acesse em: `http://localhost:5000`

---

## Variáveis de configuração

| Arquivo | Variável | Padrão | Descrição |
|---|---|---|---|
| `server.py` | `DB_CONFIG['host']` | `localhost` | Host do MySQL |
| `server.py` | `DB_CONFIG['user']` | `root` | Usuário do MySQL |
| `server.py` | `DB_CONFIG['password']` | `''` | Senha do MySQL |
| `server.py` | `model` (nas chamadas `chat()`) | `gemma4:latest` | Modelo Ollama |
| `login.php` | `$dbuser`, `$dbpass` | `root`, `''` | Credenciais PHP→MySQL |

---

## Testando o sistema

1. Abra `http://localhost:5000`
2. Crie uma conta em **Entrar → Cadastrar**
3. Faça login
4. Clique em **Teste** → responda as 6 perguntas
5. Veja o resultado: top 3 sistemas compatíveis com justificativa (IA ou regras)
6. Favorite SOs nas páginas de detalhe ou nos cards do resultado
7. Consulte seus favoritos em **Favoritos**

Se o Ollama não estiver rodando, o sistema usa automaticamente a pontuação determinística e exibe `Análise por regras determinísticas` no resultado.

---

## Captura de screenshots (documentação)

O script `scripts/screenshots.py` usa Playwright para capturar automaticamente todas as telas do projeto em alta resolução (1440×900 @2x).

```bash
# Instalar dependências do script (uma vez)
pip install playwright
playwright install chromium

# Com Flask rodando em http://127.0.0.1:5000:
python3 scripts/screenshots.py
```

As imagens são salvas em `docs/screenshots/` (não versionadas no git).

---

## Autores

Desenvolvido por **[Letícia Miniuk Rosa Pereira](https://github.com/ltcmnk)**, **[Rayssa Gaievicz Grafetti](https://github.com/T-800-888)** e **Victor Willian Rodrigues Bittencourt**.

---

## Licença

MIT — use, modifique e contribua livremente.
