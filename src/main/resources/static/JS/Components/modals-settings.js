import { admModal } from './utils/closeModals.js';


function openModal(modalId) {
    const modal = document.getElementById(modalId);
    
    if (!modal) return;

    const isHidden = window.getComputedStyle(modal).display === "none";
    
    if (isHidden) {
        
        admModal(true, modal);
        const closeSpan = modal.querySelector(".close-modal");
        closeSpan.onclick = () => admModal(false, modal);

    } 

    modal.addEventListener("click", (e) => {
        if (e.target === modal) admModal(false, modal);
    });
    
}

const btnConfirm = document.getElementById("btn-confirmation");
btnConfirm.addEventListener("click", () => {

    const modalConfirm = document.getElementById("modal-confirm-msg");
    admModal(false, modalConfirm);
    
    openModal("modal-confirm-password");

});

window.openModal = openModal;