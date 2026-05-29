let isLogin = true;

function changePanel() {

    isLogin = !isLogin;
    const title = document.getElementById('auth-title');
    const nameField = document.getElementById('name-field');
    const btn = document.querySelector('.btn-primary');
    const toggleText = document.getElementById('toggle-text');
    
    const inputs = document.querySelectorAll("input");
    inputs.forEach(i => i.value = "");

    if (!isLogin) {
        title.innerText = "Crie sua credencial de acesso.";
        nameField.style.display = "block";
        btn.innerText = "Registrar";
        toggleText.innerHTML = 'Já possui conta? <a href="#" onclick="changePanel()">Fazer Login</a>';
    } else {
        title.innerText = "Bem-vindo de volta, Comandante.";
        nameField.style.display = "none";
        btn.innerText = "Iniciar Sessão";
        toggleText.innerHTML = 'Não possui acesso? <a href="#" onclick="changePanel()">Criar conta</a>';
    }

}

document.addEventListener("DOMContentLoaded", () => {

    const token = localStorage.getItem("Token");

    if (!token) return;

    const data = validateToken(token);

    if (data.ok) {
        window.location.href = "/chat";
    }

});