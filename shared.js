const utils = {
    showToast(message, type = 'success') {
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        toast.textContent = message;
        document.body.appendChild(toast);
        
        toast.offsetHeight;
        toast.classList.add('show');
        
        setTimeout(() => {
            toast.classList.remove('show');
            setTimeout(() => toast.remove(), 300);
        }, 3000);
    },
    
    validateEmail(email) {
        return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
    },
    
    debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }
};

const auth = {
    isLoggedIn() {
        try {
            return localStorage.getItem('userLoggedIn') === 'true';
        } catch (error) {
            console.error('Error checking login status:', error);
            return false;
        }
    },
    
    getUserName() {
        try {
            return localStorage.getItem('userName') || 'Usuário';
        } catch (error) {
            console.error('Error getting username:', error);
            return 'Usuário';
        }
    },
    
    login(data) {
        try {
            if (!data || !data.user) {
                throw new Error('Invalid login data');
            }
            localStorage.setItem('userLoggedIn', 'true');
            localStorage.setItem('userName', data.user);
            utils.showToast('Login successful!');
        } catch (error) {
            console.error('Error during login:', error);
            utils.showToast('Login failed. Please try again.', 'error');
            throw error;
        }
    },
    
    logout() {
        try {
            localStorage.removeItem('userLoggedIn');
            localStorage.removeItem('userName');
            window.location.href = 'login.html';
        } catch (error) {
            console.error('Error during logout:', error);
            utils.showToast('Logout failed. Please try again.', 'error');
            throw error;
        }
    },
    
    updateUI() {
        const userArea = document.querySelector('.user-area');
        if (!userArea) return;

        try {
            if (this.isLoggedIn()) {
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
                
                const usernameElement = document.getElementById('username');
                if (usernameElement) {
                    usernameElement.textContent = '@' + this.getUserName();
                }
                
                this.setupDropdown();
            } else {
                userArea.innerHTML = '<a href="login.html" class="login-btn">Entrar</a>';
            }
        } catch (error) {
            console.error('Error updating UI:', error);
            utils.showToast('Error updating interface', 'error');
        }
    },
    
    setupDropdown() {
        const userAvatar = document.getElementById('userAvatar');
        const userDropdown = document.getElementById('userDropdown');
        const logoutBtn = document.getElementById('logoutBtn');
        
        if (userAvatar && userDropdown) {
            userAvatar.addEventListener('click', (e) => {
                e.stopPropagation();
                userDropdown.classList.toggle('show');
            });
            
            document.addEventListener('click', () => {
                userDropdown.classList.remove('show');
            });
        }
        
        if (logoutBtn) {
            logoutBtn.addEventListener('click', (e) => {
                e.preventDefault();
                this.logout();
            });
        }
    }
};

const testProgress = {
    getCurrentQuestion() {
        try {
            const progress = JSON.parse(localStorage.getItem('testProgress') || '{}');
            return progress.currentQuestion || 'test1.html';
        } catch (error) {
            console.error('Error getting current question:', error);
            return 'test1.html';
        }
    },
    
    setCurrentQuestion(page) {
        try {
            if (!page) throw new Error('Invalid page');
            const progress = JSON.parse(localStorage.getItem('testProgress') || '{}');
            progress.currentQuestion = page;
            localStorage.setItem('testProgress', JSON.stringify(progress));
        } catch (error) {
            console.error('Error setting current question:', error);
            throw error;
        }
    },
    
    saveAnswer(questionNumber, answer) {
        try {
            if (!questionNumber || answer === undefined) {
                throw new Error('Invalid answer data');
            }
            const answers = this.getAnswers();
            answers[questionNumber] = answer;
            localStorage.setItem('testAnswers', JSON.stringify(answers));
        } catch (error) {
            console.error('Error saving answer:', error);
            throw error;
        }
    },
    
    getAnswers() {
        try {
            return JSON.parse(localStorage.getItem('testAnswers') || '{}');
        } catch (error) {
            console.error('Error getting answers:', error);
            return {};
        }
    },
    
    getAnswer(questionNumber) {
        try {
            const answers = this.getAnswers();
            return answers[questionNumber];
        } catch (error) {
            console.error('Error getting answer:', error);
            return null;
        }
    },
    
    clearProgress() {
        try {
            localStorage.removeItem('testProgress');
            localStorage.removeItem('testAnswers');
        } catch (error) {
            console.error('Error clearing progress:', error);
            throw error;
        }
    }
};

