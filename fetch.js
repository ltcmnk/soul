// Função para cadastro de usuário
function registerUser(nome, email, senha) {
  fetch('cadastro.php', {
      method: 'POST',
      headers: {
          'Content-Type': 'application/json'
      },
      body: JSON.stringify({
          nome: nome,
          email: email,
          senha: senha
      })
  })
  .then(response => {
      if (!response.ok) {
          throw new Error('Erro na requisição');
      }
      return response.json();
  })
  .then(data => {
      const messageEl = document.getElementById('signupMessage');
      messageEl.textContent = data.message;
      messageEl.style.color = data.success ? 'green' : 'red';
      
      if (data.success) {
          setTimeout(() => {
              window.location.href = data.redirect || 'login.html';
          }, 1500);
      }
  })
  .catch(error => {
      console.error('Erro:', error);
      document.getElementById('signupMessage').textContent = 'Erro ao conectar com o servidor';
      document.getElementById('signupMessage').style.color = 'red';
  });
}

// Função para login de usuário
function loginUser(email, senha) {
  fetch('login.php', {
      method: 'POST',
      headers: {
          'Content-Type': 'application/json'
      },
      body: JSON.stringify({
          email: email,
          senha: senha
      })
  })
  .then(response => {
      if (!response.ok) {
          throw new Error('Erro na requisição');
      }
      return response.json();
  })
  .then(data => {
      const messageEl = document.getElementById('loginMessage');
      messageEl.textContent = data.message;
      messageEl.style.color = data.success ? 'green' : 'red';
      
      if (data.success) {
          localStorage.setItem('userLoggedIn', 'true');
          localStorage.setItem('userName', data.user || 'Usuário');
          
          setTimeout(() => {
              window.location.href = data.redirect || 'index.html';
          }, 1500);
      }
  })
  .catch(error => {
      console.error('Erro:', error);
      document.getElementById('loginMessage').textContent = 'Erro ao conectar com o servidor';
      document.getElementById('loginMessage').style.color = 'red';
  });
}

// Verifica se o usuário está logado ao carregar a página
document.addEventListener('DOMContentLoaded', function() {
  if (localStorage.getItem('userLoggedIn') === 'true') {
      const usernameElement = document.getElementById('username');
      if (usernameElement) {
          usernameElement.textContent = '@' + localStorage.getItem('userName');
      }
      
      // Atualiza o header para mostrar o usuário logado
      const userArea = document.querySelector('.user-area');
      if (userArea) {
          userArea.innerHTML = `
              <div class="user-avatar" id="userAvatar">
                  <i class="fas fa-user"></i>
              </div>
              <div class="user-dropdown" id="userDropdown">
                  <a href="#"><i class="fas fa-user-circle"></i> Minha Conta</a>
                  <a href="#"><i class="fas fa-cog"></i> Configurações</a>
                  <a href="#" id="logoutBtn"><i class="fas fa-sign-out-alt"></i> Sair</a>
              </div>
          `;
          
          // Adiciona evento de logout
          document.getElementById('logoutBtn').addEventListener('click', function(e) {
              e.preventDefault();
              localStorage.removeItem('userLoggedIn');
              localStorage.removeItem('userName');
              window.location.href = 'login.html';
          });
          
          // Controle do dropdown do usuário
          const userAvatar = document.getElementById('userAvatar');
          const userDropdown = document.getElementById('userDropdown');
          
          userAvatar.addEventListener('click', function(e) {
              e.stopPropagation();
              userDropdown.classList.toggle('show');
          });
          
          document.addEventListener('click', function() {
              userDropdown.classList.remove('show');
          });
      }
  }
});