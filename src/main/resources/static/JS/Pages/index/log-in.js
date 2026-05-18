import { checkEmailAndPassword } from "../../API/users.js";
import { createMessage } from "./utils/errorUserLog.js";

export async function logIn() {
    
    const password = document.getElementById("password").value;
    const email = document.getElementById("email").value;

    const btn = document.getElementById("btn-submit");
    const btnOrigin = btn.textContent;
    btn.textContent = "Fazendo login...";
    btn.disabled = true;

    try {
        
        const data = await checkEmailAndPassword(email, password);

        localStorage.setItem("Token", data.token);
        localStorage.setItem("User", data.user);
        createMessage("Login realizado com sucesso!", false);

        setInterval(() => {
            window.location.href = "../templates/Pages/chat.html";
        }, 1500);

    } catch (error) {
        createMessage("Erro no servidor.", true);
        console.log("Erro detalhado: ", error);
    } finally {
        btn.textContent = btnOrigin;
        btn.disabled = false;
    }

}