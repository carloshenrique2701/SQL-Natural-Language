const infoTrigger = document.getElementById("info-tooltip");
const tooltipPanel = document.getElementById("tooltip-info-modal");
const modalContent = document.querySelector("#modal-db-settings .modal-content");

if (infoTrigger && tooltipPanel && modalContent) {
    let hideTimeout = null;

    const showTooltip = () => {
        clearTimeout(hideTimeout);
        tooltipPanel.classList.add("tooltip-visible");
        tooltipPanel.setAttribute("aria-hidden", "false");
    };

    const hideTooltip = () => {
        hideTimeout = setTimeout(() => {
            tooltipPanel.classList.remove("tooltip-visible");
            tooltipPanel.setAttribute("aria-hidden", "true");
        }, 120);
    };

    const cancelHide = () => clearTimeout(hideTimeout);

    infoTrigger.addEventListener("mouseenter", showTooltip);
    infoTrigger.addEventListener("mouseleave", hideTooltip);
    infoTrigger.addEventListener("focus", showTooltip);
    infoTrigger.addEventListener("blur", hideTooltip);

    tooltipPanel.addEventListener("mouseenter", cancelHide);
    tooltipPanel.addEventListener("mouseleave", hideTooltip);

    infoTrigger.addEventListener("keydown", (e) => {
        if (e.key === "Escape") {
            tooltipPanel.classList.remove("tooltip-visible");
            tooltipPanel.setAttribute("aria-hidden", "true");
            infoTrigger.blur();
        }
    });

    const modal = document.getElementById("modal-db-settings");
    if (modal) {
        const observer = new MutationObserver(() => {
            if (modal.style.display === "none" || getComputedStyle(modal).display === "none") {
                tooltipPanel.classList.remove("tooltip-visible");
                tooltipPanel.setAttribute("aria-hidden", "true");
            }
        });
        observer.observe(modal, { attributes: true, attributeFilter: ["style", "class"] });
    }
}
