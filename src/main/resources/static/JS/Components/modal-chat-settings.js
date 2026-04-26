import { admModal } from './utils/closeModals.js';

const modal = document.getElementById("settings-modal");
const profile = document.getElementById("user-profile");

const resetProfileStyle = () => {
    profile.style.borderColor = "var(--border-color)";
    profile.style.color = "#fff"; 
};

profile.addEventListener("click", () => {
    
    const isHidden = window.getComputedStyle(modal).display === "none";

    if (isHidden) {

        profile.style.borderColor = "var(--primary-green)";
        profile.style.color = "var(--primary-green)";
        admModal(true, modal);

    } else {

        resetProfileStyle();
        admModal(false, modal);

    }

});

document.addEventListener("click", (e) => {
    if (!modal.contains(e.target) && !profile.contains(e.target)) {
        resetProfileStyle();
        admModal(false, modal);
    }
});