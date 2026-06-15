"""
scripts/screenshots.py — Captura automática de telas do SOul
============================================================

Pré-requisitos
--------------
    # Na raiz do projeto, com o venv ativo:
    pip install playwright
    playwright install chromium

    # Em terminais separados:
    ollama serve                   # necessário só para oscar_chat.png
    python3 server.py              # Flask em http://localhost:5000

    # Se /ubuntu.html retornar 404, adicione ao server.py (antes do if __name__):
    #   @app.route('/<path:filename>')
    #   def serve_static(filename):
    #       return send_from_directory('.', filename)

Execução
--------
    python3 scripts/screenshots.py

Saída: docs/screenshots/*.png
"""

import asyncio
from pathlib import Path

from playwright.async_api import Browser, BrowserContext, Page, async_playwright

# ── Configuração ──────────────────────────────────────────────────────────────

BASE_URL  = "http://127.0.0.1:5000"
OUT_DIR   = Path(__file__).parent.parent / "docs" / "screenshots"

VIEWPORT  = {"width": 1440, "height": 900}
DPR       = 2          # device pixel ratio — imagens nítidas em retina
AI_TIMEOUT = 60_000    # ms — tempo para o Ollama responder

OSCAR_QUESTION = "Qual sistema operacional é melhor para desenvolvimento de software?"

# localStorage injetado em TODOS os contextos para evitar redirects de auth
_AUTH_SCRIPT = """
    localStorage.setItem('userLoggedIn', 'true');
    localStorage.setItem('userName', 'Demo');
    localStorage.setItem('favoriteOS', JSON.stringify(['Ubuntu', 'Arch Linux']));
"""

# Respostas do questionário no formato que recommendOS() usa (chaves q1…q7)
_QUIZ_ANSWERS = """
    localStorage.setItem('testAnswers', JSON.stringify({
        "q1": "easy", "q2": "free", "q3": "gui",
        "q4": "productivity", "q5": "stable",
        "q6": "basic", "q7": "beginner"
    }));
"""

# ── Helpers ───────────────────────────────────────────────────────────────────

async def new_ctx(browser: Browser) -> BrowserContext:
    ctx = await browser.new_context(
        viewport=VIEWPORT,
        device_scale_factor=DPR,
    )
    # Injeta auth antes de qualquer script da página para evitar redirects
    await ctx.add_init_script(_AUTH_SCRIPT)
    return ctx


async def goto(page: Page, url: str) -> None:
    """
    Navega com domcontentloaded (confiável mesmo com CDNs lentos/bloqueados)
    e aguarda 1.5 s para o JavaScript da página inicializar.
    """
    await page.goto(url, wait_until="domcontentloaded", timeout=30_000)
    await asyncio.sleep(1.5)


async def snap(page: Page, filename: str) -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    dest = OUT_DIR / filename
    # Sobe ao topo para garantir que o header aparece
    await page.evaluate("window.scrollTo(0, 0)")
    await page.screenshot(path=str(dest), full_page=True)
    title = await page.title()
    print(f"  ✓  {filename}  [{title}]")


# ── Capturas ──────────────────────────────────────────────────────────────────

async def capture_home(browser: Browser) -> None:
    ctx = await new_ctx(browser)
    page = await ctx.new_page()
    await goto(page, f"{BASE_URL}/index.html")
    await page.wait_for_selector("section.hero", timeout=8_000)
    await snap(page, "home.png")
    await ctx.close()


async def capture_os_page(browser: Browser) -> None:
    """Página de SOs com a mensagem de boas-vindas do OSCAR já carregada."""
    ctx = await new_ctx(browser)
    page = await ctx.new_page()
    await goto(page, f"{BASE_URL}/os.html")
    await page.wait_for_selector(".os-grid", timeout=8_000)
    # Aguarda o OSCAR renderizar a mensagem de boas-vindas (setada via JS)
    await page.wait_for_selector(".chat-message.message-bot", timeout=8_000)
    await snap(page, "os.png")
    await ctx.close()


