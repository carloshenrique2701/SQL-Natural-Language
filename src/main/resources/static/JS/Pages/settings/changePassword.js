import { userUpdatePassword } from "../../API/users.js";
import { closeAllModals } from "../../Components/utils/closeModals.js";

const btnNewPassword = document.getElementById("btn-new-password");

btnNewPassword.addEventListener("click", async function(event) {

    const inputPassword = document.getElementById("input-password");
    const btnContext = btnNewPassword.textContent;
    btnNewPassword.textContent = "Salvando...";

    try {

        const newPassword = inputPassword.value.trim();
        if (newPassword === "") {
            alert("A senha não pode ser vazia.");
            btnNewPassword.textContent = btnContext;
            return;
        }

        const user = JSON.parse(localStorage.getItem("User"));
        const response = await userUpdatePassword(user.id, newPassword);

        if (response.status === 200) {
            alert("Senha atualizada com sucesso.");
            closeAllModals();
        } else {
            alert("Erro ao atualizar senha.");
        }

    } catch (error) {
        console.error("Erro ao atualizar senha:", error);
        alert("Erro ao atualizar senha.");
    } finally {
        btnNewPassword.textContent = btnContext;
        inputPassword.value = "";
    }

    closeAllModals();

});