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

        localStorage.setItem("user", data.user);
        createMessage("Cadastro realizado com sucesso!", false);

    } catch (error) {
        createMessage("Erro no servidor",true);
        console.error("Erro detalhado:", error);
    } finally {
        btn.textContent = btnOrigin;
        btn.disabled = false;
        
    }

}