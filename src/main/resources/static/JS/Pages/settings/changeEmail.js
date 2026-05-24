import { userUpdateProfile } from "../../API/users.js";
import { closeAllModals } from "../../Components/utils/closeModals.js";

const btnNewEmail = document.getElementById("btn-new-email");

btnNewEmail.addEventListener("click", async function(event) {

    const inputEmail = document.getElementById("input-email");

    if (!inputEmail.value.includes("@") || !inputEmail.value.includes(".")) {
        return alert("Por favor, insira um email válido.");
    }

    const btnContext = btnNewEmail.textContent;
    btnNewEmail.textContent = "Salvando...";

    try {

        const newEmail = inputEmail.value.trim();
        if (newEmail === "") {
            alert("O email não pode ser vazio.");
            btnNewEmail.textContent = btnContext;
            return;
        }

        const user = JSON.parse(localStorage.getItem("User"));
        const response = await userUpdateProfile(user.id, { email: newEmail });

        if (response) {
            user.email = newEmail;
            localStorage.setItem("User", JSON.stringify(user));
            alert("Email atualizado com sucesso!");
        } else {
            alert("Erro ao atualizar o email!");
        }

        document.getElementById("userEmail").textContent = `Email: ${newEmail}`;

    } catch (error) {
        console.error("Erro ao atualizar o email:", error);
        alert("Erro ao atualizar o email!");
    } finally {
        btnNewEmail.textContent = btnContext;
        inputEmail.value = "";
    }
    
    closeAllModals();
    
});