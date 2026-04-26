import { admModal } from './utils/closeModals.js';

const btnDbSettings = document.getElementById("db-settings");
const modal = document.getElementById("modal-db-settings");
const btnCloseModal = document.getElementById("close-modal");

btnDbSettings.addEventListener("click", () => admModal(true, modal));
btnCloseModal.addEventListener("click", () => admModal(false, modal));

modal.addEventListener("click", (e) => {
    if (e.target === modal) admModal(false, modal);
});

const inputCheckbox = document.getElementById("standard-bank");
if (inputCheckbox) {
    inputCheckbox.checked = true;
    checkInputs();
}

function checkInputs() {
    if (inputCheckbox.checked) {
        modal.querySelectorAll("input").forEach(input => {
            if (input !== inputCheckbox) input.disabled = true;
        });
    } else {
        modal.querySelectorAll("input").forEach(input => {
            if (input !== inputCheckbox) input.disabled = false;
        });
    }
}

inputCheckbox.addEventListener("change", checkInputs);