import { newUser } from '../../API/users.js';
import { createMessage } from './utils/errorUserLog.js';

export async function signIn() {
    
    const name = document.getElementById("name").value;
    const email = document.getElementById("email").value;
    const password = document.getElementById("password").value;
    
    const btn = document.getElementById("btn-submit");
    const btnOrigin = btn.textContent;
    btn.textContent = "Cadastrando...";
    btn.disabled = true;

    try {

        const data = await newUser({
            name: name,
            email: email,
            password: password,
            dbCredentials: null
        });

        if (!data || data.id == null || !data.token) {
            createMessage("Resposta inválida do servidor no cadastro.", true);
            console.error("Resposta inesperada em sign-in:", data);
            return;
        }

        const user = {
            id: data.id,
            name: data.name,
            email: data.email
        }

        localStorage.setItem("Token", data.token);
        localStorage.setItem("User", JSON.stringify(user));
        createMessage("Cadastro realizado com sucesso!", false);


        setInterval(() => {
            window.location.href = "../templates/Pages/chat.html";
        }, 1500);

    } catch (error) {
        createMessage("Erro no servidor.",true);
        console.error("Erro detalhado:", error);
    } finally {
        btn.textContent = btnOrigin;
        btn.disabled = false;
        
    }

}