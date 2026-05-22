import { userUpdateProfile } from "../../API/users.js";
import { closeAllModals } from "../../Components/utils/closeModals.js";

const btnNewName = document.getElementById("btn-new-name");

btnNewName.addEventListener("click", async function(event) {

    const inputName = document.getElementById("input-name");
    const btnContext = btnNewName.textContent;
    btnNewName.textContent = "Salvando...";

    try {

        const newName = inputName.value.trim();
        if (newName === "") {
            alert("O nome não pode ser vazio.");
            btnNewName.textContent = btnContext;
            return;
        }

        const user = JSON.parse(localStorage.getItem("User"));
        const response = await userUpdateProfile(user.id, { name: newName });

        if (response) {
            user.name = newName;
            localStorage.setItem("User", JSON.stringify(user));
            alert("Nome atualizado com sucesso!");
        } else {
            alert("Erro ao atualizar o nome!");
        }

        window.location.reload();

    } catch (error) {
        console.error("Erro ao atualizar o nome:", error);
        alert("Erro ao atualizar o nome!");
    } finally {
        btnNewName.textContent = btnContext;
        inputName.value = "";
    }
    
    closeAllModals();
    
});