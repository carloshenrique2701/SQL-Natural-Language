import { userUpdateDatabaseCredentials } from "../../API/users.js";
import { createMessage } from "./utils/messageDbUpdated.js"

const form = document.getElementById("formDbSettings");

form.addEventListener("submit", async (event) => {
    event.preventDefault();

    const urlElement = document.getElementById("db-url");
    const usernameElement = document.getElementById("db-user");
    const passwordElement = document.getElementById("db-password");

    const url = urlElement.value;
    const username = usernameElement.value;
    const password = passwordElement.value;

    const btnSubmit = form.querySelector('button[type="submit"]');
    btnSubmit.disabled = true;
    btnSubmit.textContent = "Updating...";

    try {
        
        const user = JSON.parse(localStorage.getItem("User"));

        const data = await userUpdateDatabaseCredentials(user.id, {
            url,
            username,
            password
        });

        console.log(data);
        const dbNameElement = document.getElementById("db-name");
        dbNameElement.textContent = data;

        createMessage("Credenciais de banco de dados atualizadas com sucesso!", false);

    } catch (error) {
        createMessage(error ?? "Ocorreu um erro ao atualizar as credenciais do banco de dados.", true);
        console.error("Erro ao atualizar as credenciais do banco de dados:", error);
    } finally {
        btnSubmit.disabled = false;
        btnSubmit.textContent = "Update Credentials";
    }

    urlElement.value = "";
    usernameElement.value = "";
    passwordElement.value = "";

});