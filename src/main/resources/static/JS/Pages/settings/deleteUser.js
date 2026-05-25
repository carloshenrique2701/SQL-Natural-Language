import { deleteUser } from "../../API/users.js";
import { verifyUserPassword } from "../../API/users.js";
import { closeAllModals } from "../../Components/utils/closeModals.js";

const btnConfirmationPassword = document.getElementById("btn-confirmation-password");
btnConfirmationPassword.addEventListener("click", async function(event) {

    const inputConfirmPassword = document.getElementById("input-confirm-password");
    const btnContext = btnConfirmationPassword.textContent;
    btnConfirmationPassword.textContent = "Verificando...";
    try {

        const confirmPassword = inputConfirmPassword.value.trim();
        if (confirmPassword === "") {
            alert("A senha de confirmação não pode ser vazia.");
            btnConfirmationPassword.textContent = btnContext;
            return;
        }
        const user = JSON.parse(localStorage.getItem("User"));
        const response = await verifyUserPassword(user.id, confirmPassword);

        if (response.valid) {
            closeAllModals();
            document.getElementById("modal-delete-account").style.display = "block";
        } else {
            alert("Senha de confirmação incorreta.");
            btnConfirmationPassword.textContent = btnContext;
            return;
        }

    } catch (error) {
        console.error("Erro ao verificar a senha de confirmação:", error);
        alert("Erro ao verificar a senha de confirmação.");
        return;
    } finally {
        btnConfirmationPassword.textContent = btnContext;
        inputConfirmPassword.value = "";
    }

});

const btnDeleteAccount = document.getElementById("btn-delete-account");

btnDeleteAccount.addEventListener("click", async function(event) {

    const btnContext = btnDeleteAccount.textContent;
    btnDeleteAccount.textContent = "Excluindo...";
    try {

        const user = JSON.parse(localStorage.getItem("User"));
        await deleteUser(user.id); 

        alert("Conta excluída com sucesso.");
        localStorage.removeItem("User");
        localStorage.removeItem("Token");
        window.location.replace('/');
        
    } catch (error) {
        console.error("Erro ao excluir a conta:", error);
        alert("Erro ao excluir a conta.");
        return;
    } finally {
        btnDeleteAccount.textContent = btnContext;
    }

});