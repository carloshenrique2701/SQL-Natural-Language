import { userUpdateDatabaseCredentials } from "../../API/users.js";
import { closeAllModals } from "../../Components/utils/closeModals.js";

const form = document.getElementById("formDbSettings");

form.addEventListener("submit", async (event) => {
    event.preventDefault();

    const url = document.getElementById("db-url").value;
    const username = document.getElementById("db-user").value;
    const password = document.getElementById("db-password").value;

    const btnSubmit = form.querySelector('button[type="submit"]');
    btnSubmit.disabled = true;
    btnSubmit.textContent = "Updating...";

    try {
        
        const user = JSON.parse(localStorage.getItem("User"));

        await userUpdateDatabaseCredentials(user.id, {
            url,
            username,
            password
        });

        alert("Credenciais de banco de dados atualizadas com sucesso!");

    } catch (error) {
        alert(error ?? "Ocorreu um erro ao atualizar as credenciais do banco de dados.");
        console.error("Erro ao atualizar as credenciais do banco de dados:", error);
    } finally {
        btnSubmit.disabled = false;
        btnSubmit.textContent = "Update Credentials";
    }

    closeAllModals();

});