async def capture_oscar_chat(browser: Browser) -> None:
    """
    Captura o chat OSCAR com uma conversa de exemplo injetada via JS.

    Injetar o conteúdo diretamente é a abordagem padrão para screenshots de
    documentação: o visual é idêntico ao real, sem depender do tempo de
    inferência do modelo (gemma4 no M1 pode ultrapassar 60 s em cold start).
    """
    ctx = await new_ctx(browser)
    page = await ctx.new_page()
    await goto(page, f"{BASE_URL}/os.html")

    # Aguarda a mensagem de boas-vindas do OSCAR estar no DOM
    await page.wait_for_selector(".chat-message.message-bot", timeout=8_000)

    # Injeta pergunta do usuário + resposta do bot com o mesmo HTML que o JS real produziria
    await page.evaluate(f"""() => {{
        const chat = document.getElementById('chat-messages');
        const loading = document.getElementById('loading-indicator');

        // Pergunta do usuário
        const userMsg = document.createElement('div');
        userMsg.className = 'chat-message message-user';
        userMsg.innerHTML = '<p>{OSCAR_QUESTION}</p>';
        chat.insertBefore(userMsg, loading);

        // Resposta do bot (mesmo formato gerado por addMessage no os.html)
        const botMsg = document.createElement('div');
        botMsg.className = 'chat-message message-bot';
        botMsg.innerHTML = `
            <strong>Ubuntu</strong>
            <p>Ubuntu é uma das melhores escolhas para desenvolvimento de software,
               oferecendo suporte nativo a praticamente todas as ferramentas modernas
               de dev e um terminal poderoso.</p>
            <div class="pros-cons-container">
                <div class="pros-section">
                    <strong>✔ Vantagens</strong>
                    <ul>
                        <li>Suporte amplo a linguagens e frameworks</li>
                        <li>Terminal e ferramentas CLI de alto nível</li>
                        <li>Grande comunidade e documentação</li>
                    </ul>
                </div>
                <div class="cons-section">
                    <strong>✖ Desvantagens</strong>
                    <ul>
                        <li>Menor compatibilidade com software proprietário</li>
                        <li>Curva de aprendizado inicial para iniciantes</li>
                    </ul>
                </div>
            </div>
            <div class="best-for">
                <strong>💡 Melhor para:</strong>
                Desenvolvedores web, backend e DevOps
            </div>
        `;
        chat.insertBefore(botMsg, loading);

        // Scrola para mostrar a resposta
        chat.scrollTop = chat.scrollHeight;
    }}""")

    await asyncio.sleep(0.3)
    await snap(page, "oscar_chat.png")
    await ctx.close()


async def capture_quiz_intro(browser: Browser) -> None:
    ctx = await new_ctx(browser)
    page = await ctx.new_page()
    await goto(page, f"{BASE_URL}/test.html")
    await page.wait_for_selector(".quiz-intro-card", timeout=8_000)
    await snap(page, "quiz_intro.png")
    await ctx.close()


async def capture_quiz_q1(browser: Browser) -> None:
    ctx = await new_ctx(browser)
    page = await ctx.new_page()
    await goto(page, f"{BASE_URL}/test1.html")
    await page.wait_for_selector(".options-grid", timeout=8_000)
    await snap(page, "quiz_q1.png")
    await ctx.close()


async def capture_testresult(browser: Browser) -> None:
    """
    Injeta respostas do quiz via add_init_script ANTES que o DOMContentLoaded
    da página execute — sem race condition. Aguarda #resultsSection ficar visível
    (aparece após 1.5 s de delay simulado + renderização dos cards).
    """
    ctx = await new_ctx(browser)
    await ctx.add_init_script(_QUIZ_ANSWERS)  # adiciona às respostas já no contexto
    page = await ctx.new_page()
    await goto(page, f"{BASE_URL}/testresult.html")
    await page.wait_for_selector("#resultsSection", state="visible", timeout=15_000)
    await snap(page, "testresult.png")
    await ctx.close()


