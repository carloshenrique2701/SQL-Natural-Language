export function admModal(open, modal) {
    
    if (open) {
        modal.style.display = "block";
    } else {
        modal.style.display = "none"
    }
}

export function closeAllModals() {
    
    const modals = document.querySelectorAll(".modal");
    modals.forEach(modal => {
        modal.style.display = "none";
    });
    
}