const favorites = {
    getAll() {
        try {
            return JSON.parse(localStorage.getItem('favoriteOS')) || [];
        } catch (error) {
            console.error('Error getting favorites:', error);
            return [];
        }
    },
    
    add(osName) {
        try {
            if (!osName) throw new Error('Invalid OS name');
            const favs = this.getAll();
            if (!favs.includes(osName)) {
                favs.push(osName);
                localStorage.setItem('favoriteOS', JSON.stringify(favs));
                utils.showToast(`${osName} added to favorites`);
            }
        } catch (error) {
            console.error('Error adding favorite:', error);
            utils.showToast('Error adding to favorites', 'error');
            throw error;
        }
    },
    
    remove(osName) {
        try {
            if (!osName) throw new Error('Invalid OS name');
            const favs = this.getAll().filter(item => item !== osName);
            localStorage.setItem('favoriteOS', JSON.stringify(favs));
            utils.showToast(`${osName} removed from favorites`);
        } catch (error) {
            console.error('Error removing favorite:', error);
            utils.showToast('Error removing from favorites', 'error');
            throw error;
        }
    },
    
    toggle(osName) {
        try {
            if (!osName) throw new Error('Invalid OS name');
            const favs = this.getAll();
            if (favs.includes(osName)) {
                this.remove(osName);
                return false;
            } else {
                this.add(osName);
                return true;
            }
        } catch (error) {
            console.error('Error toggling favorite:', error);
            utils.showToast('Error updating favorites', 'error');
            throw error;
        }
    },
    
    isFavorite(osName) {
        try {
            return this.getAll().includes(osName);
        } catch (error) {
            console.error('Error checking favorite status:', error);
            return false;
        }
    }
};

const navigation = {
    pages: {
        home: 'index.html',
        login: 'login.html',
        signup: 'signup.html',
        test: 'test.html',
        favorites: 'favorites.html',
        os: 'os.html'
    },
    
    getCurrentPage() {
        return window.location.pathname.split('/').pop() || 'index.html';
    },
    
    goTo(page) {
        if (this.pages[page]) {
            window.location.href = this.pages[page];
        } else {
            console.error('Invalid page:', page);
        }
    },
    
    requireAuth(redirectTo = 'login.html') {
        const currentPage = this.getCurrentPage();
        if (currentPage.startsWith('test')) {
            return true;
        }
        
        if (!auth.isLoggedIn()) {
            utils.showToast('Please log in to continue', 'error');
            window.location.href = redirectTo;
            return false;
        }
        return true;
    }
};

goBackToTest() {
        try {
            const currentPage = this.getCurrentPage();
            if (!currentPage.startsWith('test')) return;
            
            const currentTestNumber = parseInt(currentPage.replace('test', '').replace('.html', ''));
            if (currentTestNumber > 1) {
                const prevPage = `test${currentTestNumber - 1}.html`;
                window.location.href = prevPage;
            } else {
                window.location.href = 'test.html';
            }
        } catch (error) {
            console.error('Error navigating back:', error);
            window.location.href = 'test.html';
        }
    }
};

document.addEventListener('DOMContentLoaded', () => {
    auth.updateUI();
    
    document.querySelectorAll('nav a').forEach(link => {
        link.addEventListener('click', (e) => {
            const href = link.getAttribute('href');
            if (href.startsWith('#')) {
                e.preventDefault();
                navigation.goTo(href.substring(1));
            }
        });
    });
}); 