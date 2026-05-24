import { signIn } from './sign-in.js';
import { logIn } from './log-in.js';
import { createMessage } from './utils/errorUserLog.js';
import { validateToken } from '../../API/auth.js'

const form = document.getElementById("auth-form");

form.addEventListener("submit", async (e) => {

    e.preventDefault();

    const isLogin = document.getElementById('name-field').style.display === "none";
    const formData = new FormData(form);
    const name = document.getElementById("name").value.trim() || ""; 
    const email = document.getElementById("email").value.trim() || "";
    const password = document.getElementById("password").value.trim() || "";

    if (!isLogin) {
        if (name === "" || email === "" || password === "") {
            return createMessage("TODOS OS CAMPOS DEVEM ESTAR PREENCHIDOS.", true);
        }
        await signIn();
    } else {
        if (email === "" || password === "") {
            return createMessage("TODOS OS CAMPOS DEVEM ESTAR PREENCHIDOS.", true);
        }
        await logIn();
    }

});


document.addEventListener("DOMContentLoaded", () => {

    const token = localStorage.getItem("Token");

    if (!token) return;
    console.log(token)

    const data = validateToken(token);

    if (data.ok) {
        window.location.href = "/chat.html";
    }

});