async def capture_ubuntu(browser: Browser) -> None:
    ctx = await new_ctx(browser)
    page = await ctx.new_page()
    await goto(page, f"{BASE_URL}/ubuntu.html")
    await page.wait_for_selector(".os-hero", timeout=8_000)
    await snap(page, "ubuntu.png")
    await ctx.close()


async def capture_windows(browser: Browser) -> None:
    ctx = await new_ctx(browser)
    page = await ctx.new_page()
    await goto(page, f"{BASE_URL}/windows.html")
    await page.wait_for_selector("main", timeout=8_000)
    await snap(page, "windows.png")
    await ctx.close()


async def capture_favorites(browser: Browser) -> None:
    ctx = await new_ctx(browser)
    page = await ctx.new_page()
    await goto(page, f"{BASE_URL}/favorites.html")
    await page.wait_for_selector("main", timeout=8_000)
    await snap(page, "favoritos.png")
    await ctx.close()


async def capture_login(browser: Browser) -> None:
    # Login não requer auth; abre contexto sem injeção para mostrar a tela real
    ctx = await browser.new_context(viewport=VIEWPORT, device_scale_factor=DPR)
    page = await ctx.new_page()
    await goto(page, f"{BASE_URL}/login.html")
    await page.wait_for_selector(".auth-container", timeout=8_000)
    await snap(page, "login.png")
    await ctx.close()


async def capture_signup(browser: Browser) -> None:
    ctx = await browser.new_context(viewport=VIEWPORT, device_scale_factor=DPR)
    page = await ctx.new_page()
    await goto(page, f"{BASE_URL}/signup.html")
    await page.wait_for_selector("main, .auth-container, form", timeout=8_000)
    await snap(page, "signup.png")
    await ctx.close()


async def capture_about(browser: Browser) -> None:
    ctx = await new_ctx(browser)
    page = await ctx.new_page()
    await goto(page, f"{BASE_URL}/about.html")
    await page.wait_for_selector("main", timeout=8_000)
    await snap(page, "about.png")
    await ctx.close()


# ── Orquestração ──────────────────────────────────────────────────────────────

CAPTURES = [
    ("Home",                        capture_home),
    ("Sistemas Operacionais",       capture_os_page),
    ("OSCAR — resposta da IA",      capture_oscar_chat),
    ("Questionário — intro",        capture_quiz_intro),
    ("Questionário — pergunta 1",   capture_quiz_q1),
    ("Resultados do teste",         capture_testresult),
    ("Ubuntu",                      capture_ubuntu),
    ("Windows",                     capture_windows),
    ("Favoritos",                   capture_favorites),
    ("Login",                       capture_login),
    ("Cadastro",                    capture_signup),
    ("Sobre Nós",                   capture_about),
]


def _check_flask() -> None:
    import urllib.request
    try:
        urllib.request.urlopen(BASE_URL, timeout=3)
    except Exception:
        print(
            f"\n❌  Flask não está respondendo em {BASE_URL}\n"
            "    Abra outro terminal e rode:\n"
            "        source .venv/bin/activate\n"
            "        python3 server.py\n"
            "    Depois execute este script novamente.\n"
        )
        raise SystemExit(1)


async def main() -> None:
    _check_flask()
    print(f"\nSalvando em: {OUT_DIR.resolve()}\n")

    async with async_playwright() as pw:
        browser = await pw.chromium.launch(headless=True)

        for label, fn in CAPTURES:
            print(f"[{label}]")
            try:
                await fn(browser)
            except Exception as exc:
                print(f"  ✗  ERRO: {exc}\n")

        await browser.close()

    print("\nConcluído. Revise as imagens antes de commitar.\n")


if __name__ == "__main__":
    asyncio.run(main())
