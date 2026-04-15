```
# SOul 🖥️🤖  
SOul é uma aplicação web interativa que ajuda usuários a escolherem o sistema operacional ideal (Windows, Ubuntu, Mint, MacOS, Arch Linux etc.) com base no perfil e necessidades do usuário. O projeto utiliza uma interface web simples e um backend em **Flask** integrado ao **Ollama (LLM local)** para gerar recomendações e respostas.

---

## 📌 Funcionalidades

- Páginas dedicadas a diferentes sistemas operacionais
- Recomendações e respostas geradas por IA (Ollama)
- Backend em Flask para processar requisições
- Sistema de login e cadastro (PHP + MySQL)
- Página de favoritos
- Interface web responsiva (HTML/CSS/JS)

---

## 🛠️ Tecnologias Utilizadas

- **Frontend:** HTML5, CSS3, JavaScript  
- **Backend:** Python (Flask)  
- **IA / LLM Local:** Ollama  
- **Banco de Dados:** MySQL (`SOul.sql`)  
- **Autenticação:** PHP (`login.php`, `cadastro.php`)  

---

## 📂 Estrutura do Projeto

```

soul/
│── index.html
│── about.html
│── favorites.html
│── styles.css
│── fetch.js
│── server.py
│── SOul.sql
│── login.html
│── login.php
│── cadastro.php
│── windows.html
│── ubuntu.html
│── mint.html
│── macos.html
│── arch.html
│── test.html / test2.html / test3.html ...

````

---

## ⚙️ Pré-requisitos

Antes de rodar o projeto, você precisa ter instalado:

- Python 3.10+
- Flask
- Ollama instalado e rodando localmente
- MySQL (para login/cadastro)
- Navegador moderno

---

## 🚀 Como Rodar o Projeto

### 1️⃣ Clone o repositório

```bash
git clone https://github.com/ltcmnk/soul.git
cd soul
````

---

### 2️⃣ Instale as dependências Python

```bash
pip install flask pydantic ollama
```

*(Opcional: usando ambiente virtual)*

```bash
python -m venv venv
source venv/bin/activate   # Mac/Linux
venv\Scripts\activate      # Windows
pip install flask pydantic ollama
```

---

### 3️⃣ Instale e rode o Ollama

Verifique se o Ollama está rodando:

```bash
ollama serve
```

Instale um modelo (exemplo):

```bash
ollama pull llama3
```

---

### 4️⃣ Execute o servidor Flask

```bash
python server.py
```

A aplicação ficará disponível em:

```
http://localhost:5000
```

---

## 🧠 Integração com IA (Ollama)

O projeto utiliza o Ollama para gerar respostas e recomendações com base no sistema operacional escolhido e no perfil do usuário.

O backend Flask recebe os dados e retorna a resposta gerada pelo modelo local.

---

## 🗄️ Banco de Dados (MySQL)

O arquivo `SOul.sql` contém a estrutura necessária para login e cadastro.

### Importar o banco:

```bash
mysql -u root -p < SOul.sql
```

Depois disso, ajuste as credenciais dentro dos arquivos PHP caso necessário.

---

## 🔐 Login e Cadastro

A autenticação do sistema é feita via PHP:

* `login.php`
* `cadastro.php`

Esses arquivos se conectam ao MySQL para validação e registro de usuários.

---

## ⭐ Favoritos

O projeto conta com uma página `favorites.html` onde o usuário pode salvar e consultar sistemas operacionais favoritos.

---

## 📌 Melhorias Futuras (ideias)

* Unificar backend (substituir PHP por Flask)
* Salvar favoritos diretamente no banco de dados
* Melhorar UI/UX e responsividade
* Deploy com Docker
* Adicionar ranking de OS mais recomendados

---

## 👩‍💻 Autor

Desenvolvido por **Letícia Miniuk Rosa Pereira, Rayssa Gaievicz Grafetti e Victor Willian Rodrigues Bittencourt**
GitHub Letícia: [https://github.com/ltcmnk](https://github.com/ltcmnk)
GitHub Rayssa: [https://github.com/T-800-888](https://github.com/T-800-888)

---

## 📜 Licença

Este projeto está sob a licença MIT.
Sinta-se livre para usar, modificar e contribuir.